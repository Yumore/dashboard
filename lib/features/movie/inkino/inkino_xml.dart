/// A parsed Finnkino XML element.
///
/// Names and nesting are preserved exactly as the API sent them. `package:html`
/// was the first choice, but its HTML tree builder folds tag names to lower
/// case and mis-nests Finnkino's repeated sibling blocks, so the two small
/// parser files this migration needs live here instead.
class InKinoXmlNode {
  InKinoXmlNode(this.name, this.parent);

  final String name;
  final InKinoXmlNode? parent;
  final List<InKinoXmlNode> children = [];
  final List<String> _text = [];
  final Map<String, String> attributes = {};

  /// Raw element text, entity-decoded.
  String get text => _text.join();

  void addText(String value) => _text.add(value);

  /// First direct child named [tagName], or null.
  InKinoXmlNode? child(String tagName) {
    for (final node in children) {
      if (node.name == tagName) return node;
    }
    return null;
  }

  /// Every direct child named [tagName], in document order.
  List<InKinoXmlNode> childrenNamed(String tagName) =>
      children.where((node) => node.name == tagName).toList();

  /// Every descendant named [tagName], in document order (self excluded).
  List<InKinoXmlNode> descendants(String tagName) {
    final found = <InKinoXmlNode>[];
    for (final node in children) {
      if (node.name == tagName) found.add(node);
      found.addAll(node.descendants(tagName));
    }
    return found;
  }

  /// Trimmed, entity-decoded text of the first direct child named [tagName].
  /// Null when the element is absent, which is how Finnkino expresses
  /// "not rated yet" and other optional data.
  String? textOf(String tagName) {
    final node = child(tagName);
    if (node == null) return null;
    final value = node.text.trim();
    return value.isEmpty ? null : value;
  }

  @override
  String toString() => '<$name>(${children.length} children)';
}

/// A very small, dependency-free XML reader.
///
/// Finnkino's payloads are element trees with attributes, comments, CDATA,
/// XML declarations, entity references and self-closing tags — all handled
/// here. Not handled: DTD entity definitions and namespaces (Finnkino uses
/// neither; its `xmlns:xsd` attributes are read and ignored).
class InKinoXml {
  const InKinoXml._();

  static const Map<String, String> _entities = {
    'amp': '&',
    'lt': '<',
    'gt': '>',
    'quot': '"',
    'apos': "'",
    'nbsp': '\u00a0',
    'aelig': 'æ',
    'oslash': 'ø',
    'aring': 'å',
    'auml': 'ä',
    'ouml': 'ö',
  };

  static final RegExp _numericEntity = RegExp(r'^#(x[0-9a-fA-F]+|\d+)$');

  /// Every element descending from [node] named [tagName], document order.
  static List<InKinoXmlNode> findAll(InKinoXmlNode node, String tagName) =>
      node.descendants(tagName);

  /// Trimmed text of the first direct child of [node] named [tagName].
  static String? childText(InKinoXmlNode node, String tagName) =>
      node.textOf(tagName);

  /// First direct child of [node] named [tagName], or null.
  static InKinoXmlNode? child(InKinoXmlNode node, String tagName) =>
      node.child(tagName);

  /// Every direct child of [node] named [tagName], document order.
  static List<InKinoXmlNode> children(InKinoXmlNode node, String tagName) =>
      node.childrenNamed(tagName);

  /// Parses [source] and returns the first element whose name is [rootTag], or
  /// a synthetic [rootTag] element if it is absent (matching the tolerant
  /// behaviour the source's parser cascade relied on).
  static InKinoXmlNode parse(String source, {String? rootTag}) {
    final document = InKinoXmlNode('#document', null);
    var current = document;
    final length = source.length;
    var index = 0;

    while (index < length) {
      final open = source.indexOf('<', index);
      if (open < 0) {
        current.addText(_decode(source.substring(index)));
        break;
      }
      if (open > index) {
        current.addText(_decode(source.substring(index, open)));
      }

      if (source.startsWith('<!--', open)) {
        final end = source.indexOf('-->', open + 4);
        index = end < 0 ? length : end + 3;
        continue;
      }
      if (source.startsWith('<![CDATA[', open)) {
        final end = source.indexOf(']]>', open + 9);
        if (end < 0) {
          current.addText(source.substring(open + 9));
          break;
        }
        // CDATA is literal; it is not entity-decoded.
        current.addText(source.substring(open + 9, end));
        index = end + 3;
        continue;
      }
      if (source.startsWith('<?', open)) {
        final end = source.indexOf('?>', open + 2);
        index = end < 0 ? length : end + 2;
        continue;
      }
      if (source.startsWith('<!', open)) {
        final end = source.indexOf('>', open + 2);
        index = end < 0 ? length : end + 1;
        continue;
      }

      final close = source.indexOf('>', open + 1);
      if (close < 0) break;
      var tag = source.substring(open + 1, close).trim();

      if (tag.startsWith('/')) {
        final name = tag.substring(1).trim();
        if (current.parent != null && current.name == name) {
          current = current.parent!;
        }
        index = close + 1;
        continue;
      }

      final selfClosing = tag.endsWith('/');
      if (selfClosing) tag = tag.substring(0, tag.length - 1);

      final spaceIndex = tag.indexOf(RegExp(r'[\s/]'));
      final name = spaceIndex < 0 ? tag : tag.substring(0, spaceIndex);
      if (name.isEmpty) {
        index = close + 1;
        continue;
      }

      final element = InKinoXmlNode(name, current);
      if (spaceIndex >= 0) {
        element.attributes.addAll(_parseAttributes(tag.substring(spaceIndex)));
      }
      current.children.add(element);
      if (!selfClosing) {
        current = element;
      }
      index = close + 1;
    }

    if (rootTag == null) return document;
    for (final node in document.descendants(rootTag)) {
      return node;
    }
    return InKinoXmlNode(rootTag, null)..children.addAll(document.children);
  }

  static Map<String, String> _parseAttributes(String source) {
    final attributes = <String, String>{};
    final pattern = RegExp(
      r'''([A-Za-z_:][-\w.:]*)\s*=\s*("([^"]*)"|'([^']*)')''',
    );
    for (final match in pattern.allMatches(source)) {
      final name = match.group(1)!;
      final value = match.group(3) ?? match.group(4) ?? '';
      attributes[name] = _decode(value);
    }
    return attributes;
  }

  static String _decode(String value) {
    if (!value.contains('&')) return value;
    final buffer = StringBuffer();
    var index = 0;
    while (index < value.length) {
      final amp = value.indexOf('&', index);
      if (amp < 0) {
        buffer.write(value.substring(index));
        break;
      }
      buffer.write(value.substring(index, amp));
      final semi = value.indexOf(';', amp + 1);
      if (semi < 0 || semi - amp > 12) {
        buffer.write('&');
        index = amp + 1;
        continue;
      }
      final entity = value.substring(amp + 1, semi);
      final numeric = _numericEntity.firstMatch(entity);
      if (numeric != null) {
        final digits = numeric.group(1)!;
        final code = digits.startsWith('x')
            ? int.tryParse(digits.substring(1), radix: 16)
            : int.tryParse(digits);
        if (code != null && code > 0) {
          buffer.write(String.fromCharCode(code));
        }
      } else {
        buffer.write(_entities[entity] ?? '&$entity;');
      }
      index = semi + 1;
    }
    return buffer.toString();
  }
}
