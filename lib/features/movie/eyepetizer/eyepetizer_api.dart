import 'package:dashboard/features/movie/eyepetizer/eyepetizer_category.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_endpoint.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_exception.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_issue.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_issue_entity.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_json.dart';
import 'package:dio/dio.dart';

/// The 开眼 HTTP client.
///
/// One class replaces the source's five static `ApiService` classes
/// (`module_home`, `module_discover`, `module_hot`, `module_detail`,
/// `module_common`) which all did `HttpUtil.get(url, headers: HttpConstant
/// .httpHeaders)` and then decoded `response.data` by hand. The transport is
/// injected so every ported screen can be driven by a fake in tests — the
/// source's static `HttpUtil` could not be.
///
/// Paging follows the source exactly: the server hands back an absolute
/// `nextPageUrl`, and the caller passes that URL straight back.
class EyepetizerApi {
  EyepetizerApi({Dio? dio, String baseUrl = EyepetizerEndpoint.baseUrl})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: baseUrl,
              headers: EyepetizerEndpoint.httpHeaders,
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
            ),
          );

  final Dio _dio;

  /// `v2/feed?num=1` — first page of the home feed
  /// (`module_home/lib/const/api_service.dart:4`).
  Future<EyepetizerIssueEntity> feed() =>
      _feed(EyepetizerEndpoint.feed, query: <String, dynamic>{'num': 1});

  /// The absolute `nextPageUrl` from a previous feed call.
  Future<EyepetizerIssueEntity> feedPage(String nextPageUrl) =>
      _feed(nextPageUrl);

  /// `v3/queries/hot` — the search screen's keyword chips.
  Future<List<String>> hotKeywords() async {
    final data = await _get(path: EyepetizerEndpoint.hotKeywords);
    return EyepetizerJson.asStringList(data);
  }

  /// `v1/search?query=<query>` — first page.
  ///
  /// The source's `VideoSearchModel.loadData` returned silently on a blank
  /// query; a transport method cannot "return nothing", so a blank query is a
  /// programming error here.
  Future<EyepetizerIssue> search(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(query, 'query', '搜索关键字不能为空');
    }
    return _issue(
      EyepetizerEndpoint.search,
      query: <String, dynamic>{'query': trimmed},
    );
  }

  /// The absolute `nextPageUrl` from a previous search call
  /// (`video_search_model.dart:36` passed it back unchanged).
  Future<EyepetizerIssue> searchPage(String nextPageUrl) => _issue(nextPageUrl);

  /// `v4/categories` — every browsable category.
  Future<List<EyepetizerCategory>> categories() async {
    final data = await _get(path: EyepetizerEndpoint.categories);
    if (data is! List) {
      throw const EyepetizerException('分类数据格式无法解析');
    }
    return EyepetizerJson.asMapList(
      data,
    ).map(EyepetizerCategory.fromJson).toList(growable: false);
  }

  /// `v4/categories/videoList?id=<id>&udid=..&deviceModel=..`
  /// (`category_detail_model.dart:20-25`).
  Future<EyepetizerIssue> categoryVideos(int categoryId) => _issue(
    EyepetizerEndpoint.categoryVideoList,
    query: <String, dynamic>{
      'id': categoryId,
      'udid': EyepetizerEndpoint.udid,
      'deviceModel': EyepetizerEndpoint.deviceModel,
    },
  );

  /// The absolute `nextPageUrl` from [categoryVideos], with the source's
  /// unconditional `&udid=..&deviceModel=..` suffix preserved.
  Future<EyepetizerIssue> categoryVideosPage(String nextPageUrl) =>
      _issue(EyepetizerEndpoint.categoryNextPage(nextPageUrl));

  /// `v4/video/related?id=<id>` — the detail screen's recommendation strip.
  Future<EyepetizerIssue> related(int videoId) => _issue(
    EyepetizerEndpoint.videoRelated,
    query: <String, dynamic>{'id': videoId},
  );

  /// `v4/rankList` — the source's rank tab (kept for parity; no ported screen
  /// consumes it yet).
  Future<EyepetizerIssue> rankList() => _issue(EyepetizerEndpoint.rankList);

  /// Releases the transport. Safe to call twice.
  void dispose() => _dio.close(force: true);

  Future<EyepetizerIssueEntity> _feed(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    final map = await _requestMap(path: path, query: query);
    return EyepetizerIssueEntity.fromJson(map);
  }

  Future<EyepetizerIssue> _issue(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    final map = await _requestMap(path: path, query: query);
    return EyepetizerIssue.fromJson(map);
  }

  Future<Map<String, dynamic>> _requestMap({
    required String path,
    Map<String, dynamic>? query,
  }) async {
    final data = await _get(path: path, query: query);
    if (data is! Map) {
      throw const EyepetizerException('开眼返回的数据格式无法解析');
    }
    return EyepetizerJson.asMap(data);
  }

  Future<Object?> _get({
    required String path,
    Map<String, dynamic>? query,
  }) async {
    final Response<dynamic> response;
    try {
      response = await _dio.get<dynamic>(path, queryParameters: query);
    } on DioException catch (error) {
      throw EyepetizerException(
        _messageFor(error),
        statusCode: error.response?.statusCode,
      );
    }
    final status = response.statusCode;
    if (status != null && (status < 200 || status >= 300)) {
      throw EyepetizerException('请求失败：HTTP $status', statusCode: status);
    }
    return response.data;
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
