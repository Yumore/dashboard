import 'package:flutter/widgets.dart';

/// 播放器构建器。
///
/// 生产实现返回 `MediaPlaybackPage`；测试注入占位组件，避免启动 media_kit
/// 原生解码器（宿主 `short_video_feed_page.dart` 的 `clipBuilder` 同款做法）。
typedef DouyinPlaybackBuilder = Widget Function(
  BuildContext context,
  String title,
  String url,
);
