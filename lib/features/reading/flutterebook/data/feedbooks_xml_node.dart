/// 手写 XML 解析后的节点，[FeedbooksXmlParser] 的中间产物。
///
/// 只保留 GData 变换需要的信息：元素名、属性（原样保留限定名里的冒号）、
/// 文本段、CDATA 段、子节点。多条文本段必须分别保留，因为 GData 规则是
/// “最后一个非空白文本段胜出”（见 [FeedbooksGdataConverter]）。
class FeedbooksXmlNode {
  FeedbooksXmlNode(this.name);

  /// 元素名，未做任何重命名（`dcterms:language` 仍是 `dcterms:language`）。
  final String name;

  /// 属性表。处理指令里的伪属性也合并到这里，与 xml2json 的行为一致。
  final Map<String, String> attributes = <String, String>{};

  /// 文本段，按出现顺序；实体已解码。
  final List<String> texts = <String>[];

  /// CDATA 段，按出现顺序；内容不参与实体解码。
  final List<String> cdata = <String>[];

  final List<FeedbooksXmlNode> children = <FeedbooksXmlNode>[];

  /// `<x/>` 自闭合。
  bool selfClosed = false;

  @override
  String toString() => 'FeedbooksXmlNode($name)';
}
