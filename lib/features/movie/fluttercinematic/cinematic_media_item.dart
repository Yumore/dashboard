import 'package:dashboard/features/movie/fluttercinematic/cinematic_date_format.dart';
import 'package:dashboard/features/movie/fluttercinematic/cinematic_image_url.dart';

enum CinematicMediaType { movie, show }

/// Port of the source `lib/model/mediaitem.dart`.
///
/// Field names and source keys are unchanged: `id`, `vote_average`, `title`
/// (movie) / `name` (show), `poster_path`, `backdrop_path`, `overview`,
/// `release_date` (movie) / `first_air_date` (show), `genre_ids`.
class CinematicMediaItem {
  CinematicMediaItem({
    required this.type,
    required this.id,
    required this.voteAverage,
    required this.title,
    required this.posterPath,
    required this.backdropPath,
    required this.overview,
    required this.releaseDate,
    required this.genreIds,
  });

  factory CinematicMediaItem.fromJson(
    Map jsonMap, {
    CinematicMediaType type = CinematicMediaType.movie,
  }) => CinematicMediaItem(
    type: type,
    id: _asInt(jsonMap['id']),
    voteAverage: _asDouble(jsonMap['vote_average']),
    title:
        '${jsonMap[type == CinematicMediaType.movie ? 'title' : 'name'] ?? ''}',
    posterPath: '${jsonMap['poster_path'] ?? ''}',
    backdropPath: '${jsonMap['backdrop_path'] ?? ''}',
    overview: '${jsonMap['overview'] ?? ''}',
    releaseDate:
        '${jsonMap[type == CinematicMediaType.movie ? 'release_date' : 'first_air_date'] ?? ''}',
    genreIds: _asIntList(jsonMap['genre_ids']),
  );

  /// Favourite round-trip used by `AppModel`/SharedPreferences. The source
  /// wrote `type` as `1` for a movie and `0` for a show, and persisted the
  /// display title under whichever key the type reads.
  factory CinematicMediaItem.fromPrefsJson(Map jsonMap) {
    final type = _asInt(jsonMap['type']) == 1
        ? CinematicMediaType.movie
        : CinematicMediaType.show;
    return CinematicMediaItem.fromJson(<String, dynamic>{
      ...jsonMap.map((key, value) => MapEntry('$key', value)),
      if (type == CinematicMediaType.show)
        'name': '${jsonMap['name'] ?? jsonMap['title'] ?? ''}',
    }, type: type);
  }

  final CinematicMediaType type;
  final int id;
  final double voteAverage;
  final String title;
  final String posterPath;
  final String backdropPath;
  final String overview;
  final String releaseDate;
  final List<int> genreIds;

  bool get isMovie => type == CinematicMediaType.movie;

  String getBackDropUrl() => CinematicImageUrl.large(backdropPath);

  String getPosterUrl() => CinematicImageUrl.medium(posterPath);

  /// Source returns `0` when the date is missing, otherwise the parsed year.
  int getReleaseYear() => CinematicDateFormat.year(releaseDate) ?? 0;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'type': isMovie ? 1 : 0,
    'id': id,
    'vote_average': voteAverage,
    'title': title,
    'poster_path': posterPath,
    'backdrop_path': backdropPath,
    'overview': overview,
    'release_date': releaseDate,
    'genre_ids': genreIds,
  };

  static int _asInt(Object? value) {
    if (value is num) return value.toInt();
    return int.tryParse('${value ?? ''}') ?? 0;
  }

  static double _asDouble(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse('${value ?? ''}') ?? 0;
  }

  static List<int> _asIntList(Object? value) {
    if (value is! List) return const <int>[];
    return value
        .map((item) => item is num ? item.toInt() : int.tryParse('$item') ?? 0)
        .toList();
  }
}
