import 'package:dashboard/features/anime/animetrace/pages/animetrace_tools_page_state.dart';
import 'package:dashboard/features/anime/animetrace/animetrace_repository.dart';
import 'package:dashboard/features/anime/animetrace/store/animetrace_anime_dao.dart';
import 'package:flutter/material.dart';

/// Maintenance tools ported from the source app's `dedup` and
/// `lapse_cover_fix` pages.
class AnimeTraceToolsPage extends StatefulWidget {
  const AnimeTraceToolsPage({
    required this.animeDao,
    required this.repository,
    required this.onChanged,
    super.key,
  });

  final AnimeTraceAnimeDao animeDao;
  final AnimeTraceRepository repository;
  final VoidCallback onChanged;

  @override
  State<AnimeTraceToolsPage> createState() => AnimeTraceToolsPageState();
}
