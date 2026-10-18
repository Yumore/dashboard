import 'package:flutter/material.dart';

/// 区块标题。源工程有两个几乎同名的小组件：
/// 首页的 `_SectionTitle`（20 号 w500）和详情页的 `_SectionTitle`
/// （secondary 色、20 号 bold），这里用 [emphasized] 区分。
class FeedbooksSectionTitle extends StatelessWidget {
  const FeedbooksSectionTitle({
    super.key,
    required this.title,
    this.emphasized = false,
  });

  final String title;

  /// true = 详情页样式（主题 secondary 色 + 加粗）。
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    if (emphasized) {
      return Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.secondary,
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
