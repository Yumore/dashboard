import 'package:dashboard/features/anime/tsdm/tsdm_collections.dart';
import 'package:html/dom.dart' as dom;

/// A medal image shown in a post floor.
///
/// Ported from `tsdm_client/lib/widgets/card/post_card/post_medal.dart`.
class TsdmPostMedal {
  const TsdmPostMedal({
    required this.id,
    required this.image,
    required this.alter,
    required this.menuItemId,
  });

  /// Medal id, the `id` attribute of the image node.
  final String id;

  /// Image url.
  final String image;

  /// Alt text.
  final String alter;

  /// Id of the medal description node in the hidden medal menu.
  final String menuItemId;

  /// Build from an `<img>` node.
  ///
  /// The `menuItemId` is the 6th single-quoted part of the `onmouseover`
  /// attribute, as in the source:
  /// `onmouseover="showMenu({'ctrlid':this.id, 'menuid':'${MENU_ITEM_ID}', 'pos':'12!'});"`
  static TsdmPostMedal? fromImg(dom.Element element) {
    final id = element.attributes['id'];
    final image = element.attributes['src'];
    final alter = element.attributes['alt'];
    final menuItemId = element.attributes['onmouseover']
        ?.split("'")
        .elementAtOrNull(5);

    if (id == null || image == null || alter == null || menuItemId == null) {
      return null;
    }

    return TsdmPostMedal(
      id: id,
      image: image,
      alter: alter,
      menuItemId: menuItemId,
    );
  }
}
