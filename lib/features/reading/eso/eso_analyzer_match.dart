import 'dart:convert';

import 'package:dashboard/features/reading/eso/eso_analyzer.dart';
import 'package:html/dom.dart';

/// `@match:` 规则解析器（移植 eso `lib/api/analyzer_match.dart`）。
///
/// 规则形如 `正则` 或 `正则@@分组号`，多处匹配用两个半角空格连接。
class EsoAnalyzerMatch implements EsoAnalyzer {
  String _content = '';

  @override
  EsoAnalyzerMatch parse(dynamic content) {
    if (content is List || content is Map) {
      _content = jsonEncode(content);
    } else if (content is Element) {
      _content = content.outerHtml;
    } else if (content is List<Element>) {
      _content = content.map((e) => e.outerHtml).join('\n');
    } else {
      _content = '$content';
    }
    return this;
  }

  @override
  String getElements(String rule) => getString(rule);

  @override
  String getString(String rule) {
    if (rule.isEmpty) return '';
    final r = rule.split('@@');
    final group = r.length > 1 ? int.parse(r[1]) : 0;
    return RegExp(r[0]).allMatches(_content).map((m) => m.group(group)).join('  ');
  }

  @override
  String getStringList(String rule) => getString(rule);
}
