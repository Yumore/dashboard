import 'package:dashboard/features/shared/ui/content_entry_section_view.dart';
import 'package:dashboard/features/novel/novel_entry_catalog.dart';
import 'package:dashboard/features/shared/ui/content_tokens.dart';
import 'package:dashboard/features/shared/ui/module_page_scaffold.dart';
import 'package:flutter/material.dart';

/// Novel module page: the local library and the network-novel reader.
class NovelModulePage extends StatelessWidget {
  const NovelModulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ModulePageScaffold(
      title: '小说',
      body: ListView(
        padding: ModulePageScaffold.pagePadding,
        children: [
          for (
            var index = 0;
            index < novelEntryCatalog.length;
            index++
          ) ...[
            if (index > 0) const SizedBox(height: ContentSpacing.md),
            ContentEntrySectionView(section: novelEntryCatalog[index]),
          ],
        ],
      ),
    );
  }
}
