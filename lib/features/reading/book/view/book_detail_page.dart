import 'package:dashboard/features/reading/book/model/search_book.dart';
import 'package:dashboard/features/reading/book/view/book_detail_page_state.dart';
import 'package:flutter/material.dart';

/// Book detail screen: refreshes [BookInfo] from the source, then adds the book
/// to the shelf + persists its TOC.
///
/// Ported from `book/lib/view/book/book_detail.dart`.
class BookDetailPage extends StatefulWidget {
  const BookDetailPage({super.key, required this.searchBook});

  /// Seed produced by search / explore; supplies name, cover, source and URL.
  final SearchBook searchBook;

  @override
  State<BookDetailPage> createState() => BookDetailPageState();
}
