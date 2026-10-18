import 'package:flutter/material.dart';

/// 源工程 `EmptyView`。
///
/// 源工程放的是 `assets/images/empty.png`（宿主没有这张图），移植版换成同尺寸
/// 图标 + 完全相同的文案 `Nothing is here`。
class FeedbooksEmptyView extends StatelessWidget {
  const FeedbooksEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.inbox_outlined,
            size: 160.0,
            color: Theme.of(context).colorScheme.outline,
          ),
          const Text(
            'Nothing is here',
            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
