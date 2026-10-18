import 'package:dashboard/features/reading/book/engine/book_source_engine.dart';
import 'package:dashboard/features/reading/book/entity/book_info.dart';
import 'package:dashboard/features/reading/book/entity/chapter_toc_entry.dart';
import 'package:dashboard/features/reading/book/repository/book_repository.dart';
import 'package:dashboard/features/reading/book/repository/chapter_repository.dart';
import 'package:dashboard/features/reading/book/repository/source_repository.dart';
import 'package:dashboard/features/reading/book/util/book_id.dart';
import 'package:dashboard/features/reading/book/util/book_log.dart';
import 'package:dashboard/features/reading/book/view/book_detail_page.dart';
import 'package:dashboard/features/reading/book/view/book_reader_page.dart';
import 'package:flutter/material.dart';

class BookDetailPageState extends State<BookDetailPage> {
  final BookSourceEngine _engine = BookSourceEngine();
  final BookRepository _books = BookRepository.instance;
  final ChapterRepository _chapters = ChapterRepository.instance;
  final SourceRepository _sources = SourceRepository.instance;

  BookInfo? _info;
  List<ChapterTocEntry> _toc = const <ChapterTocEntry>[];
  bool _loading = true;
  bool _onShelf = false;
  String? _error;
  String _status = '正在加载详情…';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final seed = widget.searchBook;
    setState(() {
      _loading = true;
      _error = null;
      _status = '正在加载详情…';
    });
    try {
      final source = await _sources.getByUrl(seed.sourceUrl);
      if (source == null) {
        throw StateError('书源不存在：${seed.sourceName}');
      }
      final onShelf = await _books.exists(
        makeBookKey(source.bookSourceUrl, seed.bookUrl),
      );
      setState(() {
        _onShelf = onShelf;
        _status = '正在加载详情…';
      });
      final info = await _engine.bookInfo(
        source,
        seed.bookUrl,
        seed: seed,
      );
      final tocUrl = info.tocUrl.isNotEmpty ? info.tocUrl : info.bookUrl;
      setState(() => _status = '正在加载目录…');
      final chapters = await _engine.toc(source, tocUrl);
      if (!mounted) return;
      setState(() {
        _info = info;
        _toc = chapters
            .map(
              (c) => ChapterTocEntry(
                id: makeChapterId(info.id, c.url),
                title: c.name,
                url: c.url,
                hasBody: false,
                ord: c.index,
              ),
            )
            .toList();
        _loading = false;
        _status = '';
      });
    } catch (e, st) {
      BookLog.e('Detail', 'load failed', error: e, stackTrace: st);
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = '$e';
      });
    }
  }

  Future<void> _addToShelf() async {
    final info = _info;
    if (info == null) return;
    try {
      final book = info.toBook();
      await _books.upsert(book);
      if (_toc.isNotEmpty) {
        await _chapters.syncToc(_toc, book.id, sourceUrl: book.sourceUrl);
      }
      if (!mounted) return;
      setState(() => _onShelf = true);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('已加入书架')));
    } catch (e, st) {
      BookLog.e('Detail', 'add to shelf failed', error: e, stackTrace: st);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('加入书架失败：$e')));
    }
  }

  Future<void> _read() async {
    final info = _info;
    if (info == null) return;
    if (!_onShelf) await _addToShelf();
    final book = (await _books.getById(info.id)) ?? info.toBook();
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => BookReaderPage(book: book)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.searchBook.name)),
      body: _buildBody(),
      bottomNavigationBar: _info == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _onShelf ? null : _addToShelf,
                        icon: const Icon(Icons.library_add_outlined),
                        label: Text(_onShelf ? '已在书架' : '加入书架'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _toc.isEmpty ? null : _read,
                        icon: const Icon(Icons.menu_book),
                        label: const Text('开始阅读'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 12),
            Text(_status),
          ],
        ),
      );
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('详情加载失败：$_error', textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(onPressed: _load, child: const Text('重试')),
            ],
          ),
        ),
      );
    }
    final info = _info!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (info.coverUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(
                  info.coverUrl,
                  width: 96,
                  height: 132,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      const SizedBox(width: 96, height: 132),
                ),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    info.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  Text('作者：${info.author.isEmpty ? "未知" : info.author}'),
                  if (info.category.isNotEmpty) Text('分类：${info.category}'),
                  if (info.status.isNotEmpty) Text('状态：${info.status}'),
                  if (info.latestChapter.isNotEmpty)
                    Text(
                      '最新：${info.latestChapter}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  Text('书源：${info.originName}'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text('目录（${_toc.length} 章）', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (info.description.isNotEmpty) ...[
          Text('简介', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(info.description),
          const SizedBox(height: 16),
        ],
        ..._toc.take(30).map(
          (c) => ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(c.title, maxLines: 1, overflow: TextOverflow.ellipsis),
            onTap: () => _openChapter(c),
          ),
        ),
        if (_toc.length > 30)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              '仅预览前 30 章，共 ${_toc.length} 章',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
      ],
    );
  }

  Future<void> _openChapter(ChapterTocEntry entry) async {
    final info = _info;
    if (info == null) return;
    if (!_onShelf) await _addToShelf();
    final book = (await _books.getById(info.id)) ?? info.toBook();
    final index = _toc.indexWhere((c) => c.id == entry.id);
    if (index >= 0) book.chapterIndex = index;
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => BookReaderPage(book: book)),
    );
  }
}
