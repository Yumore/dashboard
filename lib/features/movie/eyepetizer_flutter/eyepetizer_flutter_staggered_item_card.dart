import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_content_data.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_cover_image_widget.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_item.dart';
import 'package:flutter/material.dart';

/// `lib/pages/community/widgets/staggered_item_card.dart` → `StaggeredItemCard`.
///
/// Tapping a card opens the surface that owns its resource type. The source
/// pushed the *video* detail route for `ugc_video`; that route belongs to the
/// already-ported `lib/features/movie/eyepetizer/` surface, which this module
/// must not import, so the port reports the target instead of navigating and
/// only navigates for `ugc_picture` (via [onPictureTap]).
class EyepetizerFlutterStaggeredItemCard extends StatelessWidget {
  const EyepetizerFlutterStaggeredItemCard({
    super.key,
    required this.data,
    this.onPictureTap,
    this.onVideoTap,
  });

  final EyepetizerFlutterItem data;
  final ValueChanged<EyepetizerFlutterContentData>? onPictureTap;
  final ValueChanged<int>? onVideoTap;

  @override
  Widget build(BuildContext context) {
    final content = data.data?.content?.data;
    if (content == null) return Container();
    final owner = content.owner;
    return InkWell(
      onTap: () => _handleTap(content),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: EyepetizerFlutterCoverImageWidget(
              imageUrl: content.cover?.feed,
              width: double.infinity,
              borderRadius: 2,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            content.description ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, color: Colors.black45),
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              InkWell(
                onTap: () => onVideoTap?.call(owner?.uid ?? 0),
                child: EyepetizerFlutterCoverImageWidget(
                  imageUrl: owner?.avatar,
                  width: 20,
                  height: 20,
                  borderRadius: 100,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  owner?.nickname ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ),
              Text(
                (content.consumption?.collectionCount ?? 0).toString(),
                style: const TextStyle(fontSize: 10, color: Colors.black),
              ),
              const Icon(Icons.store, size: 15),
            ],
          ),
        ],
      ),
    );
  }

  /// The source's `resourceType` switch: `ugc_video` → video detail (out of
  /// scope, reported through [onVideoTap]), `ugc_picture` → picture detail
  /// (navigated through [onPictureTap]).
  void _handleTap(EyepetizerFlutterContentData content) {
    if (content.resourceType == 'ugc_video') {
      onVideoTap?.call(data.data?.header?.id ?? 0);
    } else if (content.resourceType == 'ugc_picture') {
      onPictureTap?.call(content);
    }
  }
}
