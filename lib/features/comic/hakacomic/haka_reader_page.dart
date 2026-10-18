import 'package:flutter/material.dart';
import 'package:dashboard/features/comic/hakacomic/haka_chapter.dart';
import 'package:dashboard/features/comic/hakacomic/haka_read_record_store.dart';
import 'package:dashboard/features/comic/hakacomic/haka_reader_page_state.dart';
import 'package:dashboard/features/comic/hakacomic/haka_repository.dart';

/// Chapter reader (`haka_comic/lib/views/reader/reader.dart`).
class HakaReaderPage extends StatefulWidget {
  const HakaReaderPage({
    super.key,
    required this.repository,
    required this.comicId,
    required this.chapters,
    required this.readRecords,
    this.initialOrder = 1,
    this.initialPage = 1,
  });

  final HakaRepository repository;

  final String comicId;

  /// All chapters, any order; the controller sorts by `order`.
  final List<HakaChapter> chapters;

  final HakaReadRecordStore readRecords;

  /// 1-based chapter `order` to open.
  final int initialOrder;

  /// 1-based page to resume.
  final int initialPage;

  @override
  State<HakaReaderPage> createState() => HakaReaderPageState();
}
