import 'package:dashboard/features/comic/u17_chapter.dart';
import 'package:dashboard/features/comic/u17_comic.dart';
import 'package:dashboard/features/comic/u17_library_store.dart';
import 'package:dashboard/features/comic/u17_reader_page_state.dart';
import 'package:dashboard/features/comic/u17_source.dart';
import 'package:flutter/material.dart';

class U17ReaderPage extends StatefulWidget {
  const U17ReaderPage({
    required this.comic,
    required this.chapters,
    required this.initialChapter,
    required this.source,
    required this.store,
    super.key,
  });

  final U17Comic comic;
  final List<U17Chapter> chapters;
  final U17Chapter initialChapter;
  final U17Source source;
  final U17LibraryStore store;

  @override
  State<U17ReaderPage> createState() => U17ReaderPageState();
}
