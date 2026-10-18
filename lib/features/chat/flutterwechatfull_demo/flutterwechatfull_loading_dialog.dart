import 'dart:async';

import 'package:flutter/material.dart';

/// The source's `LoadingDialog`: a blocking spinner shown for one second while
/// the demo "logs in" against its bundled mock user.
class FlutterWechatFullLoadingDialog {
  const FlutterWechatFullLoadingDialog._();

  static Future<void> simulate(
    BuildContext context, {
    required VoidCallback onFinished,
  }) async {
    final NavigatorState navigator = Navigator.of(context, rootNavigator: true);
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: SizedBox(
            width: 96.0,
            height: 96.0,
            child: Card(child: Center(child: CircularProgressIndicator())),
          ),
        ),
      ),
    );
    await Future<void>.delayed(const Duration(seconds: 1));
    if (navigator.canPop()) {
      navigator.pop();
    }
    onFinished();
  }
}
