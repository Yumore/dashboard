import 'package:dashboard/features/movie/fluttercinematic/cinematic_actor.dart';
import 'package:dashboard/features/movie/fluttercinematic/cinematic_constants.dart';
import 'package:dashboard/features/movie/fluttercinematic/cinematic_episode.dart';
import 'package:dashboard/features/movie/fluttercinematic/cinematic_media_item.dart';
import 'package:dashboard/features/movie/fluttercinematic/cinematic_search_result.dart';
import 'package:dashboard/features/movie/fluttercinematic/cinematic_tv_season.dart';
import 'package:dio/dio.dart';

/// TMDb client for the FlutterCinematic port, over the host's `dio`.
///
/// Every endpoint, path and query parameter below is taken from the source
/// `lib/util/api_client.dart`:
///
/// * `movie/{category}`        — `api_key`, `page`        (`fetchMovies`)
/// * `tv/{category}`           — `api_key`, `page`        (`fetchShows`)
/// * `{movie|tv}/{id}/similar` — `api_key`                (`getSimilarMedia`)
/// * `discover/movie`          — `api_key`, `with_cast`,
///   `sort_by=popularity.desc`                            (`getMoviesForActor`)
/// * `person/{id}/tv_credits`  — `api_key`, reads `cast`  (`getShowsForActor`)
/// * `{movie|tv}/{id}/credits` — `api_key`, reads `cast`  (`getMediaCredits`)
/// * `{movie|tv}/{id}`         — `api_key`                (`getMediaDetails`)
/// * `tv/{id}/season/{n}`      — `api_key`, reads `episodes` (`fetchEpisodes`)
/// * `search/multi`            — `api_key`, `query`       (`getSearchResults`)
///
/// The source used `dart:io` HttpClient against host `api.themoviedb.org`; this
/// port uses the host's `dio` and the source's own API-key placeholder, unless
/// another key is injected.
class CinematicApi {
  CinematicApi({
    Dio? dio,
    String apiKey = CinematicConstants.defaultApiKey,
    String language = CinematicConstants.defaultLanguage,
  }) : _dio =
           dio ??
           Dio(
             BaseOptions(
               baseUrl: CinematicConstants.baseUrl,
               connectTimeout: const Duration(seconds: 10),
               receiveTimeout: const Duration(seconds: 20),
             ),
           ),
       _apiKey = apiKey,
       _language = language;

  final Dio _dio;
  final String _apiKey;
  final String _language;

  /// Source `fetchMovies`: `movie/$category` with `api_key` + `page`.
  Future<List<CinematicMediaItem>> fetchMovies({
    int page = 1,
    String category = 'popular',
  }) => _results('movie/$category', CinematicMediaType.movie, page);

  /// Source `fetchShows`: `tv/$category` with `api_key` + `page`.
  Future<List<CinematicMediaItem>> fetchShows({
    int page = 1,
    String category = 'popular',
  }) => _results('tv/$category', CinematicMediaType.show, page);

  /// Source `getSimilarMedia`; the source never sent `page` — this port offers
  /// it because TMDb's similar endpoint is paged.
  Future<List<CinematicMediaItem>> getSimilarMedia(
    int mediaId, {
    String type = 'movie',
    int? page,
  }) => _results(
    '$type/$mediaId/similar',
    type == 'movie' ? CinematicMediaType.movie : CinematicMediaType.show,
    page,
  );

  /// Source `getMoviesForActor`: `discover/movie` filtered by `with_cast`.
  Future<List<CinematicMediaItem>> getMoviesForActor(int actorId) => _results(
    'discover/movie',
    CinematicMediaType.movie,
    null,
    extra: <String, dynamic>{
      'with_cast': '$actorId',
      'sort_by': 'popularity.desc',
    },
  );

  /// Source `getShowsForActor`: reads the `cast` array, not `results`.
  Future<List<CinematicMediaItem>> getShowsForActor(int actorId) async {
    final json = await _getJson('person/$actorId/tv_credits');
    return _asMapList(json['cast'])
        .map(
          (row) =>
              CinematicMediaItem.fromJson(row, type: CinematicMediaType.show),
        )
        .toList();
  }

  /// Source `getMediaCredits`: reads the `cast` array.
  Future<List<CinematicActor>> getMediaCredits(
    int mediaId, {
    String type = 'movie',
  }) async {
    final json = await _getJson('$type/$mediaId/credits');
    return _asMapList(
      json['cast'],
    ).map((row) => CinematicActor.fromJson(row)).toList();
  }

  /// Source `getMediaDetails`.
  Future<Map<String, dynamic>> getMediaDetails(
    int mediaId, {
    String type = 'movie',
  }) => _getJson('$type/$mediaId');

  /// Source `getShowSeasons`: `tv/{id}` then its `seasons` array.
  Future<List<CinematicTvSeason>> getShowSeasons(int showId) async {
    final detailJson = await getMediaDetails(showId, type: 'tv');
    return _asMapList(
      detailJson['seasons'],
    ).map((row) => CinematicTvSeason.fromMap(row)).toList();
  }

  /// Source `getSearchResults`: `search/multi` with `api_key` + `query`.
  Future<List<CinematicSearchResult>> getSearchResults(String query) async {
    final json = await _getJson('search/multi', <String, dynamic>{
      'query': query,
    });
    return _asMapList(
      json['results'],
    ).map((row) => CinematicSearchResult.fromJson(row)).toList();
  }

  /// Source `fetchEpisodes`: `tv/{showId}/season/{seasonNumber}` then the
  /// `episodes` array.
  Future<List<CinematicEpisode>> fetchEpisodes(
    int showId,
    int seasonNumber,
  ) async {
    final json = await _getJson('tv/$showId/season/$seasonNumber');
    return _asMapList(
      json['episodes'],
    ).map((row) => CinematicEpisode.fromJson(row)).toList();
  }

  void dispose() => _dio.close();

  /// Source read `json['results']` directly; this port tolerates a missing or
  /// non-list key by returning an empty list instead of throwing.
  Future<List<CinematicMediaItem>> _results(
    String path,
    CinematicMediaType type,
    int? page, {
    Map<String, dynamic>? extra,
  }) async {
    final json = await _getJson(path, <String, dynamic>{
      if (page != null) 'page': '$page',
      ...?extra,
    });
    return _asMapList(
      json['results'],
    ).map((row) => CinematicMediaItem.fromJson(row, type: type)).toList();
  }

  List<Map<String, dynamic>> _asMapList(Object? value) {
    if (value is! List) return const <Map<String, dynamic>>[];
    return value
        .whereType<Map>()
        .map((row) => row.map((key, item) => MapEntry('$key', item)))
        .toList();
  }

  Future<Map<String, dynamic>> _getJson(
    String path, [
    Map<String, dynamic> query = const <String, dynamic>{},
  ]) async {
    final response = await _dio.get<dynamic>(
      path,
      queryParameters: <String, dynamic>{
        ...query,
        'api_key': _apiKey,
        'language': _language,
      },
    );
    final data = response.data;
    if (data is Map) {
      return data.map((key, value) => MapEntry('$key', value));
    }
    return <String, dynamic>{};
  }
}
