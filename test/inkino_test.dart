import 'package:dashboard/features/movie/inkino/inkino_api.dart';
import 'package:dashboard/features/movie/inkino/inkino_clock.dart';
import 'package:dashboard/features/movie/inkino/inkino_content_descriptor_parser.dart';
import 'package:dashboard/features/movie/inkino/inkino_dates.dart';
import 'package:dashboard/features/movie/inkino/inkino_event_parser.dart';
import 'package:dashboard/features/movie/inkino/inkino_exception.dart';
import 'package:dashboard/features/movie/inkino/inkino_image_rewriter.dart';
import 'package:dashboard/features/movie/inkino/inkino_name_cleaner.dart';
import 'package:dashboard/features/movie/inkino/inkino_schedule.dart';
import 'package:dashboard/features/movie/inkino/inkino_show_grouper.dart';
import 'package:dashboard/features/movie/inkino/inkino_show_parser.dart';
import 'package:dashboard/features/movie/inkino/inkino_theater_area.dart';
import 'package:dashboard/features/movie/inkino/inkino_theater_areas_catalog.dart';
import 'package:dashboard/features/movie/inkino/inkino_theater_parser.dart';
import 'package:dashboard/features/movie/inkino/inkino_xml.dart';
import 'package:dashboard/features/movie/inkino/inkino_page.dart';
import 'package:dashboard/features/movie/movie_module_page.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/inkino_fixtures.dart';

/// Resolves every request locally: nothing in this file touches the network.
Dio _fakeDio(
  Object? body, {
  int status = 200,
  void Function(RequestOptions options)? observe,
}) {
  final dio = Dio(BaseOptions(baseUrl: 'https://www.finnkino.fi'));
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        observe?.call(options);
        handler.resolve(
          Response<dynamic>(
            requestOptions: options,
            statusCode: status,
            data: body,
          ),
        );
      },
    ),
  );
  return dio;
}

Dio _errorDio(DioExceptionType type) {
  final dio = Dio(BaseOptions(baseUrl: 'https://www.finnkino.fi'));
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) => handler.reject(
        DioException(requestOptions: options, type: type),
      ),
    ),
  );
  return dio;
}

bool _matchesAll(
  Map<String, dynamic> actual,
  Map<String, dynamic> expected,
) {
  if (actual.length != expected.length) return false;
  for (final entry in expected.entries) {
    if ('${actual[entry.key]}' != '${entry.value}') return false;
  }
  return true;
}

