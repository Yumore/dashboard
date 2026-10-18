/// The slice of a database the local cache needs.
///
/// The source talked to `sqflite`'s `Database` directly from its providers,
/// which made the cache untestable without a device. This interface is the one
/// deliberate abstraction added to the port: `lib/` ships the sqflite
/// implementation, and the test suite supplies an in-memory implementation so
/// the insert/query/replace-by-tag rules can be asserted without a plugin.
abstract class EyepetizerFlutterDatabase {
  /// Runs a statement with no result rows (`create table ...`).
  Future<void> execute(String sql);

  /// `db.rawQuery`, used for the `Sqlite_master` table-exists probe.
  Future<List<Map<String, Object?>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]);

  Future<int> insert(String table, Map<String, Object?> values);

  Future<int> delete(String table, {String? where, List<Object?>? whereArgs});

  Future<List<Map<String, Object?>>> query(
    String table, {
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
  });

  Future<void> close();
}
