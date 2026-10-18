import 'package:dashboard/features/comic/picacomic/controllers/picacomic_reader_controller.dart';
import 'package:dashboard/features/comic/picacomic/pages/picacomic_reader_page_state.dart';
import 'package:flutter/material.dart';

/// Reader screen of the picacomic module.
///
/// Ports the vertical/horizontal paging part of PicaComic
/// lib/pages/reader/comic_reading_page.dart: a [PageView] over the page urls
/// returned by `loadComicPages`, with tap-to-toggle overlays and the reading
/// position persisted by the controller.
class PicacomicReaderPage extends StatefulWidget {
  const PicacomicReaderPage({
    required this.sourceKey,
    required this.comicId,
    this.chapterId,
    this.chapterName,
    this.title = '',
    this.cover = '',
    this.chapterCount,
    this.controller,
    super.key,
  });

  final String sourceKey;
  final String comicId;
  final String? chapterId;
  final String? chapterName;
  final String title;
  final String cover;
  final int? chapterCount;
  final PicacomicReaderController? controller;

  @override
  State<PicacomicReaderPage> createState() => PicacomicReaderPageState();
}
