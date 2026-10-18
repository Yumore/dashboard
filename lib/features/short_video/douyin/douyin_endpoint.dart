/// 源工程三个 app 里硬编码的接口地址。
///
/// `flutter_app_cn/lib/config/api.dart`（榜单/作品信息/播放地址）与
/// `flutter_app/lib/config/api.dart`（tiktok share 列表）逐字对应。
class DouyinEndpoint {
  DouyinEndpoint._();

  static const String creatorOrigin = 'https://creator.douyin.com';
  static const String billboardPath = '/aweme/v1/creator/data/billboard/';
  static const String billboardUrl = '$creatorOrigin$billboardPath';

  static const String itemInfoOrigin = 'https://www.iesdouyin.com';
  static const String itemInfoPath = '/web/api/v2/aweme/iteminfo/';
  static const String itemInfoUrl = '$itemInfoOrigin$itemInfoPath';

  static const String playOrigin = 'https://aweme.snssdk.com';
  static const String playPath = '/aweme/v1/play/';
  static const String playUrl = '$playOrigin$playPath';

  static const String shareOrigin = 'https://www.tiktok.com';
  static const String shareItemListPath = '/share/item/list';
  static const String shareItemListUrl = '$shareOrigin$shareItemListPath';

  static const String creatorReferer =
      'https://creator.douyin.com/data/billboard/hot';
  static const String shareReferer = 'https://www.tiktok.com/trending/?lang';

  static const String mobileUserAgent =
      'Mozilla/5.0 (iPhone; CPU iPhone OS 11_0 like Mac OS X) '
      'AppleWebKit/604.1.38 (KHTML, like Gecko) Version/11.0 '
      'Mobile/15A372 Safari/604.1';
  static const String desktopUserAgent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64 AppleWebKit/537.36 '
      '(KHTML: like Gecko Chrome/80.0.3987.149 Safari/537.36';

  /// 播放地址接口的固定参数（顺序与源码一致）。
  static const Map<String, String> playQuery = <String, String>{
    'ratio': '720p',
    'line': '0',
    'media_type': '4',
    'vr_type': '0',
    'improve_bitrate': '0',
    'is_play_url': '1',
    'h265': '1',
    'adapt720': '1',
  };
}
