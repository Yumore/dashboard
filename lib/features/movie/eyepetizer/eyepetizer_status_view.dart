import 'package:flutter/material.dart';

/// The loading / empty / error body shared by the ported 开眼 screens.
///
/// The source rendered these through `LoadingContainer`
/// (`component/lib_common/lib/loading_container.dart`) plus `easyloading`; the
/// port uses one small Material widget instead.
class EyepetizerStatusView extends StatelessWidget {
  const EyepetizerStatusView._({
    this.icon,
    this.message,
    this.onRetry,
    this.loading = false,
    super.key,
  });

  const EyepetizerStatusView.loading({Key? key})
    : this._(loading: true, key: key);

  const EyepetizerStatusView.empty([String message = '没有找到相关内容', Key? key])
    : this._(
        icon: Icons.sentiment_dissatisfied_outlined,
        message: message,
        key: key,
      );

  const EyepetizerStatusView.error(
    String message, {
    VoidCallback? onRetry,
    Key? key,
  }) : this._(
         icon: Icons.error_outline,
         message: message,
         onRetry: onRetry,
         key: key,
       );

  final IconData? icon;
  final String? message;
  final VoidCallback? onRetry;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      // Scrollable so a short host (e.g. the detail page's remaining height
      // under a full-height video) clips the status instead of overflowing.
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (loading)
              const CircularProgressIndicator()
            else if (icon != null)
              Icon(icon, size: 44, color: theme.colorScheme.outline),
            if (message != null) ...<Widget>[
              const SizedBox(height: 12),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (onRetry != null) ...<Widget>[
              const SizedBox(height: 8),
              TextButton(onPressed: onRetry, child: const Text('重试')),
            ],
          ],
        ),
      ),
    );
  }
}
