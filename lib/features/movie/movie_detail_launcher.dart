import 'package:dashboard/features/movie/movie_details_page.dart';
import 'package:dashboard/features/movie/movie_hub_controller.dart';
import 'package:dashboard/features/movie/movie_item.dart';
import 'package:dashboard/features/shared/ui/content_navigation.dart';
import 'package:flutter/material.dart';

/// Opens the shared movie detail page for [item], wiring episode loading and
/// the watch-list toggle to [controller].
Future<void> openMovieDetail(
  BuildContext context,
  MovieItem item,
  MovieHubController controller,
) async {
  final detailsSource = controller.detailsSource(item);
  try {
    return await openContentPage<void>(
      context,
      (_) => MovieDetailsPage(
        movie: item,
        loadEpisodes: detailsSource == null
            ? null
            : () => detailsSource.episodes(item.id),
        onFavorite: () => controller.toggleFavorite(item),
      ),
    );
  } finally {
    detailsSource?.dispose();
  }
}
