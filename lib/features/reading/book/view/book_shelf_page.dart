import 'package:dashboard/features/reading/book/view/book_shelf_page_state.dart';
import 'package:flutter/material.dart';

/// Book-shelf entry screen for the ported book module.
///
/// Lists books persisted by [BookRepository] and routes into search / explore /
/// source management / reader. Ported from `book/lib/view/book/...` shelf and
/// home surfaces, collapsed into the host's `FooPage` + `FooPageState`
/// convention.
class BookShelfPage extends StatefulWidget {
  const BookShelfPage({super.key});

  @override
  State<BookShelfPage> createState() => BookShelfPageState();
}
