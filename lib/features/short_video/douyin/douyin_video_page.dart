import 'package:dashboard/features/short_video/douyin/douyin_api.dart';
import 'package:dashboard/features/short_video/douyin/douyin_video_page_state.dart';
import 'package:dashboard/features/short_video/douyin/douyin_billboard_entry.dart';
import 'package:dashboard/features/short_video/douyin/douyin_playback_builder.dart';
import 'package:dashboard/features/short_video/douyin/douyin_video_controller.dart';
import 'package:flutter/material.dart';

/// 垂直翻页播放页（源工程 `trendingScreen.dart` 整屏 PageView）。
///
/// 播放器通过 [playbackBuilder] 注入，默认打开宿主 `MediaPlaybackPage`。
class DouyinVideoPage extends StatefulWidget {
  const DouyinVideoPage({
    super.key,
    required this.entries,
    this.initialIndex = 0,
    this.api,
    this.controller,
    this.playbackBuilder,
  });

  final List<DouyinBillboardEntry> entries;
  final int initialIndex;
  final DouyinApi? api;
  final DouyinVideoController? controller;
  final DouyinPlaybackBuilder? playbackBuilder;

  @override
  State<DouyinVideoPage> createState() => DouyinVideoPageState();
}
