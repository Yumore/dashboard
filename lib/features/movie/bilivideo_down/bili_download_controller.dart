import 'dart:io';

import 'package:dashboard/features/movie/bilivideo_down/bili_api.dart';
import 'package:dashboard/features/movie/bilivideo_down/bili_api_exception.dart';
import 'package:dashboard/features/movie/bilivideo_down/bili_download_cancelled_exception.dart';
import 'package:dashboard/features/movie/bilivideo_down/bili_download_format.dart';
import 'package:dashboard/features/movie/bilivideo_down/bili_download_task.dart';
import 'package:dashboard/features/movie/bilivideo_down/bili_play_info.dart';
import 'package:dashboard/features/movie/bilivideo_down/bili_quality.dart';
import 'package:dashboard/features/movie/bilivideo_down/bili_range_downloader.dart';
import 'package:dashboard/features/movie/bilivideo_down/bili_stream_selection.dart';
import 'package:dashboard/features/movie/bilivideo_down/bili_task_status.dart';
import 'package:dashboard/features/movie/bilivideo_down/bili_task_store.dart';
import 'package:dashboard/features/movie/bilivideo_down/bili_ugc_episode.dart';
import 'package:dashboard/features/movie/bilivideo_down/bili_video_id.dart';
import 'package:dashboard/features/movie/bilivideo_down/bili_video_info.dart';
import 'package:dashboard/features/movie/bilivideo_down/bili_video_stream.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:dashboard/features/movie/bilivideo_down/bili_file_paths.dart';
import 'package:path_provider/path_provider.dart';

/// State and orchestration for the bilibili downloader: resolve a video, pick a
/// stream, drive [BiliRangeDownloader], and mirror every state change into
/// [BiliTaskStore].
///
/// Ports `BiliVideoSearchController`, `DownloadingController` and
/// `DownloadCompleteController` from the source app, with the clock, the API
/// client, the downloader and the storage directory all injectable so the whole
/// flow can be driven from tests without a network or a platform channel.
class BiliDownloadController extends ChangeNotifier {
  BiliDownloadController({
    required BiliApi api,
    required BiliTaskStore store,
    required BiliRangeDownloader downloader,
    Future<String> Function()? storageDirectory,
    DateTime Function()? now,
    this.cookie,
  }) : _api = api,
       _store = store,
       _downloader = downloader,
       _storageDirectory = storageDirectory ?? defaultStorageDirectory,
       _now = now ?? DateTime.now;

  final BiliApi _api;
  final BiliTaskStore _store;
  final BiliRangeDownloader _downloader;
  final Future<String> Function() _storageDirectory;
  final DateTime Function() _now;

  /// The user's own bilibili cookie, sent only when they supplied one; the
  /// source app relied on the WebView's cookies for member-only content.
  final String? cookie;

  BiliVideoId? _videoId;
  BiliVideoInfo? _videoInfo;
  BiliPlayInfo? _playInfo;
  BiliStreamSelection? _selection;
  BiliUgcEpisode? _episode;
  BiliDownloadFormat? _format;
  int? _quality;
  int _resolvedCid = 0;
  bool _resolving = false;
  bool _disposed = false;
  String? _errorMessage;
  String? _notice;
  List<BiliDownloadTask> _tasks = const <BiliDownloadTask>[];
  final Map<String, CancelToken> _tokens = <String, CancelToken>{};
  final Map<String, Future<void>> _runs = <String, Future<void>>{};
  final Map<String, int> _received = <String, int>{};
  final Map<String, int> _totals = <String, int>{};

  bool get isResolving => _resolving;
  String? get errorMessage => _errorMessage;
  String? get notice => _notice;
  BiliVideoId? get videoId => _videoId;
  BiliVideoInfo? get videoInfo => _videoInfo;
  BiliPlayInfo? get playInfo => _playInfo;
  BiliStreamSelection? get selection => _selection;
  BiliUgcEpisode? get selectedEpisode => _episode;
  BiliDownloadFormat? get selectedFormat => _format;
  int? get selectedQuality => _quality;
  bool get hasVideo => _videoInfo != null && _playInfo != null;
  bool get hasCookie => cookie != null && cookie!.isNotEmpty;

