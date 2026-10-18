import 'package:dashboard/features/reading/flutterebook/models/category_feed.dart';
import 'package:dashboard/features/reading/flutterebook/models/link.dart';
import 'package:flutter/material.dart';

/// 源工程首页 `_GenreSection`：50 高的横向分类胶囊列表。
///
/// 关键业务规则照抄源工程：popular feed 的 `link` 前 10 项是 OPDS 导航
/// 标签（不是分类），因此 `index < 10` 直接返回空盒子。
class FeedbooksGenreRow extends StatelessWidget {
  const FeedbooksGenreRow({super.key, required this.popular, this.onTapLink});

  final FeedbooksCategoryFeed popular;
  final void Function(FeedbooksLink link)? onTapLink;

  @override
  Widget build(BuildContext context) {
    final Color secondary = Theme.of(context).colorScheme.secondary;
    return SizedBox(
      height: 50.0,
      child: Center(
        child: ListView.builder(
          primary: false,
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          scrollDirection: Axis.horizontal,
          itemCount: popular.feed?.link?.length ?? 0,
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
            final FeedbooksLink link = popular.feed!.link![index];

            // We don't need the tags from 0-9 because they are not categories.
            if (index < 10) {
              return const SizedBox.shrink();
            }

            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 5.0,
                vertical: 10.0,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: secondary,
                  borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                ),
                child: InkWell(
                  borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                  onTap: () => onTapLink?.call(link),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        '${link.title}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
