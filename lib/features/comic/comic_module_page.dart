import 'package:dashboard/features/shared/ui/content_entry_section_view.dart';
import 'package:dashboard/features/comic/comic_entry_catalog.dart';
import 'package:dashboard/features/shared/ui/content_tokens.dart';
import 'package:dashboard/features/shared/ui/module_page_scaffold.dart';
import 'package:flutter/material.dart';

/// Comic module page: the local library plus every migrated online source.
class ComicModulePage extends StatelessWidget {
  const ComicModulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ModulePageScaffold(
      title: '漫画',
      body: ListView(
        padding: ModulePageScaffold.pagePadding,
        children: [
          for (
            var index = 0;
            index < comicEntryCatalog.length;
            index++
          ) ...[
            if (index > 0) const SizedBox(height: ContentSpacing.md),
            ContentEntrySectionView(section: comicEntryCatalog[index]),
          ],
        ],
      ),
    );
  }
}
