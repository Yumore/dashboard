import 'package:dashboard/features/movie/movieapp/movieapp_genre.dart';
import 'package:dashboard/features/movie/movieapp/movieapp_image.dart';
import 'package:dashboard/features/movie/movieapp/movieapp_json.dart';
import 'package:dashboard/features/movie/movieapp/movieapp_media_kind.dart';

/// `movie/{id}` / `tv/{id}` detail payload.
///
/// The two TMDb shapes differ, so this maps both: TV uses `name` /
/// `first_air_date` / `episode_run_time` (a list) / `number_of_seasons`.
class MovieAppMovieDetail {
  const MovieAppMovieDetail({
    required this.id,
    required this.title,
    this.tagline = '',
    this.overview = '',
    this.releaseDate = '',
    this.runtime,
    this.status = '',
    this.homepage = '',
    this.imdbId = '',
    this.voteAverage = 0,
    this.voteCount = 0,
    this.posterPath,
    this.backdropPath,
    this.genres = const [],
    this.seasonCount,
    this.episodeCount,
    this.kind = MovieAppMediaKind.movie,
  });

  final int id;
  final String title;
  final String tagline;
  final String overview;
  final String releaseDate;
  final int? runtime;
  final String status;
  final String homepage;
  final String imdbId;
  final double voteAverage;
  final int voteCount;
  final String? posterPath;
  final String? backdropPath;
  final List<MovieAppGenre> genres;
  final int? seasonCount;
  final int? episodeCount;
  final MovieAppMediaKind kind;

  factory MovieAppMovieDetail.fromJson(
    Map<String, dynamic> json, {
    MovieAppMediaKind kind = MovieAppMediaKind.movie,
  }) {
    final runtime = MovieAppJson.asInt(json['runtime']);
    final episodeRuntimes = MovieAppJson.asIntList(json['episode_run_time']);
    final seasons = MovieAppJson.asInt(json['number_of_seasons']);
    final episodes = MovieAppJson.asInt(json['number_of_episodes']);
    return MovieAppMovieDetail(
      id: MovieAppJson.asInt(json['id']),
      title: MovieAppJson.asString(json['title'] ?? json['name']),
      tagline: MovieAppJson.asString(json['tagline']),
      overview: MovieAppJson.asString(json['overview']),
      releaseDate: MovieAppJson.asString(
        json['release_date'] ?? json['first_air_date'],
      ),
      runtime: runtime > 0
          ? runtime
          : (episodeRuntimes.isEmpty ? null : episodeRuntimes.first),
      status: MovieAppJson.asString(json['status']),
      homepage: MovieAppJson.asString(json['homepage']),
      imdbId: MovieAppJson.asString(json['imdb_id']),
      voteAverage: MovieAppJson.asDouble(json['vote_average']),
      voteCount: MovieAppJson.asInt(json['vote_count']),
      posterPath: MovieAppJson.asNullableString(json['poster_path']),
      backdropPath: MovieAppJson.asNullableString(json['backdrop_path']),
      genres: MovieAppJson.asMapList(
        json['genres'],
      ).map(MovieAppGenre.fromJson).toList(),
      seasonCount: seasons > 0 ? seasons : null,
      episodeCount: episodes > 0 ? episodes : null,
      kind: kind,
    );
  }

  String get year => releaseDate.length >= 4 ? releaseDate.substring(0, 4) : '';

  String get runtimeLabel {
    final minutes = runtime;
    if (minutes == null || minutes <= 0) return '';
    if (minutes < 60) return '$minutes 分钟';
    return '${minutes ~/ 60}h ${minutes % 60}min';
  }

  String? get posterUrl =>
      MovieAppImage.url(posterPath, size: MovieAppImage.poster);

  String? get backdropUrl =>
      MovieAppImage.url(backdropPath, size: MovieAppImage.backdrop);
}
