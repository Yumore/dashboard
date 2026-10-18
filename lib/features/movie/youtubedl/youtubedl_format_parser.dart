import 'package:dashboard/features/movie/youtubedl/youtubedl_audio_only_stream_info.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_json.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_muxed_stream_info.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_stream_container.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_stream_info.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_video_only_stream_info.dart';

/// Turns one `formats` / `adaptiveFormats` entry into a typed stream.
///
/// Entries that only carry a `signatureCipher` cannot be played without
/// deciphering YouTube's player JavaScript, so they are skipped and counted as
/// unavailable instead of being exposed as broken URLs.
class YoutubeDlFormatParser {
  const YoutubeDlFormatParser();

  YoutubeDlStreamInfo? parse(Map<String, dynamic> json) {
    final mimeType = YoutubeDlJson.asString(json['mimeType']);
    if (mimeType.isEmpty) return null;
    final url = _directUrl(json);
    if (url == null) return null;

    final itag = YoutubeDlJson.asInt(json['itag']);
    final bitrate = YoutubeDlJson.asInt(json['bitrate']);
    final size = _contentLength(json);
    final codecs = _codecs(mimeType);
    final container = YoutubeDlStreamContainer.fromMimeType(mimeType);
    final qualityLabel = _qualityLabel(json);

    if (mimeType.toLowerCase().startsWith('audio/')) {
      return YoutubeDlAudioOnlyStreamInfo(
        itag: itag,
        url: url,
        container: container,
        bitrate: bitrate,
        size: size,
        mimeType: mimeType,
        codecs: codecs.join(', '),
        qualityLabel: qualityLabel.isEmpty
            ? '${(bitrate / 1000).round()} kbps'
            : qualityLabel,
        audioCodec: codecs.isEmpty ? 'unknown' : codecs.first,
        channels: YoutubeDlJson.asInt(json['audioChannels']),
      );
    }

    final videoCodec = codecs.isEmpty ? 'unknown' : codecs.first;
    final height = YoutubeDlJson.asInt(json['height']);
    final fps = YoutubeDlJson.asInt(json['fps']);
    final label = qualityLabel.isEmpty ? '${height}p' : qualityLabel;
    final audioCodec = _audioCodec(codecs);
    if (audioCodec != null) {
      return YoutubeDlMuxedStreamInfo(
        itag: itag,
        url: url,
        container: container,
        bitrate: bitrate,
        size: size,
        mimeType: mimeType,
        codecs: codecs.join(', '),
        qualityLabel: label,
        height: height,
        fps: fps,
        videoCodec: videoCodec,
        audioCodec: audioCodec,
      );
    }
    return YoutubeDlVideoOnlyStreamInfo(
      itag: itag,
      url: url,
      container: container,
      bitrate: bitrate,
      size: size,
      mimeType: mimeType,
      codecs: codecs.join(', '),
      qualityLabel: label,
      height: height,
      fps: fps,
      videoCodec: videoCodec,
    );
  }

  static Uri? _directUrl(Map<String, dynamic> json) {
    final raw = YoutubeDlJson.asString(json['url']);
    if (raw.isEmpty) return null;
    return Uri.tryParse(YoutubeDlJson.normalizeUrl(raw));
  }

  static int _contentLength(Map<String, dynamic> json) {
    final length = YoutubeDlJson.asInt(json['contentLength']);
    if (length > 0) return length;
    return YoutubeDlJson.asInt(json['clen']);
  }

  static List<String> _codecs(String mimeType) {
    final match = RegExp(r'codecs="([^"]*)"').firstMatch(mimeType);
    final raw = match?.group(1) ?? '';
    return raw
        .split(',')
        .map((codec) => codec.trim())
        .where((codec) => codec.isNotEmpty)
        .toList(growable: false);
  }

  static String? _audioCodec(List<String> codecs) {
    for (final codec in codecs) {
      final normalized = codec.toLowerCase();
      if (normalized.startsWith('mp4a') ||
          normalized.startsWith('opus') ||
          normalized.startsWith('vorbis') ||
          normalized.startsWith('ac-3') ||
          normalized.startsWith('ec-3') ||
          normalized.startsWith('flac') ||
          normalized.startsWith('mp3')) {
        return codec;
      }
    }
    return null;
  }

  static String _qualityLabel(Map<String, dynamic> json) {
    final label = YoutubeDlJson.asString(json['qualityLabel']);
    if (label.isNotEmpty) return label;
    final height = YoutubeDlJson.asInt(json['height']);
    return height > 0 ? '${height}p' : '';
  }
}