  /// Every known task, in store order (newest first).
  List<BiliDownloadTask> get tasks =>
      List<BiliDownloadTask>.unmodifiable(_tasks);

  /// Finished tasks whose file can be played by the host's media_kit.
  List<BiliDownloadTask> get completedTasks => <BiliDownloadTask>[
    for (final task in _tasks)
      if (task.isCompleted) task,
  ];

  /// Tasks that still have work left (pending, running, paused or failed).
  List<BiliDownloadTask> get activeTasks => <BiliDownloadTask>[
    for (final task in _tasks)
      if (!task.isCompleted) task,
  ];

  List<BiliUgcEpisode> get episodes => _videoInfo?.episodes ?? const [];

  bool get hasCollection => episodes.isNotEmpty;

  /// Live progress of [bvid], `0` when it never started.
  double progressOf(String bvid) {
    final total = _totals[bvid] ?? 0;
    final received = _received[bvid] ?? 0;
    if (total > 0) return (received / total).clamp(0.0, 1.0);
    final task = taskOf(bvid);
    return task?.progress ?? 0;
  }

  int receivedBytesOf(String bvid) =>
      _received[bvid] ?? taskOf(bvid)?.receivedBytes ?? 0;

  int totalBytesOf(String bvid) =>
      _totals[bvid] ?? taskOf(bvid)?.totalBytes ?? 0;

  bool isDownloading(String bvid) => _tokens.containsKey(bvid);

  BiliDownloadTask? taskOf(String bvid) {
    for (final task in _tasks) {
      if (task.bvid == bvid) return task;
    }
    return null;
  }

  /// Validates pasted input without touching the network; `null` means valid.
  static String? inputError(String rawInput) {
    if (rawInput.trim().isEmpty) return '请输入B站视频链接或BV号';
    return BiliVideoId.parse(rawInput) == null ? '无法识别的B站视频链接' : null;
  }

  /// Default download location, the analogue of the source's
  /// `getDownloadsDirectory()` + `下载合集_<date>` folder.
  static Future<String> defaultStorageDirectory() async {
    String base;
    try {
      final downloads = await getDownloadsDirectory();
      base = downloads != null
          ? BiliFilePaths.join(downloads.path, 'BiliVideoDown')
          : BiliFilePaths.join(
              (await getApplicationDocumentsDirectory()).path,
              'BiliVideoDown',
            );
    } catch (_) {
      // Android/iOS have no public downloads directory.
      base = BiliFilePaths.join(
        (await getApplicationDocumentsDirectory()).path,
        'BiliVideoDown',
      );
    }
    final directory = Directory(base);
    if (!directory.existsSync()) {
      await directory.create(recursive: true);
    }
    return base;
  }

  /// Loads persisted tasks; call once from the page's `initState`, never from
  /// `build`.
  Future<void> loadTasks() async {
    _tasks = await _store.queryAll();
    for (final task in _tasks) {
      _received[task.bvid] = task.receivedBytes;
      _totals[task.bvid] = task.totalBytes;
    }
    _notify();
  }

