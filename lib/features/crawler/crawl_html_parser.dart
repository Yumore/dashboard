import 'package:dashboard/features/crawler/crawl_config.dart';
import 'package:dashboard/features/crawler/crawl_item.dart';
import 'package:html/parser.dart' as html;

/// Migrates the three source selectors; relative links resolve against the
/// actual response URL, and unsafe/empty links are not exposed as results.
class CrawlHtmlParser {
  List<CrawlItem> parse(String source, CrawlConfig config, Uri responseUri) {
    final document = html.parse(source);
    if (config.selector.trim().isEmpty) {
      throw const FormatException('CSS 选择器不能为空');
    }
    final matches = document.querySelectorAll(config.selector);
    final seen = <String>{};
    final result = <CrawlItem>[];
    for (final element in matches) {
      final anchor = element.localName == 'a'
          ? element
          : element.querySelector('a');
      final href = anchor?.attributes['href']?.trim();
      if (href == null || href.isEmpty || href.startsWith('#')) continue;
      final Uri link;
      try {
        link = responseUri.resolve(href).removeFragment();
      } on FormatException {
        continue;
      }
      if (!['http', 'https'].contains(link.scheme) ||
          link.host.isEmpty ||
          link.userInfo.isNotEmpty ||
          !seen.add(link.toString())) {
        continue;
      }
      final title =
          (config.imageTitle
                  ? element.querySelector('img')?.attributes['alt'] ??
                        anchor?.text ??
                        ''
                  : anchor?.text ?? '')
              .replaceAll(RegExp(r'\s+'), ' ')
              .trim();
      result.add(
        CrawlItem(title: title.isEmpty ? link.toString() : title, url: link),
      );
      if (result.length == 500) break;
    }
    return result;
  }
}
