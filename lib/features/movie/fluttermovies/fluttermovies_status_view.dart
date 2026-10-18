import 'package:dashboard/features/movie/fluttermovies/fluttermovies_status_kind.dart';
import 'package:flutter/material.dart';

/// 加载中 / 空 / 失败三态的统一展示。
class FlutterMoviesStatusView extends StatelessWidget {
  const FlutterMoviesStatusView._({
    required this.kind,
    this.message = '',
    this.onRetry,
    this.icon,
  });

  const FlutterMoviesStatusView.loading({Key? key})
    : this._(kind: FlutterMoviesStatusKind.loading, message: '加载中…');

  const FlutterMoviesStatusView.empty(String message, {Key? key})
    : this._(
        kind: FlutterMoviesStatusKind.empty,
        message: message,
        icon: Icons.inbox_outlined,
      );

  const FlutterMoviesStatusView.error(
    String message, {
    VoidCallback? onRetry,
    Key? key,
  }) : this._(
         kind: FlutterMoviesStatusKind.error,
         message: message,
         onRetry: onRetry,
         icon: Icons.cloud_off_outlined,
       );

  final FlutterMoviesStatusKind kind;
  final String message;
  final VoidCallback? onRetry;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    if (kind == FlutterMoviesStatusKind.loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      );
    }
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null)
              Icon(icon, size: 40, color: theme.colorScheme.outline),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              FilledButton.tonal(onPressed: onRetry, child: const Text('重试')),
            ],
          ],
        ),
      ),
    );
  }
}
