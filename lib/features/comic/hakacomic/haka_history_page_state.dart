import 'package:flutter/material.dart';
import 'package:dashboard/features/comic/hakacomic/haka_comic_tile.dart';
import 'package:dashboard/features/comic/hakacomic/haka_doc.dart';
import 'package:dashboard/features/comic/hakacomic/haka_history_entry.dart';
import 'package:dashboard/features/comic/hakacomic/haka_history_store.dart';
import 'package:dashboard/features/comic/hakacomic/haka_history_page.dart';

/// State of [HakaHistoryPage]; pages through the store in
/// [HakaHistoryStore.pageSize] windows.
class HakaHistoryPageState extends State<HakaHistoryPage> {
  final List<HakaHistoryEntry> _entries = [];
  int _page = 0;
  bool _hasMore = true;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadNext();
  }

  Future<void> _loadNext() async {
    if (_loading || !_hasMore) return;
    setState(() => _loading = true);
    final next = await widget.historyStore.getPage(_page);
    if (!mounted) return;
    setState(() {
      _entries.addAll(next);
      _page += 1;
      _hasMore = next.length == HakaHistoryStore.pageSize;
      _loading = false;
    });
  }

  Future<void> _clear() async {
    await widget.historyStore.clear();
    if (!mounted) return;
    setState(() {
      _entries.clear();
      _page = 0;
      _hasMore = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_entries.isEmpty && _loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_entries.isEmpty) {
      return const Center(child: Text('暂无阅读历史'));
    }
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(onPressed: _clear, child: const Text('清空历史')),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _entries.length + (_hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= _entries.length) {
                return TextButton(
                  onPressed: _loadNext,
                  child: Text(_loading ? '加载中…' : '加载更多'),
                );
              }
              final entry = _entries[index];
              final doc = HakaDoc.fromJson(entry.doc);
              return HakaComicTile(
                comic: doc,
                subtitle: entry.comicId,
                onTap: () => widget.onOpenComic(entry.comicId),
              );
            },
          ),
        ),
      ],
    );
  }
}