  /// Parses [rawInput], loads the video and its play URLs.
  ///
  /// Returns `true` on success; on failure [errorMessage] is set and the previous
  /// resolution is dropped.
  Future<bool> resolve(String rawInput) async {
    final error = inputError(rawInput);
    if (error != null) {
      _errorMessage = error;
      _notify();
      return false;
    }
    final id = BiliVideoId.parse(rawInput)!;
    _resolving = true;
    _errorMessage = null;
    _notice = null;
    _notify();
    try {
      final info = await _api.fetchVideoInfo(
        bvid: id.bvid,
        aid: id.aid,
        cookie: cookie,
      );
      if (info.aid <= 0 || info.primaryCid <= 0) {
        _errorMessage = '未获取到视频信息(aid/cid 为空)';
        return false;
      }
      _videoInfo = info;
      _videoId = id;
      _episode = _episodeForPage(info, id.page);
      final played = await _fetchPlayInfo(info, _episode);
      if (played == null) return false;
      return true;
    } on BiliApiException catch (exception) {
      _errorMessage = exception.message;
      return false;
    } on DioException catch (exception) {
      _errorMessage = _describeDio(exception);
      return false;
    } finally {
      _resolving = false;
      _notify();
    }
  }

  /// Switches the selected part of a multi-part/collection video and re-resolves
  /// its stream.
  Future<void> selectEpisode(BiliUgcEpisode? episode) async {
    final info = _videoInfo;
    if (info == null) return;
    if (episode != null && episode.cid == _resolvedCid) {
      _episode = episode;
      _notify();
      return;
    }
    _episode = episode;
    await _fetchPlayInfo(info, episode);
    _notify();
  }

  /// bilibili takes the quality in the request, so changing it re-resolves the
  /// play URL exactly like the source's `CollapseWidget` did per episode.
  Future<void> selectQuality(int quality) async {
    final info = _videoInfo;
    if (info == null || info.aid <= 0) {
      _quality = quality;
      _notify();
      return;
    }
    _quality = quality;
    await _fetchPlayInfo(info, _episode);
    _notify();
  }

  /// Only changes which container the next download uses; both containers come
  /// from the same play-url response.
  void selectFormat(BiliDownloadFormat format) {
    _format = format;
    _notify();
  }

  /// Resolves the selected stream into a on-disk destination and starts
  /// downloading, or returns `null` with [errorMessage] set.
  Future<BiliDownloadTask?> startDownload({BiliUgcEpisode? episode}) async {
    final info = _videoInfo;
    var playInfo = _playInfo;
    if (info == null || playInfo == null) {
      _errorMessage = '请先解析视频';
      _notify();
      return null;
    }
    final target = episode ?? _episode;
    if (target != null && target.cid != _resolvedCid) {
      try {
        playInfo = await _api.fetchPlayInfo(
          avid: info.aid,
          cid: target.cid,
          qn: _quality ?? biliDefaultQuality,
          cookie: cookie,
        );
      } on BiliApiException catch (exception) {
        _errorMessage = exception.message;
        _notify();
        return null;
      } on DioException catch (exception) {
        _errorMessage = _describeDio(exception);
        _notify();
        return null;
      }
      _playInfo = playInfo;
      _resolvedCid = target.cid;
      _selection = BiliStreamSelection.fromPlayInfo(playInfo);
    }
    final stream = BiliStreamSelection.resolve(
      playInfo,
      quality: _quality,
      format: _format,
    );
    if (stream == null) {
      _errorMessage = '该视频没有可下载的流(可能需要登录 Cookie)';
      _notify();
      return null;
    }
    if (stream.hasSeparateAudio) {
      _errorMessage = '该视频仅提供 DASH 分轨流, 需要音视频合并, 本模块暂不支持';
      _notify();
      return null;
    }
    if (isDownloading(info.bvid)) {
      _errorMessage = '该视频正在下载中';
      _notify();
      return null;
    }

    final directory = await _storageDirectory();
    final filePath = BiliFilePaths.join(
      directory,
      _fileNameFor(info, target, stream),
    );
    final task = BiliDownloadTask.pending(
      bvid: info.bvid,
      aid: info.aid,
      cid: target?.cid ?? _resolvedCid,
      title: info.title,
      episodeTitle: target?.title ?? '',
      cover: info.pic,
      stream: stream,
      filePath: filePath,
      now: _now(),
    );
    await _store.upsert(task);
    _replaceTask(task);
    _errorMessage = null;
    _notify();
    await _trackRun(task.bvid, _run(task, stream));
    return task;
  }

