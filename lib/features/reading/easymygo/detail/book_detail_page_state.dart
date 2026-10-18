import 'package:dashboard/features/reading/easymygo/detail/book_detail_page.dart';
import 'package:dashboard/features/reading/easymygo/entity/book_cover.dart';
import 'package:dashboard/features/reading/easymygo/entity/book_status.dart';
import 'package:dashboard/features/reading/easymygo/entity/book_summary.dart';
import 'package:dashboard/features/reading/easymygo/entity/source_type.dart';
import 'package:dashboard/features/reading/easymygo/library/library_store.dart';
import 'package:dashboard/features/reading/easymygo/library/shelf_item.dart';
import 'package:dashboard/features/reading/easymygo/reader/manga_reader_page.dart';
import 'package:dashboard/features/reading/easymygo/reader/novel_reader_page.dart';
import 'package:dashboard/features/reading/easymygo/service/book_detail_result.dart';
import 'package:dashboard/features/reading/easymygo/widget/book_cover_view.dart';
import 'package:flutter/material.dart';

class BookDetailPageState extends State<BookDetailPage> {
  BookDetailResult? _result;
  ShelfItem? _item;
  String? _error;
  bool _loading = true;
  bool _expandedDescription = false;

  LibraryStore get _store => widget.libraryStore ?? LibraryStore();

  BookSummary get _summary => BookSummary(
    source: widget.cover.source,
    id: widget.cover.id,
    ext: widget.cover.ext,
  );

  /// The registered source identifier. [BookCover.identify] is the library key
  /// (`id-|-source`) and must not be used to look a component up.
  String get _sourceIdentify => widget.cover.source;

