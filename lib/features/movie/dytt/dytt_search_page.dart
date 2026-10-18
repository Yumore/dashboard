import 'package:dashboard/features/movie/dytt/dytt_api.dart';
import 'package:dashboard/features/movie/dytt/dytt_search_page_state.dart';
import 'package:flutter/material.dart';

/// 电影天堂搜索页。
///
/// 源工程首页有一个从未接线的搜索图标，也没有搜索页；接口本身接受
/// `searchContent`，这里用同一 `movieList` 接口按分类补上搜索入口。
class DyttSearchPage extends StatefulWidget {
  const DyttSearchPage({required this.api, super.key});

  final DyttApi api;

  @override
  State<DyttSearchPage> createState() => DyttSearchPageState();
}
