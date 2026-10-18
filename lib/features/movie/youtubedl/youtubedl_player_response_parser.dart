import 'package:dashboard/features/movie/youtubedl/youtubedl_format_parser.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_json.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_player_result.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_stream_exception.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_stream_info.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_stream_manifest.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_video.dart';

/// Parses the `player` InnerTube response into metadata + playable streams.
class YoutubeDlPlayerResponseParser {
  const YoutubeDlPlayerResponseParser({
    YoutubeDlFormatParser formatParser = const YoutubeDlFormatParser(),
  }) : _formatParser = formatParser;

  final YoutubeDlFormatParser _formatParser;

  YoutubeDlPlayerResult parse(Map<String, dynamic> json) {
    _ensurePlayable(json);
    final details = YoutubeDlJson.asMap(json['videoDetails']);
    final streamingData = YoutubeDlJson.asMap(json['streamingData']);
    final rawFormats = <Map<String, dynamic>>[
      ...YoutubeDlJson.asMapList(streamingData['formats']),
      ...YoutubeDlJson.asMapList(streamingData['adaptiveFormats']),
    ];
    final streams = <YoutubeDlStreamInfo>[];
    var unavailable = 0;
    for (final raw in rawFormats) {
      final stream = _formatParser.parse(raw);
      if (stream == null) {
        if (YoutubeDlJson.asString(raw['url']).isEmpty) unavailable++;
        continue;
      }
      streams.add(stream);
    }
    return YoutubeDlPlayerResult(
      video: YoutubeDlVideo.fromVideoDetails(details),
      manifest: YoutubeDlStreamManifest(streams, unavailableCount: unavailable),
    );
  }

  void _ensurePlayable(Map<String, dynamic> json) {
    final status = YoutubeDlJson.asMap(json['playabilityStatus']);
    final name = YoutubeDlJson.asString(status['status']);
    if (name.isEmpty || name == 'OK') return;
    final reason = YoutubeDlJson.asString(status['reason']);
    throw YoutubeDlStreamException(
      reason.isEmpty ? 'YouTube 拒绝播放请求：$name' : reason,
    );
  }
}
