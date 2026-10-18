import 'package:dashboard/features/shared/ui/content_entry_section_view.dart';
import 'package:dashboard/features/anime/anime_entry_catalog.dart';
import 'package:dashboard/features/shared/ui/content_tokens.dart';
import 'package:dashboard/features/shared/ui/module_page_scaffold.dart';
import 'package:flutter/material.dart';

/// Anime module "入口" tab: every migrated anime site.
class AnimeEntryTab extends StatelessWidget {
  const AnimeEntryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: ModulePageScaffold.pagePadding,
      children: [
        for (var index = 0; index < animeEntryCatalog.length; index++) ...[
          if (index > 0) const SizedBox(height: ContentSpacing.md),
          ContentEntrySectionView(section: animeEntryCatalog[index]),
        ],
      ],
    );
  }
}
