import 'package:dashboard/features/movie/dytt/dytt_api.dart';
import 'package:dashboard/features/movie/dytt/dytt_category.dart';
import 'package:dashboard/features/movie/dytt/dytt_list_page_state.dart';
import 'package:flutter/material.dart';

/// 单个分类的电影列表，对应源工程 `ListPage`。
///
/// 首页的 10 个标签各放一个实例；也可以单独打开作为分类页。
class DyttListPage extends StatefulWidget {
  const DyttListPage({
    required this.category,
    required this.api,
    this.showAppBar = false,
    super.key,
  });

  final DyttCategory category;
  final DyttApi api;

  /// 作为独立页面打开时显示 AppBar；首页标签内为 `false`。
  final bool showAppBar;

  @override
  State<DyttListPage> createState() => DyttListPageState();
}
