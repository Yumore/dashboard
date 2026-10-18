import 'package:dashboard/features/movie/youtubedl/youtubedl_stream_info.dart';

/// An audio-only track, useful as the audio half of a merged download.
class YoutubeDlAudioOnlyStreamInfo extends YoutubeDlStreamInfo {
  const YoutubeDlAudioOnlyStreamInfo({
    required super.itag,
    required super.url,
    required super.container,
    required super.bitrate,
    required super.size,
    required super.mimeType,
    required super.codecs,
    required super.qualityLabel,
    required this.audioCodec,
    this.channels = 0,
  });

  final String audioCodec;

  final int channels;
}
