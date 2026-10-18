import 'dart:math';

import 'package:dashboard/features/anime/tsdm/tsdm_collections.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_string_ext.dart';
import 'package:html/dom.dart' as dom;
import 'package:dashboard/features/anime/tsdm/tsdm_selector_compat.dart';

/// Document level grep helpers used by the tsdm parsers.
///
/// Ported from `tsdm_client/lib/extensions/universal_html.dart`
/// (`GrepDocumentExtension`) from `universal_html` to `package:html`'s dom.
extension TsdmDocumentGrepExtension on dom.Document {
  /// The current page number parsed from `div.pg > strong`, null when absent.
  int? currentPage() {
    return querySelector('div.pg > strong')?.firstEndDeepText()?.parseToInt();
  }

  /// The total page count of the current document.
  ///
  /// Returns 1 when there is no pagination node. When the last child of `div.pg`
  /// is a `<strong>` node the current page is the last page. Otherwise an
  /// `a.last` node with a `1, 2, .. 100` style label is used, else the maximum
  /// page number among the plain `<a>` children.
  int? totalPages() {
    final paginateNode = querySelector('div.pg');
    if (paginateNode == null) {
      return 1;
    }
    final currentPage =
        paginateNode.q('strong')?.firstEndDeepText()?.parseToInt() ?? 1;

    final lastNode = paginateNode.children.lastOrNull;
    final skippedLastNode = paginateNode.q('a.last');
    if (lastNode != null && lastNode.localName == 'strong') {
      return currentPage;
    } else if (skippedLastNode != null) {
      final text = skippedLastNode.firstEndDeepText();
      if (text == null || text.length < 4) {
        return 1;
      }
      return text.substring(4).parseToInt() ?? 1;
    }
    final candidates = paginateNode
        .qAll('a')
        .where((e) => e.classes.isEmpty)
        .map((e) => (e.firstEndDeepText() ?? '0').parseToInt())
        .whereType<int>()
        .toList();
    if (candidates.isEmpty) {
      return 1;
    }
    return candidates.reduce(max);
  }

  /// Whether another page can be loaded.
  ///
  /// Ported from `checkCanLoadMore` of
  /// `tsdm_client/lib/features/forum/bloc/forum_bloc.dart`: the last child of
  /// `div#pgt > div.pg` is inspected, a `strong` node is the current page
  /// marker so no further page exists.
  bool checkCanLoadMore() {
    final barNode = getElementById('pgt');
    if (barNode == null) {
      return false;
    }
    final paginationNode = barNode.q('div.pg');
    if (paginationNode == null) {
      return false;
    }
    final lastNode = paginationNode.children.lastOrNull;
    if (lastNode == null || lastNode.nodeType != dom.Node.ELEMENT_NODE) {
      return false;
    }
    return lastNode.localName != 'strong';
  }
}

/// Element level grep helpers used by the tsdm parsers.
///
/// Ported from `tsdm_client/lib/extensions/universal_html.dart`
/// (`AccessExtension` / `GrepExtension`). `querySelectorRootAll` of the source
/// relies on `universal_html`'s `ElementList` and is intentionally not ported.
extension TsdmElementGrepExtension on dom.Element {
  /// The uppercase `tagName` of this element.
  ///
  /// `package:html` exposes `localName` only; the port keeps the uppercase
  /// `tagName` semantics of `universal_html` for the source parsers.
  String get tagNameUpper => (localName ?? '').toUpperCase();

  /// The node before this one in its parent, null when there is none.
  dom.Node? get previousNode {
    final parentNode = this.parentNode;
    if (parentNode == null) {
      return null;
    }
    final index = parentNode.nodes.indexOf(this);
    if (index <= 0) {
      return null;
    }
    return parentNode.nodes[index - 1];
  }

  /// The node after this one in its parent, null when there is none.
  dom.Node? get nextNode {
    final parentNode = this.parentNode;
    if (parentNode == null) {
      return null;
    }
    final index = parentNode.nodes.indexOf(this);
    if (index < 0 || index + 1 >= parentNode.nodes.length) {
      return null;
    }
    return parentNode.nodes[index + 1];
  }

  /// The child at [index], null when out of range.
  dom.Element? childAtOrNull(int index) => children.elementAtOrNull(index);

  /// The inner html of this element, empty when unavailable.
  String innerHtmlEx() => innerHtml;

  /// The text of this element, empty when unavailable.
  String innerTextEx() => text;

  /// The value of the first `href` attribute found in pre-order.
  ///
  /// Traverses down the first child, then to next siblings, then upwards,
  /// exactly as the source does.
  String? firstHref() {
    final root = this;
    var found = false;
    String? ret;

    bool work(dom.Element element) {
      final href = element.attributes['href'];
      if (href != null) {
        ret = href;
        found = true;
        return true;
      }
      return false;
    }

    bool traverseIf(dom.Element? element) {
      if (element == null) {
        return true;
      }
      if (work(element)) {
        return true;
      }
      if (element.nodes.isNotEmpty) {
        return traverseIf(element.childAtOrNull(0));
      } else if (element.nextElementSibling != null) {
        return traverseIf(element.nextElementSibling);
      }
      var e = element.parent;
      while (!identical(e, root)) {
        if (e == null) {
          return true;
        }
        if (e.nextElementSibling != null) {
          return traverseIf(e.nextElementSibling);
        } else {
          e = e.parent;
        }
      }
      return true;
    }

    traverseIf(root);
    return found ? ret : null;
  }

