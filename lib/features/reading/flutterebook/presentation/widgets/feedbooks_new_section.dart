import 'package:dashboard/features/reading/flutterebook/models/category_feed.dart';
import 'package:dashboard/features/reading/flutterebook/models/entry.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/widgets/feedbooks_book_hero_tags.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/widgets/feedbooks_book_list_item.dart';
import 'package:flutter/material.dart';

/// 源工程首页 `_NewSection`：recent feed 的纵向列表（内层不滚动）。
class FeedbooksNewSection extends StatelessWidget {
  const FeedbooksNewSection({super.key, required this.recent, this.onTapBook});

  final FeedbooksCategoryFeed recent;
  final void Function(FeedbooksEntry entry, FeedbooksBookHeroTags tags)?
  onTapBook;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      primary: false,
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recent.feed?.entry?.length ?? 0,
      itemBuilder: (BuildContext context, int index) {
        final FeedbooksEntry entry = recent.feed!.entry![index];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
          child: FeedbooksBookListItem(
            entry: entry,
            onTap: (FeedbooksBookHeroTags tags) => onTapBook?.call(entry, tags),
          ),
        );
      },
    );
  }
}
