import 'package:dashboard/features/anime/anime_category.dart';
import 'package:dashboard/features/anime/anime_hub_controller.dart';
import 'package:dashboard/features/anime/anime_show_list.dart';
import 'package:dashboard/features/shared/ui/content_tokens.dart';
import 'package:flutter/material.dart';

/// Anime module "目录" tab: category selector plus an in-catalogue filter.
class AnimeCatalogueTab extends StatelessWidget {
  const AnimeCatalogueTab({required this.controller, super.key});

  final AnimeHubController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: ContentSpacing.md,
                vertical: ContentSpacing.sm,
              ),
              child: DropdownButton<String>(
                value: controller.category,
                isExpanded: true,
                items: AnimeCategory.values
                    .map(
                      (entry) => DropdownMenuItem(
                        value: entry.path,
                        child: Text(entry.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) controller.selectCategory(value);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: ContentSpacing.md,
              ),
              child: TextField(
                decoration: const InputDecoration(
                  labelText: '筛选当前目录',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: controller.filterCatalogue,
              ),
            ),
            Expanded(
              child: AnimeShowList(
                controller: controller,
                future: controller.catalogue,
                filter: controller.catalogueFilter,
                directPlayback: controller.selectedCategory.directPlayback,
              ),
            ),
          ],
        );
      },
    );
  }
}
