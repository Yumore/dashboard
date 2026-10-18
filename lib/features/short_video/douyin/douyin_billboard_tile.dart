import 'package:dashboard/features/short_video/douyin/douyin_billboard_entry.dart';
import 'package:flutter/material.dart';

/// 榜单行：名次 / 标题 / 作者 / 热度。
class DouyinBillboardTile extends StatelessWidget {
  const DouyinBillboardTile({
    super.key,
    required this.entry,
    required this.onTap,
  });

  final DouyinBillboardEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: entry.rank <= 3
              ? colors.primaryContainer
              : colors.surfaceContainerHighest,
          child: Text(
            '${entry.rank}',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: entry.rank <= 3
                  ? colors.onPrimaryContainer
                  : colors.onSurfaceVariant,
            ),
          ),
        ),
        title: Text(
          entry.displayTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${entry.displayAuthor} · 热度 ${entry.displayValue}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.play_circle_outline),
      ),
    );
  }
}
