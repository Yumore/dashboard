import 'package:flutter/cupertino.dart';

/// Shows the iOS-style action sheet the source builds with `ActionSheet`.
///
/// Every action the source leaves inert (冻结 / 安全中心 / 取消) pops the sheet
/// without doing anything else, so the same is true here.
class FlutterWechatFullActionSheet {
  const FlutterWechatFullActionSheet._();

  static Future<void> show(
    BuildContext context, {
    String? title,
    String? message,
    required List<Widget> actions,
  }) {
    return showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: title == null ? null : Text(title),
        message: message == null ? null : Text(message),
        actions: actions,
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
      ),
    );
  }
}
