import 'package:cached_network_image/cached_network_image.dart';
import 'package:dashboard/features/comic/picacomic/core/base_comic.dart';
import 'package:flutter/material.dart';

/// Shared comic cell for the picacomic screens.
///
/// Matches PicaComic's tile layout (lib/components/comic_tile.dart): cover,
/// title, and one line of sub-information (author/pages, source specific).
class PicacomicComicTile extends StatelessWidget {
  const PicacomicComicTile({
    required this.comic,
    this.subtitle,
    this.onTap,
    this.imageHeaders,
    super.key,
  });

  final BaseComic comic;
  final String? subtitle;
  final VoidCallback? onTap;
  final Map<String, String>? imageHeaders;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: CachedNetworkImage(
                imageUrl: comic.cover,
                httpHeaders: imageHeaders,
                fit: BoxFit.cover,
                width: double.infinity,
                placeholder: (context, url) =>
                    const ColoredBox(color: Color(0xFFEEEEEE)),
                errorWidget: (context, url, error) => const ColoredBox(
                  color: Color(0xFFEEEEEE),
                  child: Icon(Icons.broken_image_outlined),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            comic.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall,
          ),
          Text(
            subtitle ?? comic.subTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}
