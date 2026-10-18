import 'package:dashboard/features/reading/easymygo/detail/book_detail_page_state.dart';
import 'package:dashboard/features/reading/easymygo/entity/book_cover.dart';
import 'package:dashboard/features/reading/easymygo/library/library_store.dart';
import 'package:dashboard/features/reading/easymygo/service/reading_service.dart';
import 'package:flutter/material.dart';

/// Book detail with the chapter list (manga chapters / novel volumes).
class BookDetailPage extends StatefulWidget {
  const BookDetailPage({
    super.key,
    required this.service,
    required this.cover,
    this.libraryStore,
    this.autoResume = false,
  });

  final ReadingService service;
  final BookCover cover;
  final LibraryStore? libraryStore;

  /// When true and the library has progress, jump straight into the reader.
  final bool autoResume;

  @override
  State<BookDetailPage> createState() => BookDetailPageState();
}
