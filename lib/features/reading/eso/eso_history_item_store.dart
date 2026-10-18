import 'dart:convert';

import 'package:dashboard/features/reading/eso/eso_search_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 书架 / 阅读记录（移植 eso `lib/database/history_item_manager.dart`）。
///
/// 与源实现一致：落盘时用 `SearchItem.fromJson(toJson())`，也就是**不保存**
/// 目录列表（`chapters` 始终为空），打开时再重新拉取目录。
class EsoHistoryItemStore {
  static const String storeKey = 'eso_history_items';

  Future<List<EsoSearchItem>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(storeKey);
    if (raw == null || raw.trim().isEmpty) return <EsoSearchItem>[];
    try {
      final dynamic data = jsonDecode(raw);
      if (data is List) {
        return data
            .whereType<Map>()
            .map((e) => EsoSearchItem.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (e) {
      // 数据损坏时按空处理
    }
    return <EsoSearchItem>[];
  }

  /// 按名称（可空）与内容类型（可空）过滤，按最后阅读时间倒序。
  Future<List<EsoSearchItem>> getHistoryItemByType(
      String? name, int? contentType) async {
    final items = await getAll();
    return items.where((element) {
      if (contentType != null && element.ruleContentType != contentType) {
        return false;
      }
      return element.name?.contains(name ?? '') ?? false;
    }).toList()
      ..sort((a, b) => (b.lastReadTime ?? 0).compareTo(a.lastReadTime ?? 0));
  }

  Future<void> _saveAll(List<EsoSearchItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        storeKey, jsonEncode(items.map((e) => e.toJson()).toList()));
  }

  /// 新增 / 更新一条阅读记录。
  Future<void> insertOrUpdateHistoryItem(EsoSearchItem searchItem) async {
    final items = await getAll();
    items.removeWhere((element) => element.id == searchItem.id);
    items.add(EsoSearchItem.fromJson(searchItem.toJson()));
    await _saveAll(items);
  }

  Future<void> removeSearchItem(Set<int> ids) async {
    final items = await getAll();
    items.removeWhere((element) => ids.contains(element.id));
    await _saveAll(items);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(storeKey);
  }

  Future<String> backup() async {
    return jsonEncode((await getAll()).map((e) => e.toJson()).toList());
  }

  /// 还原：只接受非空数组。
  Future<bool> restore(String data) async {
    final dynamic decoded = jsonDecode(data);
    if (decoded is! List || decoded.isEmpty) return false;
    final items = decoded
        .whereType<Map>()
        .map((e) => EsoSearchItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    await _saveAll(items);
    return true;
  }
}
