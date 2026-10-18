import 'dart:convert';

import 'package:dashboard/features/reading/eso/eso_rule.dart';
import 'package:dashboard/features/reading/eso/eso_rule_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 书源持久化（移植 eso 的 floor `ruleDao` + `Rule.backupRules/restore`）。
///
/// 宿主没有 `floor`，改用 shared_preferences 保存一个 JSON 数组；
/// 每条规则用 `toJson(true)` 落盘以便连 cookie 一起保存。
class EsoRuleStore implements EsoRuleProvider {
  static const String storeKey = 'eso_rule_store';

  @override
  Future<List<EsoRule>> getAllRules() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(storeKey);
    final rules = _decodeRules(raw);
    rules.sort((a, b) => b.modifiedTime.compareTo(a.modifiedTime));
    return rules;
  }

  @override
  Future<EsoRule?> findRuleById(String? id) async {
    if (id == null || id.isEmpty) return null;
    for (final rule in await getAllRules()) {
      if (rule.id == id) return rule;
    }
    return null;
  }

  Future<void> insertOrUpdate(EsoRule rule) async {
    final rules = await getAllRules();
    rules.removeWhere((element) => element.id == rule.id);
    rules.add(rule);
    await saveAll(rules);
  }

  Future<void> saveAll(List<EsoRule> rules) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(storeKey, backup(rules));
  }

  Future<void> remove(Set<String> ids) async {
    final rules = await getAllRules();
    rules.removeWhere((element) => ids.contains(element.id));
    await saveAll(rules);
  }

  /// 导出（对应 `Rule.backupRules`）：`jsonEncode` 一个规则数组。
  String backup(List<EsoRule> rules) =>
      jsonEncode(rules.map((e) => e.toJson(true)).toList());

  /// 导入（对应 `Rule.restore`）：解析失败返回 false；`reset` 为 true 时覆盖。
  Future<bool> restore(String data, {bool reset = false}) async {
    final rules = _decodeRules(data);
    if (rules.isEmpty) return false;
    if (reset) {
      await saveAll(rules);
      return true;
    }
    final all = await getAllRules();
    final ids = all.map((e) => e.id).toSet();
    for (final rule in rules) {
      if (!ids.contains(rule.id)) all.add(rule);
    }
    await saveAll(all);
    return true;
  }

  List<EsoRule> _decodeRules(String? raw) {
    if (raw == null || raw.trim().isEmpty) return <EsoRule>[];
    try {
      final dynamic data = jsonDecode(raw);
      if (data is List) {
        return data
            .map((e) => EsoRule.fromJson(e))
            .where((e) => e.id.isNotEmpty)
            .toList();
      }
    } catch (e) {
      // 数据损坏时按空处理
    }
    return <EsoRule>[];
  }
}
