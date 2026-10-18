import 'package:dashboard/features/reading/easymygo/component/manga_component.dart';
import 'package:dashboard/features/reading/easymygo/entity/book_cover.dart';
import 'package:dashboard/features/reading/easymygo/entity/book_summary.dart';
import 'package:dashboard/features/reading/easymygo/entity/manga_chapter.dart';
import 'package:dashboard/features/reading/easymygo/library/library_store.dart';
import 'package:dashboard/features/reading/easymygo/reader/manga_reader_page_state.dart';
import 'package:flutter/material.dart';

/// Manga reader: one chapter of pictures with a persisted cursor.
class MangaReaderPage extends StatefulWidget {
  const MangaReaderPage({
    super.key,
    required this.component,
    required this.summary,
    required this.cover,
    required this.chapters,
    this.libraryStore,
    this.initialChapterIndex = 0,
    this.restoreProgress = false,
  });

  final MangaComponent component;
  final BookSummary summary;
  final BookCover cover;
  final List<MangaChapter> chapters;
  final LibraryStore? libraryStore;
  final int initialChapterIndex;

  /// Restores the library cursor instead of [initialChapterIndex].
  final bool restoreProgress;

  @override
  State<MangaReaderPage> createState() => MangaReaderPageState();
}
