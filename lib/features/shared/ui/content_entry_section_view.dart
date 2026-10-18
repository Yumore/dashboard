import 'package:dashboard/features/shared/ui/content_entry_grid.dart';
import 'package:flutter/material.dart';
import 'package:dashboard/features/shared/ui/content_entry_section.dart';
import 'package:dashboard/features/shared/ui/content_section_header.dart';

/// Renders one [ContentEntrySection] inside any scrollable page.
class ContentEntrySectionView extends StatelessWidget {
  const ContentEntrySectionView({required this.section, super.key});

  final ContentEntrySection section;

  @override
  Widget build(BuildContext context) {
    final entries = section.entries.where((entry) => entry.isAvailable).toList();
    if (entries.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ContentSectionHeader(
          title: section.title,
          description: section.description,
        ),
        ContentEntryGrid(entries: entries),
      ],
    );
  }
}
