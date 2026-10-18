import 'package:dashboard/features/short_video/douyin/douyin_api.dart';
import 'package:dashboard/features/short_video/douyin/douyin_feed_page_state.dart';
import 'package:dashboard/features/short_video/douyin/douyin_feed_controller.dart';
import 'package:dashboard/features/short_video/douyin/douyin_playback_builder.dart';
import 'package:flutter/material.dart';

/// 榜单页（源工程 `trendingScreen.dart` 的 billboard 部分）。
class DouyinFeedPage extends StatefulWidget {
  const DouyinFeedPage({
    super.key,
    this.api,
    this.controller,
    this.playbackBuilder,
  });

  final DouyinApi? api;
  final DouyinFeedController? controller;
  final DouyinPlaybackBuilder? playbackBuilder;

  @override
  State<DouyinFeedPage> createState() => DouyinFeedPageState();
}
