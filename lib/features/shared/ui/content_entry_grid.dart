import 'package:dashboard/features/shared/ui/content_entry.dart';
import 'package:dashboard/features/shared/ui/content_entry_card.dart';
import 'package:dashboard/features/shared/ui/content_tokens.dart';
import 'package:flutter/material.dart';

/// Responsive grid of compact entry tiles.
///
/// One layout rule for the hub and every module page: the number of columns is
/// a function of the available width, so entries never need a per-page layout.
class ContentEntryGrid extends StatelessWidget {
  const ContentEntryGrid({required this.entries, super.key});

  final List<ContentEntry> entries;

  static const double _spacing = ContentSpacing.sm;

  static int columnsFor(double width) {
    if (width >= 900) return 4;
    if (width >= 620) return 3;
    if (width >= 360) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 600.0;
        final columns = columnsFor(width);
        final itemWidth = (width - _spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: _spacing,
          runSpacing: _spacing,
          children: [
            for (final entry in entries)
              SizedBox(
                width: itemWidth,
                child: ContentEntryCard(entry: entry),
              ),
          ],
        );
      },
    );
  }
}
