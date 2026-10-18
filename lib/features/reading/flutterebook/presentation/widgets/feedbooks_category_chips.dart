import 'package:dashboard/features/reading/flutterebook/models/category.dart';
import 'package:dashboard/features/reading/flutterebook/models/entry.dart';
import 'package:flutter/material.dart';

/// 源工程详情页的 `_CategoryChips`：每个 `category.label` 一个描边圆角标签。
class FeedbooksCategoryChips extends StatelessWidget {
  const FeedbooksCategoryChips({super.key, required this.entry});

  final FeedbooksEntry entry;

  @override
  Widget build(BuildContext context) {
    final List<FeedbooksCategory>? categories = entry.category;
    if (categories == null) {
      return const SizedBox.shrink();
    }
    final Color secondary = Theme.of(context).colorScheme.secondary;
    return Wrap(
      children: <Widget>[
        for (final FeedbooksCategory category in categories)
          Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 5.0, 5.0, 5.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                border: Border.all(color: secondary),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 7.0,
                  vertical: 5,
                ),
                child: Text(
                  '${category.label}',
                  style: TextStyle(
                    color: secondary,
                    fontSize: 12.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
