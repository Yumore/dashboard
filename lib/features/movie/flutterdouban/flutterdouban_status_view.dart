import 'package:flutter/material.dart';

/// Loading / empty / error chrome for every douban screen section.
///
/// The source leaned on `oktoast` + `shimmer` + a bare `Text('暂无数据')`
/// (`home_page.dart:143`). Those dependencies are not in this host, so the
/// states are plain Material widgets; the empty copy is kept where the source
/// had specific text.
class FlutterDouBanStatusView extends StatelessWidget {
  const FlutterDouBanStatusView.loading({super.key})
    : message = '',
      icon = null,
      onRetry = null,
      loading = true;

  const FlutterDouBanStatusView.empty(this.message, {super.key})
    : icon = Icons.inbox_outlined,
      onRetry = null,
      loading = false;

  const FlutterDouBanStatusView.error(this.message, {super.key, this.onRetry})
    : icon = Icons.error_outline,
      loading = false;

  final String message;
  final IconData? icon;
  final VoidCallback? onRetry;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (loading)
              const CircularProgressIndicator()
            else if (icon != null)
              Icon(
                icon,
                size: 44,
                color: Theme.of(context).colorScheme.outline,
              ),
            if (message.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(message, textAlign: TextAlign.center),
              ),
            if (onRetry != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextButton(onPressed: onRetry, child: const Text('重试')),
              ),
          ],
        ),
      ),
    );
  }
}
