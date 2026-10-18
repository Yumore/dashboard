import 'package:dashboard/features/reading/easymygo/detail/book_detail_page.dart';
import 'package:dashboard/features/reading/easymygo/library/library_store.dart';
import 'package:dashboard/features/reading/easymygo/library/shelf_item.dart';
import 'package:dashboard/features/reading/easymygo/shelf/shelf_page.dart';
import 'package:dashboard/features/reading/easymygo/widget/book_cover_view.dart';
import 'package:flutter/material.dart';

class ShelfPageState extends State<ShelfPage> {
  List<ShelfItem> _shelf = const <ShelfItem>[];
  List<ShelfItem> _history = const <ShelfItem>[];
  bool _loading = true;

  LibraryStore get _store => widget.libraryStore ?? LibraryStore();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final shelf = await _store.shelf();
    final history = await _store.history();
    if (!mounted) return;
    setState(() {
      _shelf = shelf;
      _history = history;
      _loading = false;
    });
  }

  Future<void> _openDetail(ShelfItem item, {bool resume = false}) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BookDetailPage(
          service: widget.service,
          cover: item.cover,
          libraryStore: _store,
          autoResume: resume,
        ),
      ),
    );
    await _load();
  }

  Future<void> _toggleStar(ShelfItem item) async {
    await _store.setStarred(item.cover, !item.starred);
    await _load();
  }

  Future<void> _togglePinned(ShelfItem item) async {
    await _store.setPinned(item.cover, !item.pinned);
    await _load();
  }

  Future<void> _remove(ShelfItem item) async {
    await _store.remove(item.identify);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('书架与历史'),
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(text: '书架'),
              Tab(text: '历史'),
            ],
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: <Widget>[
                  _buildList(
                    _shelf,
                    empty: '书架还是空的，去搜索或从书源里收藏一本吧',
                    key: 'shelf-list',
                  ),
                  _buildList(
                    _history,
                    empty: '还没有阅读记录',
                    key: 'history-list',
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildList(
    List<ShelfItem> items, {
    required String empty,
    required String key,
  }) {
    if (items.isEmpty) {
      return Center(
        child: Text(empty, key: ValueKey<String>('$key-empty')),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        key: ValueKey<String>(key),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final progress = item.progress;
          return ListTile(
            leading: BookCoverView(cover: item.cover),
            title: Text(item.cover.label),
            subtitle: Text(
              progress == null
                  ? item.cover.source
                  : '${progress.chapterLabel} · 第 ${progress.pageIndex + 1}/${progress.pageCount} 页',
            ),
            onTap: () => _openDetail(item, resume: progress != null),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                IconButton(
                  key: ValueKey<String>('star-${item.identify}'),
                  tooltip: item.starred ? '取消收藏' : '收藏',
                  icon: Icon(
                    item.starred ? Icons.star : Icons.star_border,
                    color: item.starred ? Colors.amber : null,
                  ),
                  onPressed: () => _toggleStar(item),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'pin':
                        _togglePinned(item);
                      case 'remove':
                        _remove(item);
                    }
                  },
                  itemBuilder: (context) => <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: 'pin',
                      child: Text(item.pinned ? '取消置顶' : '置顶'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'remove',
                      child: Text('移出书架'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