  /// The deepest leading text of this element.
  ///
  /// Descends through first children until a leaf is reached and returns its
  /// text. See the source doc comment for the exact semantics.
  String? firstEndDeepText() {
    var e = this;
    var ch = e.children;
    while (ch.isNotEmpty) {
      e = ch.first;
      ch = e.children;
    }
    return e.text;
  }

  /// The deepest trailing text of this element.
  ///
  /// Ported from `tsdm_client/lib/extensions/universal_html.dart`. Used by the
  /// notification parser to read the message body of a notice node.
  String? lastEndDeepText() {
    var e = this;
    var ch = e.children;
    while (ch.isNotEmpty) {
      e = ch.last;
      ch = e.children;
    }
    return e.text;
  }

  /// Parse a `<li>` node holding an `<em>` key and a value.
  ///
  /// Returns a `(key, value)` pair, or null when any side is missing or empty.
  /// With [second] the second node's text is used as the value, otherwise all
  /// nodes after the first `<em>` are joined, using `outerHtml` for elements.
  (String, String)? parseLiEmNode({bool second = false}) {
    if (children.elementAtOrNull(0)?.localName != 'em') {
      return null;
    }

    final key = children.elementAtOrNull(0)?.text.trim();
    final String? value;
    if (second) {
      value = nodes.elementAtOrNull(1)?.text;
    } else if (children.length >= 2) {
      value = nodes.skip(1).map((e) {
        if (e is dom.Element) {
          return e.outerHtml;
        }
        return e.text;
      }).join();
    } else {
      final lastNode = nodes.lastOrNull;
      value = lastNode?.text?.trim();
    }
    if (key == null || value == null || key.isEmpty || value.isEmpty) {
      return null;
    }
    return (key, value);
  }

  /// The image url in this element's attributes, `data-original` first.
  String? dataOriginalOrSrcImgUrl() =>
      attributes['data-original'] ?? attributes['src'];

  /// The image url of this element, `zoomfile > data-original > src > file`.
  ///
  /// A relative value is prefixed with the tsdm base url.
  String? imageUrl() {
    final str =
        attributes['zoomfile']?.prependHost() ??
        attributes['data-original'] ??
        attributes['src'] ??
        attributes['file'];

    if (str == null) {
      return null;
    }
    if (str.startsWith('http')) {
      return str;
    }
    return 'https://www.tsdm39.com/$str';
  }

  /// Parse a table row into its first `<th>` text and all `<td>` texts.
  (String?, List<String>) parseTableRow() {
    String? title;
    final data = <String>[];
    for (final node in nodes) {
      if (node is! dom.Element) {
        continue;
      }
      if (node.localName == 'th' && title == null) {
        title = node.text;
        continue;
      }
      if (node.localName == 'td' && node.text.isNotEmpty) {
        data.add(node.text);
      }
    }
    return (title, data);
  }

  /// Parse the date time carried by this node or its first child.
  ///
  /// This is the unified time parser of the source: it understands the
  /// `<a><span title="...">` recent-7-days form, the more-than-7-days text form,
  /// the `发表于 $time` post header form and the generic nested span form.
  DateTime? dateTime() {
    final tag = (localName ?? '').toUpperCase();
    if (tag == 'A') {
      final firstChild = children.firstOrNull;
      if (firstChild != null &&
          (firstChild.localName ?? '').toUpperCase() == 'SPAN') {
        return firstChild.attributes['title']?.parseToDateTimeUtc8();
      }
      return nodes.firstOrNull?.text?.trim().parseToDateTimeUtc8();
    }

    if (tag == 'SPAN') {
      final title = attributes['title'];
      if (title != null) {
        return title.parseToDateTimeUtc8();
      }
      final firstChild = children.firstOrNull;
      if (firstChild != null &&
          (firstChild.localName ?? '').toUpperCase() == 'SPAN') {
        return firstChild.attributes['title']?.parseToDateTimeUtc8();
      }
      return text.trim().parseToDateTimeUtc8();
    }

    final firstChild = children.firstOrNull;
    if (firstChild != null &&
        (firstChild.localName ?? '').toUpperCase() == 'SPAN' &&
        firstChild.attributes.containsKey('title')) {
      return firstChild.attributes['title']!.parseToDateTimeUtc8();
    }

    final firstNode = nodes.firstOrNull;
    if (firstNode != null && firstNode is! dom.Element) {
      final childText = firstNode.text ?? '';
      if (childText.startsWith('发表于')) {
        return childText.replaceAll('发表于', '').trim().parseToDateTimeUtc8();
      }
      return childText.trim().parseToDateTimeUtc8();
    }

    return null;
  }
}
