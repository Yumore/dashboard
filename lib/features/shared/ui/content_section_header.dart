import 'package:dashboard/features/shared/ui/content_tokens.dart';
import 'package:flutter/material.dart';

/// Shared section title: one type scale and one spacing for every module.
class ContentSectionHeader extends StatelessWidget {
  const ContentSectionHeader({
    required this.title,
    this.description,
    super.key,
  });

  final String title;
  final String? description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final description = this.description;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        ContentSpacing.xs,
        ContentSpacing.lg,
        ContentSpacing.xs,
        ContentSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          if (description != null && description.isNotEmpty) ...[
            const SizedBox(height: ContentSpacing.xs),
            Text(description, style: theme.textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}
