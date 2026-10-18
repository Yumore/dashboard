import 'package:flutter/material.dart';

import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_palette.dart';

/// Bottom-navigation icon with the unread badge of the FlutterSocialAppUIKit
/// demo (source `lib/views/widgets/icon_badge.dart`).
///
/// Source detail: the badge text is the hard-coded string `'16'` — there is no
/// counter to configure and no state behind it. The port keeps that dead
/// display value instead of inventing a notification count.
class FlutterSocialAppUIKitIconBadge extends StatelessWidget {
  const FlutterSocialAppUIKitIconBadge({
    required this.icon,
    this.size,
    this.color,
    super.key,
  });

  final IconData icon;
  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Icon(icon, size: size, color: color),
        Positioned(
          right: 0.0,
          child: Container(
            padding: const EdgeInsets.all(1.0),
            decoration: BoxDecoration(
              color: FlutterSocialAppUIKitPalette.badgeColor,
              borderRadius: BorderRadius.circular(6.0),
            ),
            constraints: const BoxConstraints(minWidth: 11.0, minHeight: 11.0),
            child: const Padding(
              padding: EdgeInsets.only(top: 1.0),
              child: Text(
                '16',
                style: TextStyle(color: Colors.white, fontSize: 9.0),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
