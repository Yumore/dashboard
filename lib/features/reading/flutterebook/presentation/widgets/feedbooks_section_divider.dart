import 'package:flutter/material.dart';

/// 源工程详情页的 `_Divider`：颜色取 `textTheme.bodySmall`。
class FeedbooksSectionDivider extends StatelessWidget {
  const FeedbooksSectionDivider({super.key});

  @override
  Widget build(BuildContext context) =>
      Divider(color: Theme.of(context).textTheme.bodySmall?.color);
}
