import 'package:dashboard/features/anime/takoplay/tako_play_episode_page.dart';
import 'package:dashboard/features/anime/takoplay/tako_play_endpoints.dart';
import 'package:dashboard/features/anime/takoplay/tako_play_stream_resolver.dart';
import 'package:dashboard/features/anime/takoplay/tako_playback.dart';
import 'package:dashboard/features/anime/takoplay/tako_stream_source.dart';
import 'package:dashboard/features/media/media_playback_page.dart';
import 'package:dashboard/features/media/media_stream_source.dart';
import 'package:flutter/material.dart';

class TakoPlayEpisodePageState extends State<TakoPlayEpisodePage> {
  late final TakoPlayStreamResolver _resolver = TakoPlayStreamResolver(
    client: widget.client,
  );
  late Future<TakoPlayback> _playback;

  @override
  void initState() {
    super.initState();
    _playback = _resolver.resolve(widget.episode, title: widget.title);
  }

  @override
  void dispose() {
    _resolver.dispose();
    super.dispose();
  }

  void _retry() {
    setState(() {
      _playback = _resolver.resolve(widget.episode, title: widget.title);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<TakoPlayback>(
      future: _playback,
      builder: (context, snapshot) {
        final playback = snapshot.data;
        if (playback != null && playback.sources.isNotEmpty) {
          return MediaPlaybackPage(
            title: playback.title,
            sources: playback.sources.map(_mediaSource).toList(),
            historyId: playback.page.toString(),
          );
        }
        return Scaffold(
          appBar: AppBar(title: const Text('Tako-Play 播放')),
          body: Center(
            child: snapshot.hasError
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('播放失败：${snapshot.error}'),
                      TextButton(onPressed: _retry, child: const Text('重试')),
                    ],
                  )
                : const CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  MediaStreamSource _mediaSource(TakoStreamSource source) => MediaStreamSource(
    label: source.label,
    url: source.url,
    // gogoplay rejects requests without a referer (source `constants.header`).
    headers: TakoPlayEndpoints.browserHeaders,
  );
}
