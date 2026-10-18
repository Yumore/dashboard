import 'package:dashboard/features/shared/ui/content_entry_section_view.dart';
import 'package:dashboard/features/content_hub/content_module_catalog.dart';
import 'package:dashboard/features/shared/ui/content_tokens.dart';
import 'package:dashboard/features/shared/ui/module_page_scaffold.dart';
import 'package:flutter/material.dart';

/// Landing page that exposes every content module from one catalog.
class ContentHubPage extends StatelessWidget {
  const ContentHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ModulePageScaffold(
      title: '内容中心',
      body: ListView(
        padding: ModulePageScaffold.pagePadding,
        children: [
          for (var index = 0; index < contentModuleCatalog.length; index++)
            Padding(
              padding: EdgeInsets.only(top: index == 0 ? 0 : ContentSpacing.md),
              child: ContentEntrySectionView(
                section: contentModuleCatalog[index],
              ),
            ),
        ],
      ),
    );
  }
}
