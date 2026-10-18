import 'package:dashboard/features/movie/bilivideo_down/bili_download_format.dart';
import 'package:dashboard/features/movie/bilivideo_down/bili_task_status.dart';
import 'package:dashboard/features/movie/bilivideo_down/bili_video_stream.dart';

/// One row of the download-task table.
///
/// Replaces the source app's `VideoInfoEntity` + `video_info` row
/// (`bvid` PK, `title`, `pic`, `downloadStatus`, `location`) with the fields the
/// task actually needs to survive a restart: status, byte progress and the
/// destination path. `bvid` stays the primary key, exactly like the source.
class BiliDownloadTask {
  const BiliDownloadTask({
    required this.bvid,
    required this.aid,
    required this.cid,
    required this.title,
    required this.cover,
    required this.quality,
    required this.format,
    required this.status,
    required this.receivedBytes,
    required this.totalBytes,
    required this.filePath,
    required this.createdAt,
    required this.updatedAt,
    this.episodeTitle = '',
    this.errorMessage = '',
  });

  final String bvid;
  final int aid;
  final int cid;
  final String title;

  /// Part title for a multi-part/collection video; empty for single-part.
  final String episodeTitle;
  final String cover;
  final int quality;
  final BiliDownloadFormat format;
  final BiliTaskStatus status;
  final int receivedBytes;
  final int totalBytes;

  /// Destination of the finished file; empty until the first download starts.
  final String filePath;
  final String errorMessage;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Primary key, matching the source's `bvid`-keyed table.
  String get bvidKey => bvid;

  /// 0.0–1.0, `0` while the total is still unknown.
  double get progress {
    if (totalBytes <= 0) return 0;
    final ratio = receivedBytes / totalBytes;
    return ratio.clamp(0.0, 1.0);
  }

  /// `12.00MB / 30.00MB`, in the source's `formatBytes` style. Falls back to
  /// the received count alone while the total is unknown.
  String get progressLabel => totalBytes > 0
      ? '${formatBytes(receivedBytes)} / ${formatBytes(totalBytes)}'
      : formatBytes(receivedBytes);

  bool get isCompleted =>
      status == BiliTaskStatus.completed && filePath.isNotEmpty;

  /// Display title: `合集标题 · 分P标题` for collections.
  String get displayTitle =>
      episodeTitle.isEmpty ? title : '$title · $episodeTitle';

  factory BiliDownloadTask.fromMap(Map<String, Object?> map) =>
      BiliDownloadTask(
        bvid: '${map['bvid'] ?? ''}',
        aid: _asInt(map['aid']),
        cid: _asInt(map['cid']),
        title: '${map['title'] ?? ''}',
        episodeTitle: '${map['episode_title'] ?? ''}',
        cover: '${map['cover'] ?? ''}',
        quality: _asInt(map['quality']),
        format: BiliDownloadFormat.values.firstWhere(
          (format) => format.name == map['format'],
          orElse: () => BiliDownloadFormat.flv,
        ),
        status: BiliTaskStatus.fromName(map['status'] as String?),
        receivedBytes: _asInt(map['received_bytes']),
        totalBytes: _asInt(map['total_bytes']),
        filePath: '${map['file_path'] ?? ''}',
        errorMessage: '${map['error_message'] ?? ''}',
        createdAt: _asDate(map['created_at']),
        updatedAt: _asDate(map['updated_at']),
      );

  Map<String, Object?> toMap() => <String, Object?>{
    'bvid': bvid,
    'aid': aid,
    'cid': cid,
    'title': title,
    'episode_title': episodeTitle,
    'cover': cover,
    'quality': quality,
    'format': format.name,
    'status': status.name,
    'received_bytes': receivedBytes,
    'total_bytes': totalBytes,
    'file_path': filePath,
    'error_message': errorMessage,
    'created_at': createdAt.millisecondsSinceEpoch,
    'updated_at': updatedAt.millisecondsSinceEpoch,
  };

  /// Builds a task for a freshly selected [stream]; status is
  /// [BiliTaskStatus.pending] until the first request goes out.
  factory BiliDownloadTask.pending({
    required String bvid,
    required int aid,
    required int cid,
    required String title,
    required String cover,
    required BiliVideoStream stream,
    required String filePath,
    required DateTime now,
    String episodeTitle = '',
  }) => BiliDownloadTask(
    bvid: bvid,
    aid: aid,
    cid: cid,
    title: title,
    episodeTitle: episodeTitle,
    cover: cover,
    quality: stream.quality,
    format: stream.format,
    status: BiliTaskStatus.pending,
    receivedBytes: 0,
    totalBytes: stream.size,
    filePath: filePath,
    createdAt: now,
    updatedAt: now,
  );

  BiliDownloadTask copyWith({
    int? cid,
    String? title,
    String? episodeTitle,
    String? cover,
    int? quality,
    BiliDownloadFormat? format,
    BiliTaskStatus? status,
    int? receivedBytes,
    int? totalBytes,
    String? filePath,
    String? errorMessage,
    DateTime? updatedAt,
  }) => BiliDownloadTask(
    bvid: bvid,
    aid: aid,
    cid: cid ?? this.cid,
    title: title ?? this.title,
    episodeTitle: episodeTitle ?? this.episodeTitle,
    cover: cover ?? this.cover,
    quality: quality ?? this.quality,
    format: format ?? this.format,
    status: status ?? this.status,
    receivedBytes: receivedBytes ?? this.receivedBytes,
    totalBytes: totalBytes ?? this.totalBytes,
    filePath: filePath ?? this.filePath,
    errorMessage: errorMessage ?? this.errorMessage,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  @override
  String toString() =>
      'BiliDownloadTask($bvid, ${status.name}, $receivedBytes/$totalBytes, $filePath)';
}

int _asInt(Object? value) => value is int ? value : int.tryParse('$value') ?? 0;

DateTime _asDate(Object? value) {
  if (value is DateTime) return value;
  final millis = _asInt(value);
  return DateTime.fromMillisecondsSinceEpoch(millis);
}
