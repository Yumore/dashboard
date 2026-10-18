import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_database.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_sqflite_database.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' show getDatabasesPath;

/// `lib/db/sqlite_helper.dart`.
class EyepetizerFlutterSqliteHelper {
  const EyepetizerFlutterSqliteHelper._();

  /// `SQLiteHelper.DB_NAME`.
  static const String databaseName = 'eyepetizer_flutter.db';

  /// `SQLiteHelper._VERSION`.
  static const int version = 1;

  static EyepetizerFlutterDatabase? _database;

  /// `SQLiteHelper.join` concatenated without a separator
  /// (`databasesPath + dbName`), so the source opened a sibling file whose
  /// name was the databases directory's path plus the database name. That is
  /// preserved byte-for-byte: the file it created is the file the local cache
  /// must keep reading.
  static String join(String databasesPath, String databaseName) =>
      databasesPath + databaseName;

  /// `SQLiteHelper.init` / `getCurrentDatabase`, lazily opening once.
  static Future<EyepetizerFlutterDatabase> getCurrentDatabase() async {
    final existing = _database;
    if (existing != null) return existing;
    final databasesPath = await getDatabasesPath();
    final opened = await EyepetizerFlutterSqfliteDatabase.open(
      join(databasesPath, databaseName),
      version: version,
    );
    _database = opened;
    return opened;
  }

  static Future<void> init() async {
    await getCurrentDatabase();
  }

  /// `SQLiteHelper.close` — clears the handle and closes it.
  static Future<void> close() async {
    final database = _database;
    _database = null;
    await database?.close();
  }

  /// Swaps in an in-memory database (tests), or `null` to fall back to sqflite.
  @visibleForTesting
  static void debugSetDatabase(EyepetizerFlutterDatabase? database) {
    _database = database;
  }
}
