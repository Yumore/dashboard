import 'package:dashboard/features/comic/manhuatai/manhuatai_book.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_comic.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_cover.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_image_url.dart';
import 'package:flutter/material.dart';

/// One titled grid section of the 推荐 tab (`book.title` + its `comic_info`).
class ManhuataiBookSectionView extends StatelessWidget {
  const ManhuataiBookSectionView({
    super.key,
    required this.book,
    required this.onOpenComic,
  });

  final ManhuataiBook book;
  final ValueChanged<ManhuataiComic> onOpenComic;

  @override
  Widget build(BuildContext context) {
    if (book.comicInfo.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (book.title.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
            child: Text(
              book.title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.62,
            ),
            itemCount: book.comicInfo.length,
            itemBuilder: (context, index) {
              final comic = book.comicInfo[index];
              return InkWell(
                onTap: () => onOpenComic(comic),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: ManhuataiCover(
                        url: ManhuataiImageUrl.cover(
                          comicId: comic.comicId,
                          imgUrl: comic.imgUrl,
                          horizonratio: book.config.horizonratio,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      comic.comicName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      comic.lastComicChapterName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
