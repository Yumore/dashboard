import 'package:dashboard/features/short_video/douyin/douyin_api.dart';
import 'package:dashboard/features/short_video/douyin/douyin_user_post_page_state.dart';
import 'package:dashboard/features/short_video/douyin/douyin_user_post_controller.dart';
import 'package:flutter/material.dart';

/// 用户作品页：`tiktok.com/share/item/list`（需要 `_signature`）。
class DouyinUserPostPage extends StatefulWidget {
  const DouyinUserPostPage({super.key, this.api, this.controller});

  final DouyinApi? api;
  final DouyinUserPostController? controller;

  @override
  State<DouyinUserPostPage> createState() => DouyinUserPostPageState();
}
