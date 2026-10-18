import 'package:dashboard/features/anime/animeone/animeone_detail_page.dart';
import 'package:dashboard/features/anime/animeone/animeone_history_page.dart';
import 'package:dashboard/features/anime/animeone/animeone_latest_page.dart';
import 'package:dashboard/features/anime/animeone/animeone_list_page.dart';
import 'package:dashboard/features/anime/animeone/animeone_module_page.dart';
import 'package:dashboard/features/anime/animeone/animeone_playback_page.dart';
import 'package:dashboard/features/anime/animeone/animeone_schedule_page.dart';
import 'package:dashboard/features/anime/animeone/animeone_season.dart';
import 'package:dashboard/features/anime/animeone/animeone_watch_entry.dart';
import 'package:dashboard/features/anime/animeone/animeone_watch_store.dart';
import 'package:flutter/material.dart';

class AnimeOneModulePageState extends State<AnimeOneModulePage> {
  late final AnimeOneWatchStore _store;
  AnimeOneWatchEntry? lastWatched;

  @override
  void initState() {
    super.initState();
    _store = widget.watchStore ?? AnimeOneWatchStore();
    _refreshHistory();
  }

  Future<void> _refreshHistory() async {
    await _store.load();
    if (!mounted) return;
    final history = _store.entries;
    setState(() => lastWatched = history.isEmpty ? null : history.first);
  }

  Future<void> _open(Widget page) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => page));
    await _refreshHistory();
  }

  @override
  Widget build(BuildContext context) {
    final season = AnimeOneSeason(DateTime.now());
    final last = lastWatched;
    return Scaffold(
      appBar: AppBar(title: const Text('anime1.me')),
      body: ListView(
        children: [
          if (last != null)
            ListTile(
              leading: const Icon(Icons.play_circle_fill),
              title: const Text('继续观看'),
              subtitle: Text(
                '${last.episodeName} · ${last.progressLabel}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () => _open(
                AnimeOnePlaybackPage(
                  link: last.episodeLink,
                  title: last.episodeName,
                  watchStore: _store,
                ),
              ),
            ),
          ListTile(
            leading: const Icon(Icons.fiber_new),
            title: const Text('最近更新'),
            subtitle: const Text('anime1.me 首页的更新列表'),
            onTap: () => _open(
              AnimeOneLatestPage(client: widget.client, watchStore: _store),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.list_alt),
            title: const Text('动画目录'),
            subtitle: const Text('全部动画的快速搜索与筛选'),
            onTap: () => _open(
              AnimeOneListPage(client: widget.client, watchStore: _store),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.calendar_month),
            title: Text(season.name),
            subtitle: const Text('按星期查看当季新番'),
            onTap: () => _open(
              AnimeOneSchedulePage(client: widget.client, watchStore: _store),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('观看记录'),
            onTap: () => _open(
              AnimeOneHistoryPage(client: widget.client, watchStore: _store),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.category_outlined),
            title: const Text('本季分类'),
            subtitle: Text(season.categoryLink),
            onTap: () => _open(
              AnimeOneDetailPage(
                link: season.categoryLink,
                title: season.name,
                seasonal: true,
                client: widget.client,
                watchStore: _store,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
