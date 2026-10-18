import 'package:dashboard/features/reading/eso/eso_analyzer.dart';
import 'package:dashboard/features/reading/eso/eso_rule_exception.dart';

/// 需要 JS / Hetu / WebView 才能执行的规则（`@js:` `@hetu:` `@web:` `@webview:`）。
///
/// 宿主没有 `flutter_qjs` / `hetu_script_flutter` 依赖，也没有注入 WebView 的
/// 规则执行通道，所以这些规则一律抛出带原文的 [EsoRuleException]，
/// 由上层 `try/catch` 决定是跳过还是提示，绝不静默返回空串。
class EsoAnalyzerUnsupported implements EsoAnalyzer {
  EsoAnalyzerUnsupported(this.prefix, this.code);

  final String prefix;
  final String code;

  @override
  EsoAnalyzerUnsupported parse(dynamic content) => this;

  Never _fail() => throw EsoRuleException('宿主未移植 $prefix 规则引擎', rule: code);

  @override
  Never getString(String rule) => _fail();

  @override
  Never getStringList(String rule) => _fail();

  @override
  Never getElements(String rule) => _fail();
}
