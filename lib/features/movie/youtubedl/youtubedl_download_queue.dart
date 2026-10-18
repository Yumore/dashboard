import 'dart:async';
import 'dart:io';

import 'package:dashboard/features/movie/youtubedl/youtubedl_cancellation_token.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_download_cancelled_exception.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_download_plan.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_download_status.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_download_task.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_file_name.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_stream_sink.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_video.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Owns the download state machine: pending -> running -> done/failed/cancelled,
/// with pause/resume support and explicit `needsMuxer` plan rejection.
///
/// The source app launched every download concurrently and had no pause. This
/// port serialises work by default (`maxConcurrent == 1`) so progress and
/// metadata stay deterministic, and implements pause as an in-flight cancel
/// followed by a fresh download on resume: the sink contract has no HTTP Range
/// support, so resuming cannot honestly append to a partial file.
class YoutubeDlDownloadQueue extends ChangeNotifier {
  YoutubeDlDownloadQueue({
    required YoutubeDlStreamSink sink,
    Future<String> Function()? downloadDirectory,
    DateTime Function()? now,
    String Function()? idFactory,
    int maxConcurrent = 1,
  }) : _sink = sink,
       _downloadDirectory = downloadDirectory ?? defaultDownloadDirectory,
       _now = now ?? DateTime.now,
       _idFactory = idFactory,
       _maxConcurrent = maxConcurrent < 1 ? 1 : maxConcurrent;

  static const String muxerMessage =
      '视频流与音频流相互分离，合成需要 FFmpeg；当前宿主未集成，因此尚未写入文件。';

  final YoutubeDlStreamSink _sink;
  final Future<String> Function() _downloadDirectory;
  final DateTime Function() _now;
  final String Function()? _idFactory;
  final int _maxConcurrent;
  final List<YoutubeDlDownloadTask> _tasks = <YoutubeDlDownloadTask>[];
  final Map<String, YoutubeDlCancellationToken> _tokens =
      <String, YoutubeDlCancellationToken>{};

  int _running = 0;
  int _sequence = 0;
  bool _disposed = false;
  Completer<void>? _idleCompleter;

  List<YoutubeDlDownloadTask> get tasks =>
      List<YoutubeDlDownloadTask>.unmodifiable(_tasks);

  List<YoutubeDlDownloadTask> get activeTasks =>
      List<YoutubeDlDownloadTask>.unmodifiable(
        _tasks.where((task) => task.status.isActive),
      );

  bool get isIdle => !_tasks.any(
    (task) =>
        task.status == YoutubeDlDownloadStatus.pending ||
        task.status == YoutubeDlDownloadStatus.running,
  );

  YoutubeDlDownloadTask? taskById(String id) {
    for (final task in _tasks) {
      if (task.id == id) return task;
    }
    return null;
  }

  /// Adds [plan] to the queue. Split video+audio plans never touch the disk.
  YoutubeDlDownloadTask enqueue({
    required YoutubeDlVideo video,
    required YoutubeDlDownloadPlan plan,
  }) {
    final requiresMuxer = plan.requiresMuxer;
    final now = _now();
    final task = YoutubeDlDownloadTask(
      id: _nextId(),
      videoId: video.id,
      title: video.title.isEmpty ? video.id : video.title,
      status: requiresMuxer
          ? YoutubeDlDownloadStatus.needsMuxer
          : YoutubeDlDownloadStatus.pending,
      streamType: plan.streamType,
      url: plan.url?.toString() ?? '',
      audioUrl: plan.audioUrl?.toString() ?? '',
      container: plan.containerExtension,
      totalBytes: plan.totalBytes,
      qualityLabel: plan.qualityLabel,
      error: requiresMuxer ? muxerMessage : '',
      createdAt: now,
    );
    _tasks.add(task);
    _notify();
    if (!requiresMuxer) _pump();
    return task;
  }

  void pause(String id) {
    final task = taskById(id);
    if (task == null ||
        (task.status != YoutubeDlDownloadStatus.pending &&
            task.status != YoutubeDlDownloadStatus.running)) {
      return;
    }
    _replace(task.copyWith(status: YoutubeDlDownloadStatus.paused));
    _tokens[id]?.cancel();
    _notify();
  }

  void resume(String id) {
    final task = taskById(id);
    if (task == null || task.status != YoutubeDlDownloadStatus.paused) return;
    _replace(task.copyWith(status: YoutubeDlDownloadStatus.pending));
    _notify();
    _pump();
  }

  void cancel(String id) {
    final task = taskById(id);
    if (task == null || !task.status.isActive) return;
    _replace(
      task.copyWith(
        status: YoutubeDlDownloadStatus.cancelled,
        finishedAt: _now(),
      ),
    );
    _tokens[id]?.cancel();
    _notify();
  }

