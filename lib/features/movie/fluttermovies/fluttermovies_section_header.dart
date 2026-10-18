import 'package:flutter/material.dart';

/// 首页分组的标题行（「最近更新」「热门推荐」+ 更多）。
class FlutterMoviesSectionHeader extends StatelessWidget {
  const FlutterMoviesSectionHeader({
    required this.title,
    this.trailing,
    this.onMore,
    super.key,
  });

  final String title;
  final String? trailing;
  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 4, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (trailing != null)
            Text(trailing!, style: theme.textTheme.bodySmall),
          if (onMore != null)
            TextButton(onPressed: onMore, child: const Text('更多')),
        ],
      ),
    );
  }
}
