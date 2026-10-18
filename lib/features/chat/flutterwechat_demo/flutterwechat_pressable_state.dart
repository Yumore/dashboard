import 'package:dashboard/features/chat/flutterwechat_demo/flutterwechat_pressable.dart';
import 'package:flutter/material.dart';

/// State of [FlutterWechatPressable]: paints the grey pressed background.
class FlutterWechatPressableState extends State<FlutterWechatPressable> {
  Color _color = Colors.transparent;

  void _press() {
    if (!widget.isFeed) {
      return;
    }
    setState(() {
      _color = widget.background;
    });
  }

  void _release() {
    if (_color == Colors.transparent) {
      return;
    }
    setState(() {
      _color = Colors.transparent;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      onTapDown: (details) => _press(),
      onTapUp: (details) => _release(),
      onTapCancel: _release,
      onPanDown: (details) => _press(),
      onPanCancel: _release,
      onHorizontalDragCancel: _release,
      child: Container(color: _color, child: widget.child),
    );
  }
}
