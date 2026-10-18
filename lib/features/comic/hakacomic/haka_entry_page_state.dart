import 'package:flutter/material.dart';
import 'package:dashboard/features/comic/hakacomic/haka_category.dart';
import 'package:dashboard/features/comic/hakacomic/haka_category_page.dart';
import 'package:dashboard/features/comic/hakacomic/haka_client.dart';
import 'package:dashboard/features/comic/hakacomic/haka_comic_detail_page.dart';
import 'package:dashboard/features/comic/hakacomic/haka_config.dart';
import 'package:dashboard/features/comic/hakacomic/haka_favorite_store.dart';
import 'package:dashboard/features/comic/hakacomic/haka_history_page.dart';
import 'package:dashboard/features/comic/hakacomic/haka_history_store.dart';
import 'package:dashboard/features/comic/hakacomic/haka_home_page.dart';
import 'package:dashboard/features/comic/hakacomic/haka_local_favorites_page.dart';
import 'package:dashboard/features/comic/hakacomic/haka_entry_page.dart';
import 'package:dashboard/features/comic/hakacomic/haka_read_record_store.dart';
import 'package:dashboard/features/comic/hakacomic/haka_repository.dart';
import 'package:dashboard/features/comic/hakacomic/haka_search_history_store.dart';
import 'package:dashboard/features/comic/hakacomic/haka_search_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Boots the feature: opens `shared_preferences`, builds the signed client and
/// hands the resulting stores to the four tab screens.
class HakaEntryPageState extends State<HakaEntryPage> {
  HakaRepository? _repository;
  HakaHistoryStore? _history;
  HakaFavoriteStore? _favorites;
  HakaReadRecordStore? _records;
  HakaSearchHistoryStore? _searchHistory;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final config = HakaConfig(
        baseUrl: widget.baseUrl,
        token: widget.token ?? '',
      );
      final client = HakaClient(config: config);
      if (!mounted) return;
      setState(() {
        _repository = HakaRepository(client: client);
        _history = HakaHistoryStore(prefs);
        _favorites = HakaFavoriteStore(prefs);
        _records = HakaReadRecordStore(prefs);
        _searchHistory = HakaSearchHistoryStore(prefs);
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error);
    }
  }

  void _openCategory(HakaCategory category) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => HakaCategoryPage(
          repository: _repository!,
          category: category,
          favorites: _favorites!,
          history: _history!,
          records: _records!,
        ),
      ),
    );
  }

  void _openComic(String comicId) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => HakaComicDetailPage(
          repository: _repository!,
          comicId: comicId,
          history: _history!,
          favorites: _favorites!,
          records: _records!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final error = _error;
    if (error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Haka 漫画')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 40),
                const SizedBox(height: 12),
                const Text('本地存储初始化失败'),
                const SizedBox(height: 8),
                Text('$error', textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () {
                    setState(() => _error = null);
                    _bootstrap();
                  },
                  child: const Text('重试'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final repository = _repository;
    if (repository == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Haka 漫画'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '首页'),
              Tab(text: '搜索'),
              Tab(text: '收藏'),
              Tab(text: '历史'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            HakaHomePage(
              repository: repository,
              onOpenCategory: _openCategory,
            ),
            HakaSearchPage(
              repository: repository,
              searchHistory: _searchHistory!,
              onOpenComic: _openComic,
            ),
            HakaLocalFavoritesPage(
              favoriteStore: _favorites!,
              onOpenComic: _openComic,
            ),
            HakaHistoryPage(
              historyStore: _history!,
              onOpenComic: _openComic,
            ),
          ],
        ),
      ),
    );
  }
}
