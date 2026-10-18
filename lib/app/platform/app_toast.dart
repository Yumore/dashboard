import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'app_messenger.dart';
import 'app_platform.dart';

/// 统一 toast。
///
/// 移动端与 Web 使用 fluttertoast（Web 插件为 HTML toast）；桌面与鸿蒙没有
/// fluttertoast 插件实现，降级为全局 SnackBar，避免 MissingPluginException。
abstract final class AppToast {
  static Future<void> show({
    required String msg,
    Toast? toastLength,
    int timeInSecForIosWeb = 1,
    double? fontSize,
    String? fontAsset,
    ToastGravity? gravity,
    Color? backgroundColor,
    Color? textColor,
    bool webShowClose = false,
    String webBgColor = 'linear-gradient(to right, #00b09b, #96c93d)',
    String webPosition = 'right',
  }) async {
    if (!AppPlatform.supportsNativeToast) {
      AppMessenger.show(msg);
      return;
    }
    await Fluttertoast.showToast(
      msg: msg,
      toastLength: toastLength,
      timeInSecForIosWeb: timeInSecForIosWeb,
      fontSize: fontSize,
      fontAsset: fontAsset,
      gravity: gravity,
      backgroundColor: backgroundColor,
      textColor: textColor,
      webShowClose: webShowClose,
      webBgColor: webBgColor,
      webPosition: webPosition,
    );
  }
}
