import 'package:dashboard/features/reading/book/entity/book.dart';
import 'package:dashboard/features/reading/book/repository/book_repository.dart';
import 'package:dashboard/features/reading/book/repository/chapter_repository.dart';
import 'package:dashboard/features/reading/book/util/book_log.dart';
import 'package:dashboard/features/reading/book/view/book_reader_page.dart';
import 'package:dashboard/features/reading/book/view/book_shelf_page.dart';
import 'package:dashboard/features/reading/book/view/explore_page.dart';
import 'package:dashboard/features/reading/book/view/search_page.dart';
import 'package:dashboard/features/reading/book/view/source_manage_page.dart';
import 'package:flutter/material.dart';

class BookShelfPageState extends State<BookShelfPage> {
  final BookRepository _books = BookRepository.instance;
  final ChapterRepository _chapters = ChapterRepository.instance;

  List<Book> _items = const <Book>[];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await _books.getAll();
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (e, st) {
      BookLog.e('Shelf', 'load failed', error: e, stackTrace: st);
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  Future<void> _remove(Book book) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除书籍'),
        content: Text('确定删除《${book.name}》及其缓存章节？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await _chapters.clearBook(book.id);
    await _books.delete(book.id);
    await _load();
  }

  Future<void> _openReader(Book book) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => BookReaderPage(book: book)),
    );
    await _load();
  }

  void _open(Widget page) {
    Navigator.push(context, MaterialPageRoute<void>(builder: (_) => page))
        .then((_) => _load());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('书架'),
        actions: [
          IconButton(
            tooltip: '搜索',
            icon: const Icon(Icons.search),
            onPressed: () => _open(const SearchPage()),
          ),
          IconButton(
            tooltip: '发现',
            icon: const Icon(Icons.explore_outlined),
            onPressed: () => _open(const ExplorePage()),
          ),
          IconButton(
            tooltip: '书源',
            icon: const Icon(Icons.source_outlined),
            onPressed: () => _open(const SourceManagePage()),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('书架加载失败：$_error', textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(onPressed: _load, child: const Text('重试')),
            ],
          ),
        ),
      );
    }
    if (_items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.menu_book_outlined, size: 48),
              const SizedBox(height: 12),
              const Text('书架还是空的，先去书源里搜索一本书吧'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => _open(const SearchPage()),
                child: const Text('搜索书籍'),
              ),
            ],
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        itemCount: _items.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final book = _items[index];
          return ListTile(
            leading: _cover(book.coverUrl),
            title: Text(
              book.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              book.readingChapter.isNotEmpty
                  ? '读到：${book.readingChapter}'
                  : (book.author.isNotEmpty ? book.author : '未知作者'),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: book.hasUpdate != 0
                ? const Icon(Icons.fiber_new, color: Colors.red)
                : null,
            onTap: () => _openReader(book),
            onLongPress: () => _remove(book),
          );
        },
      ),
    );
  }

  Widget _cover(String url) {
    if (url.trim().isEmpty) {
      return const SizedBox(width: 40, height: 56, child: Icon(Icons.book));
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Image.network(
        url,
        width: 40,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) =>
            const SizedBox(width: 40, height: 56, child: Icon(Icons.book)),
      ),
    );
  }
}
