import 'package:html/dom.dart';

/// 一次 XPath 查询的结果：命中的元素 + 末端 `@属性` / `text()` 取到的值。
///
/// 与 `xpath_selector` 的 `nodes` / `attrs` 同名语义，宿主缺少该依赖，
/// 由 [EsoXPath] 内置实现产出。
class EsoXPathQuery {
  const EsoXPathQuery(this.nodes, this.attrs);

  final List<Element> nodes;
  final List<String> attrs;
}
