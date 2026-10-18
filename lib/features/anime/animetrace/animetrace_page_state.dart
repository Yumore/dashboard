import 'dart:async';

import 'package:dashboard/features/anime/animetrace/animetrace_anime.dart';
import 'package:dashboard/features/anime/animetrace/animetrace_page.dart';
import 'package:dashboard/features/anime/animetrace/animetrace_refresh_bus.dart';
import 'package:dashboard/features/anime/animetrace/animetrace_repository.dart';
import 'package:dashboard/features/anime/animetrace/animetrace_source.dart';
import 'package:dashboard/features/anime/animetrace/pages/animetrace_backup_page.dart';
import 'package:dashboard/features/anime/animetrace/pages/animetrace_collection_tab.dart';
import 'package:dashboard/features/anime/animetrace/pages/animetrace_history_tab.dart';
import 'package:dashboard/features/anime/animetrace/pages/animetrace_search_tab.dart';
import 'package:dashboard/features/anime/animetrace/pages/animetrace_series_detail_page.dart';
import 'package:dashboard/features/anime/animetrace/pages/animetrace_source_tab.dart';
import 'package:dashboard/features/anime/animetrace/pages/animetrace_tools_page.dart';
import 'package:dashboard/features/anime/animetrace/store/animetrace_anime_dao.dart';
import 'package:dashboard/features/anime/animetrace/store/animetrace_episode_note_dao.dart';
import 'package:dashboard/features/anime/animetrace/store/animetrace_executor.dart';
import 'package:dashboard/features/anime/animetrace/store/animetrace_history_dao.dart';
import 'package:dashboard/features/anime/animetrace/store/animetrace_image_store.dart';
import 'package:dashboard/features/anime/animetrace/store/animetrace_label_dao.dart';
import 'package:dashboard/features/anime/animetrace/store/animetrace_series_dao.dart';
import 'package:dashboard/features/anime/animetrace/store/animetrace_source_store.dart';
import 'package:dashboard/features/anime/animetrace/store/animetrace_sqflite_database.dart';
import 'package:flutter/material.dart';

/// State of [AnimeTracePage].
///
/// The local database is opened once in [initState] — never in [build] — and
/// the four tabs receive the DAOs it produced. Any failure while opening is
/// rendered as a retryable error state instead of an exception.
class AnimeTracePageState extends State<AnimeTracePage> {
  late final AnimeTraceSourceStore _sourceStore =
      widget.sourceStore ?? AnimeTraceSourceStore();
  late final AnimeTraceRepository _repository =
      widget.repository ?? AnimeTraceRepository(sourceStore: _sourceStore);
  late final AnimeTraceExecutorDatabase _database =
      widget.database ?? AnimeTraceSqfliteDatabase.production();
  late final AnimeTraceImageStore _imageStore =
      widget.imageStore ?? AnimeTraceImageStore();

  final AnimeTraceRefreshBus _bus = AnimeTraceRefreshBus();

  AnimeTraceAnimeDao? _animeDao;
  AnimeTraceEpisodeNoteDao? _episodeNoteDao;
  AnimeTraceHistoryDao? _historyDao;
  AnimeTraceLabelDao? _labelDao;
  AnimeTraceSeriesDao? _seriesDao;

  bool _opening = true;
  String? _error;
  List<AnimeTraceSource> _sources = const <AnimeTraceSource>[];

  @override
  void initState() {
    super.initState();
    // Loading starts here, never in build: build must stay free of I/O.
    unawaited(_open());
  }

  @override
  void dispose() {
    _bus.dispose();
    super.dispose();
  }

  Future<void> _open() async {
    if (mounted) {
      setState(() {
        _opening = true;
        _error = null;
      });
    }
    try {
      await _database.open();
      final sources = await _repository.loadSources();
      if (!mounted) return;
      setState(() {
        _animeDao = AnimeTraceAnimeDao(_database);
        _episodeNoteDao = AnimeTraceEpisodeNoteDao(_database);
        _historyDao = AnimeTraceHistoryDao(_database);
        _labelDao = AnimeTraceLabelDao(_database);
        _seriesDao = AnimeTraceSeriesDao(_database);
        _sources = sources;
        _opening = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = '$error';
        _opening = false;
      });
    }
  }

  Future<void> _reloadSources() async {
    final sources = await _repository.loadSources();
    if (!mounted) return;
    setState(() => _sources = sources);
  }

  void _openSeries(AnimeTraceAnime anime) {
    final animeDao = _animeDao;
    final episodeNoteDao = _episodeNoteDao;
    final historyDao = _historyDao;
    if (animeDao == null || episodeNoteDao == null || historyDao == null) {
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AnimeTraceSeriesDetailPage(
          anime: anime,
          animeDao: animeDao,
          episodeNoteDao: episodeNoteDao,
          historyDao: historyDao,
          imageStore: _imageStore,
          repository: _repository,
          onChanged: _bus.notifyChanged,
        ),
      ),
    );
  }

  void _openBackup() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AnimeTraceBackupPage(database: _database),
      ),
    );
  }

  void _openTools() {
    final animeDao = _animeDao;
    if (animeDao == null) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AnimeTraceToolsPage(
          animeDao: animeDao,
          repository: _repository,
          onChanged: _bus.notifyChanged,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('漫迹'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.build_outlined),
              tooltip: '去重与封面修复',
              onPressed: _animeDao == null ? null : _openTools,
            ),
            IconButton(
              icon: const Icon(Icons.settings_backup_restore),
              tooltip: '备份与恢复',
              onPressed: _openBackup,
            ),
          ],
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(text: '收藏'),
              Tab(text: '搜索'),
              Tab(text: '来源'),
              Tab(text: '历史'),
            ],
          ),
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_opening) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('正在打开本地数据库…'),
          ],
        ),
      );
    }
    final error = _error;
    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.error_outline, size: 40),
              const SizedBox(height: 12),
              Text('打开失败：$error', textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => unawaited(_open()),
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      );
    }

    final animeDao = _animeDao!;
    final labelDao = _labelDao!;
    final seriesDao = _seriesDao!;
    final historyDao = _historyDao!;
    final episodeNoteDao = _episodeNoteDao!;

    return TabBarView(
      children: <Widget>[
        AnimeTraceCollectionTab(
          animeDao: animeDao,
          labelDao: labelDao,
          seriesDao: seriesDao,
          imageStore: _imageStore,
          bus: _bus,
          onOpenAnime: _openSeries,
        ),
        AnimeTraceSearchTab(
          repository: _repository,
          animeDao: animeDao,
          labelDao: labelDao,
          bus: _bus,
          onOpenAnime: _openSeries,
        ),
        AnimeTraceSourceTab(
          repository: _repository,
          sourceStore: _sourceStore,
          sources: _sources,
          onSourcesChanged: (_) => unawaited(_reloadSources()),
        ),
        AnimeTraceHistoryTab(
          historyDao: historyDao,
          animeDao: animeDao,
          imageStore: _imageStore,
          bus: _bus,
          onOpenAnime: _openSeries,
          episodeNoteDao: episodeNoteDao,
        ),
      ],
    );
  }
}
