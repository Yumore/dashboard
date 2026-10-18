import 'dart:convert';

import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_base_list_data.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_base_provider.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_json.dart';

/// `lib/db/provider/base_list_provider.dart` — the local feed cache.
///
/// One row per tag, holding the whole page as a JSON string. Writing a tag
/// deletes the old row first, so a tag always has at most one row and a refresh
/// replaces rather than appends. This is the store
/// `HomeRepository.getDiscoverData` falls back to when the network interceptor
/// answers with `Code.NETWORK_ERROR`, so the JSON round trip must keep every
/// field the feed readers touch.
class EyepetizerFlutterBaseListProvider extends EyepetizerFlutterBaseProvider {
  EyepetizerFlutterBaseListProvider({super.database});

  static const String tabName = 'base_list';
  static const String idColumn = '_id';
  static const String tagColumn = 'tag';
  static const String dataColumn = 'data';

  Future<void> insert(String tag, EyepetizerFlutterBaseListData data) async {
    final database = await getDataBase(tabName);
    if (await checkTableExists(tabName)) {
      await database.delete(
        tabName,
        where: '$tagColumn = ?',
        whereArgs: <Object?>[tag],
      );
    }
    final result = jsonEncode(data.toJson());
    await database.insert(tabName, <String, Object?>{
      tagColumn: tag,
      dataColumn: result,
    });
  }

  /// Returns `null` when the tag has no cached page — the source relied on that
  /// null to mean "nothing cached, show the error page".
  Future<EyepetizerFlutterBaseListData?> query(String tag) async {
    final database = await getDataBase(tabName);
    final rows = await database.query(
      tabName,
      columns: <String>[idColumn, tagColumn, dataColumn],
      where: '$tagColumn = ?',
      whereArgs: <Object?>[tag],
    );
    if (rows.isEmpty) return null;
    final decoded = jsonDecode(
      EyepetizerFlutterJson.asString(rows.first[dataColumn]),
    );
    if (decoded is! Map) return null;
    return EyepetizerFlutterBaseListData.fromJson(
      EyepetizerFlutterJson.asMap(decoded),
    );
  }

  @override
  String tableName() => tabName;

  @override
  String tableSql() =>
      'create table $tabName ($idColumn integer primary key autoincrement,'
      '$tagColumn text not null,$dataColumn text not null)';
}
