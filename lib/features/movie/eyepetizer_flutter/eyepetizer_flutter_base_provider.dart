import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_database.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_sqlite_helper.dart';

/// `lib/db/provider/base_provider.dart`.
///
/// One table per provider, created on first use: [open] probes
/// `Sqlite_master` and runs [tableSql] only when the table is missing. The
/// source spelled the flag `isTableExits`; the port uses the correct spelling.
abstract class EyepetizerFlutterBaseProvider {
  EyepetizerFlutterBaseProvider({EyepetizerFlutterDatabase? database})
    : _database = database;

  final EyepetizerFlutterDatabase? _database;

  bool isTableExists = false;

  /// The injected database, or the process-wide sqflite one.
  Future<EyepetizerFlutterDatabase> database() async =>
      _database ?? await EyepetizerFlutterSqliteHelper.getCurrentDatabase();

  Future<EyepetizerFlutterDatabase> getDataBase(String tabName) =>
      open(tabName);

  /// `BaseProvider.prepare` — runs the `create table` statement.
  Future<void> prepare(String name, String createSql) async {
    final database = await this.database();
    await database.execute(createSql);
  }

  /// `BaseProvider.open` — probe, create if absent, hand back the handle.
  Future<EyepetizerFlutterDatabase> open(String tabName) async {
    final database = await this.database();
    isTableExists = await checkTableExists(tabName);
    if (!isTableExists) {
      await prepare(tableName(), tableSql());
    }
    return database;
  }

  /// `BaseProvider.checkTableExits` — the probe query, verbatim.
  Future<bool> checkTableExists(String tableName) async {
    final database = await this.database();
    final rows = await database.rawQuery(
      "select * from Sqlite_master where type = 'table' and name = '$tableName'",
    );
    return rows.isNotEmpty;
  }

  String tableName();

  String tableSql();
}
