import 'package:dashboard/features/short_video/douyin/douyin_endpoint.dart';

/// 源工程 `RequestController.headers` 的请求头构造。
class DouyinHeaders {
  DouyinHeaders._();

  /// 榜单 / iteminfo / 播放地址共用（`flutter_app_cn/lib/config/api.dart`）。
  static Map<String, String> creator() {
    return <String, String>{
      'referer': DouyinEndpoint.creatorReferer,
      'user-agent': DouyinEndpoint.mobileUserAgent,
    };
  }

  static Map<String, String> play() => creator();

  /// tiktok share 列表头。源工程把 `_signature` 作为普通头一起发；
  /// 这里同样发送 provider 的返回值，不额外拼接。
  static Map<String, String> share({
    required String signature,
    String count = '30',
    String minCursor = '0',
    String maxCursor = '0',
    String lang = 'en',
  }) {
    return <String, String>{
      'type': '5',
      'count': count,
      'minCursor': minCursor,
      'maxCursor': maxCursor,
      'lang': lang,
      '_signature': signature,
      'Accept': 'application/json: text/plain: */*',
      'User-Agent': DouyinEndpoint.desktopUserAgent,
      'Origin': DouyinEndpoint.shareOrigin,
      'Referer': DouyinEndpoint.shareReferer,
      'Accept-Language': 'en-GB:en-US;q',
    };
  }
}
