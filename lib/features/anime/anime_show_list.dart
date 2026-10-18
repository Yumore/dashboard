import 'package:dashboard/features/shared/ui/content_cover.dart';
import 'package:dashboard/features/anime/anime_detail_launcher.dart';
import 'package:dashboard/features/anime/anime_episode.dart';
import 'package:dashboard/features/anime/anime_hub_controller.dart';
import 'package:dashboard/features/anime/anime_show.dart';
import 'package:dashboard/features/shared/ui/async_content_view.dart';
import 'package:dashboard/features/shared/ui/content_row.dart';
import 'package:dashboard/features/shared/ui/content_status.dart';
import 'package:dashboard/features/shared/ui/module_page_scaffold.dart';
import 'package:flutter/material.dart';

/// Shared list of anime shows for the catalogue and search tabs.
class AnimeShowList extends StatelessWidget {
  const AnimeShowList({
    required this.controller,
    required this.future,
    this.directPlayback = false,
    this.filter = '',
    super.key,
  });

  final AnimeHubController controller;
  final Future<List<AnimeShow>> future;
  final bool directPlayback;
  final String filter;

  @override
  Widget build(BuildContext context) {
    return AsyncContentView<List<AnimeShow>>(
      future: future,
      errorMessage: '加载失败',
      emptyMessage: '暂无内容',
      isEmpty: (shows) => shows.isEmpty,
      builder: (context, data) {
        final shows = data
            .where(
              (show) => show.title.toLowerCase().contains(filter.toLowerCase()),
            )
            .toList();
        if (shows.isEmpty) return const ContentStatusView(message: '暂无内容');
        return ListView.builder(
          padding: ModulePageScaffold.pagePadding,
          itemCount: shows.length,
          itemBuilder: (context, index) {
            final show = shows[index];
            return ContentRow(
              leading: ContentCover(url: show.image),
              title: show.title,
              onTap: () => directPlayback
                  ? openAnimeEpisode(
                      context,
                      controller,
                      AnimeEpisode(title: show.title, url: show.url),
                    )
                  : openAnimeShow(context, controller, show),
            );
          },
        );
      },
    );
  }
}
