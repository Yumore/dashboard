import 'dart:convert';

import 'package:dashboard/features/reading/eso/eso_analyzer.dart';
import 'package:html/dom.dart';

/// `@replace:` 规则解析器（移植 eso `lib/api/analyzer_replace.dart`）。
///
/// 规则形如 `匹配正则@@替换文本`，替换文本中 `$1` 引用分组；
/// 出现第三段（`@@` 第二次）时只替换第一处。
class EsoAnalyzerReplace implements EsoAnalyzer {
  String _content = '';

  @override
  EsoAnalyzerReplace parse(dynamic content) {
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

  /// from https://github.com/dart-lang/sdk/issues/2336
  String Function(Match) _replacement(String pattern) => (Match match) =>
      pattern.replaceAllMapped(RegExp(r'\$(\d+)'), (m) => match[int.parse(m[1]!)] ?? '');

  String Function(String) replaceSmart(String replace) {
    if (replace.isEmpty) return (String s) => s;
    final r = replace.split('@@');
    final match = RegExp(r[0]);
    if (r.length == 1) {
      return (String s) => s.replaceAll(match, '');
    }
    final pattern = r[1];
    if (pattern.contains(r'$')) {
      if (r.length == 2) {
        return (String s) => s.replaceAllMapped(match, _replacement(pattern));
      }
      return (String s) => s.replaceFirstMapped(match, _replacement(pattern));
    }
    if (r.length == 2) {
      return (String s) => s.replaceAll(match, pattern);
    }
    return (String s) => s.replaceFirst(match, pattern);
  }

  @override
  String getString(String rule) => replaceSmart(rule)(_content);

  @override
  String getStringList(String rule) => getString(rule);
}
