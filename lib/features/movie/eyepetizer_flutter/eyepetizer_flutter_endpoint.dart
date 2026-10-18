/// The 开眼 endpoints used by the surfaces this module ports.
///
/// Verbatim from `lib/http/api.dart` of the source app (`eyepetizer_flutter`).
/// The home/category/search/video-detail port that already lives in
/// `lib/features/movie/eyepetizer/` uses the `.../api/`-suffixed base URL of a
/// different source app; this module keeps *this* source's own base URLs,
/// including the separate account host that login and register call.
class EyepetizerFlutterEndpoint {
  const EyepetizerFlutterEndpoint._();

  /// `lib/http/api.dart:8` — `Api.BASE_URL`.
  static const String baseUrl = 'https://baobab.kaiyanapp.com';

  /// `lib/http/api.dart:10` — `Api.ACCOUNT_BASE_URL`.
  static const String accountBaseUrl = 'https://account.kaiyanapp.com';

  /// `lib/http/api.dart:13` — 获取验证码.
  static const String getVerificationCode = '/v1/api/sms/initialization';

  /// `lib/http/api.dart:16` — 注册.
  static const String register = '/v2/api/register';

  /// `lib/http/api.dart:19` — 登录.
  static const String login = '/v1/api/login';

  /// `lib/http/api.dart:28` — 社区->推荐.
  static const String communityRecommend = '/api/v7/community/tab/rec';

  /// `lib/http/api.dart:31` — 详情 (`Api.VIDEO_DETAIL + id`).
  static const String videoDetail = '/api/v2/video/';

  /// `lib/http/api.dart:34` — 相关视频.
  static const String relateVideo = '/api/v4/video/related';

  /// `lib/http/api.dart:40` — 个人主页 and 个人首页.
  static const String personHomepage = '/api/v5/userInfo/tab';

  /// `lib/http/api.dart:43` — 上传图片.
  static const String uploadPicture = '/api/tools/image';

  /// `lib/http/api.dart:46` — 编辑资料.
  static const String editUserData = '/api/v5/userInfo/edit';
}
