import 'package:dashboard/features/comic/manhuatai/manhuatai_chapter.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_library_store.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_reader_page_state.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_source.dart';
import 'package:flutter/material.dart';

/// Vertical reader. Mirrors the source's `comic_read.dart`: every chapter is a
/// column of full-width images built from `chapter_image.middle`, and reaching
/// the bottom advances to the next chapter.
class ManhuataiReaderPage extends StatefulWidget {
  const ManhuataiReaderPage({
    super.key,
    required this.comicId,
    required this.comicName,
    required this.chapters,
    this.initialIndex = 0,
    this.source,
    this.store,
    this.imgUrl = '',
  });

  final int comicId;
  final String comicName;
  final List<ManhuataiChapter> chapters;
  final int initialIndex;
  final ManhuataiSource? source;
  final ManhuataiLibraryStore? store;
  final String imgUrl;

  @override
  State<ManhuataiReaderPage> createState() => ManhuataiReaderPageState();
}
