import 'dart:convert';

import 'package:dashboard/features/reading/eso/eso_analyzer.dart';
import 'package:dashboard/features/reading/eso/eso_json_path.dart';

/// `@json:` / 以 `$` 开头规则的解析器（移植 eso `lib/api/analyzer_jsonpath.dart`）。
class EsoAnalyzerJsonPath implements EsoAnalyzer {
  static final RegExp _jsonRulePattern = RegExp(r'\{(\$\.[^\}]+)\}');

  dynamic _ctx;

  @override
  EsoAnalyzerJsonPath parse(dynamic content) {
    if (content is List || content is Map) {
      _ctx = content;
    } else {
      try {
        _ctx = jsonDecode('$content'.replaceAll(RegExp(r',\s*(?=\]|\})'), ''));
      } catch (e) {
        _ctx = <String>['$content'];
      }
    }
    return this;
  }

  @override
  dynamic getElements(String rule) {
    final list = EsoJsonPath(rule).readValues(_ctx);
    if (list.isEmpty) return <String>[];
    if (list.length == 1) return list[0];
    return list;
  }

  @override
  String getString(String rule) {
    if (rule.contains(r'{$.')) {
      return rule.splitMapJoin(
        _jsonRulePattern,
        onMatch: (match) => getString(match.group(1)!),
        onNonMatch: (nonMatch) => nonMatch,
      );
    }
    return EsoJsonPath(rule).readValues(_ctx).join('  ');
  }

  @override
  dynamic getStringList(String rule) => getElements(rule);
}
