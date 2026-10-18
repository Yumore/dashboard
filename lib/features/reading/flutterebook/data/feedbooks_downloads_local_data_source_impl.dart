import 'dart:async';
import 'dart:convert';

import 'package:dashboard/features/reading/flutterebook/data/feedbooks_downloads_local_data_source.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// [FeedbooksDownloadsLocalDataSource] 的 shared_preferences 实现。
///
/// 存储形状：一个 JSON 对象，键是记录 id，值是源工程那张
/// `{'id','path','image','size','name'}` map。"merge: true" 用浅合并实现
/// ——源工程 `record.put(db, book, merge: true)` 的行为就是只覆盖传入的键。
class FeedbooksDownloadsLocalDataSourceImpl
    implements FeedbooksDownloadsLocalDataSource {
  FeedbooksDownloadsLocalDataSourceImpl({SharedPreferences? preferences})
    : _preferences = preferences;

  /// prefs 键。源工程用独立的 `download.db`，这里用带前缀的单键。
  static const String storageKey = 'flutterebook.downloads';

  SharedPreferences? _preferences;

  final StreamController<List<Map<String, dynamic>>> _controller =
      StreamController<List<Map<String, dynamic>>>.broadcast();

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
    _controller.add(_ordered(records));
  }

  Future<void> _remove(String id) async {
    final Map<String, Map<String, dynamic>> records = await _read();
    records.remove(id);
    await _write(records);
  }

  static List<Map<String, dynamic>> _ordered(
    Map<String, Map<String, dynamic>> records,
  ) => records.values.toList(growable: false);

  @override
  Future<void> addBook(Map<String, dynamic> book, String id) async {
    final Map<String, Map<String, dynamic>> records = await _read();
    final Map<String, dynamic> merged = <String, dynamic>{
      ...?records[id],
      ...book,
    };
    records[id] = merged;
    await _write(records);
  }

  @override
  Future<void> deleteBook(String id) => _remove(id);

  @override
  Future<void> deleteAllBooksWithId(String id) => _remove(id);

  @override
  Future<List<Map<String, dynamic>>> downloadList() async =>
      _ordered(await _read());

  @override
  Future<Map<String, dynamic>?> fetchBook(String id) async =>
      (await _read())[id];

  /// 订阅时先推一次当前快照。
  ///
  /// 源工程用的是 sembast `query().onSnapshots(db)`，订阅那一刻就会带出已有
  /// 记录；广播流本身不会补发历史事件，所以这里用 `Stream.multi` 手动补，
  /// 否则重启应用后下载列表要等到下一次写入才会出现。
  @override
  Future<Stream<List<Map<String, dynamic>>>> downloadListStream() async {
    return Stream<List<Map<String, dynamic>>>.multi(
      (MultiStreamController<List<Map<String, dynamic>>> multi) {
        downloadList().then(multi.add, onError: multi.addError);
        final StreamSubscription<List<Map<String, dynamic>>> subscription =
            _controller.stream.listen(multi.add, onError: multi.addError);
        multi.onCancel = subscription.cancel;
      },
    );
  }

  @override
  Future<void> clearBooks() async {
    final SharedPreferences prefs = await _prefs;
    await prefs.remove(storageKey);
    _controller.add(const <Map<String, dynamic>>[]);
  }

  /// 释放流控制器；宿主 controller 的 `dispose` 会调用。
  Future<void> dispose() async {
    await _controller.close();
  }
}
