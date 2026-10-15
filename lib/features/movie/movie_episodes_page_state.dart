import 'package:dashboard/features/media/media_playback_page.dart';
import 'package:dashboard/features/media/media_stream_source.dart';
import 'package:dashboard/features/movie/movie_episode.dart';
import 'package:dashboard/features/movie/movie_episodes_page.dart';
import 'package:flutter/material.dart';

class MovieEpisodesPageState extends State<MovieEpisodesPage> {
  late Future<List<MovieEpisode>> _episodes;

  @override
  void initState() {
    super.initState();
    _episodes = widget.load();
  }

  Widget _player(MovieEpisode selected, List<MovieEpisode> episodes) {
    final group = episodes
        .where((episode) => episode.group == selected.group)
        .toList();
    final index = group.indexOf(selected);
    final alternatives = [
      selected,
      ...episodes.where(
        (episode) => episode.label == selected.label && episode != selected,
      ),
    ];
    return MediaPlaybackPage(
      title: '${widget.movie.title} · ${selected.label}',
      historyId:
          'movie:${widget.movie.serviceEndpoint ?? selected.url.origin}:${widget.movie.id}:${selected.label}',
      sources: alternatives
          .map(
            (episode) => MediaStreamSource(
              label: '线路 ${episode.group}',
              url: episode.url,
            ),
          )
          .toList(),
      previousPage: index > 0
          ? (_) => _player(group[index - 1], episodes)
          : null,
      nextPage: index >= 0 && index < group.length - 1
          ? (_) => _player(group[index + 1], episodes)
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.movie.title} · 选集')),
      body: FutureBuilder<List<MovieEpisode>>(
        future: _episodes,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('加载失败：${snapshot.error}'),
                  TextButton(
                    onPressed: () => setState(() => _episodes = widget.load()),
                    child: const Text('重试'),
                  ),
                ],
              ),
            );
          }
          final episodes = snapshot.data;
          if (episodes == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (episodes.isEmpty) return const Center(child: Text('暂无可用剧集'));
          final groups = <String, List<MovieEpisode>>{};
          for (final episode in episodes) {
            groups.putIfAbsent(episode.group, () => []).add(episode);
          }
          return ListView(
            children: [
              for (final entry in groups.entries) ...[
                ListTile(title: Text('线路 ${entry.key}')),
                for (final episode in entry.value)
                  ListTile(
                    title: Text(episode.label),
                    trailing: const Icon(Icons.play_arrow),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => _player(episode, episodes),
                      ),
                    ),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}
