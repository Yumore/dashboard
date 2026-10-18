import 'package:dashboard/features/movie/eyepetizer/eyepetizer_duration.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_item.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_thumbnail.dart';
import 'package:flutter/material.dart';

/// One search hit.
///
/// Port of `module_home/lib/widget/search_video_widget_item.dart`: a 16:9
/// thumbnail beside the title and the author/category/duration meta line.
class EyepetizerSearchResultItem extends StatelessWidget {
  const EyepetizerSearchResultItem({required this.item, this.onTap, super.key});

  final EyepetizerItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final data = item.data;
    if (data == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final cover = data.cover;
    final url = (cover?.feed.isNotEmpty ?? false) ? cover!.feed : cover?.detail;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            EyepetizerThumbnail(
              url: url,
              width: 140,
              height: 79,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    data.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    data.authorLine,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    <String>[
                      if (data.category.isNotEmpty) data.category,
                      if (data.duration > 0)
                        EyepetizerDuration.mmss(data.duration),
                    ].join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
