/// The 开眼 (Eyepetizer / Kaiyan) public API endpoints the source app calls.
///
/// The source spread these constants across four module-local `api_service.dart`
/// files (`module_home`, `module_discover`, `module_detail`, `module_hot`) and
/// read them from the mutable static `HttpConstant.baseUrl`, which
/// `lib/app_initialize.dart:11` set to `http://baobab.kaiyanapp.com/api/`.
/// They are collected here unchanged.
class EyepetizerEndpoint {
  const EyepetizerEndpoint._();

  /// Verified base URL (`lib/app_initialize.dart:11`).
  static const String baseUrl = 'http://baobab.kaiyanapp.com/api/';

  /// The device identifier the source hard-coded into *every* category request
  /// (`module_discover/lib/viewmodel/category_detail_model.dart:24`).
  static const String udid = 'd2807c895f0348a180148c9dfa6f2feeac0781b5';

  /// The device model the source hard-coded next to [udid].
  static const String deviceModel = 'Android';

  /// `module_home/lib/const/api_service.dart:4` — `v2/feed?num=1`.
  static const String feed = 'v2/feed';

  /// `module_home/lib/const/api_service.dart:6` — `v3/queries/hot`.
  static const String hotKeywords = 'v3/queries/hot';

  /// `module_home/lib/const/api_service.dart:8` — `v1/search?query=`.
  static const String search = 'v1/search';

  /// `module_discover/lib/constant/api_service.dart:5` — `v4/categories`.
  static const String categories = 'v4/categories';

  /// `module_discover/lib/constant/api_service.dart:10` — `v4/categories/videoList?`.
  static const String categoryVideoList = 'v4/categories/videoList';

  /// `module_discover`/`module_detail` — `v4/video/related?id=`.
  static const String videoRelated = 'v4/video/related';

  /// `module_hot/lib/constant/api_service.dart:4` — `v4/rankList`.
  static const String rankList = 'v4/rankList';

  /// `module_common/lib/constant/http_constant.dart:3-13`, verbatim.
  static const Map<String, String> httpHeaders = <String, String>{
    'Accept': 'application/json, text/plain, */*',
    'Accept-Encoding': 'gzip, deflate, br',
    'Accept-Language': 'zh-CN,zh;q=0.9',
    'Connection': 'keep-alive',
    'Content-Type': 'application/json',
    'User-Agent':
        'Mozilla/5.0 (iPhone; CPU iPhone OS 11_0 like Mac OS X) '
        'AppleWebKit/604.1.38 (KHTML, like Gecko) Version/11.0 '
        'Mobile/15A372 Safari/604.1',
  };

  /// The source appended `&udid=..&deviceModel=..` to a category `nextPageUrl`
  /// even though that URL may already carry both (`category_detail_model.dart:24`).
  /// The duplication is preserved deliberately so the ported request bytes match
  /// the source exactly.
  static String categoryNextPage(String nextPageUrl) =>
      '$nextPageUrl&udid=$udid&deviceModel=$deviceModel';
}
