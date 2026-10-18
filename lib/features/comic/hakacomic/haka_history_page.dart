import 'package:flutter/material.dart';
import 'package:dashboard/features/comic/hakacomic/haka_history_page_state.dart';
import 'package:dashboard/features/comic/hakacomic/haka_history_store.dart';

/// History tab: locally persisted comics, most-recent-first.
///
/// Body-only: the module page owns the scaffold and tab bar.
class HakaHistoryPage extends StatefulWidget {
  const HakaHistoryPage({
    super.key,
    required this.historyStore,
    required this.onOpenComic,
  });

  final HakaHistoryStore historyStore;

  final void Function(String comicId) onOpenComic;

  @override
  State<HakaHistoryPage> createState() => HakaHistoryPageState();
}
