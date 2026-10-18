import 'package:dashboard/features/movie/yyets/yyets_api.dart';
import 'package:dashboard/features/movie/yyets/yyets_detail_page_state.dart';
import 'package:dashboard/features/movie/yyets/yyets_link_launcher.dart';
import 'package:flutter/material.dart';

/// 影视详情页。
///
/// 源工程 `DetailPage`，通过路由参数 `id` 拉取详情。移植版改成显式构造参数
/// [movieId]（宿主没有全局路由表），[title] 只用于 AppBar 占位文案。
class YyetsDetailPage extends StatefulWidget {
  const YyetsDetailPage({
    super.key,
    required this.movieId,
    this.title,
    this.api,
    this.launcher = const YyetsLinkLauncher(),
  });

  /// `Api.detailUrl(id)` 里的 id（源工程路由参数 `id`）。
  final String movieId;

  /// AppBar 文案；详情返回后不会自动改名。
  final String? title;

  /// 不传时页面自己创建并负责 dispose。
  final YyetsApi? api;

  /// 打开下载 / 播放链接的方式。
  final YyetsLinkLauncher launcher;

  @override
  State<YyetsDetailPage> createState() => YyetsDetailPageState();
}