  /// Cancels the in-flight requests but keeps the row and its bytes, so the task
  /// can be resumed (the source's temp files make this possible).
  Future<void> pauseDownload(String bvid) async {
    final token = _tokens[bvid];
    token?.cancel('paused');
    // `_run` performs the persisted transition once the request unwinds.
  }

  /// Resumes a paused/failed task from the bytes already on disk.
  Future<void> resumeDownload(String bvid) async {
    final task = taskOf(bvid);
    final info = _videoInfo;
    if (task == null || info == null || task.status == BiliTaskStatus.completed)
      return;
    if (isDownloading(bvid)) return;
    if (task.cid != _resolvedCid || _playInfo == null) {
      try {
        final playInfo = await _api.fetchPlayInfo(
          avid: task.aid,
          cid: task.cid,
          qn: task.quality,
          cookie: cookie,
        );
        _playInfo = playInfo;
        _resolvedCid = task.cid;
      } on BiliApiException catch (exception) {
        _errorMessage = exception.message;
        _notify();
        return;
      } on DioException catch (exception) {
        _errorMessage = _describeDio(exception);
        _notify();
        return;
      }
    }
    final stream = BiliStreamSelection.resolve(
      _playInfo!,
      quality: task.quality,
      format: task.format,
    );
    if (stream == null) {
      _errorMessage = '无法恢复该任务的下载流';
      _notify();
      return;
    }
    _received[bvid] = task.receivedBytes;
    _totals[bvid] = task.totalBytes;
    await _trackRun(bvid, _run(task, stream));
  }

  /// Keeps the in-flight [Future] reachable so a pause/cancel can wait for the
  /// run to unwind before it touches the row or the task list.
  Future<void> _trackRun(String bvid, Future<void> run) async {
    _runs[bvid] = run;
    try {
      await run;
    } finally {
      _runs.remove(bvid);
    }
  }

  /// Cancels the download, forgets the row and removes the partial files.
  Future<void> cancelDownload(String bvid) async {
    final token = _tokens[bvid];
    final run = _runs[bvid];
    if (token != null && !token.isCancelled) {
      token.cancel('cancelled');
    }
    // Let the run unwind first: hearing the cancellation, `_run` may still
    // persist a `paused` row and put the task back into `_tasks`, so the row
    // (and the task) must be dropped only after that write has landed.
    await run;
    final task = taskOf(bvid);
    if (task != null) {
      await _deleteArtifacts(task);
    }
    await _store.deleteByBvid(bvid);
    _received.remove(bvid);
    _totals.remove(bvid);
    _tasks = <BiliDownloadTask>[
      for (final entry in _tasks)
        if (entry.bvid != bvid) entry,
    ];
    _notify();
  }

  /// Deletes a finished/forgotten task and, optionally, its file.
  Future<void> removeTask(String bvid, {bool deleteFile = false}) async {
    final task = taskOf(bvid);
    if (task == null) return;
    if (deleteFile) await _deleteArtifacts(task, includeFinalFile: true);
    await _store.deleteByBvid(bvid);
    _received.remove(bvid);
    _totals.remove(bvid);
    _tasks = <BiliDownloadTask>[
      for (final entry in _tasks)
        if (entry.bvid != bvid) entry,
    ];
    _notify();
  }

  /// The source's `VideoInfoDao.clear()` plus its temp-file cleanup.
  Future<void> clearAll({bool deleteFiles = false}) async {
    final running = _runs.values.toList(growable: false);
    for (final token in _tokens.values) {
      if (!token.isCancelled) token.cancel('clear');
    }
    // Wait for the runs to unwind before clearing the rows, or a run's own
    // `paused`/`failed` write lands after `clear()` and resurrects a task.
    for (final run in running) {
      await run;
    }
    if (deleteFiles) {
      for (final task in _tasks) {
        await _deleteArtifacts(task, includeFinalFile: true);
      }
    }
    await _store.clear();
    _received.clear();
    _totals.clear();
    _tasks = const <BiliDownloadTask>[];
    _notice = '已清空下载记录';
    _notify();
  }

