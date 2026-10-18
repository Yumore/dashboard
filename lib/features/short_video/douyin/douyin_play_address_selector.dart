import 'package:dashboard/features/short_video/douyin/douyin_play_address.dart';
import 'package:dashboard/features/short_video/douyin/douyin_video.dart';

/// 从 [DouyinVideo] 选出播放地址。
///
/// 顺序与源工程一致：
/// 1. `video.play_addr.uri` → 播放接口换无水印地址（源码 getRedirects 的入参）；
/// 2. `video.play_addr.url_list[0]` → 直链（源码未使用，但它是响应里现成的兜底）；
/// 3. `video.vid` → 播放接口参数；
/// 4. 都没有 → `none`，由 UI 报“没有可播放地址”。
class DouyinPlayAddressSelector {
  const DouyinPlayAddressSelector();

  DouyinPlayAddress select(DouyinVideo? video) {
    if (video == null) {
      return const DouyinPlayAddress.none();
    }
    if (video.playAddr.uri.isNotEmpty) {
      return DouyinPlayAddress.redirect(video.playAddr.uri);
    }
    if (video.playAddr.firstUrl.isNotEmpty) {
      return DouyinPlayAddress.direct(video.playAddr.firstUrl);
    }
    if (video.vid.isNotEmpty) {
      return DouyinPlayAddress.redirect(video.vid);
    }
    return const DouyinPlayAddress.none();
  }
}
