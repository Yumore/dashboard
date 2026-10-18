import 'dart:async';

import 'package:dashboard/features/novel/flutternovel/api/api_result.dart';
import 'package:dashboard/features/novel/flutternovel/api/dmzj_v3_api.dart';
import 'package:dashboard/features/novel/flutternovel/api/zssq_api.dart';
import 'package:dashboard/features/novel/flutternovel/flutternovel_page.dart';
import 'package:dashboard/features/novel/flutternovel/models/dmzj_recommend_section.dart';
import 'package:dashboard/features/novel/flutternovel/models/flutter_novel_shelf_entry.dart';
import 'package:dashboard/features/novel/flutternovel/models/novel_key_word_search.dart';
import 'package:dashboard/features/novel/flutternovel/models/novel_search_book.dart';
import 'package:dashboard/features/novel/flutternovel/page/flutternovel_book_page.dart';
import 'package:dashboard/features/novel/flutternovel/store/flutter_novel_store.dart';
import 'package:dashboard/features/novel/flutternovel/store/in_memory_flutter_novel_store.dart';
import 'package:dashboard/features/novel/flutternovel/store/novel_chapter_cache.dart';
import 'package:flutter/material.dart';

/// State for [FlutterNovelPage].
///
/// Flow mirrors the source's home: 书架 (the local shelf) and 搜索 (search +
/// recommend rails). A book opens [FlutterNovelBookPage] for the intro,
/// chapter list, short comments and the "开始阅读" action.
class FlutterNovelPageState extends State<FlutterNovelPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(
    length: 2,
    vsync: this,
    initialIndex: widget.initialTab.clamp(0, 1),
  );

  late final ZssqApi _api = widget.api ?? ZssqApi();
  late final DmzjV3Api _dmzjApi = widget.dmzjApi ?? DmzjV3Api();
  late final bool _ownsApi = widget.api == null;
  late final bool _ownsDmzjApi = widget.dmzjApi == null;

  FlutterNovelStore? _store;

  /// The shelf tab's state.
  List<FlutterNovelShelfEntry> _shelf = const <FlutterNovelShelfEntry>[];
  bool _shelfLoading = true;
  String? _shelfError;

  /// The search tab's state.
  final TextEditingController _query = TextEditingController();
  List<NovelSearchBook> _results = const <NovelSearchBook>[];
  List<String> _hotWords = const <String>[];
  bool _searching = false;
  bool _searched = false;
  String? _searchError;

  /// The recommend rail (dmzj v3).
  List<DmzjRecommendSection> _recommend = const <DmzjRecommendSection>[];
  bool _recommendLoading = true;
  String? _recommendError;

  NovelChapterCache? _cache;

  FlutterNovelStore get _storeOrThrow => _store!;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _tabs.dispose();
    _query.dispose();
    if (_ownsApi) _api.close();
    if (_ownsDmzjApi) _dmzjApi.close();
    _store?.close();
    super.dispose();
  }

  /// Warmed up outside build: open storage, publish the shelf, then fetch the
  /// recommend rail and hot words (both network) from here.
  Future<void> _initialize() async {
    final store = widget.store ?? InMemoryFlutterNovelStore();
    try {
      await store.open();
      _store = store;
    } catch (error) {
      _shelfLoading = false;
      _shelfError = '本地书架不可用: $error';
      if (mounted) setState(() {});
      return;
    }
    _cache = widget.cache ?? NovelChapterCache(store: store);
    await _loadShelf();
    unawaited(_loadHotWords());
    unawaited(_loadRecommend());
  }

  Future<void> _loadShelf() async {
    if (!mounted) return;
    setState(() {
      _shelfLoading = true;
      _shelfError = null;
    });
    try {
      final entries = await _storeOrThrow.loadShelf();
      if (!mounted) return;
      setState(() {
        _shelf = entries;
        _shelfLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _shelfLoading = false;
        _shelfError = '$error';
      });
    }
  }

  Future<void> _loadHotWords() async {
    final result = await _api.getHotSearchWord();
    if (!mounted) return;
    final words = result.data ?? const <String>[];
    if (words.isEmpty) return;
    setState(() => _hotWords = words);
  }

  Future<void> _loadRecommend() async {
    if (!mounted) return;
    setState(() {
      _recommendLoading = true;
      _recommendError = null;
    });
    try {
      final result = await _dmzjApi.fetchRecommend();
      if (!mounted) return;
      setState(() {
        _recommend = result;
        _recommendLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _recommendLoading = false;
        _recommendError = '$error';
      });
    }
  }

  Future<void> _search([String? keyword]) async {
    final query = (keyword ?? _query.text).trim();
    if (query.isEmpty) return;
    if (keyword != null) _query.text = keyword;
    setState(() {
      _searching = true;
      _searched = true;
      _searchError = null;
    });
    try {
      final ApiResult<NovelKeyWordSearch> result = await _api
          .searchTargetKeyWord(query);
      if (!mounted) return;
      final payload = result.data;
      if (!result.isSuccess || payload == null) {
        setState(() {
          _searching = false;
          _results = const <NovelSearchBook>[];
          _searchError = '搜索失败，请稍后再试';
        });
        return;
      }
      setState(() {
        _results = payload.books;
        _searching = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _searching = false;
        _searchError = '$error';
      });
    }
  }

  Future<void> _removeFromShelf(String bookId) async {
    final entry = _shelf.firstWhere(
      (item) => item.bookId == bookId,
      orElse: () => FlutterNovelShelfEntry(),
    );
    try {
      await _storeOrThrow.removeShelfEntry(bookId);
    } catch (_) {
      // The shelf row survives; the user can retry.
    }
    if (!mounted) return;
    setState(() {
      _shelf = _shelf.where((item) => item.bookId != bookId).toList();
    });
    if (entry.bookId.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已从书架移除《${entry.title}》')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('网络小说'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const <Widget>[
            Tab(text: '书架'),
            Tab(text: '搜索'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: <Widget>[
          _NovelShelfTab(
            entries: _shelf,
            loading: _shelfLoading,
            error: _shelfError,
            recommend: _recommend,
            recommendLoading: _recommendLoading,
            recommendError: _recommendError,
            onRetry: _loadShelf,
            onRetryRecommend: _loadRecommend,
            onRemove: _removeFromShelf,
            onOpen: _openBook,
          ),
          _NovelSearchTab(
            query: _query,
            hotWords: _hotWords,
            results: _results,
            searching: _searching,
            searched: _searched,
            error: _searchError,
            onSubmit: _search,
            onKeyword: _search,
            onOpen: _openBook,
          ),
        ],
      ),
    );
  }

  void _openBook(NovelSearchBook book) {
    final cache = _cache ??= NovelChapterCache(store: _storeOrThrow);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => FlutterNovelBookPage(
          bookId: book.id ?? '',
          preview: book,
          api: _api,
          store: _storeOrThrow,
          cache: cache,
        ),
      ),
    );
  }
}

