import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dashboard/features/reading/eso/eso_analyzer.dart';
import 'package:enough_convert/enough_convert.dart';
import 'package:html/dom.dart';

/// `@encode:` 规则解析器（移植 eso `lib/api/analyzer_encode.dart`）。
///
/// 支持 `base64` / `md5` / `utf8` / `gbk`。
/// 源实现 gbk 分支误用规则串做输入（`gbk.encoder.convert(rule)`），
/// 这里改为编码正文，属于对源缺陷的修正。
class EsoAnalyzerEncode implements EsoAnalyzer {
  String _content = '';

  @override
  EsoAnalyzerEncode parse(dynamic content) {
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
      return base64Encode(utf8.encode(_content));
    } else if (rule.startsWith('md5')) {
      return md5.convert(utf8.encode(_content)).toString();
    } else if (rule.startsWith('utf8')) {
      return String.fromCharCodes(utf8.encode(_content));
    } else if (rule.startsWith('gbk')) {
      return String.fromCharCodes(gbk.encoder.convert(_content));
    }
    return _content;
  }

  @override
  String getStringList(String rule) => getString(rule);
}
