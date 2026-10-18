import 'package:dashboard/features/short_video/douyin/douyin_api.dart';
import 'package:dashboard/features/short_video/douyin/douyin_detail_page_state.dart';
import 'package:dashboard/features/short_video/douyin/douyin_detail_controller.dart';
import 'package:dashboard/features/short_video/douyin/douyin_playback_builder.dart';
import 'package:flutter/material.dart';

/// 作品详情页：元数据、无水印地址、播放、下载保存。
class DouyinDetailPage extends StatefulWidget {
  const DouyinDetailPage({
    super.key,
    required this.awemeId,
    this.api,
    this.controller,
    this.playbackBuilder,
  });

  final String awemeId;
  final DouyinApi? api;
  final DouyinDetailController? controller;
  final DouyinPlaybackBuilder? playbackBuilder;

  @override
  State<DouyinDetailPage> createState() => DouyinDetailPageState();
}
