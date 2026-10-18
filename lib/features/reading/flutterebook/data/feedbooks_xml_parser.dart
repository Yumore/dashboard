import 'package:dashboard/features/reading/flutterebook/data/feedbooks_xml_node.dart';

/// 极简 XML 解析器，替换源工程依赖的 `xml2json`（宿主 pubspec 没有该包）。
///
/// 只覆盖 Feedbooks atom feed 需要的语法子集：
/// 元素 / 属性（单双引号）/ 自闭合 / 文本 / CDATA / 注释 / 处理指令 /
/// 实体引用（`&amp;` `&lt;` `&gt;` `&quot;` `&apos;` `&#65;` `&#x42;`）。
/// 命名空间前缀原样保留（GData 变换之后再改名）。
///
/// 与 `xml` + `xml2json` 的两点差异（都在 [FeedbooksGdataConverter] 里有说明）：
///  * 不校验良构性，畸形 XML 尽量解析而不是抛异常；
///  * 不展开 DTD，`<!DOCTYPE ...>` 整段跳过。
class FeedbooksXmlParser {
  /// 文档节点的名字；`FeedbooksGdataConverter` 用它承载 `<?xml ...?>` 里的
  /// `version` / `encoding`。
  static const String documentName = '#document';

  late String _source;
  int _pos = 0;
  int _length = 0;

  FeedbooksXmlNode parse(String xml) {
    _source = xml;
    _pos = 0;
    _length = xml.length;

    final FeedbooksXmlNode document = FeedbooksXmlNode(documentName);
    // BOM
    if (_startsWith('\uFEFF')) _pos++;

    while (_pos < _length) {
      _skipWhitespace();
      if (_pos >= _length) break;
      if (_startsWith('<!--')) {
        _skipComment();
        continue;
      }
      if (_startsWith('<?')) {
        _readProcessingInstruction(document);
        continue;
      }
      if (_startsWith('<!')) {
        _skipDeclaration();
        continue;
      }
      if (_startsWith('<')) {
        document.children.add(_parseElement());
        continue;
      }
      // 文档级游离文本：丢弃（与“只有根元素”的 atom feed 无关）
      _pos++;
    }
    return document;
  }

  FeedbooksXmlNode _parseElement() {
    _expect('<');
    final FeedbooksXmlNode node = FeedbooksXmlNode(_readName());
    _readAttributes(node);
    if (!node.selfClosed) _readContent(node);
    return node;
  }

  void _readAttributes(FeedbooksXmlNode node) {
    while (_pos < _length) {
      _skipWhitespace();
      if (_startsWith('/>')) {
        _pos += 2;
        node.selfClosed = true;
        return;
      }
      if (_startsWith('>')) {
        _pos += 1;
        return;
      }
      final String name = _readName();
      if (name.isEmpty) {
        // 非法字符，跳过以免死循环
        _pos++;
        continue;
      }
      _skipWhitespace();
      String value = '';
      if (_startsWith('=')) {
        _pos++;
        _skipWhitespace();
        value = _readAttributeValue();
      }
      node.attributes[name] = value;
    }
  }

  void _readContent(FeedbooksXmlNode node) {
    final StringBuffer buffer = StringBuffer();

    void flush() {
      if (buffer.isNotEmpty) {
        node.texts.add(buffer.toString());
        buffer.clear();
      }
    }

    while (_pos < _length) {
      if (_startsWith('</')) {
        _pos += 2;
        _readName();
        _skipWhitespace();
        if (_startsWith('>')) _pos++;
        flush();
        return;
      }
      if (_startsWith('<![CDATA[')) {
        flush();
        _pos += 9;
        final int end = _source.indexOf(']]>', _pos);
        if (end == -1) {
          node.cdata.add(_source.substring(_pos));
          _pos = _length;
          return;
        }
        node.cdata.add(_source.substring(_pos, end));
        _pos = end + 3;
        continue;
      }
      if (_startsWith('<!--')) {
        flush();
        _skipComment();
        continue;
      }
      if (_startsWith('<?')) {
        flush();
        _readProcessingInstruction(node);
        continue;
      }
      if (_startsWith('<!')) {
        flush();
        _skipDeclaration();
        continue;
      }
      if (_startsWith('<')) {
        flush();
        node.children.add(_parseElement());
        continue;
      }
      buffer.write(_readTextChunk());
    }
    flush();
  }

