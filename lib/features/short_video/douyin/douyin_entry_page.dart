import 'package:dashboard/features/short_video/douyin/douyin_api.dart';
import 'package:dashboard/features/short_video/douyin/douyin_entry_page_state.dart';
import 'package:flutter/material.dart';

/// 抖音模块入口。
///
/// 把源工程三个 app 的可迁移业务（公开榜单、作品信息、无水印播放地址、
/// 用户作品列表）暴露成两个入口，并在页面顶部明确说明签名已过期。
class DouyinEntryPage extends StatefulWidget {
  const DouyinEntryPage({super.key, this.api});

  final DouyinApi? api;

  @override
  State<DouyinEntryPage> createState() => DouyinEntryPageState();
}
