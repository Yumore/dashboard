import 'package:dashboard/features/reading/eso/eso_analyzer.dart';

/// 拆分后的单条规则：解析器 + 规则串 + `##` 之后的替换规则。
class EsoSingleRule {
  const EsoSingleRule(this.analyzer, this.rule, this.replace);

  final EsoAnalyzer analyzer;
  final String rule;
  final String replace;
}