/// 书架 — the local shelf plus the dmzj recommend rail.
class _NovelShelfTab extends StatelessWidget {
  const _NovelShelfTab({
    required this.entries,
    required this.loading,
    required this.error,
    required this.recommend,
    required this.recommendLoading,
    required this.recommendError,
    required this.onRetry,
    required this.onRetryRecommend,
    required this.onRemove,
    required this.onOpen,
  });

  final List<FlutterNovelShelfEntry> entries;
  final bool loading;
  final String? error;
  final List<DmzjRecommendSection> recommend;
  final bool recommendLoading;
  final String? recommendError;
  final VoidCallback onRetry;
  final VoidCallback onRetryRecommend;
  final Future<void> Function(String bookId) onRemove;
  final void Function(NovelSearchBook book) onOpen;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return RefreshIndicator(
      onRefresh: () async {
        onRetry();
        onRetryRecommend();
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: <Widget>[
          if (error != null) _NovelErrorBanner(message: error!, onRetry: onRetry),
          if (entries.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                children: <Widget>[
                  Icon(Icons.menu_book_outlined, size: 48),
                  SizedBox(height: 8),
                  Text('书架还是空的', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 4),
                  Text('去「搜索」找一本，或直接从下面的推荐里选一本'),
                ],
              ),
            )
          else
            for (final entry in entries)
              Dismissible(
                key: ValueKey<String>('shelf-${entry.bookId}'),
                direction: DismissDirection.endToStart,
                background: const ColoredBox(color: Colors.redAccent),
                onDismissed: (_) => onRemove(entry.bookId),
                child: ListTile(
                  leading: _NovelCover(url: entry.cover, width: 40, height: 56),
                  title: Text(entry.title),
                  subtitle: Text(
                    '${entry.author.isEmpty ? '佚名' : entry.author}'
                    '${entry.lastChapter.isEmpty ? '' : ' · ${entry.lastChapter}'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => onOpen(
                    NovelSearchBook(
                      id: entry.bookId,
                      title: entry.title,
                      author: entry.author,
                      cover: entry.cover,
                    ),
                  ),
                ),
              ),
          const Divider(height: 32),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('推荐', style: TextStyle(fontSize: 18)),
          ),
          if (recommendLoading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (recommendError != null)
            _NovelErrorBanner(
              message: recommendError!,
              onRetry: onRetryRecommend,
            )
          else
            for (final section in recommend)
              if (!section.isEmpty) ...<Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Text(
                    section.title ?? '推荐',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                SizedBox(
                  height: 132,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: section.books.length,
                    itemBuilder: (context, index) {
                      final brief = section.books[index];
                      return InkWell(
                        onTap: () => onOpen(
                          NovelSearchBook(
                            id: brief.id,
                            title: brief.name,
                            author: brief.authors,
                            cover: brief.cover,
                          ),
                        ),
                        child: SizedBox(
                          width: 80,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              _NovelCover(url: brief.cover, width: 72, height: 96),
                              const SizedBox(height: 4),
                              Text(
                                brief.name ?? '',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
        ],
      ),
    );
  }
}

/// 搜索 — keyword search against the zhuishushenqi `fuzzy-search` endpoint.
class _NovelSearchTab extends StatelessWidget {
  const _NovelSearchTab({
    required this.query,
    required this.hotWords,
    required this.results,
    required this.searching,
    required this.searched,
    required this.error,
    required this.onSubmit,
    required this.onKeyword,
    required this.onOpen,
  });

  final TextEditingController query;
  final List<String> hotWords;
  final List<NovelSearchBook> results;
  final bool searching;
  final bool searched;
  final String? error;
  final Future<void> Function([String? keyword]) onSubmit;
  final Future<void> Function([String? keyword]) onKeyword;
  final void Function(NovelSearchBook book) onOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: query,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => onSubmit(),
            decoration: InputDecoration(
              hintText: '书名或作者',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: () => onSubmit(),
              ),
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        if (hotWords.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Wrap(
              spacing: 8,
              children: <Widget>[
                for (final word in hotWords.take(10))
                  ActionChip(
                    label: Text(word),
                    onPressed: () => onKeyword(word),
                  ),
              ],
            ),
          ),
        if (searching) const LinearProgressIndicator(),
        if (error != null) _NovelErrorBanner(message: error!, onRetry: onSubmit),
        Expanded(
          child: !searched
              ? const Center(child: Text('输入书名或作者开始搜索'))
              : results.isEmpty && !searching
              ? const Center(child: Text('没有找到相关作品'))
              : ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final book = results[index];
                    return ListTile(
                      leading: _NovelCover(
                        url: book.cover,
                        width: 40,
                        height: 56,
                      ),
                      title: Text(book.title ?? ''),
                      subtitle: Text(
                        '${book.author ?? '佚名'}'
                        '${book.cat == null ? '' : ' · ${book.cat}'}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => onOpen(book),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

/// A book cover that degrades to an icon instead of throwing when the network
/// image has no `cached_network_image` provider yet.
class _NovelCover extends StatelessWidget {
  const _NovelCover({required this.url, required this.width, required this.height});

  final String? url;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final value = url ?? '';
    return SizedBox(
      width: width,
      height: height,
      child: value.isEmpty
          ? const ColoredBox(
              color: Color(0x22000000),
              child: Icon(Icons.book, size: 20),
            )
          : Image.network(
              value,
              width: width,
              height: height,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const ColoredBox(
                color: Color(0x22000000),
                child: Icon(Icons.book, size: 20),
              ),
            ),
    );
  }
}

class _NovelErrorBanner extends StatelessWidget {
  const _NovelErrorBanner({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(12),
    child: Row(
      children: <Widget>[
        const Icon(Icons.error_outline, color: Colors.redAccent),
        const SizedBox(width: 8),
        Expanded(child: Text(message)),
        TextButton(onPressed: onRetry, child: const Text('重试')),
      ],
    ),
  );
}
