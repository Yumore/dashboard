import 'package:dashboard/features/anime/anime_hub_controller.dart';
import 'package:dashboard/features/anime/anime_show_list.dart';
import 'package:dashboard/features/shared/ui/content_status.dart';
import 'package:dashboard/features/shared/ui/content_tokens.dart';
import 'package:flutter/material.dart';

/// Anime module "搜索" tab: keyword search over the remote catalogue.
class AnimeSearchTab extends StatelessWidget {
  const AnimeSearchTab({required this.controller, super.key});

  final AnimeHubController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final results = controller.searchResults;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(ContentSpacing.md),
              child: TextField(
                controller: controller.searchInput,
                decoration: InputDecoration(
                  labelText: '搜索动漫',
                  suffixIcon: IconButton(
                    onPressed: controller.search,
                    icon: const Icon(Icons.search),
                  ),
                ),
                onSubmitted: (_) => controller.search(),
              ),
            ),
            Expanded(
              child: results == null
                  ? const ContentStatusView(
                      message: '输入关键词搜索',
                      icon: Icons.search,
                    )
                  : AnimeShowList(controller: controller, future: results),
            ),
          ],
        );
      },
    );
  }
}