  void clearError() {
    _errorMessage = null;
    _notice = null;
    _notify();
  }

  Future<BiliPlayInfo?> _fetchPlayInfo(
    BiliVideoInfo info,
    BiliUgcEpisode? episode,
  ) async {
    try {
      final playInfo = await _api.fetchPlayInfo(
        avid: info.aid,
        cid: episode?.cid ?? info.primaryCid,
        qn: _quality ?? biliDefaultQuality,
        cookie: cookie,
      );
      if (!BiliStreamSelection.isPlayable(playInfo)) {
        _errorMessage = '该视频没有可下载的流(可能需要登录 Cookie, 或视频已下架)';
        _playInfo = null;
        _selection = null;
        return null;
      }
      _playInfo = playInfo;
      _resolvedCid = episode?.cid ?? info.primaryCid;
      _selection = BiliStreamSelection.fromPlayInfo(playInfo);
      _quality ??= _selection!.defaultQuality;
      _format ??= _selection!.defaultFormat;
      if (!_selection!.formats.contains(_format)) {
        _format = _selection!.defaultFormat;
      }
      _errorMessage = null;
      return playInfo;
    } on BiliApiException catch (exception) {
      _errorMessage = exception.message;
      _playInfo = null;
      _selection = null;
      return null;
    } on DioException catch (exception) {
      _errorMessage = _describeDio(exception);
      _playInfo = null;
      _selection = null;
      return null;
    }
  }

  Future<void> _run(BiliDownloadTask task, BiliVideoStream stream) async {
    final bvid = task.bvid;
    final token = CancelToken();
    _tokens[bvid] = token;
    _received[bvid] = task.receivedBytes;
    _totals[bvid] = task.totalBytes;
    final running = task.copyWith(
      status: BiliTaskStatus.downloading,
      updatedAt: _now(),
    );
    await _store.updateStatus(
      bvid: bvid,
      status: BiliTaskStatus.downloading,
      updatedAt: _now(),
    );
    _replaceTask(running);
    _notify();
    try {
      final written = await _downloader.download(
        url: stream.url,
        savePath: task.filePath,
        headers: BiliApi.defaultHeaders(cookie: cookie),
        cancelToken: token,
        resume: true,
        onProgress: (received, total) {
          _received[bvid] = received;
          if (total > 0) _totals[bvid] = total;
          final active = taskOf(bvid);
          if (active != null && active.status == BiliTaskStatus.downloading) {
            _replaceTask(
              active.copyWith(
                receivedBytes: received,
                totalBytes: total > 0 ? total : active.totalBytes,
              ),
            );
          }
          _notify();
        },
      );
      if (token.isCancelled) throw const BiliDownloadCancelledException();
      await _store.markCompleted(
        bvid: bvid,
        filePath: task.filePath,
        totalBytes: written,
        updatedAt: _now(),
      );
      _received[bvid] = written;
      _totals[bvid] = written;
      final done = taskOf(bvid);
      if (done != null) {
        _replaceTask(
          done.copyWith(
            status: BiliTaskStatus.completed,
            receivedBytes: written,
            totalBytes: written,
            errorMessage: '',
            updatedAt: _now(),
          ),
        );
      }
      _notice = '${task.displayTitle} 下载完成';
    } on BiliDownloadCancelledException {
      final paused = taskOf(bvid);
      if (paused != null) {
        // Paused: keep the row and the partial bytes so the download can resume.
        await _store.updateStatus(
          bvid: bvid,
          status: BiliTaskStatus.paused,
          updatedAt: _now(),
          receivedBytes: _received[bvid],
          totalBytes: _totals[bvid],
        );
        _replaceTask(
          paused.copyWith(
            status: BiliTaskStatus.paused,
            receivedBytes: _received[bvid] ?? 0,
            totalBytes: _totals[bvid] ?? 0,
            updatedAt: _now(),
          ),
        );
      } else {
        // Cancelled: the row is gone, so the temp files are orphaned — drop them.
        await _deleteArtifacts(task);
      }
    } catch (error) {
      final message = _describeError(error);
      final failed = taskOf(bvid);
      if (failed != null) {
        await _store.updateStatus(
          bvid: bvid,
          status: BiliTaskStatus.failed,
          errorMessage: message,
          updatedAt: _now(),
          receivedBytes: _received[bvid],
          totalBytes: _totals[bvid],
        );
        _replaceTask(
          failed.copyWith(
            status: BiliTaskStatus.failed,
            errorMessage: message,
            receivedBytes: _received[bvid] ?? 0,
            totalBytes: _totals[bvid] ?? 0,
            updatedAt: _now(),
          ),
        );
      }
      _errorMessage = message;
    } finally {
      _tokens.remove(bvid);
      _notify();
    }
  }

