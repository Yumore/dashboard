import 'package:dashboard/features/shared/ui/content_cover.dart';
import 'package:dashboard/features/movie/movie_detail_launcher.dart';
import 'package:dashboard/features/movie/movie_hub_controller.dart';
import 'package:dashboard/features/shared/ui/content_row.dart';
import 'package:dashboard/features/shared/ui/content_status.dart';
import 'package:dashboard/features/shared/ui/module_page_scaffold.dart';
import 'package:flutter/material.dart';

/// Movie "片单" tab: the locally stored watch list.
class MovieWatchlistTab extends StatelessWidget {
  const MovieWatchlistTab({required this.controller, super.key});

  final MovieHubController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final favorites = controller.favorites;
        if (favorites.isEmpty) {
          return const ContentStatusView(
            message: '暂无影视内容',
            icon: Icons.bookmark_border,
          );
        }
        return ListView.builder(
          padding: ModulePageScaffold.pagePadding,
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final item = favorites[index];
            return ContentRow(
              leading: ContentCover(url: item.poster),
              title: item.title,
              subtitle: item.category,
              onTap: () => openMovieDetail(context, item, controller),
            );
          },
        );
      },
    );
  }
}
