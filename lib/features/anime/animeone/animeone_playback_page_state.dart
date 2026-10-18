import 'package:dashboard/features/anime/anime_playback.dart';
import 'package:dashboard/features/anime/animeone/animeone_error_button.dart';
import 'package:dashboard/features/anime/animeone/animeone_playback_page.dart';
import 'package:dashboard/features/anime/animeone/animeone_playback_resolver.dart';
import 'package:dashboard/features/anime/animeone/animeone_site_client.dart';
import 'package:dashboard/features/anime/animeone/animeone_watch_entry.dart';
import 'package:dashboard/features/anime/animeone/animeone_watch_store.dart';
import 'package:dashboard/features/media/media_playback_page.dart';
import 'package:dashboard/features/media/playback_position_store.dart';
import 'package:flutter/material.dart';

class AnimeOnePlaybackPageState extends State<AnimeOnePlaybackPage> {
  late final AnimeOneSiteClient _client;
  AnimeOneSiteClient? _ownedClient;
  late final AnimeOneWatchStore _store;
  late Future<AnimePlayback> _playback;
  String? _historyId;

  @override
  void initState() {
    super.initState();
    _client = widget.client ?? (_ownedClient = AnimeOneSiteClient());
    _store = widget.watchStore ?? AnimeOneWatchStore();
    _playback = _load();
  }

  Future<AnimePlayback> _load() async {
    final playback = await AnimeOnePlaybackResolver(
      _client,
    ).resolve(widget.link, title: widget.title, previous: widget.previous);
    _historyId = playback.page.toString();
    await _store.save(
      AnimeOneWatchEntry(episodeLink: _historyId!, episodeName: playback.title),
    );
    return playback;
  }

  @override
  void dispose() {
    final id = _historyId;
    if (id != null) {
      // 播放器每 5 秒写入一次进度，退出时同步到观看记录。
      PlaybackPositionStore().load(id).then((position) {
        _store.updatePosition(id, position.inSeconds);
      });
    }
    _ownedClient?.close();
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
                : (_) => AnimeOnePlaybackPage(
                    link: playback.previous.toString(),
                    client: widget.client,
                    watchStore: widget.watchStore,
                  ),
            nextPage: playback.next == null
                ? null
                : (_) => AnimeOnePlaybackPage(
                    link: playback.next.toString(),
                    client: widget.client,
                    watchStore: widget.watchStore,
                  ),
          );
        }
        return Scaffold(
          appBar: AppBar(title: const Text('动漫播放')),
          body: snapshot.hasError
              ? AnimeOneErrorButton(
                  message: '加载失败：${snapshot.error}',
                  onRetry: () => setState(() => _playback = _load()),
                )
              : const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
