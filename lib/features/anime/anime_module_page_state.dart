import 'package:dashboard/features/anime/anime_catalogue_tab.dart';
import 'package:dashboard/features/anime/anime_detail_launcher.dart';
import 'package:dashboard/features/anime/anime_entry_tab.dart';
import 'package:dashboard/features/anime/anime_favorites_tab.dart';
import 'package:dashboard/features/anime/anime_hub_controller.dart';
import 'package:dashboard/features/anime/anime_recent_tab.dart';
import 'package:dashboard/features/anime/anime_search_tab.dart';
import 'package:dashboard/features/shared/ui/module_page_scaffold.dart';
import 'package:dashboard/features/anime/anime_module_page.dart';
import 'package:flutter/material.dart';

class AnimeModulePageState extends State<AnimeModulePage> {
  final _controller = AnimeHubController();

  @override
  void initState() {
    super.initState();
    _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: ModulePageScaffold(
        title: '动漫',
        actions: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final last = _controller.lastEpisode;
              return IconButton(
                tooltip: last == null ? '暂无观看记录' : '继续观看：${last.title}',
                icon: const Icon(Icons.play_circle_outline),
                onPressed: last == null
                    ? null
                    : () => openAnimeEpisode(context, _controller, last),
              );
            },
          ),
        ],
        bottom: const TabBar(
          isScrollable: true,
          tabs: [
            Tab(text: '入口'),
            Tab(text: '最近更新'),
            Tab(text: '目录'),
            Tab(text: '搜索'),
            Tab(text: '收藏'),
          ],
        ),
        body: TabBarView(
          children: [
            const AnimeEntryTab(),
            AnimeRecentTab(controller: _controller),
            AnimeCatalogueTab(controller: _controller),
            AnimeSearchTab(controller: _controller),
            AnimeFavoritesTab(controller: _controller),
          ],
        ),
      ),
    );
  }
}
