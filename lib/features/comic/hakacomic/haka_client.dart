import 'package:dio/dio.dart';
import 'package:dashboard/features/comic/hakacomic/haka_api_exception.dart';
import 'package:dashboard/features/comic/hakacomic/haka_config.dart';
import 'package:dashboard/features/comic/hakacomic/haka_method.dart';
import 'package:dashboard/features/comic/hakacomic/haka_signature.dart';

/// Signed HTTP client for the picacomic schema.
///
/// Mirrors `haka_comic/lib/network/client.dart`:
/// * every request carries `api-key`/`nonce`/`time`/`signature` headers;
/// * `400` surfaces the server `message`, `401` invalidates the token;
/// * transient failures (5xx, timeouts, connection errors) are retried up to
///   [maxRetries] attempts with a [retryDelay] pause between them.
class HakaClient {
  HakaClient({
    required this.config,
    Dio? dio,
    this.retryDelay = const Duration(seconds: 1),
  }) : dio = dio ?? Dio() {
    this.dio.options
      ..baseUrl = config.resolvedBaseUrl
      ..responseType = ResponseType.json
      ..connectTimeout = const Duration(seconds: 10)
      // Upstream let 400/401 through so the body `message` could be surfaced
      // (`haka_comic/lib/network/client.dart:30`).
      ..validateStatus = (status) =>
          status == 200 || status == 400 || status == 401;
  }

  final HakaConfig config;

  final Dio dio;

  /// Source paused `1s` between attempts (`client.dart:45`); tests set it to
  /// [Duration.zero].
  final Duration retryDelay;

  static const int maxRetries = 3;

  /// Invoked on a `401` so the caller can drop the cached token.
  void Function()? onUnauthorized;

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
  }) {
    return request(HakaMethod.get, path, query: query);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
  }) {
    return request(HakaMethod.post, path, data: data, query: query);
  }

  Future<Map<String, dynamic>> put(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
  }) {
    return request(HakaMethod.put, path, data: data, query: query);
  }

  Future<Map<String, dynamic>> delete(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
  }) {
    return request(HakaMethod.delete, path, data: data, query: query);
  }

  Future<Map<String, dynamic>> request(
    HakaMethod method,
    String path, {
    Object? data,
    Map<String, dynamic>? query,
  }) async {
    Object? lastError;
    for (var attempt = 0; attempt < maxRetries; attempt++) {
      final signedUrl = hakaSignedUrl(
        method: method,
        path: path,
        query: query,
      );
      try {
        final response = await dio.request<dynamic>(
          path,
          data: data,
          queryParameters: query,
          options: Options(
            method: method.value,
            headers: hakaHeaders(
              url: signedUrl,
              method: method,
              config: config,
            ),
          ),
        );
        return _unwrap(response);
      } on DioException catch (error) {
        if (!_isRetryable(error) || attempt == maxRetries - 1) {
          throw HakaApiException(_dioMessage(error));
        }
        lastError = error;
      }
      await Future<void>.delayed(retryDelay);
    }
    throw HakaApiException('请求失败: $lastError');
  }

  Map<String, dynamic> _unwrap(Response<dynamic> response) {
    final status = response.statusCode;
    final payload = response.data;
    if (payload == null) {
      throw HakaApiException('Empty data', statusCode: status);
    }
    switch (status) {
      case 200:
        return Map<String, dynamic>.from(payload as Map);
      case 400:
        throw HakaApiException(
          payload is Map ? '${payload['message']}' : '$payload',
          statusCode: 400,
        );
      case 401:
        onUnauthorized?.call();
        throw const HakaApiException('登录失效', statusCode: 401);
      default:
        throw HakaApiException(
          'Invalid Status Code $status',
          statusCode: status,
        );
    }
  }

  bool _isRetryable(DioException error) {
    final status = error.response?.statusCode;
    if (status != null) return status >= 500 && status < 600;
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return true;
      default:
        return false;
    }
  }

  String _dioMessage(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout) {
      return '连接超时';
    }
    if (error.type != DioExceptionType.unknown) {
      return error.message ?? '未知错误';
    }
    return error.toString();
  }
}
