import 'package:dashboard/features/shared/ui/content_cover.dart';
import 'package:dashboard/features/anime/anime_detail_launcher.dart';
import 'package:dashboard/features/anime/anime_hub_controller.dart';
import 'package:dashboard/features/shared/ui/async_content_view.dart';
import 'package:dashboard/features/shared/ui/content_row.dart';
import 'package:dashboard/features/shared/ui/module_page_scaffold.dart';
import 'package:flutter/material.dart';

/// Anime module "最近更新" tab with pull-to-refresh and watched markers.
class AnimeRecentTab extends StatelessWidget {
  const AnimeRecentTab({required this.controller, super.key});

  final AnimeHubController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return AsyncContentView(
          future: controller.recent,
          onRetry: controller.refreshRecent,
          builder: (context, episodes) => RefreshIndicator(
            onRefresh: controller.refreshRecent,
            child: ListView.builder(
              padding: ModulePageScaffold.pagePadding,
              itemCount: episodes.length,
              itemBuilder: (context, index) {
                final episode = episodes[index];
                final watched = controller.watched.contains(
                  episode.url.toString(),
                );
                return ContentRow(
                  leading: ContentCover(
                    url: episode.cover,
                    icon: Icons.ondemand_video_outlined,
                  ),
                  title: episode.title,
                  trailing: Icon(
                    watched ? Icons.check_circle_outline : Icons.play_arrow,
                  ),
                  onTap: () => openAnimeEpisode(context, controller, episode),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
