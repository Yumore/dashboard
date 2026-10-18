import 'package:dashboard/features/chat/flutterwechat_demo/flutterwechat_palette.dart';
import 'package:dashboard/features/chat/flutterwechat_demo/flutterwechat_pressable_state.dart';
import 'package:flutter/material.dart';

/// Port of the source `ClickFeedback` wrapper (source
/// `lib/common/ClickFeedback.dart`): a tappable area that paints a grey
/// background while pressed.
///
/// In flutter-wechat every tap ended in a native `Toast`; the host port has no
/// such channel, so callers pass an inert callback where the source only
/// showed a toast.
class FlutterWechatPressable extends StatefulWidget {
  const FlutterWechatPressable({
    required this.child,
    required this.onPressed,
    this.isFeed = true,
    this.background = FlutterWechatPalette.pressedBackground,
    super.key,
  });

  final Widget child;
  final VoidCallback onPressed;
  final bool isFeed;
  final Color background;

  @override
  State<FlutterWechatPressable> createState() => FlutterWechatPressableState();
}
