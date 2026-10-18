import 'package:dashboard/features/reading/eso/eso_xpath_query.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as parser;

class _EsoXPathStep {
  _EsoXPathStep(this.descendant, this.test, this.predicates);

  final bool descendant;
  final String test;
  final List<String> predicates;
}

/// eso `@xpath:` / 以 `/` 开头的规则所用的 XPath 子集引擎。
///
/// 支持：
/// * 轴：`//`（后代）、`/`（子节点）、省略前导斜杠按后代处理
/// * 节点测试：`tag`、`*`
/// * 谓词：`[n]`（从 1 开始）、`[@attr]`、`[@attr='v']`、`[@attr="v"]`、
///   `[contains(@attr,'v')]`、`[text()='v']`、`[contains(text(),'v')]`
/// * 结尾：`/@attr`、`/text()`、`/node()`
class EsoXPath {
  EsoXPath.html(String html) : _root = parser.parse(html).documentElement;

  EsoXPath.element(Element element) : _root = element;

  final Element? _root;

  /// 对应 `xpath_selector` 的 `XPath.html(x).query(rule)`。
  EsoXPathQuery query(String rule) {
    final root = _root;
    if (root == null) return const EsoXPathQuery(<Element>[], <String>[]);
    // 末端选择器 `@属性` / `text()` / `node()` 先剥掉，剩下的才是节点路径，
    // 否则会被当成子节点名解析（`xpath_selector` 的 `attrs` 语义）。
    var path = rule.trim();
    String? terminal;
    final lastSlash = path.lastIndexOf('/');
    if (lastSlash > 0) {
      final tail = path.substring(lastSlash + 1);
      if (tail.startsWith('@') || tail == 'text()' || tail == 'node()') {
        terminal = tail;
        path = path.substring(0, lastSlash);
      }
    }
    final steps = _parse(path);
    if (steps.isEmpty) return const EsoXPathQuery(<Element>[], <String>[]);

    var current = <Element>[];
    for (var i = 0; i < steps.length; i++) {
      final step = steps[i];
      final candidates = <Element>[];
      final pool = i == 0 ? <Element>[root] : current;
      for (final node in pool) {
        if (step.descendant) {
          if (i == 0) {
            if (_matchesName(node, step.test)) candidates.add(node);
          }
          for (final child in node.querySelectorAll('*')) {
            if (_matchesName(child, step.test)) candidates.add(child);
          }
        } else {
          for (final child in node.children) {
            if (_matchesName(child, step.test)) candidates.add(child);
          }
        }
      }
      var filtered = _dedupe(candidates);
      for (final predicate in step.predicates) {
        filtered = _applyPredicate(filtered, predicate);
      }
      current = filtered;
      if (current.isEmpty) break;
    }

    if (terminal != null && terminal.startsWith('@')) {
      final name = terminal.substring(1);
      final attrs = <String>[];
      for (final node in current) {
        final value = node.attributes[name];
        if (value != null) attrs.add(value);
      }
      return EsoXPathQuery(current, attrs);
    }
    if (terminal == 'text()') {
      return EsoXPathQuery(current, current.map((e) => e.text).toList());
    }
    if (terminal == 'node()') {
      return EsoXPathQuery(current, const <String>[]);
    }
    final last = steps.last;
    if (last.test.startsWith('@')) {
      final name = last.test.substring(1);
      final attrs = <String>[];
      for (final node in current) {
        final value = node.attributes[name];
        if (value != null) attrs.add(value);
      }
      return EsoXPathQuery(current, attrs);
    }
    if (last.test == 'text()') {
      return EsoXPathQuery(current, current.map((e) => e.text).toList());
    }
    return EsoXPathQuery(current, const <String>[]);
  }

  static List<_EsoXPathStep> _parse(String rule) {
    final s = rule.trim();
    final steps = <_EsoXPathStep>[];
    var pos = 0;
    var descendant = true;
    while (pos < s.length) {
      if (s[pos] == '/') {
        descendant = pos + 1 < s.length && s[pos + 1] == '/';
        pos += descendant ? 2 : 1;
      } else if (pos == 0) {
        descendant = true;
      }
      final testStart = pos;
      while (pos < s.length && s[pos] != '/' && s[pos] != '[') {
        pos++;
      }
      final test = s.substring(testStart, pos).trim();
      final predicates = <String>[];
      while (pos < s.length && s[pos] == '[') {
        final end = _closingBracket(s, pos);
        predicates.add(s.substring(pos + 1, end).trim());
        pos = end + 1;
      }
      if (test.isEmpty && predicates.isEmpty) break;
      steps.add(_EsoXPathStep(descendant, test, predicates));
    }
    return steps;
  }

  static int _closingBracket(String s, int open) {
    var depth = 0;
    for (var i = open; i < s.length; i++) {
      if (s[i] == '[') depth++;
      if (s[i] == ']') {
        depth--;
        if (depth == 0) return i;
      }
    }
    return s.length - 1;
  }

  static bool _matchesName(Element element, String test) {
    if (test.isEmpty) return false;
    if (test == '*') return true;
    if (test == 'node()') return true;
    return element.localName?.toLowerCase() == test.toLowerCase();
  }

  static List<Element> _dedupe(List<Element> input) {
    final seen = <Element>{};
    final result = <Element>[];
    for (final e in input) {
      if (seen.add(e)) result.add(e);
    }
    return result;
  }

  static List<Element> _applyPredicate(List<Element> input, String predicate) {
    final index = int.tryParse(predicate);
    if (index != null) {
      if (index >= 1 && index <= input.length) return <Element>[input[index - 1]];
      return <Element>[];
    }
    final contains = RegExp(
      r"""^contains\(\s*(@[\w:-]+|text\(\))\s*,\s*['"](.*)['"]\s*\)$""",
      dotAll: true,
    ).firstMatch(predicate);
    if (contains != null) {
      final target = contains.group(1)!;
      final needle = contains.group(2)!;
      return input.where((e) => _valueOf(e, target).contains(needle)).toList();
    }
    final equal = RegExp(
      r"""^(@[\w:-]+|text\(\))\s*=\s*['"](.*)['"]$""",
      dotAll: true,
    ).firstMatch(predicate);
    if (equal != null) {
      final target = equal.group(1)!;
      final expected = equal.group(2)!;
      return input.where((e) => _valueOf(e, target) == expected).toList();
    }
    final exists = RegExp(r'^@[\w:-]+$').firstMatch(predicate);
    if (exists != null) {
      final name = predicate.substring(1);
      return input.where((e) => e.attributes.containsKey(name)).toList();
    }
    return input;
  }

  static String _valueOf(Element element, String target) {
    if (target == 'text()') return element.text;
    if (target.startsWith('@')) return element.attributes[target.substring(1)] ?? '';
    return '';
  }

  /// `/only()` 结尾时对 innerHtml 的清理（逐字移植源实现）。
  static String onlyText(String innerHtml) {
    return innerHtml
        .replaceAll(RegExp(r'<([a-zA-Z0-9]+)[\s\S]+?/(\1)?>'), '')
        .replaceAll(RegExp(r'<.?br.?>'), '\n');
  }
}
