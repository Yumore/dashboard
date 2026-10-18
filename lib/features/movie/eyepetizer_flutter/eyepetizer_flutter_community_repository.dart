import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_base_list_data.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_endpoint.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_http.dart';

/// `lib/http/repository/community_repository.dart`.
class EyepetizerFlutterCommunityRepository {
  EyepetizerFlutterCommunityRepository({EyepetizerFlutterHttp? http})
    : _http = http ?? EyepetizerFlutterHttp();

  final EyepetizerFlutterHttp _http;

  EyepetizerFlutterHttp get http => _http;

  /// 获取社区推荐数据.
  ///
  /// [nextPageUrl] is passed straight through as the target URL. The caller
  /// passes `''` for the first page, and the transport treats an empty target
  /// URL as "use the endpoint path and base URL".
  Future<EyepetizerFlutterBaseListData> getCommunityRecommendData({
    String? nextPageUrl,
  }) async {
    final result = await _http.request(
      EyepetizerFlutterEndpoint.communityRecommend,
      targetUrl: nextPageUrl,
      method: 'GET',
    );
    return EyepetizerFlutterBaseListData.fromJson(result);
  }

  void dispose() => _http.dispose();
}
