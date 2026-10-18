import 'package:dashboard/features/reading/flutterebook/models/category_feed.dart';
import 'package:dashboard/features/reading/flutterebook/models/entry.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/widgets/feedbooks_book_card.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/widgets/feedbooks_book_hero_tags.dart';
import 'package:flutter/material.dart';

/// 源工程 `FeaturedSection`：首页顶部 200 高的横向封面列表，
/// 数据来自 popular feed 的 `entry`。
class FeedbooksFeaturedSection extends StatelessWidget {
  const FeedbooksFeaturedSection({
    super.key,
    required this.popular,
    this.onTapBook,
  });

  final FeedbooksCategoryFeed popular;
  final void Function(FeedbooksEntry entry, FeedbooksBookHeroTags tags)?
  onTapBook;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200.0,
      child: Center(
        child: ListView.builder(
          primary: false,
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          scrollDirection: Axis.horizontal,
          itemCount: popular.feed?.entry?.length ?? 0,
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
            final FeedbooksEntry entry = popular.feed!.entry![index];
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 5.0,
                vertical: 10.0,
              ),
              child: FeedbooksBookCard(
                img: entry.link![1].href!,
                entry: entry,
                onTap: (FeedbooksBookHeroTags tags) =>
                    onTapBook?.call(entry, tags),
              ),
            );
          },
        ),
      ),
    );
  }
}
