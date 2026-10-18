import 'package:dashboard/features/anime/takoplay/tako_anime.dart';
import 'package:dashboard/features/anime/takoplay/tako_play_client.dart';
import 'package:dashboard/features/anime/takoplay/tako_play_detail_page.dart';
import 'package:dashboard/features/anime/takoplay/tako_play_search_page.dart';
import 'package:dashboard/features/anime/takoplay/tako_search_results.dart';
import 'package:flutter/material.dart';

class TakoPlaySearchPageState extends State<TakoPlaySearchPage> {
  late final TakoPlayClient _client = widget.client ?? TakoPlayClient();
  final _query = TextEditingController();
  late Future<List<TakoAnime>> _recent;
  Future<TakoSearchResults>? _search;

  @override
  void initState() {
    super.initState();
    _recent = _client.recent();
  }

  @override
  void dispose() {
    if (widget.client == null) _client.dispose();
    _query.dispose();
    super.dispose();
  }

  void _runSearch() {
    final query = _query.text.trim();
    if (query.isEmpty) return;
    setState(() {
      _search = _client.search(query);
    });
  }

  void _open(TakoAnime anime) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TakoPlayDetailPage(anime: anime, client: widget.client),
      ),
    );
  }

  Widget _tile(TakoAnime anime) {
    return ListTile(
      title: Text(anime.title),
      subtitle: Text(
        anime.currentEpisode.isNotEmpty
            ? anime.currentEpisode
            : anime.releasedDate,
      ),
      leading: _cover(anime),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _open(anime),
    );
  }

  Widget _cover(TakoAnime anime) {
    final image = anime.image;
    if (image == null) return const Icon(Icons.movie_outlined);
    return Image.network(
      image.toString(),
      width: 40,
      height: 56,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => const Icon(Icons.movie_outlined),
    );
  }

  Widget _message(String text) => Center(child: Text(text));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tako-Play 动漫')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _query,
              decoration: InputDecoration(
                labelText: '搜索动漫（gogoanime）',
                suffixIcon: IconButton(
                  onPressed: _runSearch,
                  icon: const Icon(Icons.search),
                ),
              ),
              onSubmitted: (_) => _runSearch(),
            ),
          ),
          Expanded(
            child: _search == null
                ? _recentList()
                : FutureBuilder<TakoSearchResults>(
                    future: _search,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return _message('搜索失败：${snapshot.error}');
                      }
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final results = snapshot.data!;
                      if (results.isEmpty) {
                        return _message('未找到「${results.query}」');
                      }
                      return ListView.builder(
                        itemCount: results.results.length,
                        itemBuilder: (context, index) =>
                            _tile(results.results[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _recentList() {
    return FutureBuilder<List<TakoAnime>>(
      future: _recent,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('加载失败：${snapshot.error}'),
              TextButton(
                onPressed: () => setState(() {
                  _recent = _client.recent();
                }),
                child: const Text('重试'),
              ),
            ],
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final episodes = snapshot.data!;
        if (episodes.isEmpty) return _message('暂无更新');
        return RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _recent = _client.recent();
            });
            await _recent;
          },
          child: ListView.builder(
            itemCount: episodes.length,
            itemBuilder: (context, index) => _tile(episodes[index]),
          ),
        );
      },
    );
  }
}
