import 'package:flutter/material.dart';

import 'flutterwechatfull_style.dart';

/// The green text button the source puts in `AppBar.leading` / `actions`.
class FlutterWechatFullBarButton extends StatelessWidget {
  const FlutterWechatFullBarButton({
    required this.label,
    required this.onPressed,
    this.enabled = true,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: enabled ? onPressed : null,
      style: TextButton.styleFrom(
        foregroundColor: FlutterWechatFullStyle.primary,
        minimumSize: const Size(56.0, 44.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        shape: const RoundedRectangleBorder(),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 17.0,
          color: enabled
              ? FlutterWechatFullStyle.primary
              : FlutterWechatFullStyle.textHint,
        ),
      ),
    );
  }
}
