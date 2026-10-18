import 'package:dashboard/features/reading/flutterebook/models/entry.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/widgets/feedbooks_book_hero_tags.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/widgets/feedbooks_cover_image.dart';
import 'package:flutter/material.dart';

/// 源工程 `BookListItem`：150 高的横向条目，封面 100x150。
///
/// 封面固定取 `entry.link![1].href`（OPDS 里第二段 link 是封面图），标题去掉
/// 字面反斜杠，简介超过 100 字截断后补 `...`，并把字面 `\n` / `\r` / `\"`
/// 还原成真实字符。
class FeedbooksBookListItem extends StatefulWidget {
  const FeedbooksBookListItem({super.key, required this.entry, this.onTap});

  final FeedbooksEntry entry;
  final void Function(FeedbooksBookHeroTags tags)? onTap;

  @override
  State<FeedbooksBookListItem> createState() => _FeedbooksBookListItemState();
}

class _FeedbooksBookListItemState extends State<FeedbooksBookListItem> {
  late final FeedbooksBookHeroTags _tags = FeedbooksBookHeroTags.unique();

  @override
  Widget build(BuildContext context) {
    final FeedbooksEntry entry = widget.entry;
    return InkWell(
      onTap: () => widget.onTap?.call(_tags),
      child: SizedBox(
        height: 150.0,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Card(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              elevation: 4,
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                child: Hero(
                  tag: _tags.imgTag,
                  child: FeedbooksCoverImage(
                    url: entry.link![1].href!,
                    height: 150.0,
                    width: 100.0,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10.0),
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Hero(
                    tag: _tags.titleTag,
                    child: Material(
                      type: MaterialType.transparency,
                      child: Text(
                        entry.title!.t!.replaceAll(r'\', ''),
                        style: TextStyle(
                          fontSize: 17.0,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Hero(
                    tag: _tags.authorTag,
                    child: Material(
                      type: MaterialType.transparency,
                      child: Text(
                        entry.author!.name!.t!,
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Text(
                    '${entry.summary!.t!.length < 100 ? entry.summary!.t! : entry.summary!.t!.substring(0, 100)}...'
                        .replaceAll(r'\n', '\n')
                        .replaceAll(r'\r', '')
                        .replaceAll(r'\"', '"'),
                    style: TextStyle(
                      fontSize: 13.0,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
