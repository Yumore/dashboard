import 'dart:async';
import 'dart:convert';

import 'package:dashboard/features/comic/manhuatai/manhuatai_exception.dart';
import 'package:http/http.dart' as http;

/// Thin HTTP layer for the manhuatai endpoints.
///
/// Replaces the source's Dio singleton (`lib/api/http.dart`, `HttpRequest`).
/// Key differences, all deliberate:
///  * the transport is an injectable [http.Client], so tests run network-free;
///  * query parameters are appended manually instead of through Dio's encoder,
///    because Dio renders `List` values as `key[]=`, and the chapter endpoint
///    must send a repeated `chapterid` key (the source worked around this with
///    a manual URL);
///  * errors are typed as [ManhuataiApiException] instead of `DioError`.
///
/// The source's only LAN literal — a commented-out dev proxy
/// (`lib/api/http.dart:31-35`) — is not ported.
class ManhuataiClient {
  ManhuataiClient({
    http.Client? client,
    this.timeout = const Duration(seconds: 60),
  })  : _client = client ?? http.Client(),
        _ownsClient = client == null;

  final http.Client _client;
  final bool _ownsClient;

  /// Matches the source's Dio `connectTimeout`/`receiveTimeout` of 60s.
  final Duration timeout;

  static const Map<String, String> defaultHeaders = <String, String>{
    'platformname': 'android',
    'productname': 'mht',
  };

  /// Builds a URL with the given query parameters.
  ///
  /// `null` values are skipped; `List` values are expanded to repeated keys
  /// (`chapterid=1&chapterid=2`).
  Uri buildUri(String url, [Map<String, dynamic>? params]) {
    if (params == null || params.isEmpty) {
      return Uri.parse(url);
    }
    final parts = <String>[];
    params.forEach((String key, dynamic value) {
      if (value == null) {
        return;
      }
      if (value is List) {
        for (final dynamic item in value) {
          parts.add(
            '${Uri.encodeQueryComponent(key)}=${Uri.encodeQueryComponent('$item')}',
          );
        }
        return;
      }
      parts.add(
        '${Uri.encodeQueryComponent(key)}=${Uri.encodeQueryComponent('$value')}',
      );
    });
    if (parts.isEmpty) {
      return Uri.parse(url);
    }
    final separator = url.contains('?') ? '&' : '?';
    return Uri.parse('$url$separator${parts.join('&')}');
  }

  Future<dynamic> get(
    String url, {
    Map<String, dynamic>? params,
    Map<String, String>? headers,
  }) =>
      _send('GET', url, params: params, headers: headers);

  Future<dynamic> post(
    String url, {
    Object? data,
    Map<String, dynamic>? params,
    Map<String, String>? headers,
  }) =>
      _send('POST', url, data: data, params: params, headers: headers);

  Future<dynamic> put(
    String url, {
    Object? data,
    Map<String, dynamic>? params,
    Map<String, String>? headers,
  }) =>
      _send('PUT', url, data: data, params: params, headers: headers);

  Future<dynamic> _send(
    String method,
    String url, {
    Map<String, dynamic>? params,
    Object? data,
    Map<String, String>? headers,
  }) async {
    final uri = buildUri(url, params);
    final requestHeaders = <String, String>{
      ...defaultHeaders,
      ...?headers,
    };
    final body = data == null
        ? null
        : data is String
            ? data
            : jsonEncode(data);
    if (body != null && !requestHeaders.containsKey('Content-Type')) {
      // Dio v3 sent Map bodies as JSON by default; keep that behaviour.
      requestHeaders['Content-Type'] = 'application/json; charset=utf-8';
    }

    http.Response response;
    try {
      switch (method) {
        case 'POST':
          response =
              await _client.post(uri, headers: requestHeaders, body: body).timeout(timeout);
          break;
        case 'PUT':
          response =
              await _client.put(uri, headers: requestHeaders, body: body).timeout(timeout);
          break;
        default:
          response =
              await _client.get(uri, headers: requestHeaders).timeout(timeout);
      }
    } on TimeoutException {
      throw ManhuataiApiException('请求超时', url: uri.toString());
    } on ManhuataiApiException {
      rethrow;
    } catch (error) {
      throw ManhuataiApiException('网络请求失败: $error', url: uri.toString());
    }
    return _decode(response, uri);
  }

  dynamic _decode(http.Response response, Uri uri) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ManhuataiApiException(
        '接口返回异常状态码',
        url: uri.toString(),
        statusCode: response.statusCode,
      );
    }
    final text = utf8.decode(response.bodyBytes, allowMalformed: true).trim();
    if (text.isEmpty) {
      return <String, dynamic>{};
    }
    try {
      return jsonDecode(text);
    } on FormatException catch (error) {
      throw ManhuataiApiException(
        '响应不是合法 JSON: ${error.message}',
        url: uri.toString(),
        statusCode: response.statusCode,
      );
    }
  }

  void close() {
    if (_ownsClient) {
      _client.close();
    }
  }
}
