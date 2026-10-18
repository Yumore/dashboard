import 'package:dashboard/features/movie/youtubedl/youtubedl_stream_info.dart';

/// A video track without audio. Downloading it alone yields a silent file.
class YoutubeDlVideoOnlyStreamInfo extends YoutubeDlStreamInfo {
  const YoutubeDlVideoOnlyStreamInfo({
    required super.itag,
    required super.url,
    required super.container,
    required super.bitrate,
    required super.size,
    required super.mimeType,
    required super.codecs,
    required super.qualityLabel,
    required this.height,
    required this.fps,
    required this.videoCodec,
  });

  @override
  final int height;

  @override
  final int fps;

  final String videoCodec;
}
