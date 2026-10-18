import 'package:flutter/material.dart';

import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_palette.dart';

/// Full-width button of the FlutterSocialAppUIKit login form
/// (source `lib/views/widgets/custom_button.dart`).
///
/// The source takes an untyped, nullable `Function? onPressed` and force-calls
/// it, so a null handler crashes only when tapped. The port keeps the callback
/// nullable and makes a missing handler a no-op instead, so the demo never
/// throws on a dead control.
class FlutterSocialAppUIKitCustomButton extends StatelessWidget {
  const FlutterSocialAppUIKitCustomButton({
    this.label = 'Continue',
    this.onPressed,
    this.color,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50.0,
      width: MediaQuery.of(context).size.width,
      child: TextButton(
        onPressed: () => onPressed?.call(),
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll<Color>(
            color ?? FlutterSocialAppUIKitPalette.secondary,
          ),
          shape: WidgetStatePropertyAll<OutlinedBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 18.0,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
