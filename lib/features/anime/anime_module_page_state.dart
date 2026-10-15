import 'package:dashboard/features/anime/anime_episode.dart';
import 'package:dashboard/features/anime/anime_category.dart';
import 'package:dashboard/features/anime/anime_episode_page.dart';
import 'package:dashboard/features/anime/anime_favorite_store.dart';
import 'package:dashboard/features/anime/anime_module_page.dart';
import 'package:dashboard/features/anime/anime_show.dart';
import 'package:dashboard/features/anime/anime_show_details_page.dart';
import 'package:dashboard/features/anime/anime_source.dart';
import 'package:dashboard/features/anime/anime_watch_store.dart';
import 'package:flutter/material.dart';

class AnimeModulePageState extends State<AnimeModulePage> {
  final _source = AnimeSource();
  final _favorites = AnimeFavoriteStore();
  final _history = AnimeWatchStore();
  final _searchInput = TextEditingController();
  late Future<List<AnimeEpisode>> _recent;
  late Future<List<AnimeShow>> _catalogue;
  Future<List<AnimeShow>>? _searchResults;
  List<AnimeShow> _saved = const [];
  AnimeEpisode? _lastEpisode;
  Set<String> _watched = {};
  String _category = '/subbed-anime-list';
  String _catalogueFilter = '';

  @override
  void initState() {
    super.initState();
    _recent = _source.recent();
    _catalogue = _source.catalogue(_category);
    _refreshFavorites();
    _refreshHistory();
  }

  Future<void> _refreshHistory() async {
    final last = await _history.last();
    final watched = await _history.watchedUrls();
    if (!mounted) return;
    setState(() {
      _lastEpisode = last;
      _watched = watched;
    });
  }

  Future<void> _openEpisode(AnimeEpisode episode) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AnimeEpisodePage(url: episode.url),
      ),
    );
    await _refreshHistory();
  }

  Future<void> _refreshFavorites() async {
    final saved = await _favorites.load();
    if (mounted) setState(() => _saved = saved);
  }

  Future<void> _openDetails(AnimeShow show) async {
    try {
      final details = await _source.details(show);
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => AnimeShowDetailsPage(
            show: details,
            favorites: _favorites,
            history: _history,
            onChanged: _refreshFavorites,
          ),
        ),
      );
      await _refreshHistory();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$error')));
      }
    }
  }

  void _search() {
    final query = _searchInput.text.trim();
    if (query.isEmpty) return;
    setState(() => _searchResults = _source.search(query));
  }

  Widget _showList(
    Future<List<AnimeShow>> future, {
    bool directPlayback = false,
    String filter = '',
  }) {
    return FutureBuilder<List<AnimeShow>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('加载失败：${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final shows = snapshot.data!
            .where(
              (show) => show.title.toLowerCase().contains(filter.toLowerCase()),
            )
            .toList();
        if (shows.isEmpty) return const Center(child: Text('暂无内容'));
        return ListView.builder(
          itemCount: shows.length,
          itemBuilder: (context, index) {
            final show = shows[index];
            return ListTile(
              title: Text(show.title),
              leading: show.image == null
                  ? const Icon(Icons.movie_outlined)
                  : Image.network(
                      show.image.toString(),
                      width: 48,
                      errorBuilder: (_, _, _) =>
                          const Icon(Icons.movie_outlined),
                    ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => directPlayback
                  ? _openEpisode(AnimeEpisode(title: show.title, url: show.url))
                  : _openDetails(show),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _searchInput.dispose();
    _source.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('动漫'),
          actions: [
            IconButton(
              tooltip: _lastEpisode == null
                  ? '暂无观看记录'
                  : '继续观看：${_lastEpisode!.title}',
              icon: const Icon(Icons.play_circle_outline),
              onPressed: _lastEpisode == null
                  ? null
                  : () => _openEpisode(_lastEpisode!),
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: '最近更新'),
              Tab(text: '目录'),
              Tab(text: '搜索'),
              Tab(text: '收藏'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            FutureBuilder<List<AnimeEpisode>>(
              future: _recent,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('加载失败：${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() => _recent = _source.recent());
                    await _recent;
                  },
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final episode = snapshot.data![index];
                      return ListTile(
                        title: Text(episode.title),
                        leading: _watched.contains(episode.url.toString())
                            ? const Icon(Icons.check_circle_outline)
                            : null,
                        trailing: const Icon(Icons.play_arrow),
                        onTap: () => _openEpisode(episode),
                      );
                    },
                  ),
                );
              },
            ),
            Column(
              children: [
                DropdownButton<String>(
                  value: _category,
                  items: AnimeCategory.values
                      .map(
                        (entry) => DropdownMenuItem(
                          value: entry.path,
                          child: Text(entry.label),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _category = value;
                      _catalogue = _source.catalogue(value);
                    });
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: '筛选当前目录',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) =>
                        setState(() => _catalogueFilter = value.trim()),
                  ),
                ),
                Expanded(
                  child: _showList(
                    _catalogue,
                    filter: _catalogueFilter,
                    directPlayback: AnimeCategory.values
                        .firstWhere((category) => category.path == _category)
                        .directPlayback,
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: _searchInput,
                    decoration: InputDecoration(
                      labelText: '搜索动漫',
                      suffixIcon: IconButton(
                        onPressed: _search,
                        icon: const Icon(Icons.search),
                      ),
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                ),
                Expanded(
                  child: _searchResults == null
                      ? const Center(child: Text('输入关键词搜索'))
                      : _showList(_searchResults!),
                ),
              ],
            ),
            _saved.isEmpty
                ? const Center(child: Text('暂无收藏'))
                : ListView.builder(
                    itemCount: _saved.length,
                    itemBuilder: (context, index) => ListTile(
                      title: Text(_saved[index].title),
                      onTap: () => _openDetails(_saved[index]),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
