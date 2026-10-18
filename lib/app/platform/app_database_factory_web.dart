import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

/// Web 平台初始化：使用 wasm 版 SQLite。
Future<void> initializePlatformDatabaseFactory() async {
  databaseFactory = databaseFactoryFfiWeb;
}
