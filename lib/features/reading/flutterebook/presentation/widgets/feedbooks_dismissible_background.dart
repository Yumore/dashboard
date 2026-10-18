import 'package:flutter/material.dart';

/// 源工程下载页的 `_DismissibleBackground`：右对齐的红底垃圾桶。
///
/// 源工程用 `Feather.trash_2`（flutter_icons 包），宿主没有该依赖，改用
/// Material 的 [Icons.delete]。
class FeedbooksDismissibleBackground extends StatelessWidget {
  const FeedbooksDismissibleBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20.0),
      color: Colors.red,
      child: const Icon(Icons.delete, color: Colors.white),
    );
  }
}
