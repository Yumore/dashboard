import 'package:dashboard/features/comic/u17_comic_detail.dart';
import 'package:dashboard/features/comic/u17_chapter_page_state.dart';
import 'package:dashboard/features/comic/u17_library_store.dart';
import 'package:dashboard/features/comic/u17_source.dart';
import 'package:flutter/material.dart';

class U17ChapterPage extends StatefulWidget {
  const U17ChapterPage({
    required this.detail,
    required this.store,
    required this.source,
    super.key,
  });

  final U17ComicDetail detail;
  final U17LibraryStore store;
  final U17Source source;

  @override
  State<U17ChapterPage> createState() => U17ChapterPageState();
}
