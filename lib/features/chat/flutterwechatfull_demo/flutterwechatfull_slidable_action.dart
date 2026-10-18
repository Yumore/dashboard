import 'package:flutter/material.dart';

/// One trailing action behind a swipeable row.
class FlutterWechatFullSlidableAction {
  const FlutterWechatFullSlidableAction({
    required this.label,
    required this.color,
    this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback? onTap;
}
