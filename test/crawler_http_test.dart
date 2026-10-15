import 'dart:async';
import 'dart:io';

import 'package:dashboard/features/crawler/crawl_config.dart';
import 'package:dashboard/features/crawler/crawl_http_client.dart';
import 'package:dio/dio.dart';
import 'package:enough_convert/enough_convert.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'cancels an in-flight response instead of waiting for its body',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final arrived = Completer<void>();
      server.listen((request) {
        arrived.complete();
      });
      final client = CrawlHttpClient();
      addTearDown(() async {
        client.dispose();
        await server.close(force: true);
      });
      final token = CancelToken();
      final response = client.fetch(
        CrawlConfig(
          id: 'cancel',
          name: 'Cancel',
          url: 'http://127.0.0.1:${server.port}/slow',
        ),
        token,
      );
      final assertion = expectLater(
        response,
        throwsA(
          isA<DioException>().having(
            (error) => error.type,
            'type',
            DioExceptionType.cancel,
          ),
        ),
      );
      await arrived.future.timeout(const Duration(seconds: 3));
      token.cancel('user stopped');
      await assertion.timeout(const Duration(seconds: 3));
    },
  );

  test(
    'real HTTP handles redirects, GB2312 bytes, failures and size limits',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      server.listen((request) async {
        final response = request.response;
        switch (request.uri.path) {
          case '/redirect':
            response.statusCode = 302;
            response.headers.set('location', '/gbk');
          case '/gbk':
            response.headers.set('content-type', 'text/html; charset=GB2312');
            response.add(gbk.encode('<a href="/one">中文新闻</a>'));
          case '/meta':
            response.headers.set('content-type', 'text/html');
            response.add(gbk.encode('<meta charset="gbk"><a>中文</a>'));
          case '/large':
            response.add(List.filled(CrawlHttpClient.maxBytes + 1, 65));
          default:
            response.statusCode = 403;
        }
        await response.close();
      });
      final client = CrawlHttpClient();
      addTearDown(() async {
        client.dispose();
        await server.close(force: true);
      });
      CrawlConfig config(String path) => CrawlConfig(
        id: 'http',
        name: 'HTTP',
        url: 'http://127.0.0.1:${server.port}$path',
      );
      final page = await client.fetch(config('/redirect'), CancelToken());
      expect(page.html, contains('中文新闻'));
      expect(page.uri.path, '/gbk');
      expect(
        (await client.fetch(config('/meta'), CancelToken())).html,
        contains('中文'),
      );
      await expectLater(
        client.fetch(config('/large'), CancelToken()),
        throwsFormatException,
      );
      await expectLater(
        client.fetch(config('/forbidden'), CancelToken()),
        throwsA(isA<DioException>()),
      );
      final cancelled = CancelToken()..cancel();
      await expectLater(
        client.fetch(config('/gbk'), cancelled),
        throwsA(isA<DioException>()),
      );
    },
  );
}
