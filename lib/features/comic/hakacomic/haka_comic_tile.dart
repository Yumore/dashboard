import 'package:flutter/material.dart';
import 'package:dashboard/features/comic/hakacomic/haka_comic_base.dart';
import 'package:dashboard/features/comic/hakacomic/haka_network_cover.dart';

/// One comic row of a list: cover, title, author and the first tags.
class HakaComicTile extends StatelessWidget {
  const HakaComicTile({
    super.key,
    required this.comic,
    required this.onTap,
    this.subtitle,
  });

  final HakaComicBase comic;

  final VoidCallback onTap;

  /// Overrides the default author/tag subtitle (e.g. a read position).
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final trimmedTags = comic.tags.take(3).join(' · ');
    final text = subtitle ??
        [
          if (comic.author.isNotEmpty) comic.author,
          if (trimmedTags.isNotEmpty) trimmedTags,
        ].join(' · ');
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HakaNetworkCover(image: comic.thumb, width: 64, height: 86),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    comic.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    text,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    comic.finished ? '已完结' : '连载中',
                    style: Theme.of(context).textTheme.labelSmall,
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
