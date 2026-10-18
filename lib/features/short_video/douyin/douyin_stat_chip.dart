import 'package:dashboard/features/short_video/douyin/douyin_count_formatter.dart';
import 'package:flutter/material.dart';

/// 详情页的计数小标签（点赞/评论/分享/播放）。
class DouyinStatChip extends StatelessWidget {
  const DouyinStatChip({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text('$label ${DouyinCountFormatter.compact(value)}'),
      visualDensity: VisualDensity.compact,
    );
  }
}
