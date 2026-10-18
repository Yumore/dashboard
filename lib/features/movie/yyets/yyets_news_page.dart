import 'package:dashboard/features/movie/yyets/yyets_api.dart';
import 'package:dashboard/features/movie/yyets/yyets_link_launcher.dart';
import 'package:dashboard/features/movie/yyets/yyets_news_page_state.dart';
import 'package:flutter/material.dart';

/// 人人影视资讯页（源工程 `NewsPage`）。
class YyetsNewsPage extends StatefulWidget {
  const YyetsNewsPage({
    super.key,
    this.api,
    this.launcher = const YyetsLinkLauncher(),
  });

  /// 不传时页面自己创建并负责 dispose。
  final YyetsApi? api;

  /// 打开资讯网页的方式。
  final YyetsLinkLauncher launcher;

  @override
  State<YyetsNewsPage> createState() => YyetsNewsPageState();
}
