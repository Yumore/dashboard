import 'package:dashboard/features/reading/eso/eso_analyzer.dart';
import 'package:html/dom.dart';

/// 正则解析器（移植 eso `lib/api/analyzer_regexp.dart`）。
///
/// 支持 `AND` 串联（前一次匹配结果内再匹配）、`&&` 并列、`||` 择一、`%%` 交叉。
class EsoAnalyzerRegExp implements EsoAnalyzer {
  String _string = '';

  @override
  EsoAnalyzerRegExp parse(dynamic content) {
    if (content is String) {
      _string = content;
    } else if (content is Document) {
      _string = content.outerHtml;
    } else if (content is Element) {
      _string = content.outerHtml;
    } else if (content is List<Element>) {
      _string = content.map((e) => e.outerHtml).join('\n');
    } else {
      _string = '$content';
    }
    return this;
  }

  List<String> _getList(String rule, String input) {
    var result = <String>[];
    if (rule.isEmpty) return result;

    var rules = <String>[];
    if (rule.contains('AND')) {
      rules = rule.split('AND');
    }

    if (rules.isNotEmpty) {
      for (final rl in rules) {
        result = _getList(rl, input);
        input = result.join('\n');
      }
    } else {
      final matcherList = RegExp(rule).allMatches(input);
      if (matcherList.isEmpty) return result;
      final builder = <String>[];
      for (final m in matcherList) {
        final value = m.group(0);
        if (value != null && value.isNotEmpty) {
          // 因为是正则匹配，所以不使用 trim() 去掉空格
          builder.add(value);
        }
      }
      result = builder;
    }
    return result;
  }

  @override
  List<String> getString(String rule) => _getList(rule, _string);

  @override
  List<String> getStringList(String rule) {
    final result = <String>[];
    if (rule.isEmpty) return result;

    if (rule.contains('&&')) {
      for (final rl in rule.split('&&')) {
        result.addAll(getStringList(rl));
      }
    } else if (rule.contains('||')) {
      for (final rl in rule.split('||')) {
        final stringList = getStringList(rl);
        if (stringList.isNotEmpty) return stringList;
      }
    } else if (rule.contains('%%')) {
      final results = <List<String>>[];
      for (final rl in rule.split('%%')) {
        results.add(getStringList(rl));
      }
      if (results.isNotEmpty) {
        for (var i = 0; i < results[0].length; i++) {
          for (final temp in results) {
            if (i < temp.length) {
              result.add(temp[i]);
            }
          }
        }
      }
    } else {
      return _getList(rule, _string);
    }
    return result;
  }

  @override
  List<String> getElements(String rule) => getStringList(rule);
}
