import 'dart:convert';

import 'package:dashboard/features/reading/easymygo/rule/rule_exception.dart';
import 'package:dashboard/features/reading/easymygo/rule/rule_scope.dart';
import 'package:dashboard/features/reading/easymygo/rule/source_action.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;

/// Ported from `HtmlQuerySelector` (`lib/plugin/source/utils/action/impl/`).
///
/// Original funcNames: `text`, `innerHtml`, `outerHtml`. `attr`, `attrs`,
/// `allText` and `allAttr` are added by the port because EasyMyGo sources used
/// to reach for a second JS step to read `href` / `src`; with no JS layer the
/// extractor has to expose those directly.
class HtmlSelectorAction extends SourceAction {
  const HtmlSelectorAction();

  @override
  String get clazz => 'HtmlQuerySelector';

  @override
  int get constructorArgsCount => 2;

  @override
  List<String> get funcNames => const <String>[
    'text',
    'innerHtml',
    'outerHtml',
    'attr',
    'attrs',
    'allText',
    'allAttr',
  ];

  @override
  String execute(
    RuleScope scope,
    String funcName,
    List<String> constructorArgs,
    List<String> args,
  ) {
    final content = constructorArgs.isNotEmpty ? constructorArgs.first : '';
    final selector = constructorArgs.length > 1 ? constructorArgs[1] : '';
    if (content.isEmpty || selector.isEmpty) {
      throw const RuleException('HtmlQuerySelector 参数为空');
    }
    final document = html_parser.parse(content);
    final elements = document.querySelectorAll(selector);
    final first = elements.isEmpty ? null : elements.first;
    switch (funcName) {
      case 'text':
        return first?.text ?? '';
      case 'innerHtml':
        return first?.innerHtml ?? '';
      case 'outerHtml':
        return first?.outerHtml ?? '';
      case 'attr':
        final name = args.isNotEmpty ? args.first : '';
        if (first == null || name.isEmpty) return '';
        return first.attributes[name] ?? '';
      case 'attrs':
        if (first == null) return '{}';
        return jsonEncode(stringAttributes(first));
      case 'allText':
        return jsonEncode(elements.map((e) => e.text).toList());
      case 'allAttr':
        final name = args.isNotEmpty ? args.first : '';
        if (name.isEmpty) return '[]';
        return jsonEncode(
          elements.map((e) => e.attributes[name] ?? '').toList(),
        );
    }
    throw RuleException('HtmlQuerySelector 不支持 $funcName');
  }
}

/// `dom.Element.attributes` is keyed by `Object`; the buffer only carries strings.
Map<String, String> stringAttributes(dom.Element element) => <String, String>{
  for (final entry in element.attributes.entries) '${entry.key}': entry.value,
};
