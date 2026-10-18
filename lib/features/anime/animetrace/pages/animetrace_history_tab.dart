import 'dart:async';

import 'package:dashboard/features/anime/animetrace/animetrace_anime.dart';
import 'package:dashboard/features/anime/animetrace/animetrace_history_group.dart';
import 'package:dashboard/features/anime/animetrace/animetrace_refresh_bus.dart';
import 'package:dashboard/features/anime/animetrace/store/animetrace_anime_dao.dart';
import 'package:dashboard/features/anime/animetrace/store/animetrace_episode_note_dao.dart';
import 'package:dashboard/features/anime/animetrace/store/animetrace_history_dao.dart';
import 'package:dashboard/features/anime/animetrace/store/animetrace_image_store.dart';
import 'package:dashboard/features/anime/animetrace/widgets/animetrace_cover.dart';
import 'package:flutter/material.dart';

/// Watch history, day by day, plus the list of anime that already have notes.
class AnimeTraceHistoryTab extends StatefulWidget {
  const AnimeTraceHistoryTab({
    required this.historyDao,
    required this.animeDao,
    required this.episodeNoteDao,
    required this.imageStore,
    required this.bus,
    required this.onOpenAnime,
    super.key,
  });

  final AnimeTraceHistoryDao historyDao;
  final AnimeTraceAnimeDao animeDao;
  final AnimeTraceEpisodeNoteDao episodeNoteDao;
  final AnimeTraceImageStore imageStore;
  final AnimeTraceRefreshBus bus;
  final void Function(AnimeTraceAnime anime) onOpenAnime;

  @override
  State<AnimeTraceHistoryTab> createState() => _AnimeTraceHistoryTabState();
}

class _AnimeTraceHistoryTabState extends State<AnimeTraceHistoryTab> {
  static const int _pageSize = 20;

  final List<AnimeTraceHistoryGroup> _groups = <AnimeTraceHistoryGroup>[];
  List<AnimeTraceAnime> _notedAnimes = const <AnimeTraceAnime>[];
  int _page = 1;
  int _dayCount = 0;
  bool _showNotes = false;
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;
  String _coverRoot = '';

  @override
  void initState() {
    super.initState();
    widget.bus.addListener(_reload);
    unawaited(_reload());
  }

  @override
  void dispose() {
    widget.bus.removeListener(_reload);
    super.dispose();
  }

  Future<void> _reload() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final coverRoot = await widget.imageStore.coverImageRootDirPath();
      final dayCount = await widget.historyDao.getHistoryDayCount();
      final groups = await widget.historyDao.getHistoryPageable(
        page: 1,
        pageSize: _pageSize,
      );
      final notedIds = await widget.episodeNoteDao.getAnimeIdsWithRecentNotes();
      final noted = <AnimeTraceAnime>[];
      for (final id in notedIds) {
        final anime = await widget.animeDao.getAnimeById(id);
        if (anime != null) noted.add(anime);
      }
      if (!mounted) return;
      setState(() {
        _coverRoot = coverRoot;
        _dayCount = dayCount;
        _page = 1;
        _groups
          ..clear()
          ..addAll(groups);
        _notedAnimes = noted;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = '$error';
        _loading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || _groups.length >= _dayCount) return;
    setState(() => _loadingMore = true);
    try {
      final next = await widget.historyDao.getHistoryPageable(
        page: _page + 1,
        pageSize: _pageSize,
      );
      if (!mounted) return;
      setState(() {
        _page += 1;
        _groups.addAll(next);
        _loadingMore = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadingMore = false;
        _error = '$error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: SegmentedButton<bool>(
            segments: const <ButtonSegment<bool>>[
              ButtonSegment<bool>(value: false, label: Text('观看历史')),
              ButtonSegment<bool>(value: true, label: Text('笔记')),
            ],
            selected: <bool>{_showNotes},
            onSelectionChanged: (selection) {
              setState(() => _showNotes = selection.first);
            },
          ),
        ),
        const Divider(height: 1),
        Expanded(child: _buildBody()),
      ],
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
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
              Text('加载失败：$error', textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => unawaited(_reload()),
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      );
    }
    if (_showNotes) return _buildNotes();
    return _buildHistory();
  }

  Widget _buildNotes() {
    if (_notedAnimes.isEmpty) {
      return const Center(child: Text('还没有任何笔记'));
    }
    return ListView.separated(
      itemCount: _notedAnimes.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final anime = _notedAnimes[index];
        return ListTile(
          leading: AnimeTraceCover(
            url: anime.animeCoverUrl,
            localRoot: _coverRoot,
          ),
          title: Text(anime.animeName),
          subtitle: Text('已看 ${anime.checkedEpisodeCnt} 集'),
          onTap: () => widget.onOpenAnime(anime),
        );
      },
    );
  }

  Widget _buildHistory() {
    if (_groups.isEmpty) {
      return const Center(child: Text('还没有观看记录'));
    }
    final hasMore = _groups.length < _dayCount;
    return RefreshIndicator(
      onRefresh: _reload,
      child: ListView(
        children: <Widget>[
          for (final group in _groups) ...<Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
              child: Text(
                group.date,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            for (final record in group.records)
              ListTile(
                dense: true,
                leading: AnimeTraceCover(
                  url: record.anime.animeCoverUrl,
                  localRoot: _coverRoot,
                  width: 40,
                  height: 54,
                ),
                title: Text(record.anime.animeName),
                subtitle: Text(
                  record.reviewNumber > 1
                      ? '${record.episodeRangeLabel} · 第 ${record.reviewNumber} 刷'
                      : record.episodeRangeLabel,
                ),
                onTap: () => widget.onOpenAnime(record.anime),
              ),
          ],
          if (hasMore)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Center(
                child: _loadingMore
                    ? const CircularProgressIndicator()
                    : TextButton(
                        onPressed: () => unawaited(_loadMore()),
                        child: const Text('加载更多'),
                      ),
              ),
            ),
        ],
      ),
    );
  }
}
