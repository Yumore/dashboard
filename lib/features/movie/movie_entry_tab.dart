import 'package:dashboard/features/shared/ui/content_entry_section_view.dart';
import 'package:dashboard/features/movie/movie_entry_catalog.dart';
import 'package:dashboard/features/shared/ui/content_tokens.dart';
import 'package:dashboard/features/shared/ui/module_page_scaffold.dart';
import 'package:flutter/material.dart';

/// Movie module "入口" tab: every migrated movie and short-video service.
class MovieEntryTab extends StatelessWidget {
  const MovieEntryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: ModulePageScaffold.pagePadding,
      children: [
        for (var index = 0; index < movieEntryCatalog.length; index++) ...[
          if (index > 0) const SizedBox(height: ContentSpacing.md),
          ContentEntrySectionView(section: movieEntryCatalog[index]),
        ],
      ],
    );
  }
}
