import 'package:dashboard/features/short_video/douyin/douyin_api.dart';
import 'package:dashboard/features/short_video/douyin/douyin_aweme.dart';
import 'package:dashboard/features/short_video/douyin/douyin_billboard_entry.dart';
import 'package:dashboard/features/short_video/douyin/douyin_error_message.dart';
import 'package:dashboard/features/short_video/douyin/douyin_play_address_selector.dart';
import 'package:dashboard/features/short_video/douyin/douyin_video_item.dart';

/// 播放页控制器：把榜单里每条链接换成“作品 + 播放地址”。
///
/// 对应源工程 `trendingScreen.dart` 的 `getTrending()` + `getVideos(entry)`：
/// 取 `link.split('/')[5]` 的作品 id，请求 iteminfo，再用
/// `play_addr.uri` 调播放接口换无水印地址。单条失败只标记该条，不中断整榜。
class DouyinVideoController {
  DouyinVideoController({
    required this.api,
    this.selector = const DouyinPlayAddressSelector(),
  });

  final DouyinApi api;
  final DouyinPlayAddressSelector selector;

  List<DouyinVideoItem> items = const <DouyinVideoItem>[];
  int currentIndex = 0;
  bool isLoading = false;
  String? error;

  Future<void> load(List<DouyinBillboardEntry> entries) async {
    isLoading = true;
    error = null;
    final loaded = <DouyinVideoItem>[];
    try {
      for (final entry in entries) {
        loaded.add(await _loadEntry(entry));
      }
    } finally {
      items = loaded;
      isLoading = false;
    }
  }

  Future<DouyinVideoItem> _loadEntry(DouyinBillboardEntry entry) async {
    final awemeId = entry.awemeId;
    if (awemeId.isEmpty) {
      return DouyinVideoItem(
        entry: entry,
        aweme: const DouyinAweme(),
        error: '榜单链接缺少作品 id',
      );
    }
    try {
      final aweme = await api.fetchAweme(awemeId);
      final address = selector.select(aweme.video);
      if (address.isDirect) {
        return DouyinVideoItem(
          entry: entry,
          aweme: aweme,
          playAddress: address,
          playUrl: address.url,
        );
      }
      if (address.isRedirect) {
        try {
          final playUrl = await api.resolvePlayUrl(address.videoId);
          return DouyinVideoItem(
            entry: entry,
            aweme: aweme,
            playAddress: address,
            playUrl: playUrl,
          );
        } catch (failure) {
          return DouyinVideoItem(
            entry: entry,
            aweme: aweme,
            playAddress: address,
            error: douyinErrorMessage(failure),
          );
        }
      }
      return DouyinVideoItem(
        entry: entry,
        aweme: aweme,
        error: '没有可用的播放地址',
      );
    } catch (failure) {
      return DouyinVideoItem(
        entry: entry,
        aweme: const DouyinAweme(),
        error: douyinErrorMessage(failure),
      );
    }
  }

  void select(int index) {
    if (index < 0 || index >= items.length) {
      return;
    }
    currentIndex = index;
  }
}
