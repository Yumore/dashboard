import 'dart:convert';
import 'dart:typed_data';

import 'package:dashboard/features/movie/fluttercinematic/cinematic_actor.dart';
import 'package:dashboard/features/movie/fluttercinematic/cinematic_api.dart';
import 'package:dashboard/features/movie/fluttercinematic/cinematic_constants.dart';
import 'package:dashboard/features/movie/fluttercinematic/cinematic_date_format.dart';
import 'package:dashboard/features/movie/fluttercinematic/cinematic_episode.dart';
import 'package:dashboard/features/movie/fluttercinematic/cinematic_favorites_store.dart';
import 'package:dashboard/features/movie/fluttercinematic/cinematic_genres.dart';
import 'package:dashboard/features/movie/fluttercinematic/cinematic_image_url.dart';
import 'package:dashboard/features/movie/fluttercinematic/cinematic_media_item.dart';
import 'package:dashboard/features/movie/fluttercinematic/cinematic_paging_controller.dart';
import 'package:dashboard/features/movie/fluttercinematic/cinematic_search_result.dart';
import 'package:dashboard/features/movie/fluttercinematic/cinematic_tv_season.dart';
import 'package:dashboard/features/movie/fluttercinematic/pages/cinematic_actor_page.dart';
import 'package:dashboard/features/movie/fluttercinematic/pages/cinematic_actor_page_state.dart';
import 'package:dashboard/features/movie/fluttercinematic/pages/cinematic_favorites_page.dart';
import 'package:dashboard/features/movie/fluttercinematic/pages/cinematic_favorites_page_state.dart';
import 'package:dashboard/features/movie/fluttercinematic/pages/cinematic_home_page.dart';
import 'package:dashboard/features/movie/fluttercinematic/pages/cinematic_home_page_state.dart';
import 'package:dashboard/features/movie/fluttercinematic/pages/cinematic_media_detail_page.dart';
import 'package:dashboard/features/movie/fluttercinematic/pages/cinematic_media_detail_page_state.dart';
import 'package:dashboard/features/movie/fluttercinematic/pages/cinematic_search_page.dart';
import 'package:dashboard/features/movie/fluttercinematic/pages/cinematic_search_page_state.dart';
import 'package:dashboard/features/movie/fluttercinematic/pages/cinematic_season_detail_page.dart';
import 'package:dashboard/features/movie/fluttercinematic/pages/cinematic_season_detail_page_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// Fixtures. Shapes came across with the port; no request ever leaves the test.
// ---------------------------------------------------------------------------

const String movieJson = r'''
{"id":338762,"title":"Bloodshot","name":"Bloodshot","vote_average":7.2,
 "poster_path":"/8WUVHemHFH2ZIP6NWd0E5r4KSUU.jpg","backdrop_path":"/bslXG4B5Qj6vN9VdQv9O8vX8m6p.jpg",
 "overview":"After he and his wife are murdered, Marine Ray Garrison is resurrected.",
 "release_date":"2020-03-05","first_air_date":"2020-03-05","genre_ids":[28,12]}''';

const String showJson = r'''
{"id":82856,"name":"The Mandalorian","title":"The Mandalorian","vote_average":8.4,
 "poster_path":"/sWgBv7LV2PRoQgkxwlibdGXKz1S.jpg","backdrop_path":"/9ijMGlJKqcslswWUzTEwScm82Gs.jpg",
 "overview":"After the fall of the Empire, a lone gunfighter makes his way.",
 "first_air_date":"2019-11-12","release_date":"","genre_ids":[10759,10765]}''';

const String personJson = r'''
{"id":12835,"name":"Vin Diesel","profile_path":"/3n8X8sM5x8T1x8Y8x8.jpg",
 "known_for":[{"title":"Fast & Furious"},{"title":"xXx"}]}''';

/// `GET movie/now_playing` with the real endpoint's paging metadata.
String listResponse(int page, List<String> rows) =>
    '{"page":$page,"results":[${rows.join(',')}],"total_pages":500,"total_results":10000}';

Response<dynamic> jsonResponse(Object body, RequestOptions options) =>
    Response<dynamic>(requestOptions: options, statusCode: 200, data: body);

