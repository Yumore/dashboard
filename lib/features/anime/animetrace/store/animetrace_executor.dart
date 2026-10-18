/// The narrow database surface the AnimeTrace DAOs use.
///
/// It is deliberately smaller than `sqflite`'s `DatabaseExecutor`: only raw SQL
/// plus a single map insert. That keeps the DAOs trivially portable and lets
/// tests run the exact same SQL against a plain SQLite engine (see
/// `test/animetrace_test.dart`) without the sqflite platform channel.
abstract class AnimeTraceExecutor {
  /// `SELECT` returning rows as column-name/value maps.
  Future<List<Map<String, Object?>>> rawQuery(
    String sql, [
    List<Object?>? args,
  ]);

  /// `INSERT` returning the new row id.
  Future<int> rawInsert(String sql, [List<Object?>? args]);

  /// `UPDATE`/`DELETE` returning the number of affected rows.
  Future<int> rawUpdate(String sql, [List<Object?>? args]);

  /// `DELETE` returning the number of affected rows.
  Future<int> rawDelete(String sql, [List<Object?>? args]);

  /// Statement without a result, for example `CREATE TABLE`.
  Future<void> execute(String sql, [List<Object?>? args]);

  /// Convenience insert for `INSERT INTO <table> (...)` returning the row id.
  Future<int> insertMap(String table, Map<String, Object?> values);
}

/// An opened AnimeTrace database: executor plus lifecycle.
abstract class AnimeTraceExecutorDatabase implements AnimeTraceExecutor {
  /// File path of the underlying database (empty while closed for in-memory
  /// engines).
  String get path;

  bool get isOpen;

  /// Creates the schema when missing and runs pending migrations.
  Future<void> open();

  /// Runs [action] inside a transaction, rolling back when it throws.
  Future<T> transaction<T>(Future<T> Function(AnimeTraceExecutor txn) action);

  Future<void> close();
}
