import 'dart:convert';

import 'package:dashboard/features/movie/movieapp/movieapp_api.dart';
import 'package:dashboard/features/movie/movieapp/movieapp_exception.dart';
import 'package:dashboard/features/movie/movieapp/movieapp_genres.dart';
import 'package:dashboard/features/movie/movieapp/movieapp_image.dart';
import 'package:dashboard/features/movie/movieapp/movieapp_media_kind.dart';
import 'package:dashboard/features/movie/movieapp/movieapp_movie.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Realistic TMDb payloads (shapes copied from api.themoviedb.org responses).
const String _nowPlayingJson = r'''
{"page":1,"results":[{"adult":false,"backdrop_path":"/bslXG4B5Qj6vN9VdQv9O8vX8m6p.jpg","genre_ids":[28,12],"id":338762,"original_language":"en","original_title":"Bloodshot","overview":"After he and his wife are murdered, Marine Ray Garrison is resurrected by a team of scientists.","popularity":1234.567,"poster_path":"/8WUVHemHFH2ZIP6NWd0E5r4KSUU.jpg","release_date":"2020-03-05","title":"Bloodshot","video":false,"vote_average":7.2,"vote_count":4321}],"total_pages":500,"total_results":10000}
''';

const String _detailJson = r'''
{"adult":false,"backdrop_path":"/bslXG4B5Qj6vN9VdQv9O8vX8m6p.jpg","budget":45000000,"genres":[{"id":28,"name":"Action"},{"id":12,"name":"Adventure"},{"id":878,"name":"Science Fiction"}],"homepage":"https://www.sonypictures.com/movies/bloodshot","id":338762,"imdb_id":"tt0490210","original_language":"en","original_title":"Bloodshot","overview":"After he and his wife are murdered...","popularity":1234.567,"poster_path":"/8WUVHemHFH2ZIP6NWd0E5r4KSUU.jpg","release_date":"2020-03-05","revenue":0,"runtime":109,"status":"Released","tagline":"Being a hero is in his blood.","title":"Bloodshot","video":false,"vote_average":7.2,"vote_count":4321}
''';

const String _creditsJson = r'''
{"id":338762,"cast":[{"adult":false,"cast_id":1,"character":"Ray Garrison / Bloodshot","credit_id":"5e2c","gender":2,"id":12835,"known_for_department":"Acting","name":"Vin Diesel","order":0,"original_name":"Vin Diesel","popularity":30.5,"profile_path":"/3n8X8sM5x8T1x8Y8x8.jpg"},{"adult":false,"cast_id":2,"character":"KT","credit_id":"5e2d","gender":1,"id":1813,"known_for_department":"Acting","name":"Eiza Gonzalez","order":1,"original_name":"Eiza Gonzalez","popularity":18.2,"profile_path":"/abc.jpg"}]}
''';

const String _searchJson = r'''
{"page":2,"results":[{"adult":false,"backdrop_path":null,"genre_ids":[18],"id":550,"original_title":"Fight Club","overview":"A ticking-time-bomb insomniac...","popularity":60.1,"poster_path":null,"release_date":"1999-10-15","title":"Fight Club","video":false,"vote_average":8.4,"vote_count":26000}],"total_pages":5,"total_results":97}
''';

Response<dynamic> _json(Object data, RequestOptions options) =>
    Response<dynamic>(requestOptions: options, statusCode: 200, data: data);

Dio _fakeDio(Response<dynamic> Function(RequestOptions options) respond) {
  final dio = Dio(BaseOptions(baseUrl: MovieAppApi.baseUrl));
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) => handler.resolve(respond(options)),
    ),
  );
  return dio;
}

