import 'dart:io';

import 'package:dashboard/features/crawler/crawl_config.dart';
import 'package:dashboard/features/crawler/crawl_html_parser.dart';
import 'package:dashboard/features/crawler/crawl_http_client.dart';
import 'package:dio/dio.dart';

/// Explicit read-only smoke check: one request for each public news preset.
Future<void> main() async {
  final client = CrawlHttpClient();
  try {
    for (final config in CrawlConfig.presets.where(
      (item) => ['ithome', 'cnr'].contains(item.id),
    )) {
      final token = CancelToken();
      try {
        final page = await client
            .fetch(config, token)
            .timeout(const Duration(seconds: 30));
        final items = CrawlHtmlParser().parse(page.html, config, page.uri);
        stdout.writeln('${config.id}: ${page.uri} -> ${items.length} links');
        if (items.isEmpty) exitCode = 1;
      } catch (error) {
        stderr.writeln('${config.id}: verification unavailable: $error');
        exitCode = 1;
      } finally {
        if (!token.isCancelled) token.cancel('smoke check finished');
      }
    }
  } finally {
    client.dispose();
  }
}
