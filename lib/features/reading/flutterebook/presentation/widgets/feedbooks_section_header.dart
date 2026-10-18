import 'package:dashboard/features/reading/flutterebook/models/link.dart';
import 'package:flutter/material.dart';

/// 源工程 Explore 页 `_SectionHeader`：分类标题 + 右侧 `See All`。
///
/// `hideSeeAll` 由调用方按该分类已抓到的书数量决定（少于 10 本不显示入口）。
class FeedbooksSectionHeader extends StatelessWidget {
  const FeedbooksSectionHeader({
    super.key,
    required this.link,
    this.hideSeeAll = false,
    this.onSeeAll,
  });

  final FeedbooksLink link;
  final bool hideSeeAll;
  final void Function(FeedbooksLink link)? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
            child: Text(
              '${link.title}',
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (!hideSeeAll)
            GestureDetector(
              onTap: () => onSeeAll?.call(link),
              child: Text(
                'See All',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
