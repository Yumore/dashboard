import 'package:dashboard/features/reading/eso/eso_rule.dart';

/// 书源仓库接口（对应 eso 的 `ruleDao`），供 [EsoApiManager] 按 id 取源。
abstract class EsoRuleProvider {
  Future<List<EsoRule>> getAllRules();

  Future<EsoRule?> findRuleById(String? id);
}
