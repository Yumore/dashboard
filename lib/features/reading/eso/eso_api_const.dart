/// 规则引擎用到的常量（移植 eso `lib/api/api_js_engine.dart` 的 `APIConst`
/// 与 `lib/global.dart` 的 `Global.fullSpace`）。
class EsoApiConst {
  /// 地址里是否带页码：`$page` 或独立的 `page` 单词。
  static final RegExp pagePattern =
      RegExp(r"""(\$page)|((^|[^a-zA-Z'"_/-])page([^a-zA-Z0-9'"]|$))""");

  /// 连续空白（用于把简介压成一行）。
  static final RegExp largeSpaceRegExp = RegExp(r'\n+\s*|\s{2,}');

  /// 分类分隔符。
  static final RegExp tagsSplitRegExp = RegExp(r'[　,/\|\&\%]+');

  /// 全角空格（`Global.fullSpace`）。
  static const String fullSpace = '　';
}
