import 'package:dashboard/features/shared/ui/content_tokens.dart';
import 'package:flutter/material.dart';

/// Centered placeholder used for hints, empty collections and load failures so
/// every module renders these states the same way.
class ContentStatusView extends StatelessWidget {
  const ContentStatusView({
    required this.message,
    this.title,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String message;
  final String? title;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = this.title;
    final actionLabel = this.actionLabel;
    final onAction = this.onAction;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(ContentSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: theme.colorScheme.outline),
            if (title != null) ...[
              const SizedBox(height: ContentSpacing.md),
              Text(title, style: theme.textTheme.titleMedium),
            ],
            const SizedBox(height: ContentSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: ContentSpacing.lg),
              FilledButton.tonal(onPressed: onAction, child: Text(actionLabel)),
            ],
          ],
        ),
      ),
    );
  }
}

/// Shows a load failure through one snackbar style across all modules.
void showContentError(BuildContext context, Object error) {
  ScaffoldMessenger.maybeOf(
    context,
  )?.showSnackBar(SnackBar(content: Text('$error')));
}
