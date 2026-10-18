import 'dart:convert';

import 'package:dashboard/features/reading/flutterebook/data/feedbooks_xml_node.dart';
import 'package:dashboard/features/reading/flutterebook/data/feedbooks_xml_parser.dart';
import 'package:dashboard/features/reading/flutterebook/models/category_feed.dart';

/// 把 Feedbooks atom feed 变成源工程 `CategoryFeed.fromJson` 期待的那张 map。
///
/// 源工程用的是 `xml2json` 5.3.6 的 **GData** 格式：
///  * 元素名里的 `:` 换成 `$`（`dcterms:language` → `dcterms$language`）；
///  * 文本放进 `$t`，CDATA 放进 `__cdata`；
///  * 属性保留限定名里的冒号（`xml:lang`、`opds:activeFacet`、`thr:count`），
///    但命名空间声明写成 `xmlns` / `xmlns$前缀`；
///  * 同名子元素出现多次才是 List，只出现一次是 Map；
///  * 同一元素里多个文本段时**最后一个非空白段**胜出（已用 xml2json 5.3.6
///    实测确认：`<x>a<b>c</b>d</x>` → `{$t: 'd', b: {$t: 'c'}}`）；
///  * 纯空白文本被忽略（`<x>  </x>` → `{}`）。
///
/// 三处刻意的偏差（都在实现里做了取舍，见 README 式的注释与测试）：
/// 1. `<?xml version="1.0" encoding="UTF-8"?>` 会被解析成顶层的 `version` /
///    `encoding`。xml2json 5.3.6 实测**丢掉**了这两个键（它只处理
///    `XmlProcessing`，声明节点不在其中），而 [FeedbooksCategoryFeed] 正是为
///    它们准备的字段，所以这里按 GData 契约补上。
/// 2. 只声明了带前缀的命名空间、没有默认 `xmlns` 时，xml2json 会写入
///    `xmlns: [{}]`（List），这会让 `json['xmlns'] as String?` 抛类型错误；
///    这里直接不写 `xmlns`。
/// 3. 文本里的换行与反斜杠不再二次转义（xml2json 的 `escapeTextForJson` +
///    `jsonDecode` 会把一个换行变成两个反斜杠加 `n`，源工程 UI 再用
///    `replaceAll(r'\n', '\n')` 去补，移植版保持纯文本）。
class FeedbooksGdataConverter {
  FeedbooksGdataConverter({FeedbooksXmlParser? parser})
    : _parser = parser ?? FeedbooksXmlParser();

  final FeedbooksXmlParser _parser;

  /// GData 契约里的文本键。
  static const String textKey = r'$t';

  /// GData 契约里的 CDATA 键。
  static const String cdataKey = '__cdata';

  /// 解析 XML 并返回 GData map。
  Map<String, dynamic> toGData(String xml) {
    final FeedbooksXmlNode document = _parser.parse(xml);
    final Map<String, dynamic> result = <String, dynamic>{};
    // <?xml ...?>: version / encoding 落在顶层
    result.addAll(document.attributes);
    for (final FeedbooksXmlNode child in document.children) {
      result[child.name] = _convertElement(child);
    }
    return result;
  }

  /// GData 的 JSON 字符串形式（源工程先 `toGData()` 再 `jsonDecode`）。
  String toGDataString(String xml) => jsonEncode(toGData(xml));

  /// 源工程 `BookRepository.getCategory` 里的
  /// `CategoryFeed.fromJson(jsonDecode(xml2json.toGData()))`。
  FeedbooksCategoryFeed toCategoryFeed(String xml) =>
      FeedbooksCategoryFeed.fromJson(toGData(xml));

  Map<String, dynamic> _convertElement(FeedbooksXmlNode node) {
    final Map<String, dynamic> map = <String, dynamic>{};

    node.attributes.forEach((String name, String value) {
      map[_attributeKey(name)] = value;
    });

    final String? text = _lastSegment(node.texts);
    if (text != null) map[textKey] = text;

    final String? cdata = _lastSegment(node.cdata);
    if (cdata != null) map[cdataKey] = cdata;

    for (final FeedbooksXmlNode child in node.children) {
      final Map<String, dynamic> value = _convertElement(child);
      final String key = _elementKey(child.name);
      final Object? existing = map[key];
      if (existing == null) {
        map[key] = value;
      } else if (existing is List) {
        existing.add(value);
      } else {
        map[key] = <dynamic>[existing, value];
      }
    }
    return map;
  }

  /// 元素名里的 `:` 换成 `$`（`dcterms:language` → `dcterms$language`），
  /// 这是 GData 与 Badgerfish 的关键区别：**属性**保留冒号，**元素**换掉。
  static String _elementKey(String name) => name.replaceAll(':', r'$');

  /// `xmlns` 原样，`xmlns:dc` → `xmlns$dc`，其余属性的冒号保留。
  static String _attributeKey(String name) {
    if (name.startsWith('xmlns:')) {
      return 'xmlns\$${name.substring('xmlns:'.length)}';
    }
    return name;
  }

  static String? _lastSegment(List<String> segments) {
    for (int i = segments.length - 1; i >= 0; i--) {
      final String segment = segments[i];
      if (segment.trim().isNotEmpty) return segment;
    }
    return null;
  }
}
