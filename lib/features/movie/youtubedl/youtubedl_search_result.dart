import 'package:dashboard/features/movie/youtubedl/youtubedl_duration.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_json.dart';

/// One `videoRenderer` entry from a YouTube search response.
class YoutubeDlSearchResult {
  const YoutubeDlSearchResult({
    required this.videoId,
    required this.title,
    required this.author,
    required this.duration,
    required this.thumbnail,
    this.isLive = false,
  });

  factory YoutubeDlSearchResult.fromRenderer(Map<String, dynamic> json) {
    return YoutubeDlSearchResult(
      videoId: YoutubeDlJson.asString(json['videoId']),
      title: _text(json['title']),
      author: _text(json['ownerText']),
      duration: _parseDuration(_text(json['lengthText'])),
      thumbnail: YoutubeDlJson.thumbnailUrl(json['thumbnail']),
      isLive: _isLive(json),
    );
  }

  final String videoId;
  final String title;
  final String author;
  final Duration duration;
  final String thumbnail;
  final bool isLive;

  String get durationLabel => YoutubeDlDuration.format(duration);

  static String _text(Object? value) {
    final map = YoutubeDlJson.asMap(value);
    if (map.isEmpty) return '';
    final simpleText = YoutubeDlJson.asString(map['simpleText']);
    if (simpleText.isNotEmpty) return simpleText;
    final runs = YoutubeDlJson.asMapList(map['runs']);
    if (runs.isEmpty) return '';
    return runs.map((run) => YoutubeDlJson.asString(run['text'])).join();
  }

  static Duration _parseDuration(String text) {
    if (text.isEmpty) return Duration.zero;
    final parts = text.split(':').map(int.tryParse).toList(growable: false);
    if (parts.any((part) => part == null)) return Duration.zero;
    var seconds = 0;
    for (final part in parts) {
      seconds = seconds * 60 + part!;
    }
    return Duration(seconds: seconds);
  }

  static bool _isLive(Map<String, dynamic> json) {
    final hasLiveBadge = YoutubeDlJson.asMapList(
      json['badges'],
    ).any(_isLiveBadge);
    if (hasLiveBadge) return true;
    return YoutubeDlJson.asMapList(
      json['thumbnailOverlays'],
    ).any((overlay) => _isLiveBadge(YoutubeDlJson.asMap(overlay)));
  }

  static bool _isLiveBadge(Map<String, dynamic> badge) {
    final renderer = YoutubeDlJson.asMap(badge['metadataBadgeRenderer']);
    final style = YoutubeDlJson.asString(renderer['style']);
    if (style == 'BADGE_STYLE_TYPE_LIVE_NOW') return true;
    final label = YoutubeDlJson.asString(renderer['label']).toUpperCase();
    return label == 'LIVE';
  }
}