void main() {
  group('list mapping', () {
    test(
      'maps a real TMDb now_playing response and keeps paging metadata',
      () async {
        RequestOptions? seen;
        final api = MovieAppApi(
          dio: _fakeDio((options) {
            seen = options;
            return _json(jsonDecode(_nowPlayingJson), options);
          }),
        );
        addTearDown(api.dispose);

        final result = await api.nowPlaying();

        expect(seen!.path, 'movie/now_playing');
        expect(seen!.queryParameters['page'], 1);
        expect(seen!.queryParameters['api_key'], MovieAppApi.defaultApiKey);
        expect(seen!.queryParameters['language'], 'en-US');
        expect(result.page, 1);
        expect(result.totalPages, 500);
        expect(result.totalResults, 10000);
        expect(result.isEmpty, isFalse);

        final movie = result.results.single;
        expect(movie.id, 338762);
        expect(movie.title, 'Bloodshot');
        expect(movie.originalTitle, 'Bloodshot');
        expect(movie.overview, contains('Ray Garrison'));
        expect(movie.releaseDate, '2020-03-05');
        expect(movie.year, '2020');
        expect(movie.genreIds, [28, 12]);
        expect(movie.voteAverage, 7.2);
        expect(movie.voteCount, 4321);
        expect(movie.popularity, 1234.567);
        expect(movie.posterPath, '/8WUVHemHFH2ZIP6NWd0E5r4KSUU.jpg');
        expect(movie.kind, MovieAppMediaKind.movie);
      },
    );

    test(
      'maps a real TMDb movie detail response with genres and runtime',
      () async {
        final api = MovieAppApi(
          dio: _fakeDio((options) => _json(jsonDecode(_detailJson), options)),
        );
        addTearDown(api.dispose);

        final detail = await api.movieDetail(338762);

        expect(detail.id, 338762);
        expect(detail.title, 'Bloodshot');
        expect(detail.runtime, 109);
        expect(detail.runtimeLabel, '1h 49min');
        expect(detail.tagline, 'Being a hero is in his blood.');
        expect(detail.status, 'Released');
        expect(detail.genres.map((genre) => genre.name), [
          'Action',
          'Adventure',
          'Science Fiction',
        ]);
        expect(detail.imdbId, 'tt0490210');
        expect(detail.voteAverage, 7.2);
        expect(detail.kind, MovieAppMediaKind.movie);
      },
    );

    test(
      'maps the TV detail shape (name / first_air_date / episode_run_time)',
      () async {
        final api = MovieAppApi(
          dio: _fakeDio(
            (options) => _json({
              'id': 1399,
              'name': 'Game of Thrones',
              'first_air_date': '2011-04-17',
              'episode_run_time': [57],
              'number_of_seasons': 8,
              'number_of_episodes': 73,
              'genres': [
                {'id': 10765, 'name': 'Sci-Fi & Fantasy'},
              ],
              'vote_average': 8.4,
            }, options),
          ),
        );
        addTearDown(api.dispose);

        final detail = await api.tvDetail(1399);

        expect(detail.title, 'Game of Thrones');
        expect(detail.releaseDate, '2011-04-17');
        expect(detail.year, '2011');
        expect(detail.runtime, 57);
        expect(detail.runtimeLabel, '57 分钟');
        expect(detail.seasonCount, 8);
        expect(detail.episodeCount, 73);
        expect(detail.kind, MovieAppMediaKind.tv);
      },
    );

    test('empty results stay empty instead of throwing', () async {
      final api = MovieAppApi(
        dio: _fakeDio(
          (options) => _json({
            'page': 1,
            'results': <Object>[],
            'total_pages': 0,
            'total_results': 0,
          }, options),
        ),
      );
      addTearDown(api.dispose);

      final result = await api.topRated();

      expect(result.isEmpty, isTrue);
      expect(result.results, isEmpty);
      expect(result.totalPages, 0);
    });
  });

  group('credits and videos', () {
    test('maps cast and composes profile image urls', () async {
      RequestOptions? seen;
      final api = MovieAppApi(
        dio: _fakeDio((options) {
          seen = options;
          return _json(jsonDecode(_creditsJson), options);
        }),
      );
      addTearDown(api.dispose);
      const movie = MovieAppMovie(id: 338762, title: 'Bloodshot');

      final credits = await api.creditsOf(movie);

      expect(seen!.path, 'movie/338762/credits');
      expect(credits.cast.length, 2);
      expect(credits.cast.first.name, 'Vin Diesel');
      expect(credits.cast.first.character, 'Ray Garrison / Bloodshot');
      expect(credits.cast.first.order, 0);
      expect(
        credits.cast.first.profileUrl,
        'https://image.tmdb.org/t/p/w185/3n8X8sM5x8T1x8Y8x8.jpg',
      );
    });

    test('maps YouTube trailer videos to watch urls', () async {
      final api = MovieAppApi(
        dio: _fakeDio(
          (options) => _json({
            'id': 338762,
            'results': [
              {
                'id': '5e84',
                'iso_639_1': 'en',
                'key': 'KsWo3q3z8sE',
                'name': 'Official Trailer',
                'site': 'YouTube',
                'size': 1080,
                'type': 'Trailer',
                'official': true,
              },
            ],
          }, options),
        ),
      );
      addTearDown(api.dispose);
      const movie = MovieAppMovie(id: 338762, title: 'Bloodshot');

      final videos = await api.videosOf(movie);

      expect(videos.single.name, 'Official Trailer');
      expect(videos.single.isYouTube, isTrue);
      expect(videos.single.isTrailer, isTrue);
      expect(
        videos.single.watchUri.toString(),
        'https://www.youtube.com/watch?v=KsWo3q3z8sE',
      );
    });
  });

  group('image urls', () {
    test('composes the TMDb image base url with the original size', () {
      expect(
        MovieAppImage.url('/8WUVHemHFH2ZIP6NWd0E5r4KSUU.jpg'),
        'https://image.tmdb.org/t/p/original/8WUVHemHFH2ZIP6NWd0E5r4KSUU.jpg',
      );
    });

    test('honours the requested size', () {
      expect(
        MovieAppImage.url('/8WU.jpg', size: MovieAppImage.poster),
        'https://image.tmdb.org/t/p/w500/8WU.jpg',
      );
    });

    test('returns null for a missing poster_path or backdrop_path', () {
      expect(MovieAppImage.url(null), isNull);
      expect(MovieAppImage.url(''), isNull);
      expect(MovieAppImage.url('   '), isNull);

      final movie = MovieAppMovie.fromJson(
        jsonDecode(_searchJson)['results'][0],
      );
      expect(movie.posterPath, isNull);
      expect(movie.posterUrl, isNull);
      expect(movie.backdropUrl, isNull);
    });
  });

  group('request building', () {
    test('builds a paged list request with the real TMDb query', () async {
      RequestOptions? seen;
      final api = MovieAppApi(
        dio: _fakeDio((options) {
          seen = options;
          return _json(jsonDecode(_nowPlayingJson), options);
        }),
      );
      addTearDown(api.dispose);

      await api.popular(page: 3);

      expect(seen!.path, 'movie/popular');
      expect(seen!.uri.path, '/3/movie/popular');
      expect(seen!.queryParameters['page'], 3);
      expect(seen!.queryParameters['api_key'], MovieAppApi.defaultApiKey);
      expect(seen!.queryParameters['language'], 'en-US');
    });

    test('builds a search request with query and page', () async {
      final requests = <RequestOptions>[];
      final api = MovieAppApi(
        dio: _fakeDio((options) {
          requests.add(options);
          return _json(jsonDecode(_searchJson), options);
        }),
      );
      addTearDown(api.dispose);

      final result = await api.search('搏击俱乐部', page: 2);

      expect(requests.single.path, 'search/movie');
      expect(requests.single.queryParameters['query'], '搏击俱乐部');
      expect(requests.single.queryParameters['page'], 2);
      expect(
        requests.single.queryParameters['api_key'],
        MovieAppApi.defaultApiKey,
      );
      expect(result.page, 2);
      expect(result.totalPages, 5);
      expect(result.results.single.id, 550);
      expect(result.results.single.title, 'Fight Club');
      expect(result.results.single.voteAverage, 8.4);
    });

    test('search rejects a blank query without issuing a request', () {
      var called = false;
      final api = MovieAppApi(
        dio: _fakeDio((options) {
          called = true;
          return _json(const <Object>[], options);
        }),
      );
      addTearDown(api.dispose);

      expect(() => api.search('   '), throwsArgumentError);
      expect(called, isFalse);
    });

    test('uses the tv path for tv shows', () async {
      final paths = <String>[];
      final api = MovieAppApi(
        dio: _fakeDio((options) {
          paths.add(options.path);
          return _json({
            'page': 1,
            'results': <Object>[],
            'total_pages': 0,
            'total_results': 0,
          }, options);
        }),
      );
      addTearDown(api.dispose);

      await api.tvPopular(page: 4);

      expect(paths.single, 'tv/popular');
    });

    test('uses the discover path for the discover flow', () async {
      final paths = <String>[];
      final api = MovieAppApi(
        dio: _fakeDio((options) {
          paths.add(options.path);
          return _json(jsonDecode(_nowPlayingJson), options);
        }),
      );
      addTearDown(api.dispose);

      final result = await api.discover();

      expect(paths.single, 'discover/movie');
      expect(result.results.single.title, 'Bloodshot');
    });
  });

  group('errors', () {
    test('surfaces the real TMDb error payload as MovieAppException', () async {
      final api = MovieAppApi(
        dio: _fakeDio(
          (options) => _json({
            'status_code': 34,
            'status_message': 'The resource you requested could not be found.',
            'success': false,
          }, options),
        ),
      );
      addTearDown(api.dispose);

      await expectLater(
        api.movieDetail(1),
        throwsA(
          isA<MovieAppException>()
              .having((error) => error.statusCode, 'statusCode', 34)
              .having(
                (error) => error.message,
                'message',
                'The resource you requested could not be found.',
              ),
        ),
      );
    });

    test('maps an HTTP failure to a retryable message', () async {
      final dio = Dio(
        BaseOptions(baseUrl: MovieAppApi.baseUrl, validateStatus: (_) => true),
      );
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) => handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              statusCode: 401,
              data: const <String, dynamic>{},
            ),
          ),
        ),
      );
      final api = MovieAppApi(dio: dio);
      addTearDown(api.dispose);

      await expectLater(
        api.nowPlaying(),
        throwsA(
          isA<MovieAppException>()
              .having((error) => error.statusCode, 'statusCode', 401)
              .having((error) => error.message, 'message', '请求失败：HTTP 401'),
        ),
      );
    });

    test('maps a dropped connection to a network message', () async {
      final dio = Dio(BaseOptions(baseUrl: MovieAppApi.baseUrl));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) => handler.reject(
            DioException(
              requestOptions: options,
              type: DioExceptionType.connectionError,
              message: 'offline',
            ),
          ),
        ),
      );
      final api = MovieAppApi(dio: dio);
      addTearDown(api.dispose);

      await expectLater(
        api.nowPlaying(),
        throwsA(
          isA<MovieAppException>().having(
            (error) => error.message,
            'message',
            '网络连接失败，请检查网络后重试',
          ),
        ),
      );
    });
  });

  group('genre table', () {
    test('resolves the genre ids the list endpoints return', () {
      expect(MovieAppGenres.name(28), 'Action');
      expect(MovieAppGenres.name(878), 'Science Fiction');
      expect(MovieAppGenres.name(10765), 'Sci-Fi & Fantasy');
      expect(MovieAppGenres.name(999999), '');
    });
  });
}
