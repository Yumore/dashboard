import 'package:dashboard/features/movie/inkino/inkino_dates.dart';
import 'package:dashboard/features/movie/inkino/inkino_event.dart';
import 'package:dashboard/features/movie/inkino/inkino_event_parser.dart';
import 'package:dashboard/features/movie/inkino/inkino_exception.dart';
import 'package:dashboard/features/movie/inkino/inkino_show.dart';
import 'package:dashboard/features/movie/inkino/inkino_show_parser.dart';
import 'package:dashboard/features/movie/inkino/inkino_theater_area.dart';
import 'package:dashboard/features/movie/inkino/inkino_theater_parser.dart';
import 'dart:convert';

import 'package:dio/dio.dart';

/// Finnkino XML client over the host's `dio`.
///
/// Endpoints are exactly the ones the source really calls
/// (`core/lib/src/networking/finnkino_api.dart`): `/xml/Schedule` and
/// `/xml/Events` (with `listType=NowInTheatres` and `listType=ComingSoon`).
/// The source had NO event-detail endpoint — the film detail page is served
/// from the `<Show>` / `<Event>` fields returned by these two calls.
///
/// `/xml/TheatreAreas` is the live endpoint behind the source's *preloaded*
/// `theaters.xml` asset (`core/lib/src/preloaded_data.dart`); the source
/// bundled that response instead of fetching it, so the fetch here is an
/// addition with the same response shape and query semantics (no parameters).
///
/// All three return XML, so responses are read as bytes and decoded as UTF-8
/// before parsing — never trusted as JSON.
class InKinoApi {
  InKinoApi({Dio? dio, this.useFinnish = false, String host = defaultHost})
    : _dio = dio ?? _defaultDio(host);

  static const String defaultHost = 'www.finnkino.fi';

  /// English path prefix used by the source (`/en/xml/...`).
  static const String englishPrefix = '/en';

  /// The source kept a mutable `useFinnish` flag; it is a constructor option
  /// here because the host has no global mutable config.
  final bool useFinnish;

  final Dio _dio;

  static Dio _defaultDio(String host) => Dio(
    BaseOptions(
      baseUrl: 'https://$host',
      responseType: ResponseType.plain,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
    ),
  );

  String get localizedPath => useFinnish ? '' : englishPrefix;

  /// `https://www.finnkino.fi[/en]/xml/Schedule`
  Uri scheduleUri(String areaId, DateTime date) =>
      Uri.https(defaultHost, '$localizedPath/xml/Schedule', <String, String>{
        'area': areaId,
        'dt': InKinoDates.apiDate(date),
        'includeGallery': 'true',
      });

  /// `https://www.finnkino.fi[/en]/xml/Events`
  Uri eventsUri({
    required String areaId,
    required String listType,
    bool includeGallery = true,
  }) => Uri.https(defaultHost, '$localizedPath/xml/Events', <String, String>{
    'area': areaId,
    'listType': listType,
    if (includeGallery) 'includeGallery': 'true',
  });

  /// `https://www.finnkino.fi/xml/TheatreAreas` (no parameters).
  Uri theaterAreasUri() =>
      Uri.https(defaultHost, '$localizedPath/xml/TheatreAreas');

  /// Showtimes for one theatre area on one day.
  Future<List<InKinoShow>> schedule({
    required String areaId,
    required DateTime date,
  }) async {
    final body = await _getString(
      '$localizedPath/xml/Schedule',
      queryParameters: <String, dynamic>{
        'area': areaId,
        'dt': InKinoDates.apiDate(date),
        'includeGallery': 'true',
      },
    );
    return InKinoShowParser.parse(body);
  }

  /// Source: `getNowInTheatersEvents`.
  Future<List<InKinoEvent>> nowInTheatersEvents({
    required String areaId,
  }) async {
    final body = await _getString(
      '$localizedPath/xml/Events',
      queryParameters: <String, dynamic>{
        'area': areaId,
        'listType': 'NowInTheatres',
        'includeGallery': 'true',
      },
    );
    return InKinoEventParser.parse(body);
  }

  /// Source: `getUpcomingEvents` — note it sends no `area` at all.
  Future<List<InKinoEvent>> upcomingEvents() async {
    final body = await _getString(
      '$localizedPath/xml/Events',
      queryParameters: <String, dynamic>{
        'listType': 'ComingSoon',
        'includeGallery': 'true',
      },
    );
    return InKinoEventParser.parse(body);
  }

  /// Theatre areas / theatres. See the class doc: the source pre-bundled this
  /// response, the live endpoint is fetched here instead.
  Future<List<InKinoTheaterArea>> theaterAreas() async {
    final body = await _getString('$localizedPath/xml/TheatreAreas');
    return InKinoTheaterParser.parse(body);
  }

  void dispose() => _dio.close();

  Future<String> _getString(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final Response<dynamic> response;
    try {
      response = await _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
        options: Options(responseType: ResponseType.plain),
      );
    } on DioException catch (error) {
      throw InKinoException(
        _messageFor(error),
        statusCode: error.response?.statusCode,
      );
    }

    final status = response.statusCode;
    if (status != null && (status < 200 || status >= 300)) {
      throw InKinoException('请求失败：HTTP $status', statusCode: status);
    }

    final body = _decode(response.data);
    if (body.trim().isEmpty) {
      throw const InKinoException('Finnkino 返回了空响应');
    }
    return body;
  }

  /// Dio is configured for `ResponseType.plain` (UTF-8 String). `bytes` is
  /// still handled so an injected client that returns raw bytes cannot break
  /// the Finnish/Scandinavian characters in titles.
  String _decode(Object? data) {
    if (data == null) return '';
    if (data is String) return data;
    if (data is List<int>) return utf8.decode(data, allowMalformed: true);
    return data.toString();
  }

  String _messageFor(DioException error) {
    switch (error.type) {
      case DioExceptionType.transformTimeout:
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
        return error.message ?? '网络请求失败';
    }
  }
}
