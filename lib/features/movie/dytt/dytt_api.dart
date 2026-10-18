import 'dart:convert';

import 'package:dashboard/features/movie/dytt/dytt_api_exception.dart';
import 'package:dashboard/features/movie/dytt/dytt_endpoint.dart';
import 'package:dashboard/features/movie/dytt/dytt_headers.dart';
import 'package:dashboard/features/movie/dytt/dytt_movie_detail.dart';
import 'package:dashboard/features/movie/dytt/dytt_signature.dart';
import 'package:dashboard/features/movie/dytt/dytt_unsupported_signature.dart';
import 'package:dio/dio.dart';

/// 电影天堂公开接口客户端（`http://m.dydytt.net:8080/adminapi`）。
///
/// 与源工程 `lib/networkapi.dart` 对齐的要点：
/// * 两个接口都是 `POST`，请求体是表单（源工程 `http.post(body: Map)`），
///   不是 JSON；这里显式设置 `application/x-www-form-urlencoded`。
/// * 列表请求体的键顺序是 `categoryId`、`page`、`searchContent`。
/// * 详情响应是根对象，列表响应是 `{total, rows}`。
/// * 每个请求先签名，再发送；签名失败时一个字节都不会发出去。
///
/// 默认签名器为 [DyttUnsupportedSignature]，因此默认实例只会失败并在
/// [signingSupported] 上返回 `false`，页面据此展示迁移缺口。
class DyttApi {
  DyttApi({
    Dio? dio,
    DyttSignature signature = const DyttUnsupportedSignature(),
    DateTime Function()? now,
  }) : _dio =
           dio ??
           Dio(
             BaseOptions(
               connectTimeout: const Duration(seconds: 15),
               receiveTimeout: const Duration(seconds: 20),
             ),
           ),
       _signature = signature,
       _headers = DyttHeaders(signature: signature, now: now);

  final Dio _dio;
  final DyttSignature _signature;
  final DyttHeaders _headers;

  /// 默认实例为 `false`；注入可用的 [DyttSignature] 后才会发起请求。
  bool get signingSupported => _signature.isSupported;

  DyttSignature get signature => _signature;

  /// `/adminapi/api/movieList.json`
  ///
  /// [searchContent] 是源工程请求体里永远存在、但在列表页恒为空串的字段；
  /// 搜索页复用同一接口并传入关键词。
  Future<List<DyttMovieDetail>> movieList({
    required int categoryId,
    int page = 1,
    String searchContent = '',
  }) async {
    final json = await _post(DyttEndpoint.movieListUrl, <String, String>{
      'categoryId': '$categoryId',
      'page': '$page',
      'searchContent': searchContent,
    });
    final rows = json['rows'];
    if (rows is! List) {
      throw const DyttApiException('电影天堂列表响应缺少 rows 数组');
    }
    try {
      return List<DyttMovieDetail>.unmodifiable(
        rows.map((row) {
          if (row is! Map) {
            throw const FormatException('rows 中存在非对象元素');
          }
          return DyttMovieDetail.fromJson(Map<String, dynamic>.from(row));
        }),
      );
    } on FormatException catch (error) {
      throw DyttApiException('电影天堂列表 JSON 解析失败：${error.message}');
    }
  }

  /// `/adminapi/api/movieDetail.json`
  Future<DyttMovieDetail> movieDetail({
    required int categoryId,
    required int movieDetailId,
  }) async {
    final json = await _post(DyttEndpoint.movieDetailUrl, <String, String>{
      'categoryId': '$categoryId',
      'movieDetailId': '$movieDetailId',
    });
    try {
      return DyttMovieDetail.fromJson(json);
    } on FormatException catch (error) {
      throw DyttApiException('电影天堂详情 JSON 解析失败：${error.message}');
    }
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, String> body,
  ) async {
    // 先签名：签名器抛错时不会走到 Dio，避免发出没有 key 的请求。
    final headers = await _headers.build();
    final Response<dynamic> response;
    try {
      response = await _dio.post<dynamic>(
        path,
        data: body,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: headers,
          responseType: ResponseType.json,
        ),
      );
    } on DioException catch (error) {
      throw DyttApiException(
        '请求电影天堂失败：${error.message ?? error.type.name}',
        statusCode: error.response?.statusCode,
      );
    }
    if (response.statusCode != 200) {
      throw DyttApiException(
        '电影天堂返回 HTTP ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
    var data = response.data;
    if (data is String) {
      try {
        data = jsonDecode(data);
      } on FormatException {
        throw const DyttApiException('电影天堂响应不是合法 JSON');
      }
    }
    if (data is! Map) {
      throw const DyttApiException('电影天堂响应不是 JSON 对象');
    }
    return Map<String, dynamic>.from(data);
  }

  void dispose() => _dio.close(force: true);
}
