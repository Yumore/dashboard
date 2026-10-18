import 'package:dashboard/features/comic/manhuatai/manhuatai_comic_tile.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_cover.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_image_url.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_rank_comic.dart';
import 'package:flutter/material.dart';

/// One row of the rank list: position, cover, name, heat and rise badge.
class ManhuataiRankTile extends StatelessWidget {
  const ManhuataiRankTile({
    super.key,
    required this.rank,
    required this.comic,
    required this.onTap,
  });

  final int rank;
  final ManhuataiRankComic comic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final rising = comic.riseRank.isNotEmpty && comic.riseRank != '0';
    return ManhuataiComicTile(
      onTap: onTap,
      imageUrl: ManhuataiImageUrl.cover(comicId: comic.comicId),
      title: comic.comicName,
      subtitle: comic.authorName,
      leading: SizedBox(
        width: 86,
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 26,
              child: Text(
                '$rank',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(width: 4),
            ManhuataiCover(
              url: ManhuataiImageUrl.cover(comicId: comic.comicId),
              width: 40,
              height: 56,
              borderRadius: 6,
            ),
          ],
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Text(ManhuataiImageUrl.formatNumber(comic.countNum)),
          if (rising)
            Text(
              comic.riseRank,
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: Colors.red),
            ),
        ],
      ),
    );
  }
}
