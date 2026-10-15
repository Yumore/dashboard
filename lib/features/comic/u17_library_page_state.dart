import 'package:dashboard/features/comic/u17_chapter_page.dart';
import 'package:dashboard/features/comic/u17_comic.dart';
import 'package:dashboard/features/comic/u17_library_page.dart';
import 'package:dashboard/features/comic/u17_library_store.dart';
import 'package:dashboard/features/comic/u17_reader_page.dart';
import 'package:dashboard/features/comic/u17_reading_record.dart';
import 'package:dashboard/features/comic/u17_source.dart';
import 'package:flutter/material.dart';

class U17LibraryPageState extends State<U17LibraryPage> {
  late final U17Source _source;
  late final U17LibraryStore _store;
  final _input = TextEditingController();
  List<U17Comic> _items = [];
  Map<int, U17ReadingRecord> _history = {};
  String _query = '';
  String? _error;
  int _tab = 0;
  int _page = 1;
  int _generation = 0;
  bool _loading = false;
  bool _more = true;
  bool _opening = false;

  @override
  void initState() {
    super.initState();
    _source = widget.source ?? U17Source();
    _store = widget.store ?? U17LibraryStore();
    _refresh();
  }

  Future<void> _refresh() async {
    final generation = ++_generation;
    final tab = _tab;
    final query = _query;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      List<U17Comic> items;
      Map<int, U17ReadingRecord> history = {};
      if (tab == 1) {
        items = await _store.favorites();
      } else if (tab == 2) {
        final records = await _store.history();
        history = {for (final record in records) record.comic.id: record};
        items = records.map((record) => record.comic).toList();
      } else {
        items = query.isEmpty
            ? await _source.list()
            : await _source.search(query);
      }
      if (query.isNotEmpty && tab != 0) {
        items = items
            .where(
              (comic) => comic.name.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
      if (!mounted || generation != _generation) return;
      setState(() {
        _items = items;
        _history = history;
        _page = 1;
        _more = items.isNotEmpty;
      });
    } catch (error) {
      if (mounted && generation == _generation) {
        setState(() => _error = '$error');
      }
    } finally {
      if (mounted && generation == _generation) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _loadMore() async {
    if (_loading || !_more || _tab != 0 || _query.isNotEmpty) return;
    final generation = _generation;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await _source.list(page: _page + 1);
      if (!mounted || generation != _generation) return;
      final known = _items.map((comic) => comic.id).toSet();
      final added = items.where((comic) => known.add(comic.id)).toList();
      setState(() {
        _items = [..._items, ...added];
        _page++;
        _more = added.isNotEmpty;
      });
    } catch (error) {
      if (mounted && generation == _generation) {
        setState(() => _error = '$error');
      }
    } finally {
      if (mounted && generation == _generation) {
        setState(() => _loading = false);
      }
    }
  }

  void _search() {
    _query = _input.text.trim();
    _refresh();
  }

  Future<void> _openComic(U17Comic comic) async {
    if (_opening) return;
    setState(() => _opening = true);
    try {
      final detail = await _source.details(comic);
      if (!mounted) return;
      final lastId = _history[comic.id]?.chapter.id;
      final resume = detail.chapters
          .where((chapter) => chapter.id == lastId && !chapter.locked)
          .firstOrNull;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => resume == null
              ? U17ChapterPage(detail: detail, source: _source, store: _store)
              : U17ReaderPage(
                  comic: detail.comic,
                  chapters: detail.chapters,
                  initialChapter: resume,
                  source: _source,
                  store: _store,
                ),
        ),
      );
      if (mounted && _tab != 0) await _refresh();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$error')));
      }
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  @override
  void dispose() {
    _input.dispose();
    if (widget.source == null) _source.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('有妖气漫画源')),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (tab) {
          setState(() {
            _tab = tab;
            _items = [];
            _history = {};
          });
          _refresh();
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            label: '全部',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            label: '关注',
          ),
          NavigationDestination(icon: Icon(Icons.history), label: '历史'),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _input,
              decoration: InputDecoration(
                labelText: '搜索漫画',
                suffixIcon: IconButton(
                  onPressed: _search,
                  icon: const Icon(Icons.search),
                ),
              ),
              onSubmitted: (_) => _search(),
            ),
          ),
          if (_loading || _opening) const LinearProgressIndicator(),
          if (_error != null)
            ListTile(
              title: Text('加载失败：$_error'),
              trailing: TextButton(
                onPressed: _loading ? null : _refresh,
                child: const Text('重新加载'),
              ),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  if (!_loading && _items.isEmpty)
                    const SizedBox(
                      height: 180,
                      child: Center(child: Text('暂无漫画')),
                    ),
                  for (final comic in _items)
                    ListTile(
                      leading: comic.cover == null
                          ? const Icon(Icons.menu_book_outlined)
                          : Image.network(
                              comic.cover.toString(),
                              width: 48,
                              errorBuilder: (_, _, _) =>
                                  const Icon(Icons.menu_book_outlined),
                            ),
                      title: Text(comic.name),
                      subtitle: _history[comic.id] == null
                          ? null
                          : Text(_history[comic.id]!.chapter.name),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _opening ? null : () => _openComic(comic),
                    ),
                  if (_tab == 0 && _query.isEmpty && _items.isNotEmpty)
                    TextButton(
                      onPressed: _loading || !_more ? null : _loadMore,
                      child: Text(_more ? '加载更多' : '已加载全部漫画'),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
