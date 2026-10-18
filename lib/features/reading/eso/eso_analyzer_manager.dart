import 'package:dashboard/features/reading/eso/eso_analyzer.dart';
import 'package:dashboard/features/reading/eso/eso_analyzer_decode.dart';
import 'package:dashboard/features/reading/eso/eso_analyzer_encode.dart';
import 'package:dashboard/features/reading/eso/eso_analyzer_filter.dart';
import 'package:dashboard/features/reading/eso/eso_analyzer_html.dart';
import 'package:dashboard/features/reading/eso/eso_analyzer_jsonpath.dart';
import 'package:dashboard/features/reading/eso/eso_analyzer_match.dart';
import 'package:dashboard/features/reading/eso/eso_analyzer_regexp.dart';
import 'package:dashboard/features/reading/eso/eso_analyzer_replace.dart';
import 'package:dashboard/features/reading/eso/eso_analyzer_unsupported.dart';
import 'package:dashboard/features/reading/eso/eso_analyzer_xpath.dart';
import 'package:dashboard/features/reading/eso/eso_single_rule.dart';

/// 书源规则引擎（移植 eso `lib/api/analyzer_manager.dart`）。
///
/// 一条规则形如 `rule##replaceRegex##replacement##replaceFirst`，规则从后往前解析：
/// 后面的解析器吃前面解析器的输出。首规则解析原始内容（HTML/JSON），
/// 其余规则解析上一段结果。
class EsoAnalyzerManager {
  EsoAnalyzerManager(this._content, {this.host = ''});

  /// 规则前缀 + 首规则符号（`$` jsonpath、`/` xpath、`:` 正则）。
  static final RegExp ruleTypePattern = RegExp(
      r'@js:|@hetu:|@web:|@webview:|@css:|@json:|@http:|@xpath:'
      r'|@match:|@regex:|@regexp:|@filter:|@replace:|@encode:|@decode:|^',
      caseSensitive: false);

  /// `{{...}}` 字符串插值。
  static final RegExp expressionPattern = RegExp(r'\{\{(.*?)\}\}', dotAll: true);

  final dynamic _content;

  /// 书源 host，供 `@filter:` 相对地址补全使用。
  final String host;

  /// from https://github.com/dart-lang/sdk/issues/2336
  static String Function(Match) _replacement(String pattern) => (Match match) =>
      pattern.replaceAllMapped(RegExp(r'\$(\d+)'), (m) => match[int.parse(m[1]!)] ?? '');

