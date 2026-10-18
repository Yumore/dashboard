import 'package:dashboard/features/movie/flutterdouban/flutterdouban_data.dart';
import 'package:flutter/material.dart';

/// States, per screen, which backend answered: `网络 · api.douban.com` or
/// `本地 Mock · mock/in_theaters.json`.
///
/// This is the port's replacement for the source's silent `useNetData` switch
/// (`movie_repository.dart:44-49`) — the same flag, but visible in the UI.
class FlutterDouBanProvenanceBanner extends StatelessWidget {
  const FlutterDouBanProvenanceBanner({
    super.key,
    required this.data,
    this.trailing,
  });

  final FlutterDouBanData<Object?> data;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mocked = data.mocked;
    return Container(
      width: double.infinity,
      color: theme.colorScheme.surfaceContainerHigh,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          Icon(
            mocked ? Icons.sd_storage_outlined : Icons.cloud_done_outlined,
            size: 16,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              '数据来源：${data.label}${trailing == null ? '' : ' · $trailing'}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall,
            ),
          ),
          Text(
            mocked ? 'useNetData = false' : 'useNetData = true',
            style: theme.textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}
