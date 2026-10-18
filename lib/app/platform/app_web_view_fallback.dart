import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// 平台没有内嵌 WebView 时的降级卡片：展示地址并可复制/在浏览器打开。
class AppWebViewFallback extends StatelessWidget {
  const AppWebViewFallback({required this.url, this.title, super.key});

  final String url;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Card(
        margin: const EdgeInsets.all(24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.public_outlined, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(title ?? '网页内容', style: theme.textTheme.titleMedium),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '当前平台不提供内嵌网页浏览，可在系统浏览器中打开：',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              SelectableText(url, style: theme.textTheme.bodySmall),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: [
                  FilledButton.icon(
                    onPressed: () => launchUrl(
                      Uri.parse(url),
                      mode: LaunchMode.externalApplication,
                    ),
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('在浏览器打开'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: url));
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('链接已复制')),
                      );
                    },
                    icon: const Icon(Icons.copy_all_outlined),
                    label: const Text('复制链接'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
