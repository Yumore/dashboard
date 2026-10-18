import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_cover_image_widget.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_item.dart';
import 'package:flutter/material.dart';

/// The `followCard` / `pictureFollowCard` / `videoSmallCard` branches of
/// `ViewCardUtil` (the source's `NormalCard` / `CoverCard` / `VideoSmallCard`),
/// which all render the same facts: cover art, title, and the author row with
/// the collection count.
///
/// Rendered with the full row instead of three near-identical widgets; the
/// caller's `compact` flag picks the `videoSmallCard` proportions.
class EyepetizerFlutterVideoCard extends StatelessWidget {
  const EyepetizerFlutterVideoCard({
    super.key,
    required this.data,
    this.compact = false,
    this.onTap,
  });

  final EyepetizerFlutterItem data;
  final bool compact;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = data.data;
    final inner = content?.content?.data;
    final owner = inner?.owner;
    final cover = inner?.cover?.feed ?? content?.cover?.feed;
    final title = inner?.title ?? content?.title ?? '';
    final description = inner?.description ?? content?.description ?? '';
    final collectionCount = inner?.consumption?.collectionCount ?? 0;
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            EyepetizerFlutterCoverImageWidget(
              imageUrl: cover,
              width: double.infinity,
              height: compact ? 110 : 200,
              borderRadius: 3,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (description.isNotEmpty)
              Text(
                description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            const SizedBox(height: 5),
            Row(
              children: <Widget>[
                EyepetizerFlutterCoverImageWidget(
                  imageUrl: owner?.avatar,
                  width: 20,
                  height: 20,
                  borderRadius: 100,
                ),
                const SizedBox(width: 6),
                Text(
                  owner?.nickname ?? '',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
                const Spacer(),
                Text(
                  collectionCount.toString(),
                  style: const TextStyle(fontSize: 10, color: Colors.black),
                ),
                const Icon(Icons.store, size: 15),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
