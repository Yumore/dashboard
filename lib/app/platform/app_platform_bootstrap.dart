import 'app_database_factory.dart';
import 'app_platform.dart';

/// 启动期平台初始化。
///
/// 只做与平台相关的必要准备工作，业务初始化仍由 `main.dart` 负责。
abstract final class AppPlatformBootstrap {
  static Future<void> initialize() async {
    await initAppDatabaseFactory();
    if (AppPlatform.isWeb) {
      // Web 没有本地文件系统，SQLite 使用 IndexedDB 承载的 wasm 实现。
    }
  }
}
