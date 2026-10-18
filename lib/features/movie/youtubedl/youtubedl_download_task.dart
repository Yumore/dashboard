import 'package:dashboard/features/movie/youtubedl/youtubedl_download_status.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_progress.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_stream_type.dart';

/// Immutable description and live state of one queued download.
class YoutubeDlDownloadTask {
  const YoutubeDlDownloadTask({
    required this.id,
    required this.videoId,
    required this.title,
    required this.status,
    required this.streamType,
    required this.url,
    required this.container,
    required this.totalBytes,
    required this.createdAt,
    this.audioUrl = '',
    this.downloadedBytes = 0,
    this.filePath = '',
    this.error = '',
    this.qualityLabel = '',
    this.startedAt,
    this.finishedAt,
  });

  final String id;
  final String videoId;
  final String title;
  final YoutubeDlDownloadStatus status;
  final YoutubeDlStreamType streamType;
  final String url;
  final String audioUrl;
  final String container;
  final int totalBytes;
  final int downloadedBytes;
  final String filePath;
  final String error;
  final String qualityLabel;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? finishedAt;

  bool get requiresMuxer => status == YoutubeDlDownloadStatus.needsMuxer;

  YoutubeDlProgress progressAt(DateTime now) {
    final started = startedAt;
    var elapsed = started == null ? Duration.zero : now.difference(started);
    if (elapsed.isNegative) elapsed = Duration.zero;
    return YoutubeDlProgress(
      downloadedBytes: downloadedBytes,
      totalBytes: totalBytes,
      elapsed: elapsed,
      completed: status == YoutubeDlDownloadStatus.done,
    );
  }

  YoutubeDlDownloadTask copyWith({
    YoutubeDlDownloadStatus? status,
    int? downloadedBytes,
    String? filePath,
    String? error,
    DateTime? startedAt,
    DateTime? finishedAt,
  }) {
    return YoutubeDlDownloadTask(
      id: id,
      videoId: videoId,
      title: title,
      status: status ?? this.status,
      streamType: streamType,
      url: url,
      audioUrl: audioUrl,
      container: container,
      totalBytes: totalBytes,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      filePath: filePath ?? this.filePath,
      error: error ?? this.error,
      qualityLabel: qualityLabel,
      createdAt: createdAt,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
    );
  }
}
