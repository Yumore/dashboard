import 'package:dashboard/features/movie/flutterdouban/flutterdouban_celebrity.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_celebrity_works.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_comment_page.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_credits.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_endpoint.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_exception.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_json.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_review_page.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_search_result.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_subject_detail.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_subject_list.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_us_box_result.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_weekly_result.dart';
import 'package:dio/dio.dart';

/// The douban v2 client, built on the host's `dio` exactly like
/// [MovieAppApi] is for TMDb.
///
/// Everything the source's `lib/http/API.dart` really called is here, plus the
/// missing per-subject builders it hard-coded:
/// `in_theaters`, `coming_soon`, `top250`, `weekly`, `us_box`, `search`,
/// `subject/{id}`, `subject/{id}/comments`, `subject/{id}/reviews`,
/// `celebrity/{id}`, `celebrity/{id}/works`.
class FlutterDouBanApi {
  FlutterDouBanApi({
    Dio? dio,
    String? apiKey,
    String baseUrl = FlutterDouBanEndpoint.baseUrl,
  }) : _dio =
           dio ??
           Dio(
             BaseOptions(
               baseUrl: baseUrl,
               connectTimeout: const Duration(seconds: 10),
               receiveTimeout: const Duration(seconds: 20),
             ),
           ),
       _apiKey = apiKey ?? FlutterDouBanEndpoint.apiKey;

  /// The page size the source's `MockRequest` fixtures were produced with.
  static const int defaultCount = 20;

  final Dio _dio;
  final String _apiKey;

  Future<FlutterDouBanSubjectList> inTheaters({
    int start = 0,
    int count = defaultCount,
  }) async => FlutterDouBanSubjectList.fromJson(
    await _getJson(
      FlutterDouBanEndpoint.inTheaters,
      start: start,
      count: count,
    ),
  );

  Future<FlutterDouBanSubjectList> comingSoon({
    int start = 0,
    int count = defaultCount,
  }) async => FlutterDouBanSubjectList.fromJson(
    await _getJson(
      FlutterDouBanEndpoint.comingSoon,
      start: start,
      count: count,
    ),
  );

  Future<FlutterDouBanSubjectList> top250({
    int start = 0,
    int count = defaultCount,
  }) async => FlutterDouBanSubjectList.fromJson(
    await _getJson(FlutterDouBanEndpoint.top250, start: start, count: count),
  );

  /// `/v2/movie/weekly` takes no paging parameters.
  Future<FlutterDouBanWeeklyResult> weekly() async =>
      FlutterDouBanWeeklyResult.fromJson(
        await _getJson(FlutterDouBanEndpoint.weekly),
      );

  Future<FlutterDouBanUsBoxResult> usBox() async =>
      FlutterDouBanUsBoxResult.fromJson(
        await _getJson(FlutterDouBanEndpoint.usBox),
      );

  /// `/v2/movie/search?q=...&start=&count=` — throws [ArgumentError] on a blank
  /// query so no pointless request is issued (same rule as `MovieAppApi.search`).
  Future<FlutterDouBanSearchResult> search(
    String query, {
    int start = 0,
    int count = defaultCount,
  }) {
    final value = query.trim();
    if (value.isEmpty) throw ArgumentError('搜索关键词不能为空');
    return _getJson(
      FlutterDouBanEndpoint.search,
      start: start,
      count: count,
      query: value,
    ).then(FlutterDouBanSearchResult.fromJson);
  }

  Future<FlutterDouBanSubjectDetail> subject(String subjectId) async =>
      FlutterDouBanSubjectDetail.fromJson(
        await _getJson(FlutterDouBanEndpoint.subject(subjectId)),
      );

  /// Douban v2 has no standalone credits endpoint; credits live on the subject
  /// payload the source's detail page already parsed.
  Future<FlutterDouBanCredits> creditsOf(String subjectId) async =>
      FlutterDouBanCredits.fromJson(
        await _getJson(FlutterDouBanEndpoint.subject(subjectId)),
      );

  Future<FlutterDouBanCommentPage> subjectComments(
    String subjectId, {
    int start = 0,
    int count = defaultCount,
  }) async => FlutterDouBanCommentPage.fromJson(
    await _getJson(
      FlutterDouBanEndpoint.subjectComments(subjectId),
      start: start,
      count: count,
    ),
  );

  Future<FlutterDouBanReviewPage> subjectReviews(
    String subjectId, {
    int start = 0,
    int count = defaultCount,
  }) async => FlutterDouBanReviewPage.fromJson(
    await _getJson(
      FlutterDouBanEndpoint.subjectReviews(subjectId),
      start: start,
      count: count,
    ),
  );

  Future<FlutterDouBanCelebrity> celebrity(String celebrityId) async =>
      FlutterDouBanCelebrity.fromJson(
        await _getJson(FlutterDouBanEndpoint.celebrity(celebrityId)),
      );

  Future<FlutterDouBanCelebrityWorks> celebrityWorks(
    String celebrityId, {
    int start = 0,
    int count = defaultCount,
  }) async => FlutterDouBanCelebrityWorks.fromJson(
    await _getJson(
      FlutterDouBanEndpoint.celebrityWorks(celebrityId),
      start: start,
      count: count,
    ),
  );

  void dispose() => _dio.close();

  Future<Map<String, dynamic>> _getJson(
    String path, {
    int? start,
    int? count,
    String? query,
  }) async {
    final params = <String, dynamic>{'apikey': _apiKey};
    if (start != null) params['start'] = start;
    if (count != null) params['count'] = count;
    if (query != null) params['q'] = query;
    final Response<dynamic> response;
    try {
      response = await _dio.get<dynamic>(path, queryParameters: params);
    } on DioException catch (error) {
      throw FlutterDouBanException(
        _messageFor(error),
        statusCode: error.response?.statusCode,
      );
    }
    final status = response.statusCode;
    if (status != null && (status < 200 || status >= 300)) {
      throw FlutterDouBanException('请求失败：HTTP $status', statusCode: status);
    }
    final data = response.data;
    if (data is Map) return FlutterDouBanJson.asMap(data);
    throw const FlutterDouBanException('豆瓣返回的数据格式无法解析');
  }

  String _messageFor(DioException error) {
    switch (error.type) {
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
      default:
        return error.message ?? '网络请求失败';
    }
  }
}
