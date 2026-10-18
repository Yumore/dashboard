import 'package:flutter/material.dart';

/// 全局 ScaffoldMessenger。
///
/// 用于没有 BuildContext 的场景（桌面/鸿蒙 toast 降级、启动期错误提示）。
abstract final class AppMessenger {
  static final GlobalKey<ScaffoldMessengerState> key =
      GlobalKey<ScaffoldMessengerState>();

  static void show(String message) {
    key.currentState?.showSnackBar(SnackBar(content: Text(message)));
  }
}
