import 'package:dashboard/features/anime/anime_episode_page.dart';
import 'package:dashboard/features/anime/anime_episode.dart';
import 'package:dashboard/features/anime/anime_watch_store.dart';
import 'package:dashboard/features/anime/anime_episode_resolver.dart';
import 'package:dashboard/features/anime/anime_playback.dart';
import 'package:dashboard/features/media/media_playback_page.dart';
import 'package:flutter/material.dart';

class AnimeEpisodePageState extends State<AnimeEpisodePage> {
  final _resolver = AnimeEpisodeResolver();
  late Future<AnimePlayback> _playback;

  @override
  void initState() {
    super.initState();
    _playback = _load();
  }

  Future<AnimePlayback> _load() async {
    final playback = await _resolver.resolve(widget.url);
    await AnimeWatchStore().record(
      AnimeEpisode(title: playback.title, url: playback.page),
    );
    return playback;
  }

  @override
  void dispose() {
    _resolver.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AnimePlayback>(
      future: _playback,
      builder: (context, snapshot) {
        final playback = snapshot.data;
        if (playback != null) {
          return MediaPlaybackPage(
            title: playback.title,
            sources: playback.sources,
            historyId: playback.page.toString(),
            previousPage: playback.previous == null
                ? null
                : (_) => AnimeEpisodePage(url: playback.previous!),
            nextPage: playback.next == null
                ? null
                : (_) => AnimeEpisodePage(url: playback.next!),
          );
        }
        return Scaffold(
          appBar: AppBar(title: const Text('动漫播放')),
          body: Center(
            child: snapshot.hasError
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('加载失败：${snapshot.error}'),
                      TextButton(
                        onPressed: () => setState(() => _playback = _load()),
                        child: const Text('重试'),
                      ),
                    ],
                  )
                : const CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