  /// Cancels every in-flight request and deletes partial files for [bvid].
  Future<void> _deleteArtifacts(
    BiliDownloadTask task, {
    bool includeFinalFile = false,
  }) async {
    if (task.filePath.isEmpty) return;
    BiliRangeDownloader.deletePartialArtifacts(task.filePath);
    if (includeFinalFile) {
      final file = File(task.filePath);
      if (file.existsSync()) await file.delete();
    }
  }

  void _replaceTask(BiliDownloadTask task) {
    final next = <BiliDownloadTask>[];
    var replaced = false;
    for (final entry in _tasks) {
      if (entry.bvid == task.bvid) {
        next.add(task);
        replaced = true;
      } else {
        next.add(entry);
      }
    }
    if (!replaced) {
      next.insert(0, task);
    }
    _tasks = next;
  }

  /// First part of a collection, or the part the URL's `?p=` asked for.
  static BiliUgcEpisode? _episodeForPage(BiliVideoInfo info, int page) {
    final episodes = info.episodes;
    if (episodes.isEmpty) return null;
    if (page >= 2 && page <= episodes.length) return episodes[page - 1];
    return episodes.first;
  }

  /// `<title>[_<part>].mp4`, sanitised for the filesystem.
  static String _fileNameFor(
    BiliVideoInfo info,
    BiliUgcEpisode? episode,
    BiliVideoStream stream,
  ) {
    final title = sanitizeFileName(info.title);
    final part = episode == null ? '' : '_${sanitizeFileName(episode.title)}';
    final suffix = stream.quality > 0 ? '_q${stream.quality}' : '';
    return '$title$part$suffix.${stream.format.extension}';
  }

  /// Replaces path-hostile characters; keeps CJK titles untouched.
  static String sanitizeFileName(String input) {
    final cleaned = input
        .replaceAll(RegExp(r'[\\/:*?"<>|\n\r\t]'), '_')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (cleaned.isEmpty) return 'bili_video';
    return cleaned.length <= 80 ? cleaned : cleaned.substring(0, 80);
  }

  static String _describeDio(DioException exception) {
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return '网络请求超时';
      case DioExceptionType.connectionError:
        return '网络连接失败';
      case DioExceptionType.badResponse:
        return 'B站接口返回 ${exception.response?.statusCode}';
      case DioExceptionType.cancel:
        return '请求已取消';
      case DioExceptionType.badCertificate:
        return '证书校验失败';
      case DioExceptionType.unknown:
        return '网络错误: ${exception.message ?? exception.error}';
    }
  }

  static String _describeError(Object error) {
    if (error is BiliApiException) return error.message;
    if (error is DioException) return _describeDio(error);
    return '$error';
  }

  void _notify() {
    if (_disposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    for (final token in _tokens.values) {
      if (!token.isCancelled) token.cancel('dispose');
    }
    _tokens.clear();
    super.dispose();
  }
}
