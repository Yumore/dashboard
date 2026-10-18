import 'dart:ui';

import 'package:dashboard/features/anime/tsdm/tsdm_collections.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_content_node.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_css_parser.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_font_size.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_html_ext.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_munch_state.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_string_ext.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_user.dart';
import 'package:flutter/painting.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import 'package:dashboard/features/anime/tsdm/tsdm_selector_compat.dart';

/// Options controlling post content parsing.
///
/// Ported from `tsdm_client/lib/utils/html/munch_options.dart`.
class TsdmMunchOptions {
  const TsdmMunchOptions({this.renderUrl = true});

  /// Render `<a>` tags as links. When false, links are rendered as plain text.
  final bool renderUrl;
}

/// Parse the html content of a forum post into a renderable node tree.
///
/// This is the port of `tsdm_client/lib/utils/html/html_muncher.dart`. The
/// source built `InlineSpan`s directly against a Flutter `BuildContext`; the
/// port instead produces a platform independent [TsdmContentNode] tree which
/// the post card renders, which keeps the parsing rules (tags, css styles,
/// quote and spoiler detection, list markers) intact and testable.
class TsdmHtmlMuncher {
  /// Create a muncher with the given [options].
  TsdmHtmlMuncher({this.options = const TsdmMunchOptions()});

  /// Parsing options.
  final TsdmMunchOptions options;

  /// Mutable parse state.
  final TsdmMunchState state = TsdmMunchState();

  /// Regex matching a netease music player iframe.
  static final neteasePlayerRe = RegExp(
    r'//music\.163\.com/outchain/player\?.*id=(?<id>\d+).*',
  );

  /// Div classes with dedicated handling, in match order.
  static const divHandlerClasses = <String>[
    'blockcode',
    'locked',
    'cm',
    'spoiler',
    'rusld',
    'rsld',
    'rwdbst',
  ];

  /// Parse a html fragment into a node tree.
  List<TsdmContentNode> munchContent(String? html) {
    if (html == null || html.isEmpty) {
      return const [];
    }
    final fragment = html_parser.parseFragment(html);
    return _munchChildren(fragment.nodes);
  }

  /// Parse a html fragment into the inline items of a single line.
  List<TsdmInlineItem> munchInline(String? html) {
    if (html == null || html.isEmpty) {
      return const [];
    }
    final fragment = html_parser.parseFragment(html);
    final items = <TsdmInlineItem>[];
    for (final node in fragment.nodes) {
      _collectInline(node, items);
    }
    _trimInline(items);
    return items;
  }

