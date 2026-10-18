import 'package:flutter/material.dart';

/// Shown when no token is configured.
///
/// The source silently fails/refreshes; this port makes the condition explicit
/// and offers token injection instead of shipping credentials or a fake
/// bypass.
class PixezLoginRequiredView extends StatelessWidget {
  const PixezLoginRequiredView({required this.onEnterToken, super.key});

  static const Key titleKey = ValueKey<String>('pixez-login-required');
  static const Key buttonKey = ValueKey<String>('pixez-enter-token');

  final VoidCallback onEnterToken;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.lock_outline, size: 48, color: theme.colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              '需要登录令牌',
              key: titleKey,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Pixiv App API 需要有效的 access_token。令牌只保存在本机，应用不内置任何账号或凭据。',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              key: buttonKey,
              onPressed: onEnterToken,
              icon: const Icon(Icons.key_outlined),
              label: const Text('输入令牌'),
            ),
          ],
        ),
      ),
    );
  }
}
