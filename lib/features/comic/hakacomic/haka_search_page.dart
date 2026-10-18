import 'package:flutter/material.dart';
import 'package:dashboard/features/comic/hakacomic/haka_repository.dart';
import 'package:dashboard/features/comic/hakacomic/haka_search_history_store.dart';
import 'package:dashboard/features/comic/hakacomic/haka_search_page_state.dart';

/// Search tab: recent/hot terms before a query, paged results after.
///
/// Body-only: the module page owns the scaffold and tab bar.
class HakaSearchPage extends StatefulWidget {
  const HakaSearchPage({
    super.key,
    required this.repository,
    required this.searchHistory,
    required this.onOpenComic,
  });

  final HakaRepository repository;

  final HakaSearchHistoryStore searchHistory;

  final void Function(String comicId) onOpenComic;

  @override
  State<HakaSearchPage> createState() => HakaSearchPageState();
}
