import 'package:flutter/material.dart';

import 'flutterwechatfull_slidable_action.dart';

/// A dependency-free stand-in for the source's `Slidable` rows.
///
/// Dragging left reveals the same actions the source defines; every action in
/// the source is a no-op (`onTap` prints only), so the buttons stay inert.
class FlutterWechatFullSlidable extends StatefulWidget {
  const FlutterWechatFullSlidable({
    required this.child,
    required this.actions,
    this.onTap,
    super.key,
  });

  final Widget child;
  final List<FlutterWechatFullSlidableAction> actions;
  final VoidCallback? onTap;

  @override
  State<FlutterWechatFullSlidable> createState() =>
      _FlutterWechatFullSlidableState();
}

class _FlutterWechatFullSlidableState extends State<FlutterWechatFullSlidable> {
  static const double _actionWidth = 72.0;

  double _offset = 0.0;
  bool _open = false;

  double get _maxOffset => -_actionWidth * widget.actions.length;

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      _offset = (_offset + details.delta.dx).clamp(_maxOffset, 0.0);
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    setState(() {
      _open = _offset < _maxOffset / 2;
      _offset = _open ? _maxOffset : 0.0;
    });
  }

  @override
  void didUpdateWidget(covariant FlutterWechatFullSlidable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_open) {
      setState(() {
        _open = false;
        _offset = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  for (final FlutterWechatFullSlidableAction action
                      in widget.actions)
                    SizedBox(
                      width: _actionWidth,
                      height: double.infinity,
                      child: Material(
                        color: action.color,
                        child: InkWell(
                          onTap: action.onTap,
                          child: Center(
                            child: Text(
                              action.label,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 15.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onHorizontalDragUpdate: _handleDragUpdate,
            onHorizontalDragEnd: _handleDragEnd,
            onTap: () {
              if (_open) {
                setState(() {
                  _open = false;
                  _offset = 0.0;
                });
                return;
              }
              widget.onTap?.call();
            },
            child: Transform.translate(
              offset: Offset(_offset, 0.0),
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }
}