  String _readAttributeValue() {
    if (_startsWith('"') || _startsWith("'")) {
      final String quote = _source[_pos];
      _pos++;
      final int end = _source.indexOf(quote, _pos);
      if (end == -1) {
        final String rest = _decode(_source.substring(_pos));
        _pos = _length;
        return rest;
      }
      final String raw = _source.substring(_pos, end);
      _pos = end + 1;
      return _decode(raw);
    }
    final int start = _pos;
    while (_pos < _length) {
      final String c = _source[_pos];
      if (c == ' ' || c == '\t' || c == '\n' || c == '\r' || c == '>' ||
          c == '/') {
        break;
      }
      _pos++;
    }
    return _decode(_source.substring(start, _pos));
  }

  String _readTextChunk() {
    final int start = _pos;
    while (_pos < _length &&
        _source[_pos] != '<' &&
        _source[_pos] != '&') {
      _pos++;
    }
    if (_pos > start) return _source.substring(start, _pos);

    // 当前位置是 '&'
    final int end = _source.indexOf(';', _pos);
    if (end == -1 || end - _pos > 12) {
      _pos++;
      return '&';
    }
    final String? decoded = _decodeEntity(_source.substring(_pos + 1, end));
    if (decoded == null) {
      // 未知实体：原样保留
      _pos++;
      return '&';
    }
    _pos = end + 1;
    return decoded;
  }

  void _readProcessingInstruction(FeedbooksXmlNode node) {
    _pos += 2;
    final int end = _source.indexOf('?>', _pos);
    if (end == -1) {
      _pos = _length;
      return;
    }
    final String body = _source.substring(_pos, end);
    _pos = end + 2;
    node.attributes.addAll(_parsePseudoAttributes(body));
  }

  /// `<?xml version="1.0" encoding="UTF-8"?>` /
  /// `<?custom foo="bar"?>` → `{version: 1.0, encoding: UTF-8}` / `{foo: bar}`。
  static Map<String, String> _parsePseudoAttributes(String body) {
    final Map<String, String> attributes = <String, String>{};
    for (final String token in body.split(RegExp(r'\s+'))) {
      final int equals = token.indexOf('=');
      if (equals <= 0) continue;
      final String key = token.substring(0, equals);
      String value = token.substring(equals + 1);
      if (value.length >= 2 &&
          ((value.startsWith('"') && value.endsWith('"')) ||
              (value.startsWith("'") && value.endsWith("'")))) {
        value = value.substring(1, value.length - 1);
      }
      attributes[key] = value;
    }
    return attributes;
  }

  String _readName() {
    final int start = _pos;
    while (_pos < _length) {
      final int c = _source.codeUnitAt(_pos);
      final bool isNameChar = c == 0x3A || // :
          c == 0x5F || // _
          c == 0x2D || // -
          c == 0x2E || // .
          (c >= 0x30 && c <= 0x39) ||
          (c >= 0x41 && c <= 0x5A) ||
          (c >= 0x61 && c <= 0x7A) ||
          c > 0x7F;
      if (!isNameChar) break;
      _pos++;
    }
    return _source.substring(start, _pos);
  }

  void _skipWhitespace() {
    while (_pos < _length) {
      final int c = _source.codeUnitAt(_pos);
      if (c == 0x20 || c == 0x09 || c == 0x0A || c == 0x0D) {
        _pos++;
      } else {
        break;
      }
    }
  }

  void _skipComment() {
    _pos += 4;
    final int end = _source.indexOf('-->', _pos);
    _pos = end == -1 ? _length : end + 3;
  }

  void _skipDeclaration() {
    _pos += 2;
    final int end = _source.indexOf('>', _pos);
    _pos = end == -1 ? _length : end + 1;
  }

  void _expect(String character) {
    if (_startsWith(character)) _pos += character.length;
  }

  bool _startsWith(String pattern) => _source.startsWith(pattern, _pos);

  static String _decode(String value) {
    if (!value.contains('&')) return value;
    return value.replaceAllMapped(
      RegExp(r'&(#[0-9]+|#x[0-9a-fA-F]+|[A-Za-z][A-Za-z0-9]*);'),
      (Match match) => _decodeEntity(match.group(1)!) ?? match.group(0)!,
    );
  }

  static String? _decodeEntity(String entity) {
    switch (entity) {
      case 'amp':
        return '&';
      case 'lt':
        return '<';
      case 'gt':
        return '>';
      case 'quot':
        return '"';
      case 'apos':
        return "'";
    }
    if (entity.startsWith('#x') || entity.startsWith('#X')) {
      final int? code = int.tryParse(entity.substring(2), radix: 16);
      return code == null ? null : String.fromCharCode(code);
    }
    if (entity.startsWith('#')) {
      final int? code = int.tryParse(entity.substring(1));
      return code == null ? null : String.fromCharCode(code);
    }
    return null;
  }
}
