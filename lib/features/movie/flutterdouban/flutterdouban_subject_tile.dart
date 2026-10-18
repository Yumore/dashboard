import 'package:dashboard/features/movie/flutterdouban/flutterdouban_poster.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_rating_bar.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_subject_row.dart';
import 'package:flutter/material.dart';

/// One browse/search row: poster, title, meta line, optional rank note.
class FlutterDouBanSubjectTile extends StatelessWidget {
  const FlutterDouBanSubjectTile({super.key, required this.row, this.onTap});

  final FlutterDouBanSubjectRow row;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final subject = row.subject;
    final theme = Theme.of(context);
    final meta = <String>[
      if (subject.ratingText.isNotEmpty) subject.ratingText,
      if (subject.genresText.isNotEmpty) subject.genresText,
      if (subject.directorsText.isNotEmpty) subject.directorsText,
    ];
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FlutterDouBanPoster(url: subject.posterUrl, width: 56, height: 78),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject.displayTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  FlutterDouBanRatingBar(average: subject.rating.average),
                  if (meta.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        meta.join(' · '),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                ],
              ),
            ),
            if (row.rank != null)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '#${row.rankLabel}',
                      style: theme.textTheme.titleMedium,
                    ),
                    if (row.rankDelta != null && row.rankDelta!.isNotEmpty)
                      Text(row.rankDelta!, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
            if (row.note != null && row.note!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(row.note!, style: theme.textTheme.bodySmall),
              ),
          ],
        ),
      ),
    );
  }
}
