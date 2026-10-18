import 'package:dashboard/features/short_video/douyin/douyin_count_formatter.dart';
import 'package:dashboard/features/short_video/douyin/douyin_video_item.dart';
import 'package:flutter/material.dart';

/// 播放页左下角信息与详情入口（源工程 `video_description.dart` +
/// `actions_toolbar.dart` 的可用部分）。
class DouyinVideoOverlay extends StatelessWidget {
  const DouyinVideoOverlay({
    super.key,
    required this.item,
    required this.onDetail,
  });

  final DouyinVideoItem item;
  final VoidCallback onDetail;

  @override
  Widget build(BuildContext context) {
    final aweme = item.aweme;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Text(
            aweme.authorHandle,
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            aweme.displayDesc,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              const Icon(Icons.music_note, size: 16, color: Colors.white70),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  aweme.musicLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: Colors.white70),
                ),
              ),
            ],
          ),
          if (aweme.hashtagLabel.isNotEmpty) ...<Widget>[
            const SizedBox(height: 6),
            Text(
              aweme.hashtagLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.white60),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              _statBadge(
                context,
                icon: Icons.favorite_border,
                label: DouyinCountFormatter.compact(aweme.diggCount),
                tooltip: '点赞',
              ),
              const SizedBox(width: 16),
              _statBadge(
                context,
                icon: Icons.mode_comment_outlined,
                label: DouyinCountFormatter.compact(aweme.commentCount),
                tooltip: '评论',
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: onDetail,
                icon: const Icon(Icons.info_outline, size: 18),
                label: const Text('详情'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white54),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statBadge(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 18, color: Colors.white),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
