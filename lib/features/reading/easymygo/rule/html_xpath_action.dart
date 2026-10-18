import 'dart:convert';

import 'package:dashboard/features/reading/easymygo/rule/html_selector_action.dart';
import 'package:dashboard/features/reading/easymygo/rule/rule_exception.dart';
import 'package:dashboard/features/reading/easymygo/rule/rule_scope.dart';
import 'package:dashboard/features/reading/easymygo/rule/source_action.dart';
import 'package:dashboard/features/reading/easymygo/rule/xpath_to_css.dart';
import 'package:html/parser.dart' as html_parser;

/// Ported from `HtmlXPath` (`lib/plugin/source/utils/action/impl/`), which used
/// `xpath_selector_html_parser`'s `HtmlXPath(...).queryXPath(selector)` and
/// exposed `attrs` / `attr` / `allHtml` / `outerHtml` / `text`.
///
/// The host has no XPath dependency, so the selector is translated to CSS by
/// [xpathToCss] first (see that file for the supported subset) and the rest of
/// the semantics are preserved.
class HtmlXpathAction extends SourceAction {
  const HtmlXpathAction();

  @override
  String get clazz => 'HtmlXPath';

  @override
  int get constructorArgsCount => 2;

  @override
  List<String> get funcNames => const <String>[
    'attrs',
    'attr',
    'allHtml',
    'outerHtml',
    'text',
  ];

  @override
  String execute(
    RuleScope scope,
    String funcName,
    List<String> constructorArgs,
    List<String> args,
  ) {
    final content = constructorArgs.isNotEmpty ? constructorArgs.first : '';
    final xpath = constructorArgs.length > 1 ? constructorArgs[1] : '';
    if (content.isEmpty || xpath.isEmpty) {
      throw const RuleException('HtmlXPath 参数为空');
    }
    final selector = xpathToCss(xpath);
    if (selector.isEmpty) {
      return switch (funcName) {
        'attrs' => '{}',
        'allHtml' => '[]',
        _ => '',
      };
    }
    final document = html_parser.parse(content);
    final elements = document.querySelectorAll(selector);
    final first = elements.isEmpty ? null : elements.first;
    switch (funcName) {
      case 'attrs':
        if (first == null) return '{}';
        return jsonEncode(stringAttributes(first));
      case 'attr':
        if (first == null) return '';
        if (args.isNotEmpty) return first.attributes[args.first] ?? '';
        return first.attributes.values.isEmpty
            ? ''
            : first.attributes.values.first;
      case 'allHtml':
        return jsonEncode(elements.map((e) => e.outerHtml).toList());
      case 'outerHtml':
        return first?.outerHtml ?? '';
      case 'text':
        return first?.text ?? '';
    }
    throw RuleException('HtmlXPath 不支持 $funcName');
  }
}
