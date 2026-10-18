import 'package:dashboard/features/reading/flutterebook/models/entry.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/widgets/feedbooks_book_hero_tags.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/widgets/feedbooks_cover_image.dart';
import 'package:flutter/material.dart';

/// 源工程 `BookCard`：120 宽、圆角 10、elevation 4 的封面卡片。
///
/// 源卡片只渲染封面（标题 / 作者 tag 生成了但没用上），移植版保持这个行为，
/// 三个 tag 一并交给 [onTap] 供详情页续接 Hero；导航本身由页面负责（宿主
/// 约定：子组件只回调，不自己 push）。
class FeedbooksBookCard extends StatefulWidget {
  const FeedbooksBookCard({
    super.key,
    required this.img,
    required this.entry,
    this.onTap,
  });

  final String img;
  final FeedbooksEntry entry;
  final void Function(FeedbooksBookHeroTags tags)? onTap;

  @override
  State<FeedbooksBookCard> createState() => _FeedbooksBookCardState();
}

class _FeedbooksBookCardState extends State<FeedbooksBookCard> {
  late final FeedbooksBookHeroTags _tags = FeedbooksBookHeroTags.unique();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120.0,
      child: Card(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        elevation: 4.0,
        child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(10.0)),
          onTap: () => widget.onTap?.call(_tags),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
            child: Hero(
              tag: _tags.imgTag,
              child: FeedbooksCoverImage(url: widget.img),
            ),
          ),
        ),
      ),
    );
  }
}
