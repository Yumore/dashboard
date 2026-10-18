import 'package:dashboard/features/movie/youtubedl/youtubedl_bytes.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_stream_container.dart';

/// Metadata shared by every directly playable YouTube stream.
abstract class YoutubeDlStreamInfo {
  const YoutubeDlStreamInfo({
    required this.itag,
    required this.url,
    required this.container,
    required this.bitrate,
    required this.size,
    required this.mimeType,
    required this.codecs,
    required this.qualityLabel,
  });

  /// YouTube's numeric format identifier.
  final int itag;

  /// Direct media URL extracted from `streamingData`.
  final Uri url;

  final YoutubeDlStreamContainer container;

  /// Approximate bitrate in bits per second.
  final int bitrate;

  /// Content length in bytes, `0` when YouTube did not report it.
  final int size;

  final String mimeType;

  /// Raw codec list, e.g. `avc1.42001E, mp4a.40.2`.
  final String codecs;

  /// Quality label, e.g. `1080p60` or `128 kbps`.
  final String qualityLabel;

  String get sizeLabel => YoutubeDlBytes.format(size);

  String get bitrateLabel => '${(bitrate / 1000).round()} kbps';

  String get containerLabel => container.label;

  /// Video height in pixels; `0` for audio only streams.
  int get height => 0;

  /// Frames per second; `0` when unknown.
  int get fps => 0;
}
