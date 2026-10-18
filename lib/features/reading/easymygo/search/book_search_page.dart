import 'package:dashboard/features/reading/easymygo/library/library_store.dart';
import 'package:dashboard/features/reading/easymygo/search/book_search_page_state.dart';
import 'package:dashboard/features/reading/easymygo/service/reading_service.dart';
import 'package:flutter/material.dart';

/// Search over the enabled rule sources.
class BookSearchPage extends StatefulWidget {
  const BookSearchPage({super.key, required this.service, this.libraryStore});

  final ReadingService service;
  final LibraryStore? libraryStore;

  @override
  State<BookSearchPage> createState() => BookSearchPageState();
}
