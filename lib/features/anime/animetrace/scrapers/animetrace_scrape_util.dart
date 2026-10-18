/// Shared, network-free parsing helpers used by every AnimeTrace scraper.
///
/// All helpers take plain strings or `html` package nodes so they can be unit
/// tested with committed HTML fixtures.
library;

import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;

/// Parses a full HTML document.
Document parseAnimeTraceHtml(String html) => html_parser.parse(html);

/// Prefixes protocol-relative (`//host/x`) and scheme-less image URLs with
/// `https:`, mirroring the source app's cover normalization.
String normalizeAnimeTraceImageUrl(String? raw) {
  final value = raw?.trim() ?? '';
  if (value.isEmpty) return '';
  if (value.startsWith('http')) return value;
  return 'https:$value';
}

/// First element with [className], or `null`.
Element? firstByClass(Document document, String className) {
  final elements = document.getElementsByClassName(className);
  return elements.isEmpty ? null : elements.first;
}

/// `innerHtml` of the first element carrying [className], or `''`.
String classInnerHtml(Document document, String className) =>
    firstByClass(document, className)?.innerHtml ?? '';

/// `innerHtml` of the [index]-th element carrying [className], or `''`.
String classInnerHtmlAt(Document document, String className, int index) {
  final elements = document.getElementsByClassName(className);
  if (index < 0 || index >= elements.length) return '';
  return elements[index].innerHtml;
}

/// `element.innerHTML` with `<br>` (and `<br/>`) turned into newlines, as the
/// source app does for synopsis text.
String innerHtmlWithLineBreaks(Element? element) {
  if (element == null) return '';
  return element.innerHtml
      .replaceAll(RegExp(r'<br\s*/?>'), '\n')
      .replaceAll('<br>', '\n');
}

/// Attribute value of the first descendant of [element] with [tagName].
String? childAttribute(
  Element? element,
  String tagName,
  String attribute, {
  int index = 0,
}) {
  if (element == null) return null;
  final children = element.getElementsByTagName(tagName);
  if (index < 0 || index >= children.length) return null;
  return children[index].attributes[attribute];
}

/// `innerHtml` of the first descendant of [element] with [tagName].
String childInnerHtml(Element? element, String tagName, {int index = 0}) {
  if (element == null) return '';
  final children = element.getElementsByTagName(tagName);
  if (index < 0 || index >= children.length) return '';
  return children[index].innerHtml;
}

/// Episode count extracted from the free-text labels used by yhdm/agemys, for
/// example `[全集]`, `更新至第12集`, `01-24`.
///
/// Returns `0` when nothing parseable is found, and `1` for a full-series label
/// (the source app treats `[全集]` movies as a single episode).
int parseEpisodeCountOfYhdm(String text) {
  if (text.contains('[全集]')) return 1;
  if (text.contains('第')) {
    final start = text.indexOf('第') + 1;
    var end = text.indexOf('集');
    if (end == -1) end = text.indexOf('话');
    if (start < end && end <= text.length) {
      return int.tryParse(text.substring(start, end)) ?? 0;
    }
    return 0;
  }
  if (text.contains('01-')) {
    final start = text.indexOf('01-') + 3;
    if (start + 2 <= text.length) {
      return int.tryParse(text.substring(start, start + 2)) ?? 0;
    }
  }
  return 0;
}

/// The source app stored the raw source episode count but displayed
/// `episodeCnt - episodeStartNumber + 1` episodes.
int adjustEpisodeCountByStartNumber(int episodeCount, int episodeStartNumber) =>
    episodeCount - episodeStartNumber + 1;

/// Normalizes the many date shapes bangumi.tv renders into `YYYY-MM-DD`,
/// `YYYY-MM` or `YYYY`.
String normalizeBangumiDate(String text) {
  final trimmed = text.trim();
  if (trimmed.contains('年')) {
    final yearEnd = trimmed.indexOf('年');
    var result = trimmed.substring(0, yearEnd);
    if (trimmed.contains('月')) {
      var month = trimmed.substring(yearEnd + 1, trimmed.indexOf('月'));
      if (month.length == 1) month = '0$month';
      result += '-$month';
      if (trimmed.contains('日')) {
        var day = trimmed.substring(
          trimmed.indexOf('月') + 1,
          trimmed.indexOf('日'),
        );
        if (day.length == 1) day = '0$day';
        result += '-$day';
      }
    }
    return result;
  }
  final match = RegExp('[0-9]{4}-[0-9]{2}-[0-9]{2}').firstMatch(trimmed);
  return match?.group(0) ?? '';
}

/// Strips every HTML tag from [html] and collapses whitespace.
String stripAnimeTraceHtml(String html) => html
    .replaceAll(RegExp('<[^>]*>'), ' ')
    .replaceAll('&nbsp;', ' ')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();
