import 'package:dashboard/features/shared/ui/content_cover.dart';
import 'package:dashboard/features/anime/anime_detail_launcher.dart';
import 'package:dashboard/features/anime/anime_hub_controller.dart';
import 'package:dashboard/features/shared/ui/content_row.dart';
import 'package:dashboard/features/shared/ui/content_status.dart';
import 'package:dashboard/features/shared/ui/module_page_scaffold.dart';
import 'package:flutter/material.dart';

/// Anime module "收藏" tab: shows persisted anime favourites.
class AnimeFavoritesTab extends StatelessWidget {
  const AnimeFavoritesTab({required this.controller, super.key});

  final AnimeHubController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        if (controller.saved.isEmpty) {
          return const ContentStatusView(
            message: '暂无收藏',
            icon: Icons.favorite_border,
          );
        }
        return ListView.builder(
          padding: ModulePageScaffold.pagePadding,
          itemCount: controller.saved.length,
          itemBuilder: (context, index) {
            final show = controller.saved[index];
            return ContentRow(
              leading: ContentCover(url: show.image),
              title: show.title,
              onTap: () => openAnimeShow(context, controller, show),
            );
          },
        );
      },
    );
  }
}
