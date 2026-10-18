import 'package:dashboard/features/movie/yyets/yyets_api.dart';
import 'package:dashboard/features/movie/yyets/yyets_favorites_page_state.dart';
import 'package:dashboard/features/movie/yyets/yyets_link_launcher.dart';
import 'package:flutter/material.dart';

/// 我的收藏页（源工程 `FavoritesPage`）。
///
/// 需要登录态才能取到数据，见 [YyetsFavoritesPageState] 的说明。
class YyetsFavoritesPage extends StatefulWidget {
  const YyetsFavoritesPage({
    super.key,
    this.api,
    this.launcher = const YyetsLinkLauncher(),
  });

  /// 不传时页面自己创建并负责 dispose。
  final YyetsApi? api;

  /// 打开下载 / 播放链接的方式。
  final YyetsLinkLauncher launcher;

  @override
  State<YyetsFavoritesPage> createState() => YyetsFavoritesPageState();
}