  /// Detail data wins over the list row; both describe the same book.
  BookCover get _book {
    final detailed = _result?.detailed;
    if (detailed == null) return widget.cover;
    return BookCover(
      type: detailed.type,
      id: detailed.id,
      label: detailed.label,
      cover: detailed.cover,
      intro: detailed.intro,
      jumpUrl: detailed.jumpUrl,
      source: detailed.source,
      ext: detailed.ext,
    );
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await widget.service.detail(_sourceIdentify, _summary);
    final item = await _store.itemOf(widget.cover.identify);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _item = item;
      if (result.isError) {
        _error = result.errorMsg;
      } else if (result.isEmpty) {
        _error = '书源没有返回详情';
      } else {
        _result = result;
        _error = null;
      }
    });
    if (widget.autoResume && !result.isError && item?.progress != null) {
      await _openReader(restore: true);
    }
  }

  Future<void> _openReader({required bool restore, int index = 0}) async {
    final result = _result;
    if (result == null) return;
    final identify = _sourceIdentify;
    final Widget page;
    if (widget.cover.type == SourceType.novel) {
      final component = widget.service.bundle.novelComponent(identify);
      if (component == null) return;
      page = NovelReaderPage(
        component: component,
        summary: _summary,
        cover: _book,
        volumes: result.volumes,
        libraryStore: _store,
        initialVolumeIndex: restore
            ? (_item?.progress?.volumeIndex ?? 0)
            : index,
        initialChapterIndex: restore ? (_item?.progress?.chapterIndex ?? 0) : 0,
        restoreProgress: restore,
      );
    } else {
      final component = widget.service.bundle.mangaComponent(identify);
      if (component == null) return;
      page = MangaReaderPage(
        component: component,
        summary: _summary,
        cover: _book,
        chapters: result.chapters,
        libraryStore: _store,
        initialChapterIndex: restore ? (_item?.progress?.chapterIndex ?? 0) : index,
        restoreProgress: restore,
      );
    }
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => page));
    final item = await _store.itemOf(widget.cover.identify);
    if (!mounted) return;
    setState(() => _item = item);
  }

  Future<void> _toggleStar() async {
    final item = await _store.setStarred(
      _book,
      !(_item?.starred ?? false),
    );
    if (!mounted) return;
    setState(() => _item = item);
  }

  Future<void> _togglePin() async {
    final item = await _store.setPinned(_book, !(_item?.pinned ?? false));
    if (!mounted) return;
    setState(() => _item = item);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_book.label.isEmpty ? '详情' : _book.label),
        actions: <Widget>[
          IconButton(
            key: const ValueKey<String>('easymygo-detail-star'),
            tooltip: (_item?.starred ?? false) ? '取消收藏' : '收藏',
            icon: Icon(
              (_item?.starred ?? false) ? Icons.star : Icons.star_border,
              color: (_item?.starred ?? false) ? Colors.amber : null,
            ),
            onPressed: _toggleStar,
          ),
          IconButton(
            tooltip: (_item?.pinned ?? false) ? '取消置顶' : '置顶',
            icon: Icon(
              (_item?.pinned ?? false)
                  ? Icons.push_pin
                  : Icons.push_pin_outlined,
            ),
            onPressed: _togglePin,
          ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final error = _error;
    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            error,
            key: const ValueKey<String>('easymygo-detail-error'),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    final result = _result!;
    final detailed = result.detailed;
    final progress = _item?.progress;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            BookCoverView(cover: _book, width: 96, height: 132),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    _book.label,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  Text('书源：${widget.cover.source}'),
                  Text('状态：${_statusLabel(detailed?.status)}'),
                  if (detailed != null && detailed.genre.isNotEmpty)
                    Text('类型：${detailed.genre}'),
                  const SizedBox(height: 12),
                  Row(
                    children: <Widget>[
                      FilledButton.icon(
                        key: const ValueKey<String>('easymygo-detail-read'),
                        onPressed: () => _openReader(
                          restore: progress != null,
                          index: progress?.chapterIndex ?? 0,
                        ),
                        icon: const Icon(Icons.menu_book),
                        label: Text(progress == null ? '开始阅读' : '继续阅读'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        if (detailed != null && detailed.description.isNotEmpty) ...<Widget>[
          const SizedBox(height: 16),
          Text(
            detailed.description,
            maxLines: _expandedDescription ? null : 4,
            overflow: _expandedDescription ? null : TextOverflow.ellipsis,
          ),
          TextButton(
            onPressed: () => setState(
              () => _expandedDescription = !_expandedDescription,
            ),
            child: Text(_expandedDescription ? '收起' : '展开简介'),
          ),
        ],
        const SizedBox(height: 8),
        if (widget.cover.type == SourceType.novel)
          ..._buildVolumes(context, result)
        else
          ..._buildChapters(context, result),
      ],
    );
  }

  List<Widget> _buildChapters(BuildContext context, BookDetailResult result) {
    if (result.chapters.isEmpty) {
      return <Widget>[
        const Text('本书没有章节', key: ValueKey<String>('easymygo-detail-empty')),
      ];
    }
    return <Widget>[
      Text('章节（${result.chapters.length}）', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 4,
        children: <Widget>[
          for (var index = 0; index < result.chapters.length; index++)
            ActionChip(
              key: ValueKey<String>('easymygo-chapter-$index'),
              label: Text(result.chapters[index].label),
              onPressed: () => _openReader(restore: false, index: index),
            ),
        ],
      ),
    ];
  }

  List<Widget> _buildVolumes(BuildContext context, BookDetailResult result) {
    if (result.volumes.isEmpty) {
      return <Widget>[
        const Text('本书没有分卷', key: ValueKey<String>('easymygo-detail-empty')),
      ];
    }
    return <Widget>[
      Text('分卷（${result.volumes.length}）', style: Theme.of(context).textTheme.titleMedium),
      for (var index = 0; index < result.volumes.length; index++)
        ExpansionTile(
          key: ValueKey<String>('easymygo-volume-$index'),
          title: Text(result.volumes[index].label),
          children: <Widget>[
            ListTile(
              dense: true,
              leading: const Icon(Icons.play_arrow),
              title: const Text('从本卷开始阅读'),
              onTap: () => _openVolumeChapter(volumeIndex: index),
            ),
          ],
        ),
    ];
  }

  Future<void> _openVolumeChapter({required int volumeIndex}) async {
    final result = _result;
    if (result == null) return;
    final component = widget.service.bundle.novelComponent(
      widget.cover.identify,
    );
    if (component == null) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => NovelReaderPage(
          component: component,
          summary: _summary,
          cover: _book,
          volumes: result.volumes,
          libraryStore: _store,
          initialVolumeIndex: volumeIndex,
          restoreProgress: false,
        ),
      ),
    );
    final item = await _store.itemOf(widget.cover.identify);
    if (!mounted) return;
    setState(() => _item = item);
  }

  static String _statusLabel(BookStatus? status) {
    switch (status) {
      case BookStatus.ongoing:
        return '连载中';
      case BookStatus.complete:
        return '已完结';
      case BookStatus.unknown:
      case null:
        return '未知';
    }
  }
}
