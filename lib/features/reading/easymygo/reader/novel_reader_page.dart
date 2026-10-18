import 'package:dashboard/features/reading/easymygo/component/novel_component.dart';
import 'package:dashboard/features/reading/easymygo/entity/book_cover.dart';
import 'package:dashboard/features/reading/easymygo/entity/book_summary.dart';
import 'package:dashboard/features/reading/easymygo/entity/novel_volume.dart';
import 'package:dashboard/features/reading/easymygo/library/library_store.dart';
import 'package:dashboard/features/reading/easymygo/reader/novel_reader_page_state.dart';
import 'package:flutter/material.dart';

/// Novel reader: paginated text with a persisted cursor.
class NovelReaderPage extends StatefulWidget {
  const NovelReaderPage({
    super.key,
    required this.component,
    required this.summary,
    required this.cover,
    required this.volumes,
    this.libraryStore,
    this.initialVolumeIndex = 0,
    this.initialChapterIndex = 0,
    this.restoreProgress = false,
  });

  final NovelComponent component;
  final BookSummary summary;
  final BookCover cover;
  final List<NovelVolume> volumes;
  final LibraryStore? libraryStore;
  final int initialVolumeIndex;
  final int initialChapterIndex;

  /// Restores the library cursor instead of the initial indices.
  final bool restoreProgress;

  @override
  State<NovelReaderPage> createState() => NovelReaderPageState();
}
