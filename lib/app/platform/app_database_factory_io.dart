import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'app_platform.dart';

/// io 平台初始化：桌面缺少 sqflite 原生插件，改用 ffi 实现。
Future<void> initializePlatformDatabaseFactory() async {
  if (!AppPlatform.isWindows && !AppPlatform.isLinux) {
    // Android/iOS 使用 sqflite 插件；macOS 使用 sqflite_darwin 插件。
    return;
  }
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
}
