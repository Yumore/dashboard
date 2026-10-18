import 'package:dashboard/features/reading/easymygo/library/library_store.dart';
import 'package:dashboard/features/reading/easymygo/reader/manga_reader_controller.dart';
import 'package:dashboard/features/reading/easymygo/reader/manga_reader_page.dart';
import 'package:dashboard/features/reading/easymygo/reader/reader_state.dart';
import 'package:flutter/material.dart';

class MangaReaderPageState extends State<MangaReaderPage> {
  late final MangaReaderController _controller = MangaReaderController(
    component: widget.component,
    summary: widget.summary,
    chapters: widget.chapters,
  );

  LibraryStore get _store => widget.libraryStore ?? LibraryStore();

  @override
  void initState() {
    super.initState();
    _open();
  }

  Future<void> _open() async {
    if (widget.restoreProgress) {
      final progress = await _store.progressOf(widget.cover.identify);
      if (progress != null) {
        await _controller.restore(progress);
        if (!mounted) return;
        setState(() {});
        return;
      }
    }
    await _controller.openChapter(widget.initialChapterIndex);
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _run(Future<void> Function() action) async {
    await action();
    if (!mounted) return;
    setState(() {});
    if (_controller.state.status == ReaderStatus.ready) {
      await _store.saveProgress(widget.cover, _controller.buildProgress());
    }
  }

  Future<void> _openChapter(int index) async {
    await _run(() => _controller.openChapter(index));
  }

  void _showChapterSheet() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => ListView(
        key: const ValueKey<String>('easymygo-manga-chapters'),
        children: <Widget>[
          for (var index = 0; index < widget.chapters.length; index++)
            ListTile(
              dense: true,
              selected: index == _controller.state.chapterIndex,
              title: Text(widget.chapters[index].label),
              onTap: () {
                Navigator.of(context).pop();
                _openChapter(index);
              },
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = _controller.state;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${state.chapterLabel.isEmpty ? widget.cover.label : state.chapterLabel}'
          '${state.pageCount == 0 ? '' : ' ${state.pageIndex + 1}/${state.pageCount}'}',
          key: const ValueKey<String>('easymygo-manga-title'),
        ),
        actions: <Widget>[
          IconButton(
            tooltip: '上一章',
            icon: const Icon(Icons.skip_previous),
            onPressed: state.status == ReaderStatus.ready
                ? () => _run(_controller.previousChapter)
                : null,
          ),
          IconButton(
            tooltip: '下一章',
            icon: const Icon(Icons.skip_next),
            onPressed: state.status == ReaderStatus.ready
                ? () => _run(_controller.nextChapter)
                : null,
          ),
          IconButton(
            tooltip: '章节列表',
            icon: const Icon(Icons.list),
            onPressed: _showChapterSheet,
          ),
        ],
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(ReaderState state) {
    switch (state.status) {
      case ReaderStatus.idle:
      case ReaderStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case ReaderStatus.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  state.errorMsg,
                  key: const ValueKey<String>('easymygo-manga-error'),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => _openChapter(state.chapterIndex),
                  child: const Text('重试'),
                ),
              ],
            ),
          ),
        );
      case ReaderStatus.ready:
        break;
    }
    final picture = state.pictures[state.pageIndex];
    return GestureDetector(
      key: const ValueKey<String>('easymygo-manga-gesture'),
      onHorizontalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;
        if (velocity < 0) {
          _run(_controller.nextPage);
        } else if (velocity > 0) {
          _run(_controller.previousPage);
        }
      },
      child: Column(
        children: <Widget>[
          Expanded(
            child: InteractiveViewer(
              child: Center(
                child: picture.url.isEmpty
                    ? const Text('本章没有图片')
                    : Image.network(
                        picture.url,
                        key: const ValueKey<String>('easymygo-manga-image'),
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => const Padding(
                          padding: EdgeInsets.all(24),
                          child: Text('图片加载失败'),
                        ),
                      ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton(
                  key: const ValueKey<String>('easymygo-manga-prev'),
                  tooltip: '上一页',
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => _run(_controller.previousPage),
                ),
                Text('${state.pageIndex + 1} / ${state.pageCount}'),
                IconButton(
                  key: const ValueKey<String>('easymygo-manga-next'),
                  tooltip: '下一页',
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => _run(_controller.nextPage),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
