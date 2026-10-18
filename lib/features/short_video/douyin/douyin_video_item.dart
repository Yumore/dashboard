import 'package:dashboard/features/short_video/douyin/douyin_aweme.dart';
import 'package:dashboard/features/short_video/douyin/douyin_billboard_entry.dart';
import 'package:dashboard/features/short_video/douyin/douyin_play_address.dart';

/// 榜单一行 + 加载到的作品 + 解析出的播放地址。
class DouyinVideoItem {
  const DouyinVideoItem({
    required this.entry,
    required this.aweme,
    this.playAddress = const DouyinPlayAddress.none(),
    this.playUrl = '',
    this.error = '',
  });

  final DouyinBillboardEntry entry;
  final DouyinAweme aweme;
  final DouyinPlayAddress playAddress;
  final String playUrl;
  final String error;

  bool get hasPlayback => playUrl.isNotEmpty;

  bool get hasError => error.isNotEmpty;

  String get playbackTitle {
    final desc = aweme.desc.trim();
    if (desc.isNotEmpty) {
      return desc;
    }
    return '抖音视频 ${entry.rank}';
  }
}
