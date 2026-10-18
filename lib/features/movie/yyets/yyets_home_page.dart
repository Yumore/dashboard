import 'package:dashboard/features/movie/yyets/yyets_api.dart';
import 'package:dashboard/features/movie/yyets/yyets_home_page_state.dart';
import 'package:dashboard/features/movie/yyets/yyets_link_launcher.dart';
import 'package:flutter/material.dart';

/// 人人影视首页：6 个榜单 tab。
///
/// 源工程 `MainPage` 的“热榜” tab（`RankPage`）。移植版把它做成模块入口页面，
/// 依赖通过构造函数注入，方便宿主复用同一个 [YyetsApi] 或测试塞假实现。
class YyetsHomePage extends StatefulWidget {
  const YyetsHomePage({
    super.key,
    this.api,
    this.launcher = const YyetsLinkLauncher(),
  });

  /// 不传时页面自己创建并负责 dispose。
  final YyetsApi? api;

  /// 打开下载 / 播放链接的方式，测试可注入记录型实现。
  final YyetsLinkLauncher launcher;

  @override
  State<YyetsHomePage> createState() => YyetsHomePageState();
}
