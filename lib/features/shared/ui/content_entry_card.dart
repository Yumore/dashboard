import 'package:dashboard/features/shared/ui/content_entry.dart';
import 'package:dashboard/features/shared/ui/content_row.dart';
import 'package:dashboard/features/shared/ui/content_entry_grid.dart';
import 'package:dashboard/features/shared/ui/content_navigation.dart';
import 'package:dashboard/features/shared/ui/content_tokens.dart';
import 'package:flutter/material.dart';

/// Opens [entry], either by running its local action or by pushing its page.
void openContentEntry(BuildContext context, ContentEntry entry) {
  final onTap = entry.onTap;
  if (onTap != null) {
    onTap(context);
    return;
  }
  final builder = entry.builder;
  if (builder != null) {
    openContentPage<void>(context, builder);
  }
}

/// One compact entry tile: icon, title and one-line description.
///
/// The hub and every module page render the same tile so navigation looks the
/// same everywhere; density comes from [ContentEntryGrid].
class ContentEntryCard extends StatelessWidget {
  const ContentEntryCard({required this.entry, super.key});

  final ContentEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = entry.accent ?? theme.colorScheme.primary;
    final subtitle = entry.subtitle;
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Tooltip(
        message: entry.tooltip ?? entry.title,
        child: InkWell(
          onTap: () => openContentEntry(context, entry),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: ContentSpacing.md,
              vertical: ContentSpacing.md,
            ),
            child: Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(ContentRadius.cover),
                  ),
                  child: SizedBox(
                    height: 32,
                    width: 32,
                    child: Icon(entry.icon, color: accent, size: 18),
                  ),
                ),
                const SizedBox(width: ContentSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        entry.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall,
                      ),
                      if (subtitle != null && subtitle.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Shows entries in a bottom sheet.
///
/// Module pages use this for secondary demos instead of pushing a full page so
/// primary destinations stay on the page itself.
Future<void> showContentEntrySheet(
  BuildContext context, {
  required String title,
  required List<ContentEntry> entries,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.only(bottom: ContentSpacing.lg),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              ContentSpacing.lg,
              ContentSpacing.xs,
              ContentSpacing.lg,
              ContentSpacing.sm,
            ),
            child: Text(
              title,
              style: Theme.of(sheetContext).textTheme.titleMedium,
            ),
          ),
          for (final entry in entries)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: ContentSpacing.md,
              ),
              child: ContentRow(
                leadingIcon: entry.icon,
                title: entry.title,
                subtitle: entry.subtitle,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  openContentEntry(context, entry);
                },
              ),
            ),
        ],
      ),
    ),
  );
}
