import 'dart:async';
import 'dart:convert';

import 'package:dashboard/features/reading/flutterebook/data/feedbooks_favorites_local_data_source.dart';
import 'package:dashboard/features/reading/flutterebook/models/entry.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// [FeedbooksFavoritesLocalDataSource] 的 shared_preferences 实现。
///
/// 存储形状：一个 JSON 对象，键是 id，值是 `Entry.toJson()` 的输出。
class FeedbooksFavoritesLocalDataSourceImpl
    implements FeedbooksFavoritesLocalDataSource {
  FeedbooksFavoritesLocalDataSourceImpl({SharedPreferences? preferences})
    : _preferences = preferences;

  /// prefs 键。源工程用独立的 `favorites11.db`。
  static const String storageKey = 'flutterebook.favorites';

  SharedPreferences? _preferences;

  final StreamController<List<FeedbooksEntry>> _controller =
      StreamController<List<FeedbooksEntry>>.broadcast();

  Future<SharedPreferences> get _prefs async =>
      _preferences ??= await SharedPreferences.getInstance();

  Future<Map<String, Map<String, dynamic>>> _read() async {
    final SharedPreferences prefs = await _prefs;
    final String? raw = prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) {
      return <String, Map<String, dynamic>>{};
    }
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! Map) return <String, Map<String, dynamic>>{};
      return decoded.map(
        (Object? key, Object? value) => MapEntry<String, Map<String, dynamic>>(
          key.toString(),
          value is Map
              ? value.map(
                  (Object? k, Object? v) =>
                      MapEntry<String, dynamic>(k.toString(), v),
                )
              : <String, dynamic>{},
        ),
      );
    } on FormatException {
      return <String, Map<String, dynamic>>{};
    }
  }

  Future<void> _write(Map<String, Map<String, dynamic>> records) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setString(storageKey, jsonEncode(records));
    _controller.add(_toEntries(records));
  }

  static List<FeedbooksEntry> _toEntries(
    Map<String, Map<String, dynamic>> records,
  ) => records.values.map(FeedbooksEntry.fromJson).toList(growable: false);

  @override
  Future<void> addBook(FeedbooksEntry book, String id) async {
    final Map<String, Map<String, dynamic>> records = await _read();
    records[id] = book.toJson();
    await _write(records);
  }

  @override
  Future<void> deleteBook(String id) async {
    final Map<String, Map<String, dynamic>> records = await _read();
    records.remove(id);
    await _write(records);
  }

  /// 订阅时先推一次当前快照（源工程 sembast `onSnapshots` 的行为）。
  @override
  Future<Stream<List<FeedbooksEntry>>> favoritesListStream() async {
    return Stream<List<FeedbooksEntry>>.multi(
      (MultiStreamController<List<FeedbooksEntry>> multi) {
        _read().then(
          (Map<String, Map<String, dynamic>> records) =>
              multi.add(_toEntries(records)),
          onError: multi.addError,
        );
        final StreamSubscription<List<FeedbooksEntry>> subscription =
            _controller.stream.listen(multi.add, onError: multi.addError);
        multi.onCancel = subscription.cancel;
      },
    );
  }

  @override
  Future<void> clearBooks() async {
    final SharedPreferences prefs = await _prefs;
    await prefs.remove(storageKey);
    _controller.add(const <FeedbooksEntry>[]);
  }

  /// 释放流控制器；宿主 controller 的 `dispose` 会调用。
  Future<void> dispose() async {
    await _controller.close();
  }
}
