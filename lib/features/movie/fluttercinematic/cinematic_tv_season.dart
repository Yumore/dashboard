import 'package:dashboard/features/movie/fluttercinematic/cinematic_image_url.dart';

/// Port of the source `lib/model/tvseason.dart` (rows of `tv/{id}`'s
/// `seasons` array): `air_date`, `episode_count`, `id`, `name`, `overview`,
/// `poster_path`, `season_number`.
class CinematicTvSeason {
  CinematicTvSeason({
    required this.airDate,
    required this.episodeCount,
    required this.id,
    required this.name,
    required this.overview,
    required this.posterPath,
    required this.seasonNumber,
  });

  factory CinematicTvSeason.fromMap(Map jsonMap) => CinematicTvSeason(
    airDate: '${jsonMap['air_date'] ?? ''}',
    episodeCount: _asInt(jsonMap['episode_count']),
    id: _asInt(jsonMap['id']),
    name: '${jsonMap['name'] ?? ''}',
    overview: '${jsonMap['overview'] ?? ''}',
    posterPath: '${jsonMap['poster_path'] ?? ''}',
    seasonNumber: _asInt(jsonMap['season_number']),
  );

  final String airDate;
  final int episodeCount;
  final int id;
  final String name;
  final String overview;
  final String posterPath;
  final int seasonNumber;

  String getPosterUrl() => CinematicImageUrl.medium(posterPath);

  /// Source returns `""` for an absent air date (TMDb specials can omit it).
  String getReleaseYear() {
    if (airDate.isEmpty) return '';
    return '${_year(airDate)}';
  }

  /// Source title rule: season 0 is labelled `Extras`, otherwise
  /// `Season <n> (<year>)`.
  String getFormattedTitle() {
    if (seasonNumber == 0) return 'Extras';
    return 'Season $seasonNumber (${getReleaseYear()})';
  }

  static int _year(String date) {
    if (date.length < 4) return 0;
    return int.tryParse(date.substring(0, 4)) ?? 0;
  }

  static int _asInt(Object? value) {
    if (value is num) return value.toInt();
    return int.tryParse('${value ?? ''}') ?? 0;
  }
}