  /// `##` 之后的替换规则：`正则##替换`、`正则##替换##仅替换一次`。
  String Function(String) replaceSmart(String replace) {
    if (replace.isEmpty) return (String s) => s;
    final r = replace.split('##');
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

  List<dynamic> _getElements(EsoSingleRule r, [String? rule]) {
    rule ??= r.rule;
    if (rule.contains('&&')) {
      final result = <dynamic>[];
      for (final rSimple in rule.split('&&')) {
        final temp = _getElements(r, rSimple);
        if (temp.isNotEmpty) result.addAll(temp);
      }
      return result;
    } else if (rule.contains('||')) {
      for (final rSimple in rule.split('||')) {
        final temp = _getElements(r, rSimple);
        if (temp.isNotEmpty) return temp;
      }
      return <dynamic>[];
    }
    final temp = r.analyzer.getElements(rule);
    if (temp is List) return temp;
    return <dynamic>[temp];
  }

  List<dynamic> getElements(String rule) {
    final result = <dynamic>[];
    if (rule.isEmpty) return result;
    rule = rule.trimLeft();
    var temp = _content;
    for (final r in splitRuleReversed(rule).reversed) {
      r.analyzer.parse(temp);
      temp = _getElements(r);
    }
    if (temp is List) {
      return temp.where((e) => e != null).toList();
    } else if (temp != null) {
      return <dynamic>[temp];
    }
    return result;
  }

  dynamic _getStringList(EsoSingleRule r, [String? rule]) {
    rule ??= r.rule;
    if (rule.contains('&&')) {
      final result = <String>[];
      for (final rSimple in rule.split('&&')) {
        final temp = _getStringList(r, rSimple);
        if (temp is List) {
          result.addAll(temp
              .where((e) => e != null)
              .map((s) => '$s'.trim())
              .where((s) => s.isNotEmpty));
        } else if (temp != null && '$temp'.trim().isNotEmpty) {
          result.add('$temp'.trim());
        }
      }
      return result;
    } else if (rule.contains('||')) {
      var result = <String>[];
      for (final rSimple in rule.split('||')) {
        final temp = _getStringList(r, rSimple);
        if (temp is List) {
          result = temp
              .where((e) => e != null)
              .map((s) => '$s'.trim())
              .where((s) => s.isNotEmpty)
              .toList();
        } else if (temp != null && '$temp'.trim().isNotEmpty) {
          result = <String>['$temp'.trim()];
        }
        if (result.isNotEmpty) return result;
      }
      return <String>[];
    }
    return r.analyzer.getStringList(rule);
  }

  List<String> getStringList(String rule) {
    var result = <String>[];
    if (rule.isEmpty) return result;
    rule = rule.trimLeft();

    final pLeft = rule.lastIndexOf('{{');
    final pRight = rule.lastIndexOf('}}');
    if (-1 < pLeft && pLeft < pRight) {
      var position = 0;
      int? minCount;
      final rs = <dynamic>[];
      for (final match in expressionPattern.allMatches(rule)) {
        rs.add(rule.substring(position, match.start));
        position = match.end;
        final temp = getStringList(match.group(1)!);
        if (temp.isEmpty) continue;
        if (temp.length == 1) {
          rs.add(temp[0]);
        } else {
          rs.add(temp);
          if (minCount == null || temp.length < minCount) {
            minCount = temp.length;
          }
        }
      }
      if (position < rule.length) {
        rs.add(rule.substring(position));
      }
      return List.generate(minCount ?? 1, (int i) {
        return rs.map((e) {
          if (e is String) return e;
          if (e is List<String>) return e[i];
          return '';
        }).join();
      });
    }

    var temp = result.isEmpty ? _content : result;
    for (final r in splitRuleReversed(rule).reversed) {
      r.analyzer.parse(temp);
      temp = _getStringList(r);
      if (r.replace.isNotEmpty) {
        if (temp is List) {
          temp = replaceSmart(r.replace)(temp.join('\n'));
        } else {
          temp = replaceSmart(r.replace)('$temp');
        }
      }
    }
    if (temp is List) {
      result = temp
          .where((e) => e != null)
          .map((s) => '$s'.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    } else if (temp != null) {
      result = <String>['$temp'.trim()];
    }
    return result;
  }

  String _getString(EsoSingleRule r, [String? rule]) {
    rule ??= r.rule;
    if (rule.contains('&&')) {
      final rs = <String>[];
      for (final rSimple in rule.split('&&')) {
        final temp = _getString(r, rSimple);
        if (temp.isNotEmpty) rs.add(temp);
      }
      return rs.join('  ');
    } else if (rule.contains('||')) {
      for (final rSimple in rule.split('||')) {
        final temp = _getString(r, rSimple);
        if (temp.isNotEmpty) return temp;
      }
      return '';
    }
    var result = '';
    final temp = r.analyzer.getString(rule);
    if (temp is List) {
      /// 使用双半角空格分隔
      result = temp
          .where((s) => s != null)
          .map((s) => '$s'.trim())
          .where((s) => s.isNotEmpty)
          .join('  ');
    } else if (temp != null) {
      result = '$temp'.trim();
    }
    return result.isEmpty ? '' : replaceSmart(r.replace)(result);
  }

  String getString(String rule) {
    var result = '';
    if (rule.isEmpty) return result;
    rule = rule.trimLeft();

    final pLeft = rule.lastIndexOf('{{');
    final pRight = rule.lastIndexOf('}}');
    if (-1 < pLeft && pLeft < pRight) {
      var position = 0;
      final rs = <String>[];
      for (final match in expressionPattern.allMatches(rule)) {
        rs.add(rule.substring(position, match.start));
        position = match.end;
        rs.add(getString(match.group(1)!));
      }
      if (position < rule.length) {
        rs.add(rule.substring(position));
      }
      return rs.join();
    }

    var first = true;
    for (final r in splitRuleReversed(rule).reversed) {
      if (first) {
        r.analyzer.parse(result.isNotEmpty ? result : _content);
        first = false;
      } else {
        r.analyzer.parse(result);
      }
      result = _getString(r);
    }
    return result;
  }

  /// 规则从后往前解析，返回顺序即“从后到前”。
  List<EsoSingleRule> splitRuleReversed(String rule) {
    final ruleList = <EsoSingleRule>[];
    var lastStart = rule.length;
    for (final m in ruleTypePattern.allMatches(rule).toList().reversed) {
      var r = rule.substring(m.start, lastStart).trimLeft();
      if (r.isEmpty) {
        lastStart = m.start;
        continue;
      }
      EsoAnalyzer? analyzer;
      switch (r[0]) {
        case r'$':
          analyzer = EsoAnalyzerJsonPath();
          break;
        case '@':
          if (r.startsWith(RegExp(r'@js:', caseSensitive: false))) {
            analyzer = EsoAnalyzerUnsupported('@js:', r.substring(4));
            r = r.substring(4);
          } else if (r.startsWith(RegExp(r'@hetu:', caseSensitive: false))) {
            analyzer = EsoAnalyzerUnsupported('@hetu:', r.substring(6));
            r = r.substring(6);
          } else if (r.startsWith(RegExp(r'@css:', caseSensitive: false))) {
            r = r.substring(5);
            analyzer = EsoAnalyzerHtml();
          } else if (r.startsWith(RegExp(r'@json:', caseSensitive: false))) {
            r = r.substring(6);
            analyzer = EsoAnalyzerJsonPath();
          } else if (r.startsWith(RegExp(r'@xpath:', caseSensitive: false))) {
            r = r.substring(7);
            analyzer = EsoAnalyzerXPath();
          } else if (r.startsWith(RegExp(r'@match:', caseSensitive: false))) {
            r = r.substring(7);
            analyzer = EsoAnalyzerMatch();
          } else if (r.startsWith(RegExp(r'@regex:', caseSensitive: false))) {
            r = r.substring(7);
            analyzer = EsoAnalyzerRegExp();
          } else if (r.startsWith(RegExp(r'@regexp:', caseSensitive: false))) {
            r = r.substring(8);
            analyzer = EsoAnalyzerRegExp();
          } else if (r.startsWith(RegExp(r'@filter:', caseSensitive: false))) {
            r = r.substring(8);
            analyzer = EsoAnalyzerFilter(host: host);
          } else if (r.startsWith(RegExp(r'@replace:', caseSensitive: false))) {
            r = r.substring(9);
            analyzer = EsoAnalyzerReplace();
          } else if (r.startsWith(RegExp(r'@encode:', caseSensitive: false))) {
            r = r.substring(8);
            analyzer = EsoAnalyzerEncode();
          } else if (r.startsWith(RegExp(r'@decode:', caseSensitive: false))) {
            r = r.substring(8);
            analyzer = EsoAnalyzerDecode();
          } else if (r.startsWith(RegExp(r'@http:', caseSensitive: false))) {
            analyzer = EsoAnalyzerUnsupported('@http:', r);
          } else if (r.startsWith(RegExp(r'@webview:', caseSensitive: false))) {
            analyzer = EsoAnalyzerUnsupported('@webview:', r.substring(9));
            r = r.substring(9);
          } else if (r.startsWith(RegExp(r'@web:', caseSensitive: false))) {
            analyzer = EsoAnalyzerUnsupported('@web:', r.substring(5));
            r = r.substring(5);
          }
          break;
        case ':':
          r = r.substring(1);
          analyzer = EsoAnalyzerRegExp();
          break;
        case '/':
          analyzer = EsoAnalyzerXPath();
          break;
        default:
          analyzer = EsoAnalyzerHtml();
      }
      final target = analyzer ?? EsoAnalyzerUnsupported('@?', r);
      final position = r.indexOf('##');
      if (target is! EsoAnalyzerUnsupported && position > -1) {
        ruleList.add(EsoSingleRule(
            target, r.substring(0, position), r.substring(position + 2)));
      } else {
        ruleList.add(EsoSingleRule(target, r, ''));
      }
      lastStart = m.start;
    }
    return ruleList;
  }
}
