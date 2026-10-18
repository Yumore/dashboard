import 'package:flutter/material.dart';

/// Shared idle / empty / error placeholder used by the three Alexandria tabs.
class AlexandriaMessageView extends StatelessWidget {
  const AlexandriaMessageView({
    required this.icon,
    required this.message,
    this.onRetry,
    super.key,
  });

  final IconData icon;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onRetry, child: const Text('重试')),
          ],
        ],
      ),
    ),
  );
}
