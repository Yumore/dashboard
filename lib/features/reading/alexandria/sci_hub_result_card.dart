import 'package:dashboard/features/reading/alexandria/sci_hub_result.dart';
import 'package:flutter/material.dart';

/// Ported `SciHubArticle`: the share link, the resolved download link (opened
/// through the platform browser instead of `flutter_downloader`) and a shortcut
/// back to the Sci-Hub home page.
class SciHubResultCard extends StatelessWidget {
  const SciHubResultCard({
    required this.result,
    required this.onDownload,
    required this.onShare,
    required this.onOpenSource,
    super.key,
  });

  final SciHubResult result;
  final VoidCallback onDownload;
  final VoidCallback onShare;
  final VoidCallback onOpenSource;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle_outline),
                const SizedBox(width: 8),
                Text('已找到文章', style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 8),
            if (result.shareUrl.isNotEmpty)
              Text(
                '文章页：${result.shareUrl}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall,
              ),
            if (result.downloadUrl.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                '下载地址：${result.absoluteDownloadUrl}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: onDownload,
                  icon: const Icon(Icons.download_rounded, size: 18),
                  label: const Text('下载'),
                ),
                OutlinedButton.icon(
                  onPressed: onShare,
                  icon: const Icon(Icons.share_outlined, size: 18),
                  label: const Text('分享'),
                ),
                OutlinedButton.icon(
                  onPressed: onOpenSource,
                  icon: const Icon(Icons.public, size: 18),
                  label: const Text('打开 Sci-Hub'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
