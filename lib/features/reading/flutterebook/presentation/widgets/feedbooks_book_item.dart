import 'package:dashboard/features/reading/flutterebook/models/entry.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/widgets/feedbooks_book_hero_tags.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/widgets/feedbooks_cover_image.dart';
import 'package:flutter/material.dart';

/// 源工程 `BookItem`：150 宽的竖版卡片（封面 + 居中标题），收藏页在用。
class FeedbooksBookItem extends StatefulWidget {
  const FeedbooksBookItem({
    super.key,
    required this.img,
    required this.title,
    required this.entry,
    this.onTap,
  });

  final String img;
  final String title;
  final FeedbooksEntry entry;
  final void Function(FeedbooksBookHeroTags tags)? onTap;

  @override
  State<FeedbooksBookItem> createState() => _FeedbooksBookItemState();
}

class _FeedbooksBookItemState extends State<FeedbooksBookItem> {
  late final FeedbooksBookHeroTags _tags = FeedbooksBookHeroTags.unique();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: InkWell(
        onTap: () => widget.onTap?.call(_tags),
        child: Column(
          children: <Widget>[
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(10.0)),
              child: Hero(
                tag: _tags.imgTag,
                child: FeedbooksCoverImage(url: widget.img, height: 150.0),
              ),
            ),
            const SizedBox(height: 5.0),
            Hero(
              tag: _tags.titleTag,
              child: Material(
                type: MaterialType.transparency,
                child: Text(
                  widget.title.replaceAll(r'\', ''),
                  style: const TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
