import 'dart:io';

import 'package:dashboard/features/live/easy_tv_live/easy_tv_catalog.dart';
import 'package:dashboard/features/live/easy_tv_live/easy_tv_catalog_cache.dart';
import 'package:dashboard/features/live/easy_tv_live/easy_tv_catalog_parser.dart';
import 'package:dashboard/features/live/easy_tv_live/easy_tv_env.dart';
import 'package:http/http.dart' as http;
import 'package:dashboard/app/platform/app_platform.dart';

/// Loads a subscription, porting `M3uUtil.getDefaultM3uData`.
///
/// A remote failure or an empty playlist falls back to the last cached copy,
/// exactly like the source app; a local playlist file is also supported.
class EasyTvCatalogRepository {
  EasyTvCatalogRepository({
    http.Client? client,
    EasyTvCatalogCache? cache,
    EasyTvCatalogParser parser = const EasyTvCatalogParser(),
    EasyTvEnv env = const EasyTvEnv(),
    Duration timeout = const Duration(seconds: 15),
  }) : _client = client ?? http.Client(),
       _ownsClient = client == null,
       _cache = cache ?? const EasyTvCatalogCache(),
       _parser = parser,
       _env = env,
       _timeout = timeout;

  final http.Client _client;
  final bool _ownsClient;
  final EasyTvCatalogCache _cache;
  final EasyTvCatalogParser _parser;
  final EasyTvEnv _env;
  final Duration _timeout;

  /// Serializes `link` (the `default` pseudo-link or an http(s)/file URL).
  Future<EasyTvCatalog> load(String link) async {
    final requestUrl = _env.resolve(link);
    final uri = Uri.tryParse(requestUrl);
    final isRemote =
        uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
    if (!isRemote && !AppPlatform.supportsFileSystem) {
      throw const FormatException('当前平台不支持本地订阅文件，仅支持 HTTP/HTTPS 地址');
    }
    final localFile = isRemote ? null : File(requestUrl);
    if (!isRemote && (localFile == null || !await localFile.exists())) {
      throw const FormatException('仅支持 HTTP/HTTPS 订阅地址');
    }

    final uaHint = isRemote ? (uri.queryParameters['ua'] ?? '') : '';
    try {
      final content = isRemote
          ? await _fetch(uri, uaHint)
          : await localFile!.readAsString();
      final catalog = _parser.parse(content, uaHint: uaHint);
      if (catalog.isEmpty) {
        throw const FormatException('订阅中没有可播放频道');
      }
      await _cache.save(content);
      return catalog;
    } catch (error) {
      final cached = await _cache.load();
      if (cached != null) {
        final catalog = _parser.parse(cached);
        if (!catalog.isEmpty) return catalog;
      }
      rethrow;
    }
  }

  Future<String> _fetch(Uri uri, String uaHint) async {
    final response = await _client
        .get(
          uri,
          headers: <String, String>{
            if (uaHint.isNotEmpty) 'User-Agent': uaHint,
          },
        )
        .timeout(_timeout);
    if (response.statusCode != 200) {
      throw Exception('订阅请求失败：HTTP ${response.statusCode}');
    }
    return response.body;
  }

  void dispose() {
    if (_ownsClient) _client.close();
  }
}
