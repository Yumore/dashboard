import 'dart:convert';

import 'package:dashboard/features/reading/eso/eso_analyzer.dart';
import 'package:enough_convert/enough_convert.dart';
import 'package:html/dom.dart';

/// `@decode:` 规则解析器（移植 eso `lib/api/analyzer_decode.dart`）。
///
/// 支持 `base64`（先去掉换行与结尾引号）/ `gbk` / `utf8`。
class EsoAnalyzerDecode implements EsoAnalyzer {
  String _content = '';

  @override
  EsoAnalyzerDecode parse(dynamic content) {
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
    if (rule.startsWith('base64')) {
      var text = _content.trim().replaceAll('\n', '');
      if (text.endsWith('"')) text = text.substring(0, text.length - 1);
      return utf8.decode(base64Decode(text));
    } else if (rule.startsWith('gbk')) {
      return gbk.decoder.convert(utf8.encode(_content));
    } else if (rule.startsWith('utf8')) {
      return utf8.decode(_content.codeUnits);
    }
    return _content;
  }

  @override
  String getStringList(String rule) => getString(rule);
}
