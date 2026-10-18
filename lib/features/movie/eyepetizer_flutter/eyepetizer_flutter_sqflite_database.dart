import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_database.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

/// [EyepetizerFlutterDatabase] on top of real `sqflite`.
///
/// The source's `SQLiteHelper.init` passed an empty `onCreate`, so a fresh
/// database file starts with **no tables** and each provider creates its own
/// table on first use. That is reproduced here.
class EyepetizerFlutterSqfliteDatabase implements EyepetizerFlutterDatabase {
  EyepetizerFlutterSqfliteDatabase._(this._database);

  /// Opens (or creates) the database file at [path].
  ///
  /// `version: 1` matches `SQLiteHelper._VERSION`; the empty `onCreate` matches
  /// the source's commented-out body.
  static Future<EyepetizerFlutterSqfliteDatabase> open(
    String path, {
    int version = 1,
  }) async {
    final database = await sqflite.openDatabase(
      path,
      version: version,
      onCreate: (db, version) async {},
    );
    return EyepetizerFlutterSqfliteDatabase._(database);
  }

  final sqflite.Database _database;

  @override
  Future<void> execute(String sql) => _database.execute(sql);

  @override
  Future<List<Map<String, Object?>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]) => _database.rawQuery(sql, arguments);

  @override
  Future<int> insert(String table, Map<String, Object?> values) =>
      _database.insert(table, values);

  @override
  Future<int> delete(String table, {String? where, List<Object?>? whereArgs}) =>
      _database.delete(table, where: where, whereArgs: whereArgs);

  @override
  Future<List<Map<String, Object?>>> query(
    String table, {
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
  }) => _database.query(
    table,
    columns: columns,
    where: where,
    whereArgs: whereArgs,
  );

  @override
  Future<void> close() => _database.close();
}
