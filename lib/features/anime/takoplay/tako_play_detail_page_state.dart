import 'package:dashboard/features/anime/takoplay/tako_anime_details.dart';
import 'package:dashboard/features/anime/takoplay/tako_episode.dart';
import 'package:dashboard/features/anime/takoplay/tako_play_client.dart';
import 'package:dashboard/features/anime/takoplay/tako_play_detail_page.dart';
import 'package:dashboard/features/anime/takoplay/tako_play_episode_page.dart';
import 'package:flutter/material.dart';

class TakoPlayDetailPageState extends State<TakoPlayDetailPage> {
  late final TakoPlayClient _client = widget.client ?? TakoPlayClient();
  late Future<TakoAnimeDetails> _details;

  @override
  void initState() {
    super.initState();
    _details = _client.details(widget.anime.url);
  }

  @override
  void dispose() {
    if (widget.client == null) _client.dispose();
    super.dispose();
  }

  void _play(String title, TakoEpisode episode) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TakoPlayEpisodePage(
          episode: episode,
          title: '$title 第${episode.number}集',
          client: widget.client,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.anime.title)),
      body: FutureBuilder<TakoAnimeDetails>(
        future: _details,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('加载失败：${snapshot.error}'),
                  TextButton(
                    onPressed: () => setState(() {
                      _details = _client.details(widget.anime.url);
                    }),
                    child: const Text('重试'),
                  ),
                ],
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return _body(snapshot.data!);
        },
      ),
    );
  }

  Widget _body(TakoAnimeDetails details) {
    final title = details.title.isEmpty ? widget.anime.title : details.title;
    final image = details.image ?? widget.anime.image;
    return ListView(
      children: [
        if (image != null)
          Image.network(
            image.toString(),
            height: 220,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const SizedBox.shrink(),
          ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                [
                  if (details.status.isNotEmpty) details.status,
                  if (details.releasedDate.isNotEmpty) details.releasedDate,
                  '${details.episodes.length} 集',
                ].join(' · '),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              if (details.summary.isNotEmpty) Text(details.summary),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: details.genres
                    .map((genre) => Chip(label: Text(genre.name)))
                    .toList(),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        ...details.episodes.map(
          (episode) => ListTile(
            title: Text('第${episode.number}集'),
            trailing: const Icon(Icons.play_circle_outline),
            onTap: () => _play(title, episode),
          ),
        ),
        if (details.episodes.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: Text('暂无剧集')),
          ),
      ],
    );
  }
}
