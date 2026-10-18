import 'package:dashboard/features/anime/animeone/animeone_playback_page.dart';
import 'package:dashboard/features/anime/animeone/animeone_recent.dart';
import 'package:dashboard/features/anime/animeone/animeone_site_client.dart';
import 'package:dashboard/features/anime/animeone/animeone_watch_store.dart';
import 'package:flutter/material.dart';

/// 最近更新列表里的一行。
class AnimeOneRecentTile extends StatelessWidget {
  const AnimeOneRecentTile({
    super.key,
    required this.recent,
    this.client,
    this.watchStore,
  });

  final AnimeOneRecent recent;
  final AnimeOneSiteClient? client;
  final AnimeOneWatchStore? watchStore;

  @override
  Widget build(BuildContext context) {
    final link = recent.link;
    return ListTile(
      leading: const Icon(Icons.play_circle_outline),
      title: Text(
        recent.name ?? '',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: link == null
          ? null
          : () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => AnimeOnePlaybackPage(
                    link: link,
                    title: recent.name,
                    client: client,
                    watchStore: watchStore,
                  ),
                ),
              );
            },
    );
  }
}
