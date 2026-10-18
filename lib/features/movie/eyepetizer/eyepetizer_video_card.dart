import 'package:dashboard/features/movie/eyepetizer/eyepetizer_duration.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_item.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_thumbnail.dart';
import 'package:flutter/material.dart';

/// The full-width video row used by the home feed, category listings, search
/// results and rank lists.
///
/// Port of `module_common/lib/widget/rank_widget_item.dart`: cover with a
/// category chip bottom-left and a duration chip bottom-right, then the author
/// avatar, title and author line. The source's share button is intentionally
/// dropped — sharing was `share_util.dart` over `share_plus`, pure chrome, and
/// the ported module has no share surface.
class EyepetizerVideoCard extends StatelessWidget {
  const EyepetizerVideoCard({
    required this.item,
    this.showCategory = true,
    this.showDivider = true,
    this.onTap,
    super.key,
  });

  final EyepetizerItem item;
  final bool showCategory;
  final bool showDivider;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final data = item.data;
    if (data == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final cover = data.cover;
    final url = (cover?.feed.isNotEmpty ?? false) ? cover!.feed : cover?.detail;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  EyepetizerThumbnail(url: url, height: 200, fit: BoxFit.cover),
                  if (showCategory && data.category.isNotEmpty)
                    Positioned(
                      left: 12,
                      bottom: 12,
                      child: _Chip(text: '# ${data.category}'),
                    ),
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: _Chip(text: EyepetizerDuration.mmss(data.duration)),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    EyepetizerThumbnail(
                      url: data.authorIcon,
                      width: 36,
                      height: 36,
                      circle: true,
                      placeholderIcon: Icons.person_outline,
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
                            style: theme.textTheme.titleSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            data.authorLine,
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
            ],
          ),
        ),
        if (showDivider) const Divider(height: 1),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 11),
      ),
    );
  }
}
