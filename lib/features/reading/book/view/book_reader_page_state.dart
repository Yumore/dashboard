import 'dart:async';

import 'package:dashboard/features/reading/book/engine/book_source_engine.dart';
import 'package:dashboard/features/reading/book/entity/book.dart';
import 'package:dashboard/features/reading/book/entity/chapter_toc_entry.dart';
import 'package:dashboard/features/reading/book/entity/text_line.dart';
import 'package:dashboard/features/reading/book/entity/text_page.dart';
import 'package:dashboard/features/reading/book/model/book_source.dart';
import 'package:dashboard/features/reading/book/reader/chapter_content_loader.dart';
import 'package:dashboard/features/reading/book/reader/chapter_download_service.dart';
import 'package:dashboard/features/reading/book/reader/reader_settings.dart';
import 'package:dashboard/features/reading/book/reader/reading_progress_store.dart';
import 'package:dashboard/features/reading/book/reader/text_paginator.dart';
import 'package:dashboard/features/reading/book/reader/toc_service.dart';
import 'package:dashboard/features/reading/book/repository/book_repository.dart';
import 'package:dashboard/features/reading/book/repository/chapter_repository.dart';
import 'package:dashboard/features/reading/book/repository/source_repository.dart';
import 'package:dashboard/features/reading/book/util/book_local_store.dart';
import 'package:dashboard/features/reading/book/util/book_log.dart';
import 'package:dashboard/features/reading/book/view/book_reader_page.dart';
import 'package:dashboard/features/reading/book/view/reader_settings_page.dart';
import 'package:flutter/material.dart';

class BookReaderPageState extends State<BookReaderPage> {
  final BookSourceEngine _engine = BookSourceEngine();
  final BookRepository _books = BookRepository.instance;
  final ChapterRepository _chapters = ChapterRepository.instance;
  final SourceRepository _sources = SourceRepository.instance;
  final TextPaginator _paginator = TextPaginator();

  late final ChapterDownloadService _download;
  late final ChapterContentLoader _loader;
  late final TocService _tocService;
  late final ReadingProgressStore _progress;

  final PageController _pageController = PageController();
  final Map<String, ChapterDiskCache> _warm = <String, ChapterDiskCache>{};

  BookSource? _source;
  List<ChapterTocEntry> _toc = <ChapterTocEntry>[];
  List<TextPage> _pages = const <TextPage>[];
  int _pageIndex = 0;
  bool _loading = true;
  bool _menuVisible = false;
  bool _generation = false;
  String? _error;

  Book get _book => widget.book;

  @override
  void initState() {
    super.initState();
    _download = ChapterDownloadService(engine: _engine, chapters: _chapters);
    _loader = ChapterContentLoader(
      chaptersRepo: _chapters,
      paginator: _paginator,
      fetchContent: (chapterId, {int? idx}) => _download.fetchBody(
        source: _source,
        toc: _toc,
        chapterId: chapterId,
        idx: idx,
      ),
    );
    _tocService = TocService(
      engine: _engine,
      chapters: _chapters,
      ensureBookRow: (book) => _books.ensureExists(book),
      resolveSource: (book) => _sources.getByUrl(book.sourceUrl),
      onMessage: _toast,
    );
    _progress = ReadingProgressStore(
      books: _books,
      chapters: _chapters,
      ensureBookRow: (book) => _books.ensureExists(book),
    );
    _bootstrap();
  }

