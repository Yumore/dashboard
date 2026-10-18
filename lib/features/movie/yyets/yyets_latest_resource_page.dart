import 'package:dashboard/features/movie/yyets/yyets_api.dart';
import 'package:dashboard/features/movie/yyets/yyets_latest_resource_page_state.dart';
import 'package:dashboard/features/movie/yyets/yyets_link_launcher.dart';
import 'package:flutter/material.dart';

/// 最新资源页（源工程 `LatestResourcePage`）。
class YyetsLatestResourcePage extends StatefulWidget {
  const YyetsLatestResourcePage({
    super.key,
    this.api,
    this.launcher = const YyetsLinkLauncher(),
  });

  /// 不传时页面自己创建并负责 dispose。
  final YyetsApi? api;

  /// 打开磁力链接的方式。
  final YyetsLinkLauncher launcher;

  @override
  State<YyetsLatestResourcePage> createState() =>
      YyetsLatestResourcePageState();
}
