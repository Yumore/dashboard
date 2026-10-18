import 'package:dashboard/features/movie/fluttermovies/fluttermovies_api.dart';
import 'package:dashboard/features/movie/fluttermovies/fluttermovies_category_page.dart';
import 'package:dashboard/features/movie/fluttermovies/fluttermovies_home_page.dart';
import 'package:dashboard/features/movie/fluttermovies/fluttermovies_page.dart';
import 'package:dashboard/features/movie/fluttermovies/fluttermovies_ranking_page.dart';
import 'package:dashboard/features/movie/fluttermovies/fluttermovies_search_page.dart';
import 'package:flutter/material.dart';

class FlutterMoviesPageState extends State<FlutterMoviesPage> {
  static const List<String> _titles = <String>['今日看片', '分类', '排行榜', '搜索'];

  late final FlutterMoviesApi _api = FlutterMoviesApi(dio: widget.dio);

  /// 只有访问过的 Tab 才构建，避免一进模块就并发发起所有请求。
  final Set<int> _visited = <int>{0};
  int _index = 0;

  @override
  void dispose() {
    // 外部注入的 Dio 由外部负责关闭。
    if (widget.dio == null) _api.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(_titles[_index])),
    body: IndexedStack(
      index: _index,
      children: [
        for (var index = 0; index < _titles.length; index++)
          _visited.contains(index) ? _pageFor(index) : const SizedBox.shrink(),
      ],
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: _index,
      onDestinationSelected: (index) => setState(() {
        _index = index;
        _visited.add(index);
      }),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: '首页',
        ),
        NavigationDestination(
          icon: Icon(Icons.category_outlined),
          selectedIcon: Icon(Icons.category),
          label: '分类',
        ),
        NavigationDestination(
          icon: Icon(Icons.leaderboard_outlined),
          selectedIcon: Icon(Icons.leaderboard),
          label: '排行',
        ),
        NavigationDestination(
          icon: Icon(Icons.search_outlined),
          selectedIcon: Icon(Icons.search),
          label: '搜索',
        ),
      ],
    ),
  );

  Widget _pageFor(int index) {
    switch (index) {
      case 1:
        return FlutterMoviesCategoryPage(api: _api);
      case 2:
        return FlutterMoviesRankingPage(api: _api);
      case 3:
        return FlutterMoviesSearchPage(api: _api);
      case 0:
      default:
        return FlutterMoviesHomePage(api: _api);
    }
  }
}
