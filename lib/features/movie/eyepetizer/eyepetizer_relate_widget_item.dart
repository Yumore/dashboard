import 'package:dashboard/features/movie/eyepetizer/eyepetizer_duration.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_item.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_thumbnail.dart';
import 'package:flutter/material.dart';

/// One row of the video detail screen's "related" strip.
///
/// Port of `module_common/lib/widget/video_relate_widget_item.dart`. The source
/// rendered `textHeader` rows as a section heading and everything else as a
/// compact row; that split is preserved.
class EyepetizerRelateWidgetItem extends StatelessWidget {
  const EyepetizerRelateWidgetItem({required this.item, this.onTap, super.key});

  final EyepetizerItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (item.isTextHeader) return _header(context);
    final data = item.data;
    if (data == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final cover = data.cover;
    final url = (cover?.detail.isNotEmpty ?? false)
        ? cover!.detail
        : cover?.feed;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            EyepetizerThumbnail(
              url: url,
              width: 150,
              height: 84,
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
                    <String>[
                      if (data.category.isNotEmpty) data.category,
                      if (data.duration > 0)
                        EyepetizerDuration.mmss(data.duration),
                    ].join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
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

  Widget _header(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 6),
      child: Row(
        children: <Widget>[
          Text(
            item.headerText.isEmpty ? '相关推荐' : item.headerText,
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(width: 8),
          const Expanded(child: Divider(height: 1)),
        ],
      ),
    );
  }
}
