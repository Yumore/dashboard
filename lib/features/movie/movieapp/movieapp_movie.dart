import 'package:dashboard/features/movie/movieapp/movieapp_image.dart';
import 'package:dashboard/features/movie/movieapp/movieapp_json.dart';
import 'package:dashboard/features/movie/movieapp/movieapp_media_kind.dart';

/// One row of a TMDb list response.
///
/// TV list rows use `name` / `original_name` / `first_air_date` while movie
/// rows use `title` / `original_title` / `release_date`; both are mapped here.
class MovieAppMovie {
  const MovieAppMovie({
    required this.id,
    required this.title,
    this.originalTitle = '',
    this.overview = '',
    this.releaseDate = '',
    this.genreIds = const [],
    this.voteAverage = 0,
    this.voteCount = 0,
    this.popularity = 0,
    this.posterPath,
    this.backdropPath,
    this.kind = MovieAppMediaKind.movie,
  });

  final int id;
  final String title;
  final String originalTitle;
  final String overview;
  final String releaseDate;
  final List<int> genreIds;
  final double voteAverage;
  final int voteCount;
  final double popularity;
  final String? posterPath;
  final String? backdropPath;
  final MovieAppMediaKind kind;

  factory MovieAppMovie.fromJson(
    Map<String, dynamic> json, {
    MovieAppMediaKind kind = MovieAppMediaKind.movie,
  }) => MovieAppMovie(
    id: MovieAppJson.asInt(json['id']),
    title: MovieAppJson.asString(json['title'] ?? json['name']),
    originalTitle: MovieAppJson.asString(
      json['original_title'] ?? json['original_name'],
    ),
    overview: MovieAppJson.asString(json['overview']),
    releaseDate: MovieAppJson.asString(
      json['release_date'] ?? json['first_air_date'],
    ),
    genreIds: MovieAppJson.asIntList(json['genre_ids']),
    voteAverage: MovieAppJson.asDouble(json['vote_average']),
    voteCount: MovieAppJson.asInt(json['vote_count']),
    popularity: MovieAppJson.asDouble(json['popularity']),
    posterPath: MovieAppJson.asNullableString(json['poster_path']),
    backdropPath: MovieAppJson.asNullableString(json['backdrop_path']),
    kind: kind,
  );

  String get displayTitle => title.isEmpty ? originalTitle : title;

  String get year => releaseDate.length >= 4 ? releaseDate.substring(0, 4) : '';

  String? get posterUrl =>
      MovieAppImage.url(posterPath, size: MovieAppImage.poster);

  String? get backdropUrl =>
      MovieAppImage.url(backdropPath, size: MovieAppImage.backdrop);

  Uri get webUri => Uri.parse('https://www.themoviedb.org/${kind.webPath}/$id');
}