  List<TsdmContentNode> _munchChildren(List<dom.Node> nodes) {
    final result = <TsdmContentNode>[];
    var items = <TsdmInlineItem>[];

    void flush() {
      if (items.isEmpty) {
        return;
      }
      _trimInline(items);
      if (items.isNotEmpty) {
        result.add(
          TsdmLineNode(
            List<TsdmInlineItem>.of(items),
            indent: state.listStack.length,
          ),
        );
      }
      items = <TsdmInlineItem>[];
    }

    for (final node in nodes) {
      final nodeType = node.nodeType;
      if (nodeType == dom.Node.TEXT_NODE) {
        final text = node.text;
        if (text == null || text.isEmpty) {
          continue;
        }
        items.add(TsdmTextItem(_buildRun(text)));
        continue;
      }
      if (nodeType != dom.Node.ELEMENT_NODE) {
        continue;
      }
      final element = node as dom.Element;

      // Skip invisible nodes, as the source does.
      if (element.attributes['style']?.contains('display: none') ?? false) {
        continue;
      }

      final blockNode = _buildBlock(element);
      if (blockNode != null) {
        flush();
        result.addAll(blockNode);
        continue;
      }

      final localName = element.localName;
      switch (localName) {
        case 'img':
          final image = _buildImage(element);
          if (image != null) {
            items.add(TsdmImageItem(image));
          }
        case 'br':
          items.add(const TsdmTextItem(TsdmTextRun('\n')));
        case 'font':
          _pushFont(element);
          _collectInlineChildren(element, items);
        case 'strong' || 'b':
          final origBold = state.bold;
          state.bold = true;
          _collectInlineChildren(element, items);
          state.bold = origBold;
        case 'u':
          final origUnderline = state.underline;
          state.underline = true;
          _collectInlineChildren(element, items);
          state.underline = origUnderline;
        case 'strike' || 's' || 'del':
          final origThrough = state.lineThrough;
          state.lineThrough = true;
          _collectInlineChildren(element, items);
          state.lineThrough = origThrough;
        case 'i' || 'em':
          final origItalic = state.italic;
          state.italic = true;
          _collectInlineChildren(element, items);
          state.italic = origItalic;
        case 'span':
          _pushSpan(element);
          _collectInlineChildren(element, items);
        case 'a':
          final origTapUrl = state.tapUrl;
          final href = element.attributes['href'];
          if (href != null && options.renderUrl) {
            state.tapUrl = href.prependHost();
          }
          _collectInlineChildren(element, items);
          state.tapUrl = origTapUrl;
        case 'sup':
          final text = element.text;
          if (text.isNotEmpty) {
            items.add(TsdmTextItem(_buildRun(text)));
          }
        case 'hr':
          items.add(TsdmTextItem(TsdmTextRun('—' * 12)));
        case 'ol':
          state.listStack.add(const TsdmOrderedList(1));
          _collectInlineChildren(element, items);
          state.listStack.removeLast();
        case 'ul':
          // Ordered lists in the web page use a `ul` tag carrying the
          // `litype_1` class, as in the source muncher.
          if (element.classes.contains('litype_1')) {
            state.listStack.add(const TsdmOrderedList(1));
          } else {
            state.listStack.add(const TsdmUnorderedList());
          }
          _collectInlineChildren(element, items);
          state.listStack.removeLast();
        case 'li':
          final leading = switch (state.listStack.lastOrNull) {
            TsdmUnorderedList() => '•  ',
            TsdmOrderedList(:final number) => () {
              state.listStack
                ..removeLast()
                ..add(TsdmOrderedList(number + 1));
              return '$number. ';
            }(),
            null => '•  ',
          };
          items.add(TsdmTextItem(_buildRun(leading)));
          _collectInlineChildren(element, items);
          items.add(const TsdmTextItem(TsdmTextRun('\n')));
        case 'code':
          final text = element.text;
          if (text.isNotEmpty) {
            items.add(TsdmTextItem(_buildRun(text)));
          }
        case 'dl':
          _collectInlineChildren(element, items);
        default:
          // Unknown container nodes are transparent, as in the source.
          _collectInlineChildren(element, items);
      }
    }
    flush();
    return result;
  }

  void _collectInline(dom.Node node, List<TsdmInlineItem> items) {
    if (node.nodeType == dom.Node.TEXT_NODE) {
      final text = node.text;
      if (text != null && text.isNotEmpty) {
        items.add(TsdmTextItem(_buildRun(text)));
      }
      return;
    }
    if (node.nodeType != dom.Node.ELEMENT_NODE) {
      return;
    }
    final element = node as dom.Element;
    if (element.attributes['style']?.contains('display: none') ?? false) {
      return;
    }
    if (element.localName == 'img') {
      final image = _buildImage(element);
      if (image != null) {
        items.add(TsdmImageItem(image));
      }
      return;
    }
    // Non-inline node: flatten its text content into the current line.
    _collectInlineChildren(element, items);
  }

  void _collectInlineChildren(dom.Element element, List<TsdmInlineItem> items) {
    for (final node in element.nodes) {
      _collectInline(node, items);
    }
  }

  List<TsdmContentNode>? _buildBlock(dom.Element element) {
    switch (element.localName) {
      case 'blockquote':
        return [_buildBlockQuote(element)];
      case 'div':
        final handler = divHandlerClasses.firstWhereOrNull(
          (c) => element.classes.contains(c),
        );
        switch (handler) {
          case 'blockcode':
            return [_buildBlockCode(element)];
          case 'spoiler':
            return [_buildSpoiler(element)];
          case 'locked':
          case 'cm':
          case 'rusld':
          case 'rsld':
          case 'rwdbst':
            // These areas are rendered as plain text in the port; their content
            // text is preserved so nothing is silently dropped.
            final text = element.text.trim();
            return text.isEmpty ? null : [_buildTextOnlyNode(text)];
          default:
            return null;
        }
      case 'p' || 'h1' || 'h2' || 'h3' || 'h4' || 'tr' || 'td':
        return null;
      case 'details':
        return [_buildSpoiler(element)];
      case 'table':
        return null;
      case 'iframe':
        final src = element.attributes['src'] ?? '';
        final neteaseId = neteasePlayerRe.firstMatch(src)?.namedGroup('id');
        if (neteaseId != null) {
          return [
            TsdmLineNode([
              TsdmTextItem(TsdmTextRun('[netease player] $neteaseId')),
            ]),
          ];
        }
        return null;
      default:
        return null;
    }
  }