void main() {
  setUp(InKinoClock.reset);
  tearDown(InKinoClock.reset);

  group('schedule model mapping (real Finnkino payloads)', () {
    test('maps every <Show> field from the captured Schedule response', () {
      final shows = InKinoShowParser.parse(showsXml);

      expect(shows, hasLength(3));

      final jumanji = shows.first;
      expect(jumanji.id, '1155306');
      expect(jumanji.eventId, '302419');
      expect(jumanji.title, 'Jumanji: Welcome to the Jungle');
      expect(
        jumanji.originalTitle,
        'Jumanji: Welcome to the Jungle (This is the original title)',
      );
      expect(jumanji.ageRating, '12');
      expect(jumanji.hasAgeRating, isTrue);
      expect(
        jumanji.ageRatingUrl,
        'https://media.finnkino.fi/images/rating_large_12.png',
      );
      expect(jumanji.url, 'http://www.finnkino.fi/websales/show/1155306/');
      expect(jumanji.presentationMethod, '2D');
      expect(jumanji.theater, 'Tennispalatsi, Helsinki');
      expect(jumanji.theaterAuditorium, 'sali 6');
      expect(jumanji.theaterAndAuditorium, 'Tennispalatsi, Helsinki, sali 6');
      expect(jumanji.theaterName, 'Tennispalatsi, Helsinki');
      expect(jumanji.auditorium, 'sali 6');
      expect(jumanji.start, DateTime(2018, 2, 21, 10, 30));
      expect(jumanji.end, DateTime(2018, 2, 21, 12, 39));
      expect(jumanji.lengthInMinutesValue, 119);
      expect(jumanji.genreList, [
        'Komedia',
        'Toiminta',
        'Seikkailu',
        'Fantasia',
      ]);
      expect(jumanji.startsAtLabel, '10:30');
      expect(jumanji.endsAtLabel, '12:39');
    });

    test('maps the nested <Images> block of a show', () {
      final images = InKinoShowParser.parse(showsXml).first.images;

      expect(images.isEmpty, isFalse);
      expect(
        images.portraitMicro,
        'http://media.finnkino.fi/1012/Event_11765/portrait_micro/'
        'Jumanji_1080u.jpg',
      );
      expect(
        images.portraitSmall,
        'http://media.finnkino.fi/1012/Event_11765/portrait_small/'
        'Jumanji_1080u.jpg',
      );
      expect(
        images.portraitMedium,
        'http://media.finnkino.fi/1012/Event_11765/portrait_medium/'
        'Jumanji_1080u.jpg',
      );
      expect(
        images.portraitLarge,
        'http://media.finnkino.fi/1012/Event_11765/portrait_small/'
        'Jumanji_1080u.jpg',
      );
      expect(
        images.landscapeSmall,
        'http://media.finnkino.fi/1012/Event_11765/landscape_small/'
        'Jumanji_444.jpg',
      );
      expect(
        images.landscapeLarge,
        'http://media.finnkino.fi/1012/Event_11765/landscape_large/'
        'Jumanji_670.jpg',
      );
      expect(images.anyPortrait, images.portraitSmall);
    });

    test('keeps the third show and its own date and theatre', () {
      final showman = InKinoShowParser.parse(showsXml).last;

      expect(showman.id, '1153867');
      expect(showman.eventId, '302492');
      expect(showman.title, 'The Greatest Showman');
      expect(showman.ageRating, '7');
      expect(showman.theaterName, 'Kinopalatsi, Helsinki');
      expect(showman.auditorium, 'sali 9');
      // A month later than the first two — this is what makes the date-scoped
      // grouping testable.
      expect(showman.start, DateTime(2018, 3, 21, 10, 30));
    });

    test('cleans presentation noise out of event names', () {
      expect(
        InKinoNameCleaner.cleanup('Avengers: Infinity War (2D)'),
        'Avengers: Infinity War',
      );
      expect(
        InKinoNameCleaner.cleanup('Avengers: Infinity War (2D dub)'),
        'Avengers: Infinity War',
      );
      expect(InKinoNameCleaner.cleanup('Wonder'), 'Wonder');
    });

    test('keeps the "Not yet rated" image-URL repair', () {
      expect(InKinoImageRewriter.rewrite(null), isNull);
      expect(InKinoImageRewriter.rewrite(''), isNull);
      expect(
        InKinoImageRewriter.rewrite('Not yet rated'),
        InKinoImageRewriter.notYetRatedImage,
      );
      expect(
        InKinoImageRewriter.rewrite(
          'https://media.finnkino.fi/images/rating_large_12.png',
        ),
        'https://media.finnkino.fi/images/rating_large_12.png',
      );
      expect(
        InKinoImageRewriter.withImgixHost(
          'http://media.finnkino.fi/1012/Event_11765/landscape_large/'
          'Jumanji_670.jpg',
        ),
        'https://inkino.imgix.net/1012/Event_11765/landscape_large/'
        'Jumanji_670.jpg?auto=format,compress',
      );
    });
  });

  group('event model mapping', () {
    test('maps the rich <Event> shape including cast, crew and trailer', () {
      final events = InKinoEventParser.parse(eventsXml);

      expect(events, hasLength(3));

      final paris = events.first;
      expect(paris.id, '302535');
      expect(paris.title, '15:17 Pariisiin');
      expect(paris.originalTitle, 'The 15:17 to Paris');
      expect(paris.releaseDate, DateTime(2018, 2, 16));
      expect(paris.releaseYear, 2018);
      expect(paris.ageRating, '12');
      expect(paris.genres, 'Draama, Jännitys');
      expect(paris.genreList, ['Draama', 'Jännitys']);
      expect(paris.lengthInMinutesValue, 94);
      expect(paris.shortSynopsis, 'Short synopsis goes here.');
      expect(paris.synopsis, 'Synopsis goes here.');
      expect(paris.anySynopsis, 'Short synopsis goes here.');
      expect(paris.directors, ['Clint Eastwood']);
      expect(paris.actors, contains('Anthony Sadler'));
      expect(paris.actors, contains('Jenna Fischer'));
      expect(paris.youtubeTrailers, [
        'https://youtube.com/watch?v=oFa4C6OcuM4',
      ]);
      expect(paris.galleryImages, hasLength(8));
      expect(
        paris.galleryImages.first.location,
        'http://media.finnkino.fi/1012/Event_12007/gallery/Adrift_800a.jpg',
      );
      expect(
        paris.galleryImages.first.thumbnailLocation,
        'http://media.finnkino.fi/1012/Event_12007/gallery/'
        'THUMB_Adrift_800a.jpg',
      );
      expect(paris.contentDescriptors.map((d) => d.name), [
        'Violence',
        'Disturbing',
      ]);
      expect(
        paris.contentDescriptors.first.imageUrl,
        'https://media.finnkino.fi/images/content_Violence.png',
      );
      expect(
        paris.images.landscapeLarge,
        'https://media.finnkino.fi/1012/Event_11881/landscape_large/'
        'BookClub_670_kke.jpg',
      );
    });

    test('handles a "Not yet rated" event and an empty <Images> block', () {
      final unrated = InKinoEventParser.parse(eventsXml)[1];

      expect(unrated.id, '302465');
      expect(unrated.title, '95');
      expect(unrated.ageRating, 'Not yet rated');
      // The fixture's <Images> block holds no image tags at all.
      expect(unrated.images.isEmpty, isTrue);
      expect(unrated.images.anyPortrait, isNull);
      // <Directors> contains only a <Test> element, so nobody is listed.
      expect(unrated.directors, isEmpty);
      expect(unrated.actors, isEmpty);
      expect(unrated.contentDescriptors.map((d) => d.name), ['Disturbing']);
    });

    test('handles an event with no <Images> tag at all', () {
      final money = InKinoEventParser.parse(eventsXml)[2];

      expect(money.id, '302478');
      expect(money.title, 'All the Money in the World');
      expect(money.ageRating, '16');
      expect(money.images.isEmpty, isTrue);
      expect(money.directors, ['Ridley Scott', 'Clint Eastwood']);
      expect(money.youtubeTrailers, [
        'https://youtube.com/watch?v=GKc9LWtlAW4',
      ]);
    });

    test('content-descriptor parser returns nothing for an empty block', () {
      final document = InKinoXml.parse(
        '<ContentDescriptors />',
        rootTag: 'ContentDescriptors',
      );
      expect(InKinoContentDescriptorParser.parseRoots([document]), isEmpty);
    });
  });

  group('theatre area mapping', () {
    test('normalizes names and relabels the placeholder row', () {
      final areas = InKinoTheaterParser.parse(theatersXml);

      expect(areas, hasLength(3));
      expect(areas[0].id, '1029');
      expect(areas[0].name, 'All theaters');
      expect(areas[0].isPlaceholder, isTrue);
      expect(areas[1].id, '001');
      expect(areas[1].name, 'Gotham: Theater One');
      expect(areas[2].name, 'Gotham: Theater Two');
    });

    test('the bundled snapshot parses and keeps the source default area', () {
      final areas = InKinoTheaterAreasCatalog.all();

      expect(areas, hasLength(21));
      expect(areas.first.name, 'All theaters');
      expect(
        areas.map((area) => area.id),
        contains(InKinoTheaterArea.defaultAreaId),
      );
      final tennispalatsi = areas.firstWhere(
        (area) => area.id == InKinoTheaterArea.defaultAreaId,
      );
      expect(tennispalatsi.name, 'Helsinki: Tennispalatsi');
      // Non-ASCII area names must survive the decode intact.
      expect(areas.map((area) => area.name), contains('Jyväskylä: Fantasia'));
    });
  });

  group('date-scoped grouping with an injected clock', () {
    // 08:00 is before the fixture's first 10:30 show, so "today" still lists
    // every showtime and the grouping assertions below are meaningful. At
    // 11:00 the already-started rule would hide both 2018-02-21 shows.
    final today = DateTime(2018, 2, 21, 8);
    final schedule = InKinoSchedule(
      areaId: '1033',
      date: DateTime(2018, 2, 21),
      shows: InKinoShowParser.parse(showsXml),
    );

    test('today hides showtimes that have already started', () {
      final visible = InKinoShowGrouper.visibleShows(
        schedule,
        DateTime(2018, 2, 21),
        clock: () => DateTime(2018, 2, 21, 11),
      );

      expect(visible.map((show) => show.id), ['1153867']);
      expect(
        visible.any((show) => show.id == '1155306'),
        isFalse,
        reason: 'the 10:30 show has started',
      );
    });

    test('boundary: a show exactly at "now" counts as started', () {
      final visible = InKinoShowGrouper.visibleShows(
        schedule,
        DateTime(2018, 2, 21),
        clock: () => DateTime(2018, 2, 21, 10, 30),
      );

      expect(visible.map((show) => show.id), ['1153867']);
    });

    test('another day keeps every showtime, including morning ones', () {
      final visible = InKinoShowGrouper.visibleShows(
        schedule,
        DateTime(2018, 2, 21),
        clock: () => DateTime(2018, 2, 22, 11),
      );

      expect(visible, hasLength(3));
    });

    test('groups today by theatre and sorts shows by start time', () {
      final grouped = InKinoShowGrouper.byTheater(
        schedule,
        DateTime(2018, 2, 21),
        clock: () => today,
      );

      expect(grouped.keys.toList(), [
        'Kinopalatsi, Helsinki',
        'Tennispalatsi, Helsinki',
      ]);
      expect(grouped['Tennispalatsi, Helsinki']!.map((s) => s.id), ['1155306']);
      // Kinopalatsi's two visible showtimes are the 2018-02-21 and the
      // 2018-03-21 one, both at 10:30, ordered by start time.
      expect(grouped['Kinopalatsi, Helsinki']!.map((s) => s.id), [
        '1154395',
        '1153867',
      ]);
      expect(grouped['Kinopalatsi, Helsinki']!.map((s) => s.startsAtLabel), [
        '10:30',
        '10:30',
      ]);
    });

    test('groups by auditorium and by calendar day', () {
      final grouped = InKinoShowGrouper.byTheater(
        schedule,
        DateTime(2018, 2, 21),
        clock: () => today,
      );
      final byAuditorium = InKinoShowGrouper.byAuditorium(
        grouped['Kinopalatsi, Helsinki']!,
      );
      expect(byAuditorium.keys.toList(), ['sali 10', 'sali 9']);

      final byDate = InKinoShowGrouper.byDate(schedule.shows);
      expect(byDate.keys.toList(), ['2018-02-21', '2018-03-21']);
      expect(byDate['2018-02-21']!.map((s) => s.id), ['1155306', '1154395']);
      expect(byDate['2018-03-21']!.map((s) => s.id), ['1153867']);
    });

    test('an empty schedule groups to nothing', () {
      final empty = InKinoSchedule(
        areaId: '1033',
        date: DateTime(2018, 2, 21),
        shows: const [],
      );

      expect(empty.isEmpty, isTrue);
      expect(
        InKinoShowGrouper.byTheater(
          empty,
          DateTime(2018, 2, 21),
          clock: () => today,
        ),
        isEmpty,
      );
      expect(InKinoShowGrouper.visibleShows(null, DateTime(2018, 2, 21)),
          isEmpty);
    });

    test('date helpers use local calendar fields, not ISO UTC', () {
      final lateEvening = DateTime(2018, 2, 21, 23, 45);
      expect(InKinoDates.apiDate(lateEvening), '21.02.2018');
      expect(InKinoDates.apiDate(DateTime(2018, 3, 5)), '05.03.2018');
      expect(InKinoDates.dateKey(lateEvening), '2018-02-21');
      expect(InKinoDates.chipLabel(lateEvening), '21.02');
      expect(
        InKinoDates.isSameDay(lateEvening, DateTime(2018, 2, 21, 0, 5)),
        isTrue,
      );
      expect(
        InKinoDates.isSameDay(lateEvening, DateTime(2018, 2, 22, 0, 5)),
        isFalse,
      );
      expect(InKinoDates.dayLabel(DateTime(2018, 2, 21), lateEvening), '今天');
      expect(InKinoDates.dayLabel(DateTime(2018, 2, 22), lateEvening), '周四');
      expect(InKinoDates.upcomingDays(DateTime(2018, 2, 21, 15)), hasLength(7));
      expect(
        InKinoDates.upcomingDays(DateTime(2018, 2, 21, 15)).last,
        DateTime(2018, 2, 27),
      );
    });
  });

  group('request URL and parameter building', () {
    test('schedule() sends area, dd.MM.yyyy dt and includeGallery', () async {
      RequestOptions? seen;
      final api = InKinoApi(
        dio: _fakeDio(showsXml, observe: (options) => seen = options),
      );
      addTearDown(api.dispose);

      final shows = await api.schedule(
        areaId: '1033',
        date: DateTime(2018, 2, 21, 15, 30),
      );

      expect(shows, hasLength(3));
      expect(seen!.path, '/en/xml/Schedule');
      expect(
        _matchesAll(seen!.queryParameters, {
          'area': '1033',
          'dt': '21.02.2018',
          'includeGallery': 'true',
        }),
        isTrue,
      );
      expect(
        seen!.uri.toString(),
        'https://www.finnkino.fi/en/xml/Schedule'
        '?area=1033&dt=21.02.2018&includeGallery=true',
      );
    });

    test('the Finnish localization drops the /en prefix', () {
      final api = InKinoApi(dio: _fakeDio(showsXml), useFinnish: true);
      addTearDown(api.dispose);

      final uri = api.scheduleUri('1033', DateTime(2018, 2, 21));
      expect(uri.path, '/xml/Schedule');
      expect(uri.queryParameters, {
        'area': '1033',
        'dt': '21.02.2018',
        'includeGallery': 'true',
      });
    });

    test(
      'now-in-theatres events send listType=NowInTheatres with an area',
      () async {
        RequestOptions? seen;
        final api = InKinoApi(
          dio: _fakeDio(eventsXml, observe: (options) => seen = options),
        );
        addTearDown(api.dispose);

        final events = await api.nowInTheatersEvents(areaId: '1033');

        expect(events, hasLength(3));
        expect(seen!.path, '/en/xml/Events');
        expect(seen!.queryParameters['area'], '1033');
        expect(seen!.queryParameters['listType'], 'NowInTheatres');
        expect(seen!.queryParameters['includeGallery'], 'true');
      },
    );

    test('coming-soon events send listType=ComingSoon and no area', () async {
      RequestOptions? seen;
      final api = InKinoApi(
        dio: _fakeDio(eventsXml, observe: (options) => seen = options),
      );
      addTearDown(api.dispose);

      await api.upcomingEvents();

      expect(seen!.path, '/en/xml/Events');
      expect(
        _matchesAll(seen!.queryParameters, {
          'listType': 'ComingSoon',
          'includeGallery': 'true',
        }),
        isTrue,
      );
      expect(seen!.queryParameters.containsKey('area'), isFalse);
    });

    test('theatre areas are requested without parameters', () async {
      RequestOptions? seen;
      final api = InKinoApi(
        dio: _fakeDio(theatersXml, observe: (options) => seen = options),
      );
      addTearDown(api.dispose);

      final areas = await api.theaterAreas();

      expect(areas, hasLength(3));
      expect(seen!.path, '/en/xml/TheatreAreas');
      expect(seen!.queryParameters, isEmpty);
    });

    test('the Uri builders match what the requests used', () {
      final api = InKinoApi(dio: _fakeDio(showsXml));
      addTearDown(api.dispose);

      expect(
        _matchesAll(
          api
              .eventsUri(areaId: '1033', listType: 'NowInTheatres')
              .queryParameters,
          {
            'area': '1033',
            'listType': 'NowInTheatres',
            'includeGallery': 'true',
          },
        ),
        isTrue,
      );
      expect(
        api.theaterAreasUri().toString(),
        'https://www.finnkino.fi/en/xml/TheatreAreas',
      );
    });
  });

  group('error and empty handling', () {
    test('a failing status becomes a user-facing InKinoException', () async {
      final api = InKinoApi(dio: _fakeDio('<html>nope</html>', status: 500));
      addTearDown(api.dispose);

      await expectLater(
        api.schedule(areaId: '1033', date: DateTime(2018, 2, 21)),
        throwsA(
          isA<InKinoException>()
              .having((e) => e.message, 'message', '请求失败：HTTP 500')
              .having((e) => e.statusCode, 'statusCode', 500),
        ),
      );
    });

    test('an empty body is reported instead of parsed', () async {
      final api = InKinoApi(dio: _fakeDio('   '));
      addTearDown(api.dispose);

      await expectLater(
        api.theaterAreas(),
        throwsA(
          isA<InKinoException>().having(
            (e) => e.message,
            'message',
            'Finnkino 返回了空响应',
          ),
        ),
      );
    });

    test('a connection timeout maps to the retry hint', () async {
      final api = InKinoApi(dio: _errorDio(DioExceptionType.connectionTimeout));
      addTearDown(api.dispose);

      await expectLater(
        api.schedule(areaId: '1033', date: DateTime(2018, 2, 21)),
        throwsA(
          isA<InKinoException>().having(
            (e) => e.message,
            'message',
            '网络连接失败，请检查网络后重试',
          ),
        ),
      );
    });

    test('a well-formed but empty schedule parses to zero shows', () async {
      final api = InKinoApi(
        dio: _fakeDio('<?xml version="1.0"?><Schedule><Shows /></Schedule>'),
      );
      addTearDown(api.dispose);

      final shows = await api.schedule(
        areaId: '1033',
        date: DateTime(2018, 2, 21),
      );
      expect(shows, isEmpty);

      final schedule = InKinoSchedule(
        areaId: '1033',
        date: DateTime(2018, 2, 21),
        shows: shows,
      );
      expect(schedule.isEmpty, isTrue);
      expect(
        InKinoShowGrouper.byTheater(
          schedule,
          DateTime(2018, 2, 21),
          clock: () => DateTime(2018, 2, 21, 12),
        ),
        isEmpty,
      );
    });

    test('a payload with no <Show> elements is not an error', () {
      expect(InKinoShowParser.parse('<Schedule></Schedule>'), isEmpty);
      expect(
        InKinoShowParser.parse('<?xml version="1.0"?>\n<Events></Events>'),
        isEmpty,
      );
      expect(InKinoEventParser.parse('<TheatreAreas></TheatreAreas>'), isEmpty);
    });
  });

  testWidgets('movie entry opens the Finnkino showtimes page', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MaterialApp(home: MovieModulePage()));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('inKino · Finnkino 场次'));
    // Advancing the route transition without pumpAndSettle: the page shows an
    // indeterminate spinner while its first request is in flight.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(InKinoPage), findsOneWidget);
  });
}
