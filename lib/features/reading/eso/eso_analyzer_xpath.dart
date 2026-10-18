import 'package:dashboard/features/reading/eso/eso_analyzer.dart';
import 'package:dashboard/features/reading/eso/eso_xpath.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as parser;

/// `@xpath:` / 以 `/` 开头规则的解析器（移植 eso `lib/api/analyzer_xpath.dart`）。
class EsoAnalyzerXPath implements EsoAnalyzer {
  EsoXPath? _xpath;

  @override
  EsoAnalyzerXPath parse(dynamic content) {
    if (content is Element) {
      _xpath = EsoXPath.element(content);
    } else if (content is Document) {
      _xpath = EsoXPath.element(content.documentElement!);
    } else if (content is String) {
      _xpath = EsoXPath.html(content);
    } else {
      _xpath = EsoXPath.html(parser.parse('$content').documentElement!.outerHtml);
    }
    return this;
  }

  @override
  List<Element> getElements(String rule) => _xpath?.query(rule).nodes ?? <Element>[];

  List<String> getR(String rule) {
    final xpath = _xpath;
    if (xpath == null) return <String>[];
    rule = rule.trimRight();
    if (rule.endsWith('node()')) {
      return xpath.query(rule).nodes.map((e) => e.outerHtml).toList();
    } else if (rule.endsWith('/html()')) {
      return xpath
          .query(rule.substring(0, rule.length - 7))
          .nodes
          .map((e) => e.outerHtml)
          .toList();
    } else if (rule.endsWith('/only()')) {
      return xpath
          .query(rule.substring(0, rule.length - 7))
          .nodes
          .map((e) => EsoXPath.onlyText(e.innerHtml))
          .toList();
    }
    final nodes = xpath.query(rule);
    final attrs = nodes.attrs;
    if (attrs.isEmpty && !rule.contains('@') && !rule.contains('()')) {
      return nodes.nodes.map((e) => e.outerHtml).toList();
    }
    return attrs;
  }

  @override
  List<String> getString(String rule) => getR(rule);

  @override
  List<String> getStringList(String rule) => getR(rule);
}
