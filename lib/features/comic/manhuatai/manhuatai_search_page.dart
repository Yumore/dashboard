import 'package:dashboard/features/comic/manhuatai/manhuatai_library_store.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_search_page_state.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_source.dart';
import 'package:flutter/material.dart';

/// Search screen: hot keywords (`gettopsearch`), local search history and
/// results from `serachcomic`.
class ManhuataiSearchPage extends StatefulWidget {
  const ManhuataiSearchPage({super.key, required this.source, required this.store});

  final ManhuataiSource source;
  final ManhuataiLibraryStore store;

  @override
  State<ManhuataiSearchPage> createState() => ManhuataiSearchPageState();
}
