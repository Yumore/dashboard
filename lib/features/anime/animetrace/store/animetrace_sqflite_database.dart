import 'dart:io';

import 'package:dashboard/features/anime/animetrace/store/animetrace_executor.dart';
import 'package:dashboard/features/anime/animetrace/store/animetrace_schema.dart';
import 'package:sqflite/sqflite.dart';

/// `sqflite`-backed AnimeTrace database, opened with the host's plain-SQL
/// conventions (`getDatabasesPath()` + `openDatabase(version: onCreate:)`).
///
/// The database file is owned by this feature (`anime_trace.db`); it never
/// touches the host's `comic_history.db`.
class AnimeTraceSqfliteDatabase implements AnimeTraceExecutorDatabase {
  AnimeTraceSqfliteDatabase({
    this.fileName = 'anime_trace.db',
    String? databasePath,
  }) : _explicitPath = databasePath;

  final String fileName;
  final String? _explicitPath;

  Database? _database;
  String _path = '';

  /// Default production instance.
  factory AnimeTraceSqfliteDatabase.production() => AnimeTraceSqfliteDatabase();

  @override
  String get path => _path;

  @override
  bool get isOpen => _database != null;

  @override
  Future<void> open() async {
    if (_database != null) return;
    final target = _explicitPath ?? '${await getDatabasesPath()}/$fileName';
    final parent = _parentDirectory(target);
    if (parent != null) {
      await Directory(parent).create(recursive: true);
    }
    _database = await openDatabase(
      target,
      version: AnimeTraceSchema.version,
      onCreate: (db, version) async {
        for (final statement in AnimeTraceSchema.statements) {
          await db.execute(statement);
        }
      },
    );
    _path = target;
  }

  @override
  Future<List<Map<String, Object?>>> rawQuery(
    String sql, [
    List<Object?>? args,
  ]) async => _executor.rawQuery(sql, args);

  @override
  Future<int> rawInsert(String sql, [List<Object?>? args]) async =>
      _executor.rawInsert(sql, args);

  @override
  Future<int> rawUpdate(String sql, [List<Object?>? args]) async =>
      _executor.rawUpdate(sql, args);

  @override
  Future<int> rawDelete(String sql, [List<Object?>? args]) async =>
      _executor.rawDelete(sql, args);

  @override
  Future<void> execute(String sql, [List<Object?>? args]) async =>
      _executor.execute(sql, args);

  @override
  Future<int> insertMap(String table, Map<String, Object?> values) async =>
      _executor.insertMap(table, values);

  @override
  Future<T> transaction<T>(
    Future<T> Function(AnimeTraceExecutor txn) action,
  ) async {
    final db = _requireDatabase();
    return db.transaction<T>((txn) => action(_SqfliteExecutor(txn)));
  }

  @override
  Future<void> close() async {
    final db = _database;
    _database = null;
    if (db != null) await db.close();
  }

  AnimeTraceExecutor get _executor => _SqfliteExecutor(_requireDatabase());

  Database _requireDatabase() {
    final db = _database;
    if (db == null) {
      throw StateError(
        'AnimeTraceSqfliteDatabase.open() must be awaited first',
      );
    }
    return db;
  }

  static String? _parentDirectory(String filePath) {
    final index = filePath.lastIndexOf('/');
    if (index <= 0) return null;
    return filePath.substring(0, index);
  }
}

/// Adapts a sqflite `DatabaseExecutor` (a `Database` or a `Transaction`) to
/// [AnimeTraceExecutor].
class _SqfliteExecutor implements AnimeTraceExecutor {
  _SqfliteExecutor(this._executor);

  final DatabaseExecutor _executor;

  @override
  Future<List<Map<String, Object?>>> rawQuery(
    String sql, [
    List<Object?>? args,
  ]) => _executor.rawQuery(sql, args);

  @override
  Future<int> rawInsert(String sql, [List<Object?>? args]) =>
      _executor.rawInsert(sql, args);

  @override
  Future<int> rawUpdate(String sql, [List<Object?>? args]) =>
      _executor.rawUpdate(sql, args);

  @override
  Future<int> rawDelete(String sql, [List<Object?>? args]) =>
      _executor.rawDelete(sql, args);

  @override
  Future<void> execute(String sql, [List<Object?>? args]) =>
      _executor.execute(sql, args);

  @override
  Future<int> insertMap(String table, Map<String, Object?> values) =>
      _executor.insert(table, values);
}
