import 'dart:convert';

import 'package:dashboard/features/short_video/douyin/douyin_api_exception.dart';
import 'package:dashboard/features/short_video/douyin/douyin_aweme.dart';
import 'package:dashboard/features/short_video/douyin/douyin_billboard_response.dart';
import 'package:dashboard/features/short_video/douyin/douyin_headers.dart';
import 'package:dashboard/features/short_video/douyin/douyin_post_list_response.dart';
import 'package:dashboard/features/short_video/douyin/douyin_request.dart';
import 'package:dashboard/features/short_video/douyin/douyin_signature_provider.dart';
import 'package:dashboard/features/short_video/douyin/douyin_signature_rejected.dart';
import 'package:dashboard/features/short_video/douyin/douyin_stale_signature.dart';
import 'package:dashboard/features/short_video/douyin/douyin_video_list_response.dart';
import 'package:dio/dio.dart';

/// 抖音公开接口客户端。
///
/// 三个端点与源工程一一对应：
/// * 榜单 `creator.douyin.com/aweme/v1/creator/data/billboard/`；
/// * 作品信息 `www.iesdouyin.com/web/api/v2/aweme/iteminfo/`；
/// * 播放地址 302 `aweme.snssdk.com/aweme/v1/play/`；
/// * 用户作品 `www.tiktok.com/share/item/list`（需要 `_signature`）。
class DouyinApi {
  DouyinApi({
    Dio? dio,
    DouyinSignatureProvider signature = const DouyinStaleSignature(),
  })  : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 20),
              ),
            ),
        _signature = signature;

  final Dio _dio;
  final DouyinSignatureProvider _signature;

  DouyinSignatureProvider get signature => _signature;

  bool get signingSupported => _signature.isSupported;

  Future<DouyinBillboardResponse> fetchBillboard({int billboardType = 4}) async {
    final data = await _getJson(
      DouyinRequest.billboard(billboardType: billboardType),
      headers: DouyinHeaders.creator(),
    );
    final response = DouyinBillboardResponse.fromJson(data);
    if (!response.isSuccess) {
      throw DouyinApiException(
        '抖音榜单接口返回 status_code=${response.statusCode}'
        '${response.statusMsg.isEmpty ? '' : '：${response.statusMsg}'}',
        statusCode: response.statusCode,
      );
    }
    return response;
  }

  Future<DouyinVideoListResponse> fetchVideoList(
    Iterable<String> awemeIds,
  ) async {
    final ids = awemeIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toList(growable: false);
    if (ids.isEmpty) {
      throw const DouyinApiException('抖音作品信息请求缺少 aweme_id');
    }
    final data = await _getJson(
      DouyinRequest.videoList(ids),
      headers: DouyinHeaders.creator(),
    );
    final response = DouyinVideoListResponse.fromJson(data);
    if (!response.isSuccess) {
      throw DouyinApiException(
        '抖音作品信息接口返回 status_code=${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
    return response;
  }

  Future<DouyinAweme> fetchAweme(String awemeId) async {
    final id = awemeId.trim();
    if (id.isEmpty) {
      throw const DouyinApiException('抖音作品信息请求缺少 aweme_id');
    }
    final response = await fetchVideoList(<String>[id]);
    final aweme = response.first;
    if (aweme == null) {
      throw DouyinApiException('抖音作品 $id 不存在或已下架');
    }
    return aweme;
  }

  /// 用户作品列表。签名不可用时**不发送请求**，直接抛
  /// [DouyinSignatureRejected]；HTTP 403 同样按签名被拒处理。
  Future<DouyinPostListResponse> fetchUserPosts({
    String secUid = '',
    String id = '',
    String shareUid = '',
    int count = 30,
    int minCursor = 0,
    int maxCursor = 0,
    String lang = 'en',
  }) async {
    if (!_signature.isSupported) {
      throw const DouyinSignatureRejected(
        reason: '签名提供者 isSupported=false，未发送 /share/item/list 请求',
      );
    }
    final signature = (await _signature.signature()).trim();
    if (signature.isEmpty) {
      throw const DouyinSignatureRejected(
        reason: '签名提供者返回空串，未发送 /share/item/list 请求',
      );
    }
    final uri = DouyinRequest.userPosts(
      signature: signature,
      secUid: secUid,
      id: id,
      count: count,
      minCursor: minCursor,
      maxCursor: maxCursor,
      shareUid: shareUid,
      lang: lang,
    );
    final Response<dynamic> response;
    try {
      response = await _dio.getUri<dynamic>(
        uri,
        options: Options(
          headers: DouyinHeaders.share(
            signature: signature,
            count: '$count',
            minCursor: '$minCursor',
            maxCursor: '$maxCursor',
            lang: lang,
          ),
          responseType: ResponseType.json,
          validateStatus: (_) => true,
        ),
      );
    } on DioException catch (error) {
      throw DouyinApiException(
        '请求抖音用户作品接口失败：${error.message ?? error.type.name}',
        statusCode: error.response?.statusCode,
      );
    }
    if (response.statusCode == 403) {
      throw DouyinSignatureRejected(signature: signature);
    }
    if (response.statusCode != 200) {
      throw DouyinApiException(
        '抖音用户作品接口返回 HTTP ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
    final data = _decode(response.data);
    final posts = DouyinPostListResponse.fromJson(data);
    if (!posts.isSuccess) {
      throw DouyinApiException(
        '抖音用户作品接口返回 statusCode=${posts.statusCode}'
        '${posts.errMsg.isEmpty ? '' : '：${posts.errMsg}'}',
        statusCode: posts.statusCode,
      );
    }
    return posts;
  }

  /// `RequestController.getRedirects`：`followRedirects: false` 读 302 的
  /// `Location`；没有该响应头时按源码从响应体 `split('"')[1]` 兜底。
  Future<String> resolvePlayUrl(String videoId) async {
    final id = videoId.trim();
    if (id.isEmpty) {
      throw const DouyinApiException('抖音播放地址请求缺少 video_id');
    }
    final Response<dynamic> response;
    try {
      response = await _dio.getUri<dynamic>(
        DouyinRequest.play(id),
        options: Options(
          headers: DouyinHeaders.play(),
          followRedirects: false,
          responseType: ResponseType.plain,
          validateStatus: (status) => (status ?? 0) < 500,
        ),
      );
    } on DioException catch (error) {
      throw DouyinApiException(
        '解析抖音播放地址失败：${error.message ?? error.type.name}',
        statusCode: error.response?.statusCode,
      );
    }
    if (response.statusCode != 302) {
      throw DouyinApiException(
        '抖音播放接口未返回 302（HTTP ${response.statusCode}）',
        statusCode: response.statusCode,
      );
    }
    final location = response.headers.value('location');
    if (location != null && location.isNotEmpty) {
      return location;
    }
    final body = response.data?.toString() ?? '';
    final segments = body.split('"');
    if (segments.length > 1 && segments[1].isNotEmpty) {
      return segments[1];
    }
    throw const DouyinApiException(
      '抖音播放接口 302 响应缺少 Location',
      statusCode: 302,
    );
  }

  void dispose() {
    _dio.close(force: true);
  }

  Future<Map<String, dynamic>> _getJson(
    Uri uri, {
    required Map<String, String> headers,
  }) async {
    final Response<dynamic> response;
    try {
      response = await _dio.getUri<dynamic>(
        uri,
        options: Options(
          headers: headers,
          responseType: ResponseType.json,
          validateStatus: (_) => true,
        ),
      );
    } on DioException catch (error) {
      throw DouyinApiException(
        '请求抖音接口失败：${error.message ?? error.type.name}',
        statusCode: error.response?.statusCode,
      );
    }
    if (response.statusCode != 200) {
      throw DouyinApiException(
        '抖音接口返回 HTTP ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
    final data = _decode(response.data);
    if (data is! Map) {
      throw const DouyinApiException('抖音响应不是 JSON 对象');
    }
    return Map<String, dynamic>.from(data);
  }

  Object? _decode(Object? data) {
    if (data is String) {
      try {
        return jsonDecode(data);
      } on FormatException {
        throw const DouyinApiException('抖音响应不是合法 JSON');
      }
    }
    return data;
  }
}
