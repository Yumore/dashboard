import 'package:dashboard/features/reading/eso/eso_analyzer.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as parser;

/// HTML/CSS 规则解析器（移植 eso `lib/api/analyzer_html.dart`）。
class EsoAnalyzerHtml implements EsoAnalyzer {
  Element? _element;

  @override
  EsoAnalyzerHtml parse(dynamic content) {
    if (content is Element) {
      _element = content;
    } else if (content is Document) {
      _element = content.documentElement;
    } else if (content is String) {
      _element = parser.parse(content).documentElement;
    } else if (content is List<String>) {
      _element = parser.parse(content.join('\n')).documentElement;
    } else if (content is List<Element>) {
      if (content.length == 1) {
        _element = content.first;
      } else {
        _element =
            parser.parse(content.map((e) => e.outerHtml).join('\n')).documentElement;
      }
    } else if (content is List) {
      _element = parser.parse(content.join('\n')).documentElement;
    } else {
      _element = parser.parse('$content').documentElement;
    }
    return this;
  }

  /// 网页编码转文本：去掉 script/style；img 单独成段；块级元素换行；其余标签移除。
  ///
  /// 块级元素见 https://developer.mozilla.org/zh-CN/docs/Web/HTML/Block-level_elements
  static String getHtmlString(String outerHtml) {
    final imgReg = RegExp(r'<img[^>]*>');
    final html = outerHtml
        .replaceAllMapped(imgReg, (match) => '\n${match.group(0)}\n')
        .replaceAll(RegExp(r'</?(?:div|p|br|hr|h\d|article|dd|dl)[^>]*>'), '\n');
    return html.splitMapJoin(
      imgReg,
      onMatch: (match) => '${match.group(0)}\n',
      onNonMatch: (noMatch) => noMatch.trim().isEmpty
          ? ''
          : '${parser.parse(noMatch).documentElement?.text ?? ''}\n',
    );
  }

  String _getResult(Element e, String lastRule) {
    switch (lastRule) {
      case 'text':
        return e.text.trim();
      case 'textNodes':
        return e.children
            .map((e) => e.text)
            .where((e) => e.isNotEmpty)
            .join('\n')
            .trim();
      case 'id':
        return e.id;
      case 'outerHtml':
        return e.outerHtml.trim();
      case 'innerHtml':
        return e.innerHtml.trim();
      case 'html':
        e.querySelectorAll('script,style').forEach((element) => element.remove());
        return getHtmlString(e.outerHtml);
      default:
        final r = e.attributes[lastRule];
        return r == null ? '' : r.trim();
    }
  }

  /// 与源实现一致：`getString` 直接返回列表。
  @override
  List<String> getString(String rule) => getStringList(rule);

  @override
  List<String> getStringList(String rule) {
    final element = _element;
    if (element == null) return <String>[];
    if (!rule.contains('@')) {
      return <String>[_getResult(element, rule)];
    }
    final result = <String>[];
    final split = rule.lastIndexOf('@');
    final lastRule = rule.substring(split + 1);
    final elementList = element.querySelectorAll(rule.substring(0, split));
    for (final e in elementList) {
      final r = _getResult(e, lastRule);
      if (r.isNotEmpty) result.add(r);
    }
    return result;
  }

  @override
  List<Element> getElements(String rule) => _element?.querySelectorAll(rule) ?? <Element>[];
}
