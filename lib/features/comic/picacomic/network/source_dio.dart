import 'package:dio/dio.dart';

/// Builds the `Dio` used by one comic source.
///
/// PicaComic configured a fresh `Dio` per network class; this port keeps the
/// same defaults (plain-text response body, status errors surfaced) but lets
/// tests inject an adapter through [dio].
Dio createSourceDio({
  String baseUrl = '',
  Map<String, String>? headers,
  Duration connectTimeout = const Duration(seconds: 10),
  Duration receiveTimeout = const Duration(seconds: 20),
}) {
  return Dio(
    BaseOptions(
      baseUrl: baseUrl,
      headers: headers,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      receiveDataWhenStatusError: true,
      responseType: ResponseType.plain,
    ),
  );
}
