import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// 搜索历史（移植 eso `lib/model/history_manager.dart` 的 `HistoryManager`）。
class EsoSearchHistoryStore {
  static const String storeKey = 'eso_search_history';

  List<String>? _searchHistory;

  Future<void> _ensureLoaded() async {
    if (_searchHistory != null) return;
    final prefs = await SharedPreferences.getInstance();
    _searchHistory = prefs.getStringList(storeKey) ?? <String>[];
  }

  Future<List<String>> getAll() async {
    await _ensureLoaded();
    return List<String>.from(_searchHistory!);
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(storeKey, _searchHistory!);
  }

  /// 新增一条：已存在则不重复添加，返回是否真的写入。
  Future<bool> newSearch(String keyWord) async {
    await _ensureLoaded();
    if (_searchHistory!.contains(keyWord)) return false;
    _searchHistory!.add(keyWord);
    await _save();
    return true;
  }

  Future<void> remove(String keyWord) async {
    await _ensureLoaded();
    _searchHistory!.removeWhere((element) => element == keyWord);
    await _save();
  }

  Future<void> clear() async {
    await _ensureLoaded();
    _searchHistory!.clear();
    await _save();
  }

  /// `clean` 为 true 时整份覆盖；否则只补齐缺失项（源实现的去重判断有缺陷，
  /// 这里保持「补齐缺失项」的可见行为）。
  Future<void> restore(List<dynamic> history, {bool clean = false}) async {
    await _ensureLoaded();
    final incoming = history.map((e) => '$e').toList();
    if (clean) {
      _searchHistory!
        ..clear()
        ..addAll(incoming);
    } else {
      for (final item in incoming) {
        if (!_searchHistory!.contains(item)) _searchHistory!.add(item);
      }
    }
    await _save();
  }

  Future<String> backup() async {
    await _ensureLoaded();
    return jsonEncode(_searchHistory);
  }
}
