import 'package:dashboard/features/movie/movieapp/movieapp_credits.dart';
import 'package:dashboard/features/movie/movieapp/movieapp_exception.dart';
import 'package:dashboard/features/movie/movieapp/movieapp_json.dart';
import 'package:dashboard/features/movie/movieapp/movieapp_list_result.dart';
import 'package:dashboard/features/movie/movieapp/movieapp_media_kind.dart';
import 'package:dashboard/features/movie/movieapp/movieapp_movie.dart';
import 'package:dashboard/features/movie/movieapp/movieapp_movie_detail.dart';
import 'package:dashboard/features/movie/movieapp/movieapp_video.dart';
import 'package:dio/dio.dart';

/// TMDb client over the host's `dio`.
///
/// Endpoints verified against the source (`libraries/core/lib/src/network/api/
/// api_service.dart`): `movie/now_playing`, `movie/upcoming`, `movie/popular`,
/// `discover/movie`, `tv/airing_today`, `tv/popular`, `tv/on_the_air`,
/// `movie/{id}/credits`, `movie/{id}/videos`, `tv/{id}/credits`,
/// `tv/{id}/videos`. The source had NO search, detail, similar or top-rated
/// call and never sent a `page` parameter; those are real TMDb endpoints added
/// to satisfy the browse/paging requirement, with TMDb's real query semantics.
class MovieAppApi {
  MovieAppApi({
    Dio? dio,
    String apiKey = defaultApiKey,
    String language = defaultLanguage,
  }) : _dio =
           dio ??
           Dio(
             BaseOptions(
               baseUrl: baseUrl,
               connectTimeout: const Duration(seconds: 10),
               receiveTimeout: const Duration(seconds: 20),
             ),
           ),
       _apiKey = apiKey,
       _language = language;

  static const String baseUrl = 'https://api.themoviedb.org/3/';
  static const String defaultApiKey = '24d18ef569e3997bf2779d05440d3c6e';
  static const String defaultLanguage = 'en-US';

  final Dio _dio;
  final String _apiKey;
  final String _language;

  Future<MovieAppListResult> nowPlaying({int page = 1}) =>
      _list('movie/now_playing', MovieAppMediaKind.movie, page);

  Future<MovieAppListResult> upcoming({int page = 1}) =>
      _list('movie/upcoming', MovieAppMediaKind.movie, page);

  Future<MovieAppListResult> popular({int page = 1}) =>
      _list('movie/popular', MovieAppMediaKind.movie, page);

  Future<MovieAppListResult> topRated({int page = 1}) =>
      _list('movie/top_rated', MovieAppMediaKind.movie, page);

  Future<MovieAppListResult> discover({int page = 1}) =>
      _list('discover/movie', MovieAppMediaKind.movie, page);

  Future<MovieAppListResult> tvOnTheAir({int page = 1}) =>
      _list('tv/on_the_air', MovieAppMediaKind.tv, page);

  Future<MovieAppListResult> tvAiringToday({int page = 1}) =>
      _list('tv/airing_today', MovieAppMediaKind.tv, page);

  Future<MovieAppListResult> tvPopular({int page = 1}) =>
      _list('tv/popular', MovieAppMediaKind.tv, page);

  /// TMDb `search/movie`; throws [ArgumentError] on a blank query so no
  /// pointless request is issued.
  Future<MovieAppListResult> search(String query, {int page = 1}) {
    final value = query.trim();
    if (value.isEmpty) throw ArgumentError('搜索关键词不能为空');
    return _list(
      'search/movie',
      MovieAppMediaKind.movie,
      page,
      extra: {'query': value},
    );
  }

  Future<MovieAppMovieDetail> detailOf(MovieAppMovie movie) =>
      movie.kind.isMovie ? movieDetail(movie.id) : tvDetail(movie.id);

  Future<MovieAppMovieDetail> movieDetail(int movieId) async =>
      MovieAppMovieDetail.fromJson(
        await _getJson('movie/$movieId'),
        kind: MovieAppMediaKind.movie,
      );

  Future<MovieAppMovieDetail> tvDetail(int tvId) async =>
      MovieAppMovieDetail.fromJson(
        await _getJson('tv/$tvId'),
        kind: MovieAppMediaKind.tv,
      );

  Future<MovieAppCredits> creditsOf(MovieAppMovie movie) async =>
      MovieAppCredits.fromJson(
        await _getJson('${movie.kind.webPath}/${movie.id}/credits'),
      );

  Future<List<MovieAppVideo>> videosOf(MovieAppMovie movie) async {
    final json = await _getJson('${movie.kind.webPath}/${movie.id}/videos');
    return MovieAppJson.asMapList(
      json['results'],
    ).map(MovieAppVideo.fromJson).toList();
  }

  Future<MovieAppListResult> similarOf(MovieAppMovie movie, {int page = 1}) =>
      _list('${movie.kind.webPath}/${movie.id}/similar', movie.kind, page);

  void dispose() => _dio.close();

  Future<MovieAppListResult> _list(
    String path,
    MovieAppMediaKind kind,
    int page, {
    Map<String, dynamic>? extra,
  }) async {
    final json = await _getJson(path, {'page': page, ...?extra});
    return MovieAppListResult.fromJson(json, kind: kind);
  }

  Future<Map<String, dynamic>> _getJson(
    String path, [
    Map<String, dynamic> query = const {},
  ]) async {
    final Response<dynamic> response;
    try {
      response = await _dio.get<dynamic>(
        path,
        queryParameters: {...query, 'api_key': _apiKey, 'language': _language},
      );
    } on DioException catch (error) {
      throw MovieAppException(
        _messageFor(error),
        statusCode: error.response?.statusCode,
      );
    }
    final status = response.statusCode;
    final data = response.data;
    if (data is Map) {
      final json = data.map((key, value) => MapEntry(key.toString(), value));
      final statusCode = int.tryParse('${json['status_code'] ?? ''}');
      if (json['success'] == false ||
          (statusCode != null && statusCode >= 400)) {
        final message = MovieAppJson.asString(json['status_message']).trim();
        throw MovieAppException(
          message.isEmpty ? 'TMDb 请求失败' : message,
          statusCode: statusCode ?? status,
        );
      }
      // A short-circuited response never reaches Dio's own status validation.
      if (status != null && (status < 200 || status >= 300)) {
        throw MovieAppException('请求失败：HTTP $status', statusCode: status);
      }
      return json;
    }
    if (status != null && (status < 200 || status >= 300)) {
      throw MovieAppException('请求失败：HTTP $status', statusCode: status);
    }
    throw const MovieAppException('TMDb 返回的数据格式无法解析');
  }

  String _messageFor(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return '网络连接失败，请检查网络后重试';
      case DioExceptionType.badResponse:
        final code = error.response?.statusCode;
        return code == null ? '请求失败，请稍后重试' : '请求失败：HTTP $code';
      case DioExceptionType.cancel:
        return '请求已取消';
      case DioExceptionType.badCertificate:
        return '证书校验失败';
      case DioExceptionType.unknown:
      default:
        return error.message ?? '网络请求失败';
    }
  }
}
