import 'package:dashboard/features/reading/easymygo/library/library_store.dart';
import 'package:dashboard/features/reading/easymygo/reader/novel_reader_controller.dart';
import 'package:dashboard/features/reading/easymygo/reader/novel_reader_page.dart';
import 'package:dashboard/features/reading/easymygo/reader/reader_state.dart';
import 'package:flutter/material.dart';

class NovelReaderPageState extends State<NovelReaderPage> {
  late final NovelReaderController _controller = NovelReaderController(
    component: widget.component,
    summary: widget.summary,
    volumes: widget.volumes,
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
    if (_controller.volumes.isEmpty) return;
    final volumeIndex = widget.initialVolumeIndex.clamp(
      0,
      _controller.volumes.length - 1,
    );
    if (await _controller.openVolume(volumeIndex)) {
      await _controller.openChapter(widget.initialChapterIndex);
    }
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

  Future<void> _openVolumeChapter(int volumeIndex, int chapterIndex) async {
    if (!await _controller.openVolume(volumeIndex)) {
      if (!mounted) return;
      setState(() {});
      return;
    }
    await _run(() => _controller.openChapter(chapterIndex));
  }

  void _showChapterSheet() {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => ListView(
        key: const ValueKey<String>('easymygo-novel-volumes'),
        children: <Widget>[
          for (var index = 0; index < widget.volumes.length; index++)
            ExpansionTile(
              title: Text(widget.volumes[index].label),
              children: <Widget>[
                for (
                  var chapterIndex = 0;
                  chapterIndex < _controller.chapters.length;
                  chapterIndex++
                )
                  if (index == _controller.state.volumeIndex)
                    ListTile(
                      dense: true,
                      selected:
                          chapterIndex == _controller.state.chapterIndex,
                      title: Text(_controller.chapters[chapterIndex].label),
                      onTap: () {
                        Navigator.of(sheetContext).pop();
                        _openVolumeChapter(index, chapterIndex);
                      },
                    ),
              ],
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = _controller.state;
    final label = state.chapterLabel.isEmpty
        ? widget.cover.label
        : state.chapterLabel;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '$label${state.pageCount == 0 ? '' : ' ${state.pageIndex + 1}/${state.pageCount}'}',
          key: const ValueKey<String>('easymygo-novel-title'),
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
            tooltip: '目录',
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
                  key: const ValueKey<String>('easymygo-novel-error'),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => _run(
                    () => _controller.openChapter(state.chapterIndex),
                  ),
                  child: const Text('重试'),
                ),
              ],
            ),
          ),
        );
      case ReaderStatus.ready:
        break;
    }
    return Column(
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: SelectableText(
              state.pages[state.pageIndex],
              key: const ValueKey<String>('easymygo-novel-text'),
              style: const TextStyle(fontSize: 17, height: 1.6),
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                key: const ValueKey<String>('easymygo-novel-prev'),
                tooltip: '上一页',
                icon: const Icon(Icons.chevron_left),
                onPressed: () => _run(_controller.previousPage),
              ),
              Text('${state.pageIndex + 1} / ${state.pageCount}'),
              IconButton(
                key: const ValueKey<String>('easymygo-novel-next'),
                tooltip: '下一页',
                icon: const Icon(Icons.chevron_right),
                onPressed: () => _run(_controller.nextPage),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
