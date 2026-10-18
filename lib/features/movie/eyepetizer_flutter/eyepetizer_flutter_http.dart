import 'dart:convert';

import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_common_parameter_interceptor.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_endpoint.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_exception.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_json.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_string_util.dart';
import 'package:dio/dio.dart';

/// Replaces the source's singleton `HttpManager` (`lib/http/http_manager.dart`).
///
/// Faithful details, all load-bearing for the ported request bytes:
/// * non-`FormData` bodies are sent as **query parameters**, not as a body —
///   which is why login/register/save-person carry `username`, `password`, ...
///   in the query string even though the method is `POST`;
/// * an absolute `targetUrl` (a paging `nextPageUrl`) replaces the path and the
///   base URL is blanked so Dio does not prefix it;
/// * the base URL is otherwise the per-request override (the account host for
///   login/register) or [EyepetizerFlutterEndpoint.baseUrl];
/// * the source put `"responseType": ResponseType.plain` inside the *headers*
///   map — so it was sent as a header and the effective response type stayed
///   JSON. The port keeps the JSON behaviour and drops the bogus header.
class EyepetizerFlutterHttp {
  EyepetizerFlutterHttp({Dio? dio, String? baseUrl})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: baseUrl ?? EyepetizerFlutterEndpoint.baseUrl,
              connectTimeout: const Duration(milliseconds: 10000),
              receiveTimeout: const Duration(milliseconds: 3000),
              headers: <String, dynamic>{
                'content-type': 'application/x-www-form-urlencoded',
              },
            ),
          ) {
    _dio.interceptors.add(const EyepetizerFlutterCommonParameterInterceptor());
  }

  final Dio _dio;

  /// Exposed so a screen (or test) can attach extra interceptors.
  Dio get dio => _dio;

  /// `HttpManager.request`, with `data` kept for non-multipart calls and
  /// [formData] used for the upload call.
  Future<Map<String, dynamic>> request(
    String path, {
    String? baseUrl,
    String? targetUrl,
    Map<String, dynamic>? data,
    FormData? formData,
    String method = 'POST',
  }) async {
    if (!EyepetizerFlutterStringUtil.isEmpty(targetUrl)) {
      path = targetUrl!;
      _dio.options.baseUrl = '';
    } else if (!EyepetizerFlutterStringUtil.isEmpty(baseUrl)) {
      _dio.options.baseUrl = baseUrl!;
    } else {
      _dio.options.baseUrl = EyepetizerFlutterEndpoint.baseUrl;
    }

    final Response<dynamic> response;
    try {
      if (formData != null) {
        response = await _dio.request<dynamic>(
          path,
          data: formData,
          options: Options(method: method),
        );
      } else {
        response = await _dio.request<dynamic>(
          path,
          queryParameters: data,
          options: Options(method: method),
        );
      }
    } on DioException catch (error) {
      throw EyepetizerFlutterException(
        _messageFor(error),
        statusCode: error.response?.statusCode,
      );
    }

    final status = response.statusCode;
    if (status != null && (status < 200 || status >= 300)) {
      throw EyepetizerFlutterException('请求失败：HTTP $status', statusCode: status);
    }
    return _decode(response.data);
  }

  /// Releases the transport. Safe to call twice.
  void dispose() => _dio.close(force: true);

  static Map<String, dynamic> _decode(Object? body) {
    if (body is Map) return EyepetizerFlutterJson.asMap(body);
    if (body is String) {
      final decoded = jsonDecode(body);
      if (decoded is Map) return EyepetizerFlutterJson.asMap(decoded);
      throw const EyepetizerFlutterException('开眼返回的数据格式无法解析');
    }
    throw const EyepetizerFlutterException('开眼返回的数据格式无法解析');
  }

  static String _messageFor(DioException error) {
    final status = error.response?.statusCode;
    if (status != null) return '请求失败：HTTP $status';
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return '请求超时，请重试';
      case DioExceptionType.badCertificate:
        return '服务器证书校验失败';
      case DioExceptionType.cancel:
        return '请求已取消';
      case DioExceptionType.connectionError:
        return '网络连接失败，请检查网络';
      case DioExceptionType.badResponse:
        return '服务器返回异常';
      case DioExceptionType.unknown:
        return '网络请求失败，请重试';
    }
  }
}
