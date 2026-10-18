import 'package:dashboard/features/novel/flutternovel/models/novel_book_source.dart';
import 'package:flutter/material.dart';

/// Lists the `btoc` sources a book is available from and lets the reader switch
/// between them (the source's book-source picker).
class NovelSourcePicker extends StatelessWidget {
  const NovelSourcePicker({
    super.key,
    required this.sources,
    required this.selectedId,
    required this.onSelected,
  });

  final List<NovelBookSource> sources;
  final String? selectedId;
  final ValueChanged<NovelBookSource> onSelected;

  @override
  Widget build(BuildContext context) => RadioGroup<String>(
    groupValue: selectedId ?? '',
    onChanged: (value) {
      if (value == null) return;
      for (final source in sources) {
        if (source.id == value) {
          onSelected(source);
          return;
        }
      }
    },
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (final source in sources)
          RadioListTile<String>(
            value: source.id ?? '',
            title: Text(source.name ?? '未知书源'),
            subtitle: Text(
              '${source.lastChapter ?? ''}'
              '${source.chaptersCount == null ? '' : ' · ${source.chaptersCount}章'}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    ),
  );
}
