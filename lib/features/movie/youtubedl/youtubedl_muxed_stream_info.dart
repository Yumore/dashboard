import 'package:dashboard/features/movie/youtubedl/youtubedl_stream_info.dart';

/// A progressive stream that already contains both video and audio.
class YoutubeDlMuxedStreamInfo extends YoutubeDlStreamInfo {
  const YoutubeDlMuxedStreamInfo({
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
    required this.audioCodec,
  });

  @override
  final int height;

  @override
  final int fps;

  final String videoCodec;

  final String audioCodec;
}
