import 'package:dashboard/features/movie/yyets/yyets_api.dart';
import 'package:dashboard/features/movie/yyets/yyets_link_launcher.dart';
import 'package:dashboard/features/movie/yyets/yyets_resource_page_state.dart';
import 'package:flutter/material.dart';

/// 资源（下载 / 播放链接）页。
///
/// 源工程 `ResInfoPage`。构造参数与源工程路由参数一一对应：
/// `id` / `itemid` / `channel` / `season` / `episode`，由 `YyetsMovie` 或
/// `YyetsEpisode` 的 `resourceArguments(...)` 产生。
class YyetsResourcePage extends StatefulWidget {
  const YyetsResourcePage({
    super.key,
    required this.id,
    this.itemid = '',
    this.channel = '',
    this.season = '',
    this.episode = '',
    this.title,
    this.api,
    this.launcher = const YyetsLinkLauncher(),
  });

  final String id;
  final String itemid;
  final String channel;
  final String season;
  final String episode;

  /// AppBar 文案。
  final String? title;

  /// 不传时页面自己创建并负责 dispose。
  final YyetsApi? api;

  /// 打开下载 / 播放链接的方式，测试可注入记录型实现。
  final YyetsLinkLauncher launcher;

  @override
  State<YyetsResourcePage> createState() => YyetsResourcePageState();
}
