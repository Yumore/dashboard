import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_content_data.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_item.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_staggered_item_card.dart';
import 'package:flutter/material.dart';

/// `lib/pages/community/widgets/staggered_view.dart` → `StaggeredViewCard`,
/// without `flutter_staggered_grid_view` (not a host dependency).
///
/// The source laid out `crossAxisCount: 4` with `StaggeredTile.count(2, index
/// .isEven ? 2 : 3)`: every card is half the width, and cards alternate between
/// 2 and 3 quarter-widths tall. The hand-written replacement reproduces those
/// proportions exactly — `unit = maxWidth / 4`, tile width `2 * unit`, tile
/// height `2 * unit` / `3 * unit` — and places each card in the currently
/// shorter of two columns, which is what a masonry grid does. There is no
/// scrolling of its own (the source passed `NeverScrollableScrollPhysics` plus
/// `shrinkWrap: true`), so it is a plain [Column]-based layout.
class EyepetizerFlutterStaggeredViewCard extends StatelessWidget {
  const EyepetizerFlutterStaggeredViewCard({
    super.key,
    required this.list,
    this.onPictureTap,
    this.onVideoTap,
  });

  final List<EyepetizerFlutterItem> list;
  final ValueChanged<EyepetizerFlutterContentData>? onPictureTap;
  final ValueChanged<int>? onVideoTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final unit = constraints.maxWidth / 4;
        final left = <Widget>[];
        final right = <Widget>[];
        var leftHeight = 0.0;
        var rightHeight = 0.0;
        for (var index = 0; index < list.length; index++) {
          final tileHeight = unit * (index.isEven ? 2 : 3);
          final card = SizedBox(
            width: unit * 2,
            height: tileHeight,
            child: EyepetizerFlutterStaggeredItemCard(
              data: list[index],
              onPictureTap: onPictureTap,
              onVideoTap: onVideoTap,
            ),
          );
          if (leftHeight <= rightHeight) {
            left.add(card);
            leftHeight += tileHeight + 10;
          } else {
            right.add(card);
            rightHeight += tileHeight + 10;
          }
        }
        return Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(child: _column(left)),
              const SizedBox(width: 10),
              Expanded(child: _column(right)),
            ],
          ),
        );
      },
    );
  }

  Widget _column(List<Widget> cards) {
    final children = <Widget>[];
    for (var i = 0; i < cards.length; i++) {
      if (i > 0) children.add(const SizedBox(height: 10));
      children.add(cards[i]);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}
