import 'package:dashboard/features/movie/movie_item.dart';
import 'package:dashboard/features/movie/movie_episode.dart';
import 'package:dio/dio.dart';

/// Ports the recommendation/search endpoints of flutter-movie-app-ui.
class MovieSource {
  MovieSource(Uri endpoint, {Dio? dio})
    : _endpoint = endpoint,
      _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 20),
            ),
          );

  final Uri _endpoint;
  final Dio _dio;

  Future<List<MovieItem>> recommendations(String classify) =>
      _load('/service/movie/getRecommend', {'classify': classify});

  Future<List<MovieItem>> search(String keyword, {int page = 1}) => _load(
    '/service/movie/search',
    {'keyword': keyword, 'pageSize': 20, 'pageNum': page},
  );

  Future<List<MovieItem>> _load(String path, Map<String, dynamic> query) async {
    final rows = await _fetch(path, query);
    return rows
        .map((item) => MovieItem.fromJson(item, _endpoint))
        .where((item) => item.title.isNotEmpty)
        .toList();
  }

  Future<List<MovieEpisode>> episodes(int movieId) async {
    final rows = await _fetch('/service/movie/getMovieUrl', {
      'movieId': movieId,
    });
    return rows.map((item) => MovieEpisode.fromJson(item, _endpoint)).toList();
  }

  Future<List<Map<String, dynamic>>> _fetch(
    String path,
    Map<String, dynamic> query,
  ) async {
    if (!<String>['http', 'https'].contains(_endpoint.scheme)) {
      throw const FormatException('影视服务地址必须使用 HTTP/HTTPS');
    }
    final response = await _dio.get<dynamic>(
      _endpoint.resolve(path).toString(),
      queryParameters: query,
    );
    final envelope = response.data;
    if (envelope is! Map || envelope['status'] != 'SUCCESS') {
      throw FormatException(
        '影视服务返回错误：${envelope is Map ? envelope['msg'] ?? envelope['status'] : response.statusCode}',
      );
    }
    final data = envelope['data'];
    if (data is! List) throw const FormatException('影视服务数据格式错误');
    return data
        .whereType<Map>()
        .map(
          (item) => item.map((key, value) => MapEntry(key.toString(), value)),
        )
        .toList();
  }

  void dispose() => _dio.close();
}
