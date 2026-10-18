import 'package:dashboard/features/movie/movieapp/movieapp_json.dart';
import 'package:dashboard/features/movie/movieapp/movieapp_media_kind.dart';
import 'package:dashboard/features/movie/movieapp/movieapp_movie.dart';

/// A TMDb paged list envelope: `{page, results, total_pages, total_results}`.
class MovieAppListResult {
  const MovieAppListResult({
    required this.page,
    required this.totalPages,
    required this.totalResults,
    required this.results,
  });

  final int page;
  final int totalPages;
  final int totalResults;
  final List<MovieAppMovie> results;

  bool get isEmpty => results.isEmpty;

  factory MovieAppListResult.fromJson(
    Map<String, dynamic> json, {
    MovieAppMediaKind kind = MovieAppMediaKind.movie,
  }) => MovieAppListResult(
    page: MovieAppJson.asInt(json['page']),
    totalPages: MovieAppJson.asInt(json['total_pages']),
    totalResults: MovieAppJson.asInt(json['total_results']),
    results: MovieAppJson.asMapList(
      json['results'],
    ).map((row) => MovieAppMovie.fromJson(row, kind: kind)).toList(),
  );
}
