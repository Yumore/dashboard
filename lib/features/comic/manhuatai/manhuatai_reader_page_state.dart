import 'package:dashboard/features/comic/manhuatai/manhuatai_cover.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_image_url.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_library_store.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_read_record.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_reader_page.dart';
import 'package:flutter/material.dart';

class ManhuataiReaderPageState extends State<ManhuataiReaderPage> {
  late final ManhuataiLibraryStore _store =
      widget.store ?? ManhuataiLibraryStore();
  final ScrollController _controller = ScrollController();
  late int _index = widget.initialIndex.clamp(
    0,
    widget.chapters.isEmpty ? 0 : widget.chapters.length - 1,
  );
  bool _advanced = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
    _remember();
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_controller.hasClients) {
      return;
    }
    final position = _controller.position;
    if (position.pixels >= position.maxScrollExtent - 240) {
      _nextChapter();
    }
  }

  Future<void> _remember() async {
    if (widget.chapters.isEmpty) {
      return;
    }
    final chapter = widget.chapters[_index];
    await _store.remember(
      ManhuataiReadRecord.fromChapter(
        comicId: widget.comicId,
        comicName: widget.comicName,
        chapter: chapter,
        chapterPage: 0,
        imgUrl: widget.imgUrl,
      ),
    );
  }

  void _goTo(int index) {
    if (index < 0 || index >= widget.chapters.length) {
      return;
    }
    setState(() {
      _index = index;
      _advanced = false;
    });
    _remember();
    if (_controller.hasClients) {
      _controller.jumpTo(0);
    }
  }

  void _nextChapter() {
    if (_advanced || _index >= widget.chapters.length - 1) {
      return;
    }
    _advanced = true;
    _goTo(_index + 1);
  }

  void _previousChapter() {
    if (_index <= 0) {
      return;
    }
    _goTo(_index - 1);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.chapters.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.comicName)),
        body: const Center(child: Text('没有可阅读的章节')),
      );
    }
    final chapter = widget.chapters[_index];
    final urls = ManhuataiImageUrl.chapterPageUrls(chapter);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          chapter.chapterName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: Text(
            '${_index + 1}/${widget.chapters.length} · ${urls.length} 页',
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ),
      ),
      body: ListView.builder(
        controller: _controller,
        itemCount: urls.length,
        itemBuilder: (context, index) => ManhuataiCover(
          url: urls[index],
          fit: BoxFit.fitWidth,
          borderRadius: 0,
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            TextButton.icon(
              onPressed: _index > 0 ? _previousChapter : null,
              icon: const Icon(Icons.skip_previous),
              label: const Text('上一章'),
            ),
            Text('${_index + 1}/${widget.chapters.length}'),
            TextButton.icon(
              onPressed:
                  _index < widget.chapters.length - 1 ? _nextChapter : null,
              icon: const Icon(Icons.skip_next),
              label: const Text('下一章'),
            ),
          ],
        ),
      ),
    );
  }
}
