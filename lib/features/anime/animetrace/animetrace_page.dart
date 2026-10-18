import 'package:dashboard/features/anime/animetrace/animetrace_page_state.dart';
import 'package:dashboard/features/anime/animetrace/animetrace_repository.dart';
import 'package:dashboard/features/anime/animetrace/store/animetrace_executor.dart';
import 'package:dashboard/features/anime/animetrace/store/animetrace_image_store.dart';
import 'package:dashboard/features/anime/animetrace/store/animetrace_source_store.dart';
import 'package:flutter/material.dart';

/// 漫迹 (AnimeTrace): a local-first anime collection, episode-note and history
/// manager with per-site scrapers.
///
/// Dependencies are injectable so widget tests can supply a preloaded
/// repository/database and avoid any network access.
class AnimeTracePage extends StatefulWidget {
  const AnimeTracePage({
    super.key,
    this.repository,
    this.database,
    this.imageStore,
    this.sourceStore,
  });

  final AnimeTraceRepository? repository;
  final AnimeTraceExecutorDatabase? database;
  final AnimeTraceImageStore? imageStore;
  final AnimeTraceSourceStore? sourceStore;

  @override
  State<AnimeTracePage> createState() => AnimeTracePageState();
}