  /// Removes the task and deletes its file when one was written.
  Future<void> remove(String id) async {
    final task = taskById(id);
    if (task == null) return;
    _tokens[id]?.cancel();
    _tokens.remove(id);
    _tasks.removeWhere((item) => item.id == id);
    _notify();
    if (task.filePath.isNotEmpty) {
      try {
        await _sink.delete(task.filePath);
      } on Exception {
        // The file may already be gone; removal must still succeed.
      }
    }
  }

  /// Completes when no task is pending or running (paused tasks do not block).
  Future<void> whenIdle() {
    if (isIdle) return Future<void>.value();
    _idleCompleter ??= Completer<void>();
    return _idleCompleter!.future;
  }

  @override
  void dispose() {
    _disposed = true;
    for (final token in _tokens.values) {
      token.cancel();
    }
    _tokens.clear();
    super.dispose();
  }

  static Future<String> defaultDownloadDirectory() async {
    try {
      final downloads = await getDownloadsDirectory();
      if (downloads != null) return downloads.path;
    } on Exception {
      // Fall through to the documents directory on platforms without one.
    }
    final documents = await getApplicationDocumentsDirectory();
    final directory = Directory(
      YoutubeDlFileName.join(documents.path, 'YouTubeDl'),
    );
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory.path;
  }

  String _nextId() {
    final factory = _idFactory;
    if (factory != null) return factory();
    return 'ytdl-${_now().microsecondsSinceEpoch}-${++_sequence}';
  }

  YoutubeDlDownloadTask? _nextPending() {
    for (final task in _tasks) {
      if (task.status == YoutubeDlDownloadStatus.pending) return task;
    }
    return null;
  }

  void _pump() {
    if (_disposed) return;
    while (_running < _maxConcurrent) {
      final next = _nextPending();
      if (next == null) break;
      _running++;
      unawaited(
        _run(next).whenComplete(() {
          _running--;
          if (_disposed) return;
          _pump();
          _notify();
        }),
      );
    }
  }

  Future<void> _run(YoutubeDlDownloadTask queued) async {
    final id = queued.id;
    final token = YoutubeDlCancellationToken();
    _tokens[id] = token;
    var task = taskById(id);
    if (task == null || task.status != YoutubeDlDownloadStatus.pending) {
      _tokens.remove(id);
      return;
    }
    _replace(
      task.copyWith(
        status: YoutubeDlDownloadStatus.running,
        downloadedBytes: 0,
        error: '',
        startedAt: _now(),
      ),
    );
    _notify();
    try {
      if (task.filePath.isNotEmpty) {
        // A resumed task restarts from byte zero, so drop the partial file.
        try {
          await _sink.delete(task.filePath);
        } on Exception {
          // Nothing to remove.
        }
      }
      final directory = await _downloadDirectory();
      final fileName = YoutubeDlFileName.withExtension(
        task.title,
        task.container,
      );
      final candidate = YoutubeDlFileName.join(directory, fileName);
      final uniquePath = await _uniquePath(candidate);
      task = taskById(id);
      if (task == null || task.status != YoutubeDlDownloadStatus.running) {
        return;
      }
      _replace(task.copyWith(filePath: uniquePath));
      _notify();

      await _sink.write(
        url: Uri.parse(task.url),
        path: uniquePath,
        totalBytes: task.totalBytes,
        cancellation: token,
        onProgress: (received) {
          final latest = taskById(id);
          if (latest == null ||
              latest.status != YoutubeDlDownloadStatus.running) {
            return;
          }
          _replace(latest.copyWith(downloadedBytes: received));
          _notify();
        },
      );

      final latest = taskById(id);
      if (latest == null || latest.status != YoutubeDlDownloadStatus.running) {
        return;
      }
      _replace(
        latest.copyWith(
          status: YoutubeDlDownloadStatus.done,
          downloadedBytes: latest.totalBytes > 0
              ? latest.totalBytes
              : latest.downloadedBytes,
          finishedAt: _now(),
        ),
      );
      _notify();
    } on YoutubeDlDownloadCancelledException {
      // pause()/cancel() already persisted the target state.
    } on Exception catch (error) {
      final latest = taskById(id);
      if (latest == null || latest.status != YoutubeDlDownloadStatus.running) {
        return;
      }
      _replace(
        latest.copyWith(
          status: YoutubeDlDownloadStatus.failed,
          error: '$error',
          finishedAt: _now(),
        ),
      );
      _notify();
    } finally {
      _tokens.remove(id);
    }
  }

  Future<String> _uniquePath(String candidate) async {
    if (!await _sink.exists(candidate)) return candidate;
    var count = 1;
    while (true) {
      final next = YoutubeDlFileName.collisionCandidate(candidate, count);
      if (!await _sink.exists(next)) return next;
      count++;
    }
  }

  void _replace(YoutubeDlDownloadTask task) {
    final index = _tasks.indexWhere((item) => item.id == task.id);
    if (index == -1) return;
    _tasks[index] = task;
  }

  void _notify() {
    if (_disposed) return;
    notifyListeners();
    if (!isIdle) return;
    final completer = _idleCompleter;
    _idleCompleter = null;
    if (completer != null && !completer.isCompleted) completer.complete();
  }
}
