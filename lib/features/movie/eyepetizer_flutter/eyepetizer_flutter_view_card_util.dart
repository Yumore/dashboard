import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_content_data.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_cover_image_widget.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_horizontal_scroll_collection_card.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_item.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_staggered_view_card.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_text_card.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_video_card.dart';
import 'package:flutter/material.dart';

/// `lib/utils/view_card_util.dart` → `ViewCardUtil`, reduced to the branches
/// this module's own surfaces can produce.
///
/// The source covered 14 `type` values because it was also the home/daily feed
/// dispatcher, and that feed belongs to the already-ported `eyepetizer/`
/// module. Ported here: `textCard`, `followCard`, `pictureFollowCard`,
/// `videoSmallCard`, `videoCollectionOfHorizontalScrollCard`,
/// `communityColumnsCard`, `banner`. Everything else keeps the source's own
/// fallback — `Text(item.type)` — so an unknown card type is visible rather
/// than silently blank. Not ported: `horizontalScrollCard`,
/// `specialSquareCardCollection`, `columnCardList`, `autoPlayFollowCard`,
/// `banner3`, `briefCard` (all feed-only card types, see module report).
class EyepetizerFlutterViewCardUtil {
  const EyepetizerFlutterViewCardUtil._();

  static Widget getViewCard(
    EyepetizerFlutterItem item, {
    String? tag,
    List<EyepetizerFlutterItem>? itemList,
    ValueChanged<EyepetizerFlutterContentData>? onPictureTap,
    ValueChanged<int>? onVideoTap,
  }) {
    switch (item.type) {
      case 'textCard':
        return EyepetizerFlutterTextCard(title: item.data?.text);
      case 'videoCollectionOfHorizontalScrollCard':
        return EyepetizerFlutterHorizontalScrollCollectionCard(data: item);
      case 'communityColumnsCard':
        return EyepetizerFlutterStaggeredViewCard(
          list: itemList ?? const <EyepetizerFlutterItem>[],
          onPictureTap: onPictureTap,
          onVideoTap: onVideoTap,
        );
      case 'banner':
        return EyepetizerFlutterCoverImageWidget(
          imageUrl: item.data?.image,
          width: double.infinity,
          height: 180,
        );
      case 'followCard':
      case 'pictureFollowCard':
        return EyepetizerFlutterVideoCard(data: item);
      case 'videoSmallCard':
        return EyepetizerFlutterVideoCard(data: item, compact: true);
      default:
        return Text(item.type ?? '');
    }
  }
}