  @override
  void dispose() {
    _progress.flush(book: _book, chapters: _toc);
    _pageController.dispose();
    super.dispose();
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  /// Load the schema round-trip the source performs before first paint:
  /// shared_preferences → source row → TOC → chapter window → pagination.
  Future<void> _bootstrap() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await SpUtil.getInstance();
      final source = await _sources.getByUrl(_book.sourceUrl);
      if (source == null) {
        throw StateError('书源不存在，请重新搜索添加或换源');
      }
      _source = source;
      await _books.ensureExists(_book);
      final toc = await _tocService.load(
        book: _book,
        current: _toc,
        init: _toc.isEmpty,
        isStillActive: () => mounted,
      );
      if (toc != null && toc.isNotEmpty) _toc = toc;
      if (_toc.isEmpty) {
        throw StateError('目录为空，请检查书源或网络后重试');
      }
      _progress.ready = true;
      var index = _book.chapterIndex;
      if (index < 0 || index >= _toc.length) index = 0;
      await _openChapter(index, jump: false);
    } catch (e, st) {
      BookLog.e('Read', 'bootstrap failed', error: e, stackTrace: st);
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = '$e';
      });
    }
  }

  Future<void> _openChapter(int index, {bool jump = true}) async {
    if (_toc.isEmpty) return;
    if (index < 0 || index >= _toc.length) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final gen = !_generation;
    _generation = gen;
    final toc = _toc;
    try {
      final readPage = await _loader.load(
        chapters: toc,
        idx: index,
        warm: _warm,
        bookId: _book.id,
        bookChapterIndex: index,
      );
      if (!mounted || gen != _generation) return;
      if (readPage == null) {
        setState(() => _loading = false);
        return;
      }
      final pages = _paginator.paginateSync(
        readPage,
        shouldJustifyHeight: false,
      );
      if (!mounted || gen != _generation) return;
      _book.chapterIndex = index;
      final restore = jump ? 0 : _book.pageIndex;
      setState(() {
        _pages = pages.isEmpty
            ? <TextPage>[
                TextPage(
                  <TextLine>[
                    TextLine(
                      '本章内容为空，请检查书源或点击菜单换源。',
                      height: 24,
                    ),
                  ],
                  24,
                ),
              ]
            : pages;
        _pageIndex = restore.clamp(0, _pages.length - 1);
        _loading = false;
      });
      _book.pageIndex = _pageIndex;
      if (_pageController.hasClients) {
        _pageController.jumpToPage(_pageIndex);
      }
      _scheduleProgress();
    } catch (e, st) {
      BookLog.e('Read', 'open chapter $index failed', error: e, stackTrace: st);
      if (!mounted || gen != _generation) return;
      setState(() {
        _loading = false;
        _error = '$e';
      });
    }
  }

  void _scheduleProgress() {
    _progress.schedule(book: _book, chapters: _toc);
  }

  void _onPageChanged(int index) {
    _pageIndex = index;
    _book.pageIndex = index;
    _scheduleProgress();
  }

  Future<void> _prevPage() async {
    if (_pageIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
      return;
    }
    await _openChapter(_book.chapterIndex - 1);
  }

  Future<void> _nextPage() async {
    if (_pageIndex < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
      return;
    }
    await _openChapter(_book.chapterIndex + 1);
  }

  Future<void> _openSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => ReaderSettingsPage(onChanged: _repaginate),
      ),
    );
    await _repaginate();
  }

  Future<void> _repaginate() async {
    if (!mounted) return;
    final page = await _loader.load(
      chapters: _toc,
      idx: _book.chapterIndex,
      warm: <String, ChapterDiskCache>{},
      bookId: _book.id,
      bookChapterIndex: _book.chapterIndex,
    );
    if (!mounted || page == null) return;
    final keep = _pageIndex;
    final pages = _paginator.paginateSync(page, shouldJustifyHeight: false);
    setState(() {
      _pages = pages.isEmpty
          ? <TextPage>[TextPage(<TextLine>[TextLine('', height: 24)], 24)]
          : pages;
      _pageIndex = keep.clamp(0, _pages.length - 1);
    });
  }

  void _showTocSheet() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => SizedBox(
        height: MediaQuery.of(ctx).size.height * 0.7,
        child: ListView.builder(
          itemCount: _toc.length,
          itemBuilder: (context, index) {
            final chapter = _toc[index];
            final current = index == _book.chapterIndex;
            return ListTile(
              dense: true,
              selected: current,
              title: Text(
                chapter.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () {
                Navigator.pop(ctx);
                _openChapter(index);
              },
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    ReaderSettings.configureScreen(
      width: media.size.width,
      height: media.size.height,
      topSafe: media.padding.top,
      bottomSafe: media.padding.bottom,
    );
    final theme = ReaderSettings.getPaperTheme();
    return Scaffold(
      backgroundColor: ReaderSettings.paperColor(theme),
      body: SafeArea(
        child: _buildBody(theme),
      ),
      bottomNavigationBar: _menuVisible ? _menu(theme) : null,
    );
  }

  Widget _buildBody(PaperTheme theme) {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(onPressed: _bootstrap, child: const Text('重试')),
            ],
          ),
        ),
      );
    }
    return Stack(
      children: [
        if (_pages.isEmpty)
          const Center(child: CircularProgressIndicator())
        else
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (details) {
              final width = MediaQuery.of(context).size.width;
              final dx = details.localPosition.dx;
              if (dx < width / 3) {
                _prevPage();
              } else if (dx > width * 2 / 3) {
                _nextPage();
              } else {
                setState(() => _menuVisible = !_menuVisible);
              }
            },
            child: PageView.builder(
              controller: _pageController,
              itemCount: _pages.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) => _pageView(_pages[index], theme),
            ),
          ),
        if (_loading)
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(minHeight: 2),
          ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 4,
          child: Text(
            '${_book.readingChapter.isEmpty ? (_toc.length > _book.chapterIndex ? _toc[_book.chapterIndex].title : "") : _book.readingChapter}  '
            '${_pageIndex + 1}/${_pages.length}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: ReaderSettings.metaColor(theme),
            ),
          ),
        ),
      ],
    );
  }

  Widget _pageView(TextPage page, PaperTheme theme) {
    final fontSize = ReaderSettings.getFontSize();
    final lineHeight = ReaderSettings.getLineHeight();
    final letterSpace = ReaderSettings.getLetterSpace();
    final paddingV = ReaderSettings.getPageDis().toDouble();
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: paddingV + 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final line in page.lines)
            SizedBox(
              height: line.height > 0 ? line.height : fontSize * lineHeight,
              child: Text(
                line.text,
                maxLines: 1,
                overflow: TextOverflow.visible,
                style: TextStyle(
                  fontSize: fontSize,
                  height: lineHeight,
                  letterSpacing: letterSpace,
                  color: ReaderSettings.inkColor(theme),
                  fontFamily: ReaderSettings.getFontFamily(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _menu(PaperTheme theme) {
    return Container(
      color: ReaderSettings.paperColor(theme),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  onPressed: () {
                    setState(() => _menuVisible = false);
                    _openChapter(_book.chapterIndex - 1, jump: true);
                  },
                  icon: const Icon(Icons.skip_previous),
                  label: const Text('上一章'),
                ),
                TextButton.icon(
                  onPressed: _showTocSheet,
                  icon: const Icon(Icons.list),
                  label: const Text('目录'),
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() => _menuVisible = false);
                    _openChapter(_book.chapterIndex + 1, jump: true);
                  },
                  icon: const Icon(Icons.skip_next),
                  label: const Text('下一章'),
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() => _menuVisible = false);
                    _openSettings();
                  },
                  icon: const Icon(Icons.settings_outlined),
                  label: const Text('设置'),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Slider(
                value: _book.chapterIndex
                    .clamp(0, _toc.isEmpty ? 0 : _toc.length - 1)
                    .toDouble(),
                min: 0,
                max: (_toc.length - 1).clamp(1, 1 << 30).toDouble(),
                onChanged: _toc.isEmpty
                    ? null
                    : (value) => _openChapter(value.round(), jump: true),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '${_toc.length} 章 · 第 ${_book.chapterIndex + 1} 章',
                style: TextStyle(
                  fontSize: 12,
                  color: ReaderSettings.metaColor(theme),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
