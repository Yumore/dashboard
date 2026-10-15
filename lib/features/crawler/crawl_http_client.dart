import 'dart:convert';

import 'package:dashboard/features/crawler/crawl_config.dart';
import 'package:dashboard/features/crawler/crawl_page_data.dart';
import 'package:dio/dio.dart';
import 'package:enough_convert/enough_convert.dart';

/// One bounded request per explicit run, no blocking sleeps or recursive retry.
class CrawlHttpClient {
  CrawlHttpClient({Dio? dio})
    : _dio =
          dio ?? Dio(BaseOptions(connectTimeout: const Duration(seconds: 15)));

  final Dio _dio;
  static const maxBytes = 2 * 1024 * 1024;

  Future<CrawlPageData> fetch(CrawlConfig config, CancelToken token) async {
    final response = await _dio.getUri<ResponseBody>(
      config.uri,
      cancelToken: token,
      options: Options(
        responseType: ResponseType.stream,
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        maxRedirects: 3,
        headers: {
          'User-Agent': 'DashboardContentCrawler/1.0',
          'Accept': 'text/html',
        },
      ),
    );
    final body = response.data;
    if (body == null) throw const FormatException('网页响应为空');
    final bytes = <int>[];
    await for (final chunk in body.stream.timeout(
      const Duration(seconds: 15),
    )) {
      if (token.isCancelled) throw token.cancelError!;
      if (bytes.length + chunk.length > maxBytes) {
        throw const FormatException('网页超过 2 MiB 限制');
      }
      bytes.addAll(chunk);
    }
    if (token.isCancelled) throw token.cancelError!;
    final contentType = response.headers.value('content-type') ?? '';
    final declared = RegExp(
      r'''charset\s*=\s*["']?([\w-]+)''',
      caseSensitive: false,
    ).firstMatch(contentType)?.group(1);
    final prefix = latin1.decode(bytes.take(2048).toList());
    final meta = RegExp(
      r'''charset\s*=\s*["']?([\w-]+)''',
      caseSensitive: false,
    ).firstMatch(prefix)?.group(1);
    final charset = (declared ?? meta ?? config.encoding).toLowerCase();
    final String text;
    if (['gb2312', 'gbk', 'x-gbk'].contains(charset)) {
      text = gbk.decode(bytes);
    } else if (['utf-8', 'utf8'].contains(charset)) {
      text = utf8.decode(bytes);
    } else {
      throw FormatException('尚不支持网页编码：$charset');
    }
    return CrawlPageData(text, response.realUri);
  }

  void dispose() => _dio.close(force: true);
}
