import 'package:dashboard/features/reading/book/view/search_page_state.dart';
import 'package:flutter/material.dart';

/// Multi-source book search screen.
///
/// Ported from `book/lib/view/book/search_page.dart`; provider-driven state was
/// replaced by [SearchPageState] + [BookSourceEngine].
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => SearchPageState();
}
