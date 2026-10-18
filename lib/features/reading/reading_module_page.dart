import 'package:dashboard/features/shared/ui/content_entry_section_view.dart';
import 'package:dashboard/features/reading/reading_entry_catalog.dart';
import 'package:dashboard/features/shared/ui/content_tokens.dart';
import 'package:dashboard/features/shared/ui/module_page_scaffold.dart';
import 'package:flutter/material.dart';

/// Reading module page: the reading entry catalog rendered with the shared
/// section and grid layout.
class ReadingModulePage extends StatelessWidget {
  const ReadingModulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ModulePageScaffold(
      title: '阅读',
      body: ListView(
        padding: ModulePageScaffold.pagePadding,
        children: [
          for (
            var index = 0;
            index < readingEntryCatalog.length;
            index++
          ) ...[
            if (index > 0) const SizedBox(height: ContentSpacing.md),
            ContentEntrySectionView(section: readingEntryCatalog[index]),
          ],
        ],
      ),
    );
  }
}
