import 'package:dashboard/features/reading/book/entity/book.dart';
import 'package:dashboard/features/reading/book/view/book_reader_page_state.dart';
import 'package:flutter/material.dart';

/// Paged chapter reader for the ported book module.
///
/// Ported from `book/lib/view/book/chapter_view.dart` +
/// `reader_menu.dart` + `read_book.dart`. The source used an FFI/Rust pager and
/// a `scrollable_positioned_list`-driven turn animation; the host port keeps the
/// pagination + chapter-window logic (see `reader/`) but renders with a plain
/// [PageView] and Flutter text widgets.
class BookReaderPage extends StatefulWidget {
  const BookReaderPage({super.key, required this.book});

  /// Book row from `BookRepository`; the reader mutates its
  /// `chapterIndex` / `pageIndex` / `readingChapter` and persists them.
  final Book book;

  @override
  State<BookReaderPage> createState() => BookReaderPageState();
}
