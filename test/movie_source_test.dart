import 'package:dashboard/features/movie/movie_source.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('movie source maps the original recommendation response', () async {
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          expect(options.uri.path, '/service/movie/getRecommend');
          expect(options.uri.queryParameters['classify'], '电影');
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: {
                'status': 'SUCCESS',
                'data': [
                  {
                    'id': 2,
                    'movieId': 300,
                    'movieName': '示例电影',
                    'img': '/poster.jpg',
                    'sourceUrl': 'https://example.com/play',
                  },
                ],
              },
            ),
          );
        },
      ),
    );
    final source = MovieSource(Uri.parse('https://movies.example'), dio: dio);
    final movie = (await source.recommendations('电影')).single;
    expect(movie.title, '示例电影');
    expect(movie.id, 2);
    expect(movie.serviceEndpoint.toString(), 'https://movies.example');
    expect(movie.poster.toString(), 'https://movies.example/poster.jpg');
    source.dispose();
  });

  test('loads selected movie episodes and preserves provider groups', () async {
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          expect(options.uri.path, '/service/movie/getMovieUrl');
          expect(options.uri.queryParameters['movieId'], '42');
          handler.resolve(
            Response(
              requestOptions: options,
              data: {
                'status': 'SUCCESS',
                'data': [
                  {'label': '第1集', 'playGroup': 'A', 'url': '/one.m3u8'},
                  {
                    'label': '第1集',
                    'playGroup': 'B',
                    'url': 'https://cdn.example/one.mp4',
                  },
                ],
              },
            ),
          );
        },
      ),
    );
    final source = MovieSource(Uri.parse('https://movies.example'), dio: dio);
    addTearDown(source.dispose);
    final episodes = await source.episodes(42);
    expect(episodes.map((e) => e.group), ['A', 'B']);
    expect(episodes.first.url.toString(), 'https://movies.example/one.m3u8');
  });
}
