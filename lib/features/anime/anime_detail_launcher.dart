import 'package:dashboard/features/anime/anime_episode.dart';
import 'package:dashboard/features/anime/anime_episode_page.dart';
import 'package:dashboard/features/anime/anime_hub_controller.dart';
import 'package:dashboard/features/anime/anime_show.dart';
import 'package:dashboard/features/anime/anime_show_details_page.dart';
import 'package:dashboard/features/shared/ui/content_navigation.dart';
import 'package:dashboard/features/shared/ui/content_status.dart';
import 'package:flutter/material.dart';

/// Opens the episode player and refreshes the watch history afterwards.
Future<void> openAnimeEpisode(
  BuildContext context,
  AnimeHubController controller,
  AnimeEpisode episode,
) async {
  await openContentPage<void>(
    context,
    (_) => AnimeEpisodePage(url: episode.url),
  );
  await controller.refreshHistory();
}

/// Loads details for [show], opens the details page and refreshes favourites.
Future<void> openAnimeShow(
  BuildContext context,
  AnimeHubController controller,
  AnimeShow show,
) async {
  try {
    final details = await controller.details(show);
    if (!context.mounted) return;
    await openContentPage<void>(
      context,
      (_) => AnimeShowDetailsPage(
        show: details,
        favorites: controller.favoriteStore,
        history: controller.watchStore,
        onChanged: controller.refreshFavorites,
      ),
    );
    await controller.refreshHistory();
  } catch (error) {
    if (context.mounted) showContentError(context, error);
  }
}
