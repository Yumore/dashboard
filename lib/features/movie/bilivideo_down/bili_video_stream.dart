import 'package:dashboard/features/movie/bilivideo_down/bili_download_format.dart';
import 'package:dashboard/features/movie/bilivideo_down/bili_quality.dart';

/// A single downloadable bilibili stream: one URL plus the byte size the
/// downloader needs.
///
/// The source app built this as `VideoInfoEntity(playUrl: durl.url,
/// length: durl.length, size: durl.size)`; this value object is that shape with
/// the container and quality attached.
class BiliVideoStream {
  const BiliVideoStream({
    required this.format,
    required this.quality,
    required this.url,
    required this.durationMs,
    required this.size,
    this.audioUrl,
    this.segmentCount = 1,
  });

  final BiliDownloadFormat format;
  final int quality;
  final String url;

  /// Duration in milliseconds (`durl.length`).
  final int durationMs;

  /// Total bytes (`durl.size`); `0` when the server did not report a size, in
  /// which case the downloader learns the total from the `content-range` or
  /// `content-length` header.
  final int size;

  /// DASH audio track URL; `null` for progressive FLV/MP4 streams that already
  /// carry their audio.
  final String? audioUrl;

  /// Number of progressive segments this stream was assembled from.
  final int segmentCount;

  bool get hasSeparateAudio => audioUrl != null && audioUrl!.isNotEmpty;

  /// Whether the source would need to concatenate segments (unsupported, and
  /// exactly what the source app skipped).
  bool get isSegmented => segmentCount > 1;

  String get qualityLabel => biliQualityLabel(quality);

  Duration get duration => Duration(milliseconds: durationMs);

  String get durationText => formatDurationText(duration);

  BiliVideoStream copyWith({int? quality, String? url, int? size}) =>
      BiliVideoStream(
        format: format,
        quality: quality ?? this.quality,
        url: url ?? this.url,
        durationMs: durationMs,
        size: size ?? this.size,
        audioUrl: audioUrl,
        segmentCount: segmentCount,
      );
}

/// `mm:ss`, or `h:mm:ss` past an hour. Ports the source's
/// `CommonUtil.formatDuration`, minus the leading-zero padding of the hour.
String formatDurationText(Duration duration) {
  final total = duration.inSeconds < 0 ? 0 : duration.inSeconds;
  final hours = total ~/ 3600;
  final minutes = (total % 3600) ~/ 60;
  final seconds = total % 60;
  String pad(int value) => value.toString().padLeft(2, '0');
  return hours > 0
      ? '$hours:${pad(minutes)}:${pad(seconds)}'
      : '${pad(minutes)}:${pad(seconds)}';
}

/// Human-readable byte count. Ports the source's `CommonUtil.formatBytes`
/// (binary steps, two decimals).
String formatBytes(int bytes) {
  if (bytes <= 0) return '0B';
  const suffixes = <String>['B', 'KB', 'MB', 'GB', 'TB', 'PB'];
  var value = bytes.toDouble();
  var index = 0;
  while (value > 1024 && index < suffixes.length - 1) {
    value /= 1024;
    index += 1;
  }
  return '${value.toStringAsFixed(2)}${suffixes[index]}';
}
