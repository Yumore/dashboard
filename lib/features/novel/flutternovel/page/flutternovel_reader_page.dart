import 'package:dashboard/features/novel/flutternovel/models/flutter_novel_progress.dart';
import 'package:dashboard/features/novel/flutternovel/models/novel_book_chapter.dart';
import 'package:dashboard/features/novel/flutternovel/reader/flutter_novel_reader_screen.dart';
import 'package:dashboard/features/novel/flutternovel/reader/novel_reader_controller.dart';
import 'package:dashboard/features/novel/flutternovel/store/flutter_novel_store.dart';
import 'package:dashboard/features/novel/flutternovel/store/novel_chapter_cache.dart';
import 'package:dashboard/features/novel/flutternovel/api/zssq_api.dart';
import 'package:flutter/material.dart';

/// A pushed route that owns one [NovelReaderController] for one book.
///
/// The controller is built in [initState] from the already-loaded catalog (so
/// opening the reader never repeats the `btoc` + `atoc` requests the detail page
/// just made) and is disposed with the route.
class FlutterNovelReaderPage extends StatefulWidget {
  const FlutterNovelReaderPage({
    super.key,
    required this.api,
    required this.store,
    required this.cache,
    required this.bookId,
    this.title = '',
    this.catalog,
    this.chapterIndex = 0,
    this.pageIndex = 0,
  });

  final ZssqApi api;
  final FlutterNovelStore store;
  final NovelChapterCache cache;
  final String bookId;
  final String title;
  final NovelBookChapter? catalog;
  final int chapterIndex;
  final int pageIndex;

  @override
  State<FlutterNovelReaderPage> createState() => _FlutterNovelReaderPageState();
}

class _FlutterNovelReaderPageState extends State<FlutterNovelReaderPage> {
  NovelReaderController? _controller;

  @override
  void initState() {
    super.initState();
    _open();
  }

  Future<void> _open() async {
    final controller = NovelReaderController(
      api: widget.api,
      store: widget.store,
      cache: widget.cache,
      bookId: widget.bookId,
      title: widget.title,
    );
    setState(() => _controller = controller);

    if (widget.catalog != null && widget.catalog!.chapters.isNotEmpty) {
      await controller.bindCatalog(
        widget.catalog,
        progress: FlutterNovelProgress(
          bookId: widget.bookId,
          chapterIndex: widget.chapterIndex,
          pageIndex: widget.pageIndex,
        ),
      );
      return;
    }

    final loaded = await controller.loadCatalog();
    if (!mounted || !loaded) return;
    final progress = await widget.store.loadProgress(widget.bookId);
    if (!mounted) return;
    await controller.bindCatalog(null, progress: progress);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return FlutterNovelReaderScreen(controller: controller);
  }
}
