import 'package:dashboard/features/movie/movieapp/movieapp_json.dart';

/// One entry of `movie/{id}/videos` | `tv/{id}/videos`.
///
/// TMDb returns YouTube keys, not playable media streams: the only honest
/// playback target is the YouTube watch page.
class MovieAppVideo {
  const MovieAppVideo({
    required this.id,
    required this.key,
    this.name = '',
    this.site = '',
    this.type = '',
    this.official = false,
  });

  final String id;
  final String key;
  final String name;
  final String site;
  final String type;
  final bool official;

  factory MovieAppVideo.fromJson(Map<String, dynamic> json) => MovieAppVideo(
    id: MovieAppJson.asString(json['id']),
    key: MovieAppJson.asString(json['key']),
    name: MovieAppJson.asString(json['name']),
    site: MovieAppJson.asString(json['site']),
    type: MovieAppJson.asString(json['type']),
    official: json['official'] == true,
  );

  bool get isYouTube =>
      site.toLowerCase() == 'youtube' && key.trim().isNotEmpty;

  bool get isTrailer => type.toLowerCase() == 'trailer';

  Uri? get watchUri =>
      isYouTube ? Uri.parse('https://www.youtube.com/watch?v=$key') : null;
}
