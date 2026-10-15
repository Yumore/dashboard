import 'package:dashboard/features/comic/u17_chapter.dart';
import 'package:dashboard/features/comic/u17_chapter_page.dart';
import 'package:dashboard/features/comic/u17_reader_page.dart';
import 'package:flutter/material.dart';

class U17ChapterPageState extends State<U17ChapterPage> {
  bool _favorite = false;
  bool _saving = false;
  bool _loaded = false;
  int? _lastChapter;
  String? _error;

  @override
  void initState() {
    super.initState();
    _restore();
  }

  Future<void> _restore() async {
    try {
      final favorites = await widget.store.favorites();
      final history = await widget.store.history();
      if (!mounted) return;
      setState(() {
        _favorite = favorites.any(
          (comic) => comic.id == widget.detail.comic.id,
        );
        _lastChapter = history
            .where((item) => item.comic.id == widget.detail.comic.id)
            .firstOrNull
            ?.chapter
            .id;
        _loaded = true;
        _error = null;
      });
    } catch (error) {
      if (mounted) setState(() => _error = '读取书架失败：$error');
    }
  }

  Future<void> _toggleFavorite() async {
    setState(() => _saving = true);
    try {
      await widget.store.setFavorite(widget.detail.comic, !_favorite);
      if (mounted) setState(() => _favorite = !_favorite);
    } catch (error) {
      if (mounted) setState(() => _error = '保存书架失败：$error');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _read(U17Chapter chapter) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => U17ReaderPage(
          comic: widget.detail.comic,
          chapters: widget.detail.chapters,
          initialChapter: chapter,
          source: widget.source,
          store: widget.store,
        ),
      ),
    );
    if (mounted) await _restore();
  }

  @override
  Widget build(BuildContext context) {
    final comic = widget.detail.comic;
    final chapters = widget.detail.chapters;
    final resume = chapters
        .where((chapter) => chapter.id == _lastChapter && !chapter.locked)
        .firstOrNull;
    return Scaffold(
      appBar: AppBar(
        title: Text(comic.name),
        actions: [
          IconButton(
            tooltip: _favorite ? '取消关注' : '关注漫画',
            onPressed: !_loaded || _saving ? null : _toggleFavorite,
            icon: Icon(_favorite ? Icons.favorite : Icons.favorite_outline),
          ),
        ],
      ),
      body: ListView(
        children: [
          if (_error != null)
            ListTile(
              title: Text(_error!),
              trailing: TextButton(
                onPressed: _restore,
                child: const Text('重试'),
              ),
            ),
          if (comic.author.isNotEmpty)
            ListTile(title: Text('作者：${comic.author}')),
          if (comic.tags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(comic.tags.join(' · ')),
            ),
          if (comic.updatedAt != null)
            ListTile(
              title: Text(
                '更新于 ${comic.updatedAt!.toLocal().toString().substring(0, 10)}',
              ),
            ),
          if (comic.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(comic.description),
            ),
          if (resume != null)
            ListTile(
              leading: const Icon(Icons.history),
              title: Text('继续阅读：${resume.name}'),
              onTap: () => _read(resume),
            ),
          if (chapters.isEmpty) const ListTile(title: Text('暂无章节')),
          for (final chapter in chapters)
            ListTile(
              title: Text(chapter.name),
              trailing: Icon(
                chapter.locked
                    ? Icons.lock_outline
                    : chapter.id == _lastChapter
                    ? Icons.bookmark
                    : Icons.chevron_right,
              ),
              onTap: chapter.locked ? null : () => _read(chapter),
            ),
        ],
      ),
    );
  }
}
