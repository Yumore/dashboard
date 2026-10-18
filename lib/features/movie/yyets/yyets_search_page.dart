import 'package:dashboard/features/movie/yyets/yyets_api.dart';
import 'package:dashboard/features/movie/yyets/yyets_link_launcher.dart';
import 'package:dashboard/features/movie/yyets/yyets_search_page_state.dart';
import 'package:flutter/material.dart';

/// 影视搜索页。
///
/// 源工程 `SearchPage`（`MainPage` 的搜索 tab）。[initialQuery] 非空时进入页面
/// 立即搜索一次，便于从其他页面带词跳转。
class YyetsSearchPage extends StatefulWidget {
  const YyetsSearchPage({
    super.key,
    this.api,
    this.launcher = const YyetsLinkLauncher(),
    this.initialQuery = '',
  });

  /// 不传时页面自己创建并负责 dispose。
  final YyetsApi? api;

  /// 打开下载 / 播放链接的方式。
  final YyetsLinkLauncher launcher;

  /// 进入页面时预填并立即搜索的关键字。
  final String initialQuery;

  @override
  State<YyetsSearchPage> createState() => YyetsSearchPageState();
}