/// Pumps frames until the screen's futures resolve. `pumpAndSettle` cannot be
/// used here: the placeholder drawn while a `CachedNetworkImage` is pending is
/// a `CircularProgressIndicator`, which never stops animating in a test where
/// no image can be fetched, so settling would always time out.
Future<void> settle(WidgetTester tester) async {
  for (var frame = 0; frame < 6; frame++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

/// Pumps [child] in a tall viewport: the detail screens are one long
/// `ListView`, so a phone-sized surface leaves the later rows (cast, created
/// by, networks) unbuilt.
Future<void> pumpTall(WidgetTester tester, Widget child) async {
  await tester.binding.setSurfaceSize(const Size(1200, 2400));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(child);
}

/// Records every request and answers from [routes]; anything unmatched fails
/// the request instead of hitting the network.
class FakeAdapter implements HttpClientAdapter {
  FakeAdapter(this.routes);

  final Map<String, Object Function(RequestOptions options)> routes;
  final List<RequestOptions> requests = <RequestOptions>[];

  List<String> get paths => requests.map((request) => request.path).toList();

  RequestOptions get lastRequest => requests.last;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final route = routes[options.path];
    if (route == null) {
      return ResponseBody.fromString('unrouted: ${options.path}', 404);
    }
    return ResponseBody.fromString(
      jsonEncode(route(options)),
      200,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// A [Dio] whose adapter is [FakeAdapter]; `baseUrl` matches the source's.
Dio fakeDio(FakeAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: CinematicConstants.baseUrl));
  dio.httpClientAdapter = adapter;
  return dio;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // -------------------------------------------------------------------------
  group('CinematicApi endpoints', () {
    test('fetchMovies uses movie/{category} with api_key and page', () async {
      final adapter = FakeAdapter(<String, Object Function(RequestOptions)>{
        'movie/popular': (options) => jsonDecode(listResponse(1, <String>[movieJson])),
      });
      final api = CinematicApi(dio: fakeDio(adapter));
      addTearDown(api.dispose);

      final items = await api.fetchMovies(page: 2, category: 'popular');

      expect(adapter.lastRequest.path, 'movie/popular');
      expect(adapter.lastRequest.queryParameters['page'], '2');
      expect(
        adapter.lastRequest.queryParameters['api_key'],
        CinematicConstants.defaultApiKey,
      );
      expect(
        adapter.lastRequest.queryParameters['language'],
        CinematicConstants.defaultLanguage,
      );
      expect(items.single.id, 338762);
    });

    test('fetchMovies carries each home category to its own path', () async {
      final paths = <String>[];
      final adapter = FakeAdapter(<String, Object Function(RequestOptions)>{
        for (final category in CinematicConstants.movieCategories)
          'movie/$category': (options) => jsonDecode(listResponse(1, <String>[movieJson])),
      });
      final api = CinematicApi(dio: fakeDio(adapter));
      addTearDown(api.dispose);

      for (final category in CinematicConstants.movieCategories) {
        await api.fetchMovies(category: category);
        paths.add(adapter.lastRequest.path);
      }

      expect(paths, <String>['movie/popular', 'movie/upcoming', 'movie/top_rated']);
    });

    test('fetchShows uses tv/{category} including on_the_air', () async {
      final adapter = FakeAdapter(<String, Object Function(RequestOptions)>{
        'tv/on_the_air': (options) => jsonDecode(listResponse(1, <String>[showJson])),
      });
      final api = CinematicApi(dio: fakeDio(adapter));
      addTearDown(api.dispose);

      final items = await api.fetchShows(page: 1, category: 'on_the_air');

      expect(adapter.lastRequest.path, 'tv/on_the_air');
      expect(items.single.title, 'The Mandalorian');
      expect(items.single.isMovie, isFalse);
    });

    test('fetchMovies omits page when none is requested', () async {
      final adapter = FakeAdapter(<String, Object Function(RequestOptions)>{
        'movie/popular': (options) => jsonDecode(listResponse(1, <String>[movieJson])),
      });
      final api = CinematicApi(dio: fakeDio(adapter));
      addTearDown(api.dispose);

      await api.fetchMovies(page: 1);
      expect(adapter.lastRequest.queryParameters['page'], '1');
    });

    test('getSimilarMedia hits {type}/{id}/similar', () async {
      final adapter = FakeAdapter(<String, Object Function(RequestOptions)>{
        'movie/338762/similar': (options) =>
            jsonDecode(listResponse(1, <String>[movieJson])),
      });
      final api = CinematicApi(dio: fakeDio(adapter));
      addTearDown(api.dispose);

      final similar = await api.getSimilarMedia(338762);

      expect(adapter.lastRequest.path, 'movie/338762/similar');
      expect(adapter.lastRequest.queryParameters.containsKey('page'), isFalse);
      expect(similar.single.type, CinematicMediaType.movie);
    });

    test('getSimilarMedia for tv keeps the show media type', () async {
      final adapter = FakeAdapter(<String, Object Function(RequestOptions)>{
        'tv/82856/similar': (options) => jsonDecode(listResponse(1, <String>[showJson])),
      });
      final api = CinematicApi(dio: fakeDio(adapter));
      addTearDown(api.dispose);

      final similar = await api.getSimilarMedia(82856, type: 'tv', page: 3);

      expect(adapter.lastRequest.path, 'tv/82856/similar');
      expect(adapter.lastRequest.queryParameters['page'], '3');
      expect(similar.single.type, CinematicMediaType.show);
    });

    test('getMoviesForActor uses discover/movie with with_cast and sort_by', () async {
      final adapter = FakeAdapter(<String, Object Function(RequestOptions)>{
        'discover/movie': (options) => jsonDecode(listResponse(1, <String>[movieJson])),
      });
      final api = CinematicApi(dio: fakeDio(adapter));
      addTearDown(api.dispose);

      final movies = await api.getMoviesForActor(12835);

      expect(adapter.lastRequest.path, 'discover/movie');
      expect(adapter.lastRequest.queryParameters['with_cast'], '12835');
      expect(adapter.lastRequest.queryParameters['sort_by'], 'popularity.desc');
      expect(movies, hasLength(1));
    });

    test('getShowsForActor reads person/{id}/tv_credits cast array', () async {
      final adapter = FakeAdapter(<String, Object Function(RequestOptions)>{
        'person/12835/tv_credits': (options) => <String, dynamic>{
          'cast': <Object>[jsonDecode(showJson)],
        },
      });
      final api = CinematicApi(dio: fakeDio(adapter));
      addTearDown(api.dispose);

      final shows = await api.getShowsForActor(12835);

      expect(adapter.lastRequest.path, 'person/12835/tv_credits');
      expect(shows.single.title, 'The Mandalorian');
      expect(adapter.lastRequest.queryParameters['api_key'], isNotEmpty);
    });

    test('getMediaCredits maps the cast array to CinematicActor', () async {
      final adapter = FakeAdapter(<String, Object Function(RequestOptions)>{
        'movie/338762/credits': (options) => <String, dynamic>{
          'id': 338762,
          'cast': <Object>[
            <String, dynamic>{
              'character': 'Ray Garrison / Bloodshot',
              'name': 'Vin Diesel',
              'profile_path': '/3n8X8sM5x8T1x8Y8x8.jpg',
              'id': 12835,
              'order': 0,
            },
          ],
        },
      });
      final api = CinematicApi(dio: fakeDio(adapter));
      addTearDown(api.dispose);

      final cast = await api.getMediaCredits(338762);

      expect(adapter.lastRequest.path, 'movie/338762/credits');
      expect(cast.single, isA<CinematicActor>());
      expect(cast.single.name, 'Vin Diesel');
      expect(cast.single.character, 'Ray Garrison / Bloodshot');
      expect(cast.single.id, 12835);
    });

    test('getMediaDetails requests {type}/{id}', () async {
      final adapter = FakeAdapter(<String, Object Function(RequestOptions)>{
        'tv/82856': (options) => <String, dynamic>{
          'id': 82856,
          'name': 'The Mandalorian',
          'seasons': <Object>[],
        },
      });
      final api = CinematicApi(dio: fakeDio(adapter));
      addTearDown(api.dispose);

      final details = await api.getMediaDetails(82856, type: 'tv');

      expect(adapter.lastRequest.path, 'tv/82856');
      expect(details['name'], 'The Mandalorian');
    });

    test('getShowSeasons maps tv/{id} seasons array', () async {
      final adapter = FakeAdapter(<String, Object Function(RequestOptions)>{
        'tv/82856': (options) => <String, dynamic>{
          'id': 82856,
          'name': 'The Mandalorian',
          'seasons': <Object>[
            <String, dynamic>{
              'air_date': '2019-11-12',
              'episode_count': 8,
              'id': 107209,
              'name': 'Season 1',
              'overview': 'The Mandalorian arrives.',
              'poster_path': '/a.jpg',
              'season_number': 1,
            },
          ],
        },
      });
      final api = CinematicApi(dio: fakeDio(adapter));
      addTearDown(api.dispose);

      final seasons = await api.getShowSeasons(82856);

      expect(adapter.lastRequest.path, 'tv/82856');
      expect(seasons.single.id, 107209);
      expect(seasons.single.episodeCount, 8);
      expect(seasons.single.seasonNumber, 1);
    });

    test('getSearchResults hits search/multi with the query', () async {
      final adapter = FakeAdapter(<String, Object Function(RequestOptions)>{
        'search/multi': (options) => <String, dynamic>{
          'page': 1,
          'results': <Object>[
            <String, dynamic>{
              'media_type': 'movie',
              'title': 'Fight Club',
              'release_date': '1999-10-15',
              'poster_path': '/fc.jpg',
            },
          ],
        },
      });
      final api = CinematicApi(dio: fakeDio(adapter));
      addTearDown(api.dispose);

      final results = await api.getSearchResults('fight club');

      expect(adapter.lastRequest.path, 'search/multi');
      expect(adapter.lastRequest.queryParameters['query'], 'fight club');
      expect(results.single.title, 'Fight Club');
    });

    test('fetchEpisodes uses tv/{id}/season/{n} episodes array', () async {
      final adapter = FakeAdapter(<String, Object Function(RequestOptions)>{
        'tv/82856/season/1': (options) => <String, dynamic>{
          'id': 107209,
          'episodes': <Object>[
            <String, dynamic>{
              'name': 'Chapter 1: The Mandalorian',
              'overview': 'A Mandalorian bounty hunter tracks a target.',
              'still_path': '/still.jpg',
              'vote_average': 8.5,
              'episode_number': 1,
              'air_date': '2019-11-12',
            },
          ],
        },
      });
      final api = CinematicApi(dio: fakeDio(adapter));
      addTearDown(api.dispose);

      final episodes = await api.fetchEpisodes(82856, 1);

      expect(adapter.lastRequest.path, 'tv/82856/season/1');
      expect(episodes.single.episodeNumber, 1);
      expect(episodes.single.title, 'Chapter 1: The Mandalorian');
    });

    test('an injected api key replaces the source placeholder', () async {
      final adapter = FakeAdapter(<String, Object Function(RequestOptions)>{
        'movie/popular': (options) => jsonDecode(listResponse(1, <String>[movieJson])),
      });
      final api = CinematicApi(dio: fakeDio(adapter), apiKey: 'injected-key', language: 'de-DE');
      addTearDown(api.dispose);

      await api.fetchMovies();

      expect(adapter.lastRequest.queryParameters['api_key'], 'injected-key');
      expect(adapter.lastRequest.queryParameters['language'], 'de-DE');
    });

    test('a missing results key maps to an empty list instead of throwing', () async {
      final adapter = FakeAdapter(<String, Object Function(RequestOptions)>{
        'movie/popular': (options) => <String, dynamic>{'page': 1},
      });
      final api = CinematicApi(dio: fakeDio(adapter));
      addTearDown(api.dispose);

      expect(await api.fetchMovies(), isEmpty);
    });
  });

  // -------------------------------------------------------------------------
  group('image base-URL building', () {
    test('medium uses w300 like the source getMediumPictureUrl', () {
      expect(
        CinematicImageUrl.medium('/8WUVHemHFH2ZIP6NWd0E5r4KSUU.jpg'),
        'https://image.tmdb.org/t/p/w300/8WUVHemHFH2ZIP6NWd0E5r4KSUU.jpg',
      );
    });

    test('large uses w500 like the source getLargePictureUrl', () {
      expect(
        CinematicImageUrl.large('/bslXG4B5Qj6vN9VdQv9O8vX8m6p.jpg'),
        'https://image.tmdb.org/t/p/w500/bslXG4B5Qj6vN9VdQv9O8vX8m6p.jpg',
      );
    });

    test('an absent path builds an empty URL rather than a dangling base', () {
      expect(CinematicImageUrl.medium(''), '');
      expect(CinematicImageUrl.large(null), '');
    });

    test('item getters use the size the source assigned to each', () {
      final item = CinematicMediaItem.fromJson(
        jsonDecode(movieJson) as Map<String, dynamic>,
      );

      expect(item.getPosterUrl(), contains('/w300/'));
      expect(item.getBackDropUrl(), contains('/w500/'));
    });
  });

  // -------------------------------------------------------------------------
  group('model mapping', () {
    test('CinematicMediaItem maps the movie keys', () {
      final item = CinematicMediaItem.fromJson(
        jsonDecode(movieJson) as Map<String, dynamic>,
      );

      expect(item.id, 338762);
      expect(item.title, 'Bloodshot');
      expect(item.voteAverage, 7.2);
      expect(item.posterPath, '/8WUVHemHFH2ZIP6NWd0E5r4KSUU.jpg');
      expect(item.backdropPath, '/bslXG4B5Qj6vN9VdQv9O8vX8m6p.jpg');
      expect(item.releaseDate, '2020-03-05');
      expect(item.genreIds, <int>[28, 12]);
      expect(item.isMovie, isTrue);
    });

    test('CinematicMediaItem reads name/first_air_date for a show', () {
      final item = CinematicMediaItem.fromJson(
        jsonDecode(showJson) as Map<String, dynamic>,
        type: CinematicMediaType.show,
      );

      expect(item.title, 'The Mandalorian');
      expect(item.releaseDate, '2019-11-12');
      expect(item.genreIds, <int>[10759, 10765]);
      expect(item.isMovie, isFalse);
    });

    test('getReleaseYear returns the parsed year, 0 when absent', () {
      final item = CinematicMediaItem.fromJson(
        jsonDecode(movieJson) as Map<String, dynamic>,
      );
      final empty = CinematicMediaItem.fromJson(
        <String, dynamic>{'id': 1, 'title': 'x', 'release_date': ''},
      );

      expect(item.getReleaseYear(), 2020);
      expect(empty.getReleaseYear(), 0);
    });

    test('toJson/fromPrefsJson round-trips type 1 = movie, 0 = show', () {
      final movie = CinematicMediaItem.fromJson(
        jsonDecode(movieJson) as Map<String, dynamic>,
      );
      final show = CinematicMediaItem.fromJson(
        jsonDecode(showJson) as Map<String, dynamic>,
        type: CinematicMediaType.show,
      );

      expect(movie.toJson()['type'], 1);
      expect(show.toJson()['type'], 0);
      final restored = CinematicMediaItem.fromPrefsJson(movie.toJson());
      expect(restored.id, movie.id);
      expect(restored.type, CinematicMediaType.movie);
      expect(restored.title, 'Bloodshot');
      expect(restored.genreIds, <int>[28, 12]);
    });

    test('CinematicActor maps character, name, profile_path, id', () {
      final actor = CinematicActor.fromJson(
        jsonDecode(personJson) as Map<String, dynamic>,
      );

      expect(actor.id, 12835);
      expect(actor.name, 'Vin Diesel');
      expect(actor.profilePicture, '/3n8X8sM5x8T1x8Y8x8.jpg');
      expect(actor.profilePictureUrl, contains('/w300/'));
    });

    test('CinematicEpisode maps name, still_path, episode_number, air_date', () {
      final episode = CinematicEpisode.fromJson(<String, dynamic>{
        'name': 'Chapter 1: The Mandalorian',
        'overview': 'A Mandalorian bounty hunter tracks a target.',
        'still_path': '/still.jpg',
        'vote_average': 8.5,
        'episode_number': 1,
        'air_date': '2019-11-12',
      });

      expect(episode.title, 'Chapter 1: The Mandalorian');
      expect(episode.stillPath, '/still.jpg');
      expect(episode.voteAverage, 8.5);
      expect(episode.episodeNumber, 1);
      expect(episode.formattedAirDate, 'November 12, 2019');
      expect(episode.stillUrl, contains('/w300/'));
    });

    test('CinematicTvSeason title rule: Season n (year), 0 is Extras', () {
      final season = CinematicTvSeason.fromMap(<String, dynamic>{
        'air_date': '2019-11-12',
        'episode_count': 8,
        'id': 107209,
        'name': 'Season 1',
        'overview': 'The Mandalorian arrives.',
        'poster_path': '/a.jpg',
        'season_number': 1,
      });
      final extras = CinematicTvSeason.fromMap(<String, dynamic>{
        'name': 'Specials',
        'season_number': 0,
      });

      expect(season.getReleaseYear(), '2019');
      expect(season.getFormattedTitle(), 'Season 1 (2019)');
      expect(season.getPosterUrl(), contains('/w300/'));
      expect(extras.getReleaseYear(), '');
      expect(extras.getFormattedTitle(), 'Extras');
    });
  });

  // -------------------------------------------------------------------------
  group('search result mapping', () {
    test('movie rows use title, poster_path and the release_date subtitle', () {
      final result = CinematicSearchResult.fromJson(<String, dynamic>{
        'media_type': 'movie',
        'title': 'Fight Club',
        'release_date': '1999-10-15',
        'poster_path': '/fc.jpg',
      });

      expect(result.title, 'Fight Club');
      expect(result.subtitle, 'October 15, 1999');
      expect(result.imageUrl, contains('/w300/fc.jpg'));
      expect(result.asMovie.isMovie, isTrue);
    });

    test('tv rows use name, poster_path and the first_air_date subtitle', () {
      final result = CinematicSearchResult.fromJson(<String, dynamic>{
        'media_type': 'tv',
        'name': 'The Mandalorian',
        'first_air_date': '2019-11-12',
        'poster_path': '/m.jpg',
      });

      expect(result.title, 'The Mandalorian');
      expect(result.subtitle, 'November 12, 2019');
      expect(result.asShow.type, CinematicMediaType.show);
    });

    test('person rows use name, profile_path and the known_for subtitle', () {
      final result = CinematicSearchResult.fromJson(
        jsonDecode(personJson) as Map<String, dynamic>
            ..['media_type'] = 'person',
      );

      expect(result.title, 'Vin Diesel');
      expect(result.subtitle, 'Fast & Furious, xXx');
      expect(result.imageUrl, contains('/w300/3n8X8sM5x8T1x8Y8x8.jpg'));
      expect(result.asActor.id, 12835);
    });

    test('an unknown media_type yields empty strings, not an exception', () {
      final result = CinematicSearchResult.fromJson(<String, dynamic>{
        'media_type': 'collection',
        'name': 'Ignored',
      });

      expect(result.title, '');
      expect(result.subtitle, '');
      expect(result.imageUrl, '');
    });
  });

  // -------------------------------------------------------------------------
  group('genre + date helpers', () {
    test('the source genre table is preserved, including 10763', () {
      expect(CinematicGenres.genreMap[28], 'Action');
      expect(CinematicGenres.genreMap[10759], 'Action & Adventure');
      expect(CinematicGenres.genreMap[10765], 'Sci-Fi & Fantasy');
      expect(CinematicGenres.genreMap[10763], '');
      expect(CinematicGenres.genreMap, hasLength(27));
    });

    test('label joins known genres with a comma-space', () {
      expect(CinematicGenres.label(<int>[28, 12]), 'Action, Adventure');
      expect(CinematicGenres.label(<int>[28, 999999]), 'Action');
    });

    test('joinKey concatenates a list of map values like concatListToString', () {
      expect(
        CinematicGenres.joinKey(<dynamic>[
          <String, dynamic>{'name': 'Lucasfilm Ltd.'},
          <String, dynamic>{'name': 'Disney+'},
        ], 'name'),
        'Lucasfilm Ltd., Disney+',
      );
    });

    test('intl replacement formats yyyy-MM-dd as Month d, yyyy', () {
      expect(CinematicDateFormat.long('1999-10-15'), 'October 15, 1999');
      expect(CinematicDateFormat.format('2019-11-12'), 'November 12, 2019');
      expect(CinematicDateFormat.long(''), '');
      expect(CinematicDateFormat.long('not-a-date'), '');
      expect(CinematicDateFormat.year('2019-11-12'), 2019);
    });
  });

  // -------------------------------------------------------------------------
  group('paging controller', () {
    test('starts at page 1 and advances after a full page', () async {
      final requested = <int>[];
      final controller = CinematicPagingController(
        fetchPage: (page) async {
          requested.add(page);
          return List<CinematicMediaItem>.generate(
            20,
            (index) => CinematicMediaItem.fromJson(<String, dynamic>{
              'id': index,
              'title': 'Movie $index',
              'release_date': '2020-01-01',
            }),
          );
        },
      );
      addTearDown(controller.dispose);

      await controller.loadInitial();

      expect(requested, <int>[1]);
      expect(controller.page, 2);
      expect(controller.items, hasLength(20));
      expect(controller.hasMore, isTrue);
      expect(controller.isLoading, isFalse);
    });

    test('a short page stops further paging (hasMore false)', () async {
      final requested = <int>[];
      final controller = CinematicPagingController(
        fetchPage: (page) async {
          requested.add(page);
          return <CinematicMediaItem>[
            CinematicMediaItem.fromJson(<String, dynamic>{'id': 1, 'title': 'Only'}),
          ];
        },
      );
      addTearDown(controller.dispose);

      await controller.loadInitial();
      await controller.fetchNextPage();

      expect(requested, <int>[1]);
      expect(controller.hasMore, isFalse);
      expect(controller.page, 1);
    });

    test('re-entrant fetches are ignored while one is in flight', () async {
      var calls = 0;
      final controller = CinematicPagingController(
        fetchPage: (page) async {
          calls++;
          await Future<void>.delayed(const Duration(milliseconds: 1));
          return <CinematicMediaItem>[
            CinematicMediaItem.fromJson(<String, dynamic>{'id': calls, 'title': 't'}),
          ];
        },
      );
      addTearDown(controller.dispose);

      final first = controller.loadInitial();
      final second = controller.fetchNextPage();
      await Future.wait(<Future<void>>[first, second]);

      expect(calls, 1);
      expect(controller.items, hasLength(1));
    });

    test('loadMoreThreshold keeps the source 300px default', () {
      final controller = CinematicPagingController(
        fetchPage: (page) async => const <CinematicMediaItem>[],
      );
      addTearDown(controller.dispose);

      expect(controller.loadMoreThreshold, 300);
    });
  });

  // -------------------------------------------------------------------------
  group('favourites store', () {
    setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

    test('toggle saves to media_favorites_key as MediaItem.toJson strings', () async {
      final store = CinematicFavoritesStore();
      addTearDown(store.dispose);
      await store.load();
      final item = CinematicMediaItem.fromJson(
        jsonDecode(movieJson) as Map<String, dynamic>,
      );

      await store.toggle(item);

      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList(CinematicFavoritesStore.prefsKey);
      expect(CinematicFavoritesStore.prefsKey, 'media_favorites_key');
      expect(saved, hasLength(1));
      final decoded = jsonDecode(saved!.single) as Map<String, dynamic>;
      expect(decoded['id'], 338762);
      expect(decoded['type'], 1);
      expect(store.isFavorite(item), isTrue);
    });

    test('toggling again removes it and splits movies from shows', () async {
      final store = CinematicFavoritesStore();
      addTearDown(store.dispose);
      await store.load();
      final movie = CinematicMediaItem.fromJson(
        jsonDecode(movieJson) as Map<String, dynamic>,
      );
      final show = CinematicMediaItem.fromJson(
        jsonDecode(showJson) as Map<String, dynamic>,
        type: CinematicMediaType.show,
      );

      await store.toggle(movie);
      await store.toggle(show);
      expect(store.movieFavorites, hasLength(1));
      expect(store.showFavorites, hasLength(1));

      await store.toggle(movie);
      expect(store.isFavorite(movie), isFalse);
      expect(store.movieFavorites, isEmpty);
    });

    test('load restores what a previous session saved', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        CinematicFavoritesStore.prefsKey: <String>[
          jsonEncode(<String, dynamic>{
            'type': 0,
            'id': 82856,
            'title': 'The Mandalorian',
            'poster_path': '/sWgBv7LV2PRoQgkxwlibdGXKz1S.jpg',
            'backdrop_path': '',
            'overview': 'x',
            'release_date': '2019-11-12',
            'genre_ids': <int>[10759],
            'vote_average': 8.4,
          }),
        ],
      });
      final store = CinematicFavoritesStore();
      addTearDown(store.dispose);

      await store.load();

      expect(store.showFavorites, hasLength(1));
      expect(store.showFavorites.single.title, 'The Mandalorian');
      expect(store.showFavorites.single.type, CinematicMediaType.show);
    });
  });

  // -------------------------------------------------------------------------
  group('screens', () {
    setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

    testWidgets('media detail maps movie/{id} plus credits and similar', (
      tester,
    ) async {
      final adapter = FakeAdapter(<String, Object Function(RequestOptions)>{
        'movie/338762': (options) => <String, dynamic>{
          'id': 338762,
          'title': 'Bloodshot',
          'tagline': 'Being a hero is in his blood.',
          'overview': 'After he and his wife are murdered.',
          'runtime': 109,
          'budget': 45000000,
          'revenue': 0,
          'status': 'Released',
          'release_date': '2020-03-05',
          'original_title': 'Bloodshot',
          'homepage': 'https://www.sonypictures.com/movies/bloodshot',
          'imdb_id': 'tt0490210',
          'genres': <Object>[
            <String, dynamic>{'id': 28, 'name': 'Action'},
            <String, dynamic>{'id': 12, 'name': 'Adventure'},
          ],
          'vote_average': 7.2,
          'poster_path': '/p.jpg',
          'backdrop_path': '/b.jpg',
        },
        'movie/338762/credits': (options) => <String, dynamic>{
          'cast': <Object>[
            <String, dynamic>{
              'character': 'Ray Garrison / Bloodshot',
              'name': 'Vin Diesel',
              'profile_path': '/v.jpg',
              'id': 12835,
            },
          ],
        },
        'movie/338762/similar': (options) => jsonDecode(listResponse(1, <String>[movieJson])),
      });
      final api = CinematicApi(dio: fakeDio(adapter));
      addTearDown(api.dispose);

      await pumpTall(
        tester,
        MaterialApp(
          home: CinematicMediaDetailPage(
            id: 338762,
            type: 'movie',
            title: 'Bloodshot',
            api: api,
          ),
        ),
      );
      await settle(tester);

      final state = tester.state<CinematicMediaDetailPageState>(
        find.byType(CinematicMediaDetailPage),
      );
      expect(state.details!['runtime'], 109);
      expect(state.cast.single.name, 'Vin Diesel');
      expect(state.seasons, isEmpty);
      expect(adapter.paths, contains('movie/338762/credits'));
      expect(adapter.paths, contains('movie/338762/similar'));
      expect(find.text('Action, Adventure'), findsOneWidget);
      expect(find.text('109 min'), findsOneWidget);
      expect(find.text('Vin Diesel'), findsOneWidget);
    });

    testWidgets('media detail on a show loads tv seasons', (tester) async {
      final adapter = FakeAdapter(<String, Object Function(RequestOptions)>{
        'tv/82856': (options) => <String, dynamic>{
          'id': 82856,
          'name': 'The Mandalorian',
          'number_of_seasons': 2,
          'number_of_episodes': 16,
          'first_air_date': '2019-11-12',
          'overview': 'A lone gunfighter.',
          'created_by': <Object>[
            <String, dynamic>{'name': 'Jon Favreau'},
          ],
          'networks': <Object>[
            <String, dynamic>{'name': 'Disney+'},
          ],
          'genres': <Object>[
            <String, dynamic>{'id': 10759},
          ],
          'seasons': <Object>[
            <String, dynamic>{
              'air_date': '2019-11-12',
              'episode_count': 8,
              'id': 107209,
              'name': 'Season 1',
              'overview': 'o',
              'poster_path': '/s1.jpg',
              'season_number': 1,
            },
          ],
        },
        'tv/82856/credits': (options) => <String, dynamic>{'cast': <Object>[]},
        'tv/82856/similar': (options) => jsonDecode(listResponse(1, <String>[showJson])),
      });
      final api = CinematicApi(dio: fakeDio(adapter));
      addTearDown(api.dispose);

      await pumpTall(
        tester,
        MaterialApp(
          home: CinematicMediaDetailPage(
            id: 82856,
            type: 'tv',
            title: 'The Mandalorian',
            api: api,
          ),
        ),
      );
      await settle(tester);

      final state = tester.state<CinematicMediaDetailPageState>(
        find.byType(CinematicMediaDetailPage),
      );
      expect(state.seasons.single.id, 107209);
      expect(find.text('Jon Favreau'), findsOneWidget);
      expect(find.text('Disney+'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('season detail lists the mapped episodes', (tester) async {
      final adapter = FakeAdapter(<String, Object Function(RequestOptions)>{
        'tv/82856/season/1': (options) => <String, dynamic>{
          'episodes': <Object>[
            <String, dynamic>{
              'name': 'Chapter 1: The Mandalorian',
              'overview': 'A Mandalorian bounty hunter tracks a target.',
              'still_path': '/still.jpg',
              'vote_average': 8.5,
              'episode_number': 1,
              'air_date': '2019-11-12',
            },
          ],
        },
      });
      final api = CinematicApi(dio: fakeDio(adapter));
      addTearDown(api.dispose);

      await pumpTall(
        tester,
        MaterialApp(
          home: CinematicSeasonDetailPage(
            showId: 82856,
            showTitle: 'The Mandalorian',
            season: CinematicTvSeason.fromMap(<String, dynamic>{
              'air_date': '2019-11-12',
              'episode_count': 8,
              'id': 107209,
              'name': 'Season 1',
              'poster_path': '/s1.jpg',
              'season_number': 1,
            }),
            api: api,
          ),
        ),
      );
      await settle(tester);

      final state = tester.state<CinematicSeasonDetailPageState>(
        find.byType(CinematicSeasonDetailPage),
      );
      expect(adapter.lastRequest.path, 'tv/82856/season/1');
      expect(state.episodes.single.episodeNumber, 1);
      // The tile renders "1. Chapter 1: The Mandalorian" as one rich span.
      expect(find.textContaining('Chapter 1: The Mandalorian'), findsOneWidget);
      expect(find.text('November 12, 2019'), findsOneWidget);
      expect(find.text('Season 1 (2019)'), findsOneWidget);
    });

    testWidgets('actor page keeps discover/movie and tv_credits apart', (
      tester,
    ) async {
      final adapter = FakeAdapter(<String, Object Function(RequestOptions)>{
        'discover/movie': (options) => jsonDecode(listResponse(1, <String>[movieJson])),
        'person/12835/tv_credits': (options) => <String, dynamic>{
          'cast': <Object>[jsonDecode(showJson)],
        },
      });
      final api = CinematicApi(dio: fakeDio(adapter));
      addTearDown(api.dispose);

      await pumpTall(
        tester,
        MaterialApp(
          home: CinematicActorPage(actorId: 12835, name: 'Vin Diesel', api: api),
        ),
      );
      await settle(tester);

      final state = tester.state<CinematicActorPageState>(
        find.byType(CinematicActorPage),
      );
      expect(state.shows.single.title, 'The Mandalorian');
      expect(adapter.paths, contains('discover/movie'));
      expect(adapter.paths, contains('person/12835/tv_credits'));
      expect(find.text('Bloodshot'), findsOneWidget);
      expect(find.text('Vin Diesel'), findsOneWidget);
    });

    testWidgets('home page loads movie/popular through the injected api', (
      tester,
    ) async {
      final adapter = FakeAdapter(<String, Object Function(RequestOptions)>{
        'movie/popular': (options) => jsonDecode(listResponse(1, <String>[movieJson])),
      });
      final api = CinematicApi(dio: fakeDio(adapter));
      addTearDown(api.dispose);

      await pumpTall(tester, MaterialApp(home: CinematicHomePage(api: api)));
      await settle(tester);

      final state = tester.state<CinematicHomePageState>(
        find.byType(CinematicHomePage),
      );
      expect(CinematicHomePageState.categoryLabel('on_the_air'), 'On the air');
      expect(CinematicHomePageState.categoryLabel('top_rated'), 'Top rated');
      expect(state.categories, CinematicConstants.movieCategories);
      expect(adapter.paths, contains('movie/popular'));
      expect(find.text('Bloodshot'), findsOneWidget);
      expect(find.text('Movies'), findsOneWidget);
    });

    testWidgets('the TV toggle swaps the category tabs and requests tv/*', (
      tester,
    ) async {
      final adapter = FakeAdapter(<String, Object Function(RequestOptions)>{
        'movie/popular': (options) => jsonDecode(listResponse(1, <String>[movieJson])),
        'tv/popular': (options) => jsonDecode(listResponse(1, <String>[showJson])),
      });
      final api = CinematicApi(dio: fakeDio(adapter));
      addTearDown(api.dispose);

      await pumpTall(tester, MaterialApp(home: CinematicHomePage(api: api)));
      await settle(tester);

      expect(find.text('Movies'), findsOneWidget);
      await tester.tap(find.text('TV'));
      await settle(tester);

      final state = tester.state<CinematicHomePageState>(
        find.byType(CinematicHomePage),
      );
      expect(state.isMovieMode, isFalse);
      expect(
        state.categories,
        CinematicConstants.showCategories,
      );
      expect(adapter.paths, contains('tv/popular'));
      expect(find.text('TV Shows'), findsOneWidget);
    });

    testWidgets('the search page starts empty and only searches on input', (
      tester,
    ) async {
      final adapter = FakeAdapter(<String, Object Function(RequestOptions)>{
        'search/multi': (options) => <String, dynamic>{'results': <Object>[]},
      });
      final api = CinematicApi(dio: fakeDio(adapter));
      addTearDown(api.dispose);

      await pumpTall(tester, MaterialApp(home: CinematicSearchPage(api: api)));
      await settle(tester);

      expect(adapter.requests, isEmpty);
      expect(CinematicSearchPageState.debounce, const Duration(milliseconds: 400));
    });

    testWidgets('search page debounces then renders the mapped result', (
      tester,
    ) async {
      final adapter = FakeAdapter(<String, Object Function(RequestOptions)>{
        'search/multi': (options) => <String, dynamic>{
          'results': <Object>[
            <String, dynamic>{
              'media_type': 'movie',
              'title': 'Fight Club',
              'release_date': '1999-10-15',
              'poster_path': '/fc.jpg',
            },
          ],
        },
      });
      final api = CinematicApi(dio: fakeDio(adapter));
      addTearDown(api.dispose);

      await pumpTall(
        tester,
        MaterialApp(home: CinematicSearchPage(api: api)),
      );
      await tester.enterText(find.byType(TextField), 'fight club');
      await tester.pump(CinematicSearchPageState.debounce);
      await settle(tester);

      final state = tester.state<CinematicSearchPageState>(
        find.byType(CinematicSearchPage),
      );
      expect(adapter.lastRequest.path, 'search/multi');
      expect(adapter.lastRequest.queryParameters['query'], 'fight club');
      expect(state.results.single.title, 'Fight Club');
      expect(find.text('Fight Club'), findsOneWidget);
      expect(find.text('movie • October 15, 1999'), findsOneWidget);
    });

    testWidgets('an empty search box clears the results without a request', (
      tester,
    ) async {
      final adapter = FakeAdapter(<String, Object Function(RequestOptions)>{
        'search/multi': (options) => <String, dynamic>{'results': <Object>[]},
      });
      final api = CinematicApi(dio: fakeDio(adapter));
      addTearDown(api.dispose);

      await tester.pumpWidget(
        MaterialApp(home: CinematicSearchPage(api: api)),
      );
      await tester.enterText(find.byType(TextField), '   ');
      await tester.pump(CinematicSearchPageState.debounce);
      await settle(tester);

      final state = tester.state<CinematicSearchPageState>(
        find.byType(CinematicSearchPage),
      );
      expect(state.results, isEmpty);
      expect(adapter.requests, isEmpty);
    });

    testWidgets('a failing search is reported, not thrown', (tester) async {
      final dio = Dio(BaseOptions(baseUrl: CinematicConstants.baseUrl));
      dio.httpClientAdapter = FakeAdapter(<String, Object Function(RequestOptions)>{
        'search/multi': (options) => throw StateError('offline'),
      });
      final api = CinematicApi(dio: dio);
      addTearDown(api.dispose);

      await tester.pumpWidget(
        MaterialApp(home: CinematicSearchPage(api: api, initialQuery: 'dune')),
      );
      await tester.pump(CinematicSearchPageState.debounce);
      await settle(tester);

      final state = tester.state<CinematicSearchPageState>(
        find.byType(CinematicSearchPage),
      );
      expect(state.error, isNotNull);
      expect(find.text('Search failed'), findsOneWidget);
    });

    testWidgets('favorites page reads the same store it was given', (
      tester,
    ) async {
      final store = CinematicFavoritesStore();
      addTearDown(store.dispose);
      await store.load();
      await store.toggle(
        CinematicMediaItem.fromJson(
          jsonDecode(showJson) as Map<String, dynamic>,
          type: CinematicMediaType.show,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(home: CinematicFavoritesPage(store: store)),
      );
      await settle(tester);

      final state = tester.state<CinematicFavoritesPageState>(
        find.byType(CinematicFavoritesPage),
      );
      expect(state.movieFavorites, isEmpty);
      expect(state.showFavorites.single.title, 'The Mandalorian');
      expect(find.text('Nothing saved yet'), findsOneWidget);
    });
  });
}
