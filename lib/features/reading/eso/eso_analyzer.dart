/// 规则解析器接口（移植 eso `lib/api/analyzer.dart`）。
///
/// 原作的 `getString` 允许返回 `List`——HTML 与 XPath 解析器就是返回列表，
/// 由 [EsoAnalyzerManager] 决定用双空格拼接，这里保留同样的宽松返回。
abstract class EsoAnalyzer {
  EsoAnalyzer parse(dynamic content);

  dynamic getString(String rule);

  dynamic getStringList(String rule);

  dynamic getElements(String rule);
}
