import 'package:dashboard/features/comic/manhuatai/manhuatai_category_page.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_home_page.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_library_page.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_library_store.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_rank_view.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_recommend_view.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_search_page.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_source.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_update_view.dart';
import 'package:flutter/material.dart';

class ManhuataiHomePageState extends State<ManhuataiHomePage> {
  late final ManhuataiSource _source = widget.source ?? ManhuataiSource();
  late final ManhuataiLibraryStore _store =
      widget.store ?? ManhuataiLibraryStore();
  late int _index = widget.initialIndex;

  @override
  void dispose() {
    if (widget.source == null) {
      _source.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('漫画台'),
        actions: <Widget>[
          IconButton(
            tooltip: '搜索',
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ManhuataiSearchPage(
                    source: _source,
                    store: _store,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _index,
        children: <Widget>[
          ManhuataiRecommendView(source: _source, store: _store),
          ManhuataiUpdateView(source: _source, store: _store),
          ManhuataiRankView(source: _source, store: _store),
          ManhuataiCategoryPage(source: _source, store: _store),
          ManhuataiLibraryPage(store: _store, source: _source),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.recommend_outlined),
            selectedIcon: Icon(Icons.recommend),
            label: '推荐',
          ),
          NavigationDestination(
            icon: Icon(Icons.update_outlined),
            selectedIcon: Icon(Icons.update),
            label: '更新',
          ),
          NavigationDestination(
            icon: Icon(Icons.leaderboard_outlined),
            selectedIcon: Icon(Icons.leaderboard),
            label: '排行',
          ),
          NavigationDestination(
            icon: Icon(Icons.category_outlined),
            selectedIcon: Icon(Icons.category),
            label: '分类',
          ),
          NavigationDestination(
            icon: Icon(Icons.collections_bookmark_outlined),
            selectedIcon: Icon(Icons.collections_bookmark),
            label: '书架',
          ),
        ],
      ),
    );
  }
}
