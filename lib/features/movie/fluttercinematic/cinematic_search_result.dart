import 'package:dashboard/features/movie/fluttercinematic/cinematic_actor.dart';
import 'package:dashboard/features/movie/fluttercinematic/cinematic_date_format.dart';
import 'package:dashboard/features/movie/fluttercinematic/cinematic_genres.dart';
import 'package:dashboard/features/movie/fluttercinematic/cinematic_image_url.dart';
import 'package:dashboard/features/movie/fluttercinematic/cinematic_media_item.dart';

/// Port of the source `lib/model/searchresult.dart`.
///
/// Wraps one `search/multi` row together with its `media_type`, which decides
/// the image key (`poster_path` vs `profile_path`), the title key
/// (`title` for movies, `name` for tv/person) and the subtitle rule.
class CinematicSearchResult {
  CinematicSearchResult({required this.mediaType, required this.data});

  factory CinematicSearchResult.fromJson(Map jsonMap) => CinematicSearchResult(
    mediaType: '${jsonMap['media_type'] ?? ''}',
    data: jsonMap.map((key, value) => MapEntry('$key', value)),
  );

  final String mediaType;
  final Map<String, dynamic> data;

  String _getImagePath() {
    switch (mediaType) {
      case 'movie':
      case 'tv':
        return '${data['poster_path'] ?? ''}';
      case 'person':
        return '${data['profile_path'] ?? ''}';
      default:
        return '';
    }
  }

  String get title {
    switch (mediaType) {
      case 'movie':
        return '${data['title'] ?? ''}';
      case 'tv':
      case 'person':
        return '${data['name'] ?? ''}';
      default:
        return '';
    }
  }

  CinematicMediaItem get asMovie =>
      CinematicMediaItem.fromJson(data, type: CinematicMediaType.movie);

  CinematicMediaItem get asShow =>
      CinematicMediaItem.fromJson(data, type: CinematicMediaType.show);

  CinematicActor get asActor => CinematicActor.fromJson(data);

  String get subtitle {
    switch (mediaType) {
      case 'movie':
        return CinematicDateFormat.format('${data['release_date'] ?? ''}');
      case 'tv':
        return CinematicDateFormat.format('${data['first_air_date'] ?? ''}');
      case 'person':
        final knownFor = data['known_for'];
        if (knownFor is! List) return '';
        return CinematicGenres.joinKey(knownFor, 'title');
      default:
        return '';
    }
  }

  String get imageUrl => CinematicImageUrl.medium(_getImagePath());
}
