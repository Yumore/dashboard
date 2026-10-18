import 'app_database_factory_stub.dart'
    if (dart.library.io) 'app_database_factory_io.dart'
    if (dart.library.js_interop) 'app_database_factory_web.dart';

/// 初始化全局 `databaseFactory`：不同平台的 SQLite 承载方式不同。
///
/// - 移动端：sqflite 插件；
/// - macOS：sqflite_darwin 插件；
/// - Windows/Linux：sqflite_common_ffi（sqlite3 随 Dart hooks 打包）；
/// - Web：sqflite_common_ffi_web（sqlite3.wasm + worker）。
Future<void> initAppDatabaseFactory() => initializePlatformDatabaseFactory();
