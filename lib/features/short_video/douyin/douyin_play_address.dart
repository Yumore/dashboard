import 'package:dashboard/features/short_video/douyin/douyin_play_address_kind.dart';

/// 一条作品“怎么拿到可播放地址”的描述。
///
/// 源工程 `RequestController.getRedirects(videoid)` 只走重定向；
/// `play_addr.url_list` 是带水印直链，仅在前者缺失时兜底。
class DouyinPlayAddress {
  const DouyinPlayAddress._(this.kind, {this.videoId = '', this.url = ''});

  const DouyinPlayAddress.redirect(String videoId)
      : this._(DouyinPlayAddressKind.redirect, videoId: videoId);

  const DouyinPlayAddress.direct(String url)
      : this._(DouyinPlayAddressKind.direct, url: url);

  const DouyinPlayAddress.none() : this._(DouyinPlayAddressKind.none);

  final DouyinPlayAddressKind kind;

  /// 作为 `/aweme/v1/play/?video_id=` 的值。
  final String videoId;

  /// 已经可播放的直链。
  final String url;

  bool get isRedirect => kind == DouyinPlayAddressKind.redirect;

  bool get isDirect => kind == DouyinPlayAddressKind.direct;

  bool get isEmpty => kind == DouyinPlayAddressKind.none;
}