  TsdmContentNode _buildTextOnlyNode(String text) {
    return TsdmLineNode([TsdmTextItem(TsdmTextRun(text))]);
  }

  TsdmQuoteNode _buildBlockQuote(dom.Element element) {
    final snapshot = state.save();
    final children = _munchChildren(element.nodes);
    state.restore(snapshot);

    TsdmUser? author;
    final citeNode = element.q('cite');
    if (citeNode != null) {
      final name = citeNode.text.trim();
      if (name.isNotEmpty) {
        author = TsdmUser(name: name, url: '');
      }
    }
    return TsdmQuoteNode(TsdmQuote(author: author, children: children));
  }

  TsdmContentNode _buildBlockCode(dom.Element element) {
    // Each line of a block code is wrapped in a `<div>`. Use those lines when
    // present, otherwise fall back to the raw text content.
    final lineNodes = element.qAll('div ol li');
    final text = lineNodes.isEmpty
        ? element.text
        : lineNodes.map((e) => e.text.trimRight()).join('\n');
    return TsdmCodeNode(TsdmCodeBlock(text.trim()));
  }

  TsdmContentNode _buildSpoiler(dom.Element element) {
    final snapshot = state.save();
    final children = _munchChildren(element.nodes);
    state.restore(snapshot);

    final titleNode = element.q('div.spoiler_title, div.title, b, strong');
    final title = (titleNode?.text ?? element.attributes['title'] ?? 'spoiler')
        .trim();
    return TsdmSpoilerNode(
      TsdmSpoiler(title: title.isEmpty ? 'spoiler' : title, children: children),
    );
  }

  TsdmImage? _buildImage(dom.Element element) {
    final url = element.imageUrl();
    if (url == null) {
      return null;
    }
    state.headingBrNodePassed = true;
    return TsdmImage(
      url: url,
      alt: element.attributes['alt'],
      width: element.attributes['width']?.parseToInt()?.toDouble(),
      height: element.attributes['height']?.parseToInt()?.toDouble(),
      href: state.tapUrl,
    );
  }

  TsdmTextRun _buildRun(String text) {
    return TsdmTextRun(
      text,
      bold:
          state.bold ||
          (state.fontWeight ?? FontWeight.normal).value >=
              FontWeight.w600.value,
      italic: state.italic,
      underline: state.underline,
      lineThrough: state.lineThrough,
      colorValue: state.color?.toARGB32(),
      backgroundColorValue: state.backgroundColor?.toARGB32(),
      fontSizeValue: state.fontSize,
      href: state.tapUrl,
    );
  }

  void _pushFont(dom.Element element) {
    final color = element.attributes['color'];
    if (color != null) {
      final colorValue = parseTsdmColor(color);
      if (colorValue != null) {
        state.color = colorValue;
      }
    }
    final size = TsdmFontSize.from(element.attributes['size']);
    if (size.isValid) {
      state.fontSize = size.value;
    }
    final style = element.attributes['style'];
    if (style != null) {
      final css = parseTsdmCssString(style);
      if (css.color != null) {
        state.color = css.color;
      }
      if (css.backgroundColor != null) {
        state.backgroundColor = css.backgroundColor;
      }
      if (css.fontWeight != null) {
        state.fontWeight = css.fontWeight;
      }
    }
  }

  void _pushSpan(dom.Element element) {
    final style = element.attributes['style'];
    if (style == null) {
      return;
    }
    final css = parseTsdmCssString(style);
    if (css.color != null) {
      state.color = css.color;
    }
    if (css.backgroundColor != null) {
      state.backgroundColor = css.backgroundColor;
    }
    if (css.fontWeight != null) {
      state.fontWeight = css.fontWeight;
    }
  }

  void _trimInline(List<TsdmInlineItem> items) {
    // Drop leading and trailing empty runs.
    while (items.isNotEmpty) {
      final first = items.first;
      if (first is TsdmTextItem && first.run.text.isEmpty) {
        items.removeAt(0);
        continue;
      }
      break;
    }
    while (items.isNotEmpty) {
      final last = items.last;
      if (last is TsdmTextItem && last.run.text.trim().isEmpty) {
        items.removeLast();
        continue;
      }
      break;
    }
  }
}
