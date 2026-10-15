import 'dart:convert';

import 'package:dashboard/features/anime/anime_playback.dart';
import 'package:dashboard/features/media/media_stream_source.dart';
import 'package:html/parser.dart' as html;
import 'package:http/http.dart' as http;

/// Port of AnimeTV's encoded iframe -> JSON endpoint -> HD/SD stream pipeline.
class AnimeEpisodeResolver {
  AnimeEpisodeResolver({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  Future<AnimePlayback> resolve(Uri page) async {
    final document = html.parse(await _get(page));
    final text = document.querySelector('td.larkax')?.text ?? '';
    final encoded = RegExp(
      r'\[(.*?)\]',
      dotAll: true,
    ).firstMatch(text)?.group(1);
    final offset = int.tryParse(
      RegExp(r'\)\)\s*-\s*(\d+)').firstMatch(text)?.group(1) ?? '',
    );
    if (encoded == null || offset == null) {
      throw const FormatException('剧集页面中没有可识别的视频源');
    }
    final iframe = _decodeIframe(page, encoded, offset);
    final script = await _get(iframe);
    final apiPath = RegExp(
      r'''get\(\s*["']([^"']+)["']''',
    ).firstMatch(script)?.group(1);
    if (apiPath == null) throw const FormatException('视频源接口未找到');
    final api = iframe.resolve(apiPath);
    final decoded = jsonDecode(
      await _get(
        api,
        headers: {
          'Referer': page.toString(),
          'x-requested-with': 'XMLHttpRequest',
        },
      ),
    );
    if (decoded is! Map) throw const FormatException('视频源响应格式错误');
    final sources = _streams(decoded, page);
    if (sources.isEmpty) throw const FormatException('该剧集暂无可用播放线路');
    return AnimePlayback(
      title:
          document.querySelector('.ilxbaslik8 > h1 > a')?.text.trim() ?? '动漫播放',
      page: page,
      sources: sources,
      previous: _related(
        page,
        document.querySelector('a[rel="prev"]')?.attributes['href'],
      ),
      next: _related(
        page,
        document.querySelector('a[rel="next"]')?.attributes['href'],
      ),
    );
  }

  Uri _decodeIframe(Uri page, String encoded, int offset) {
    final codes = encoded.split(',').map((part) {
      final value = part.trim().replaceAll(RegExp(r'''^["']|["']$'''), '');
      final decoded = utf8.decode(base64.decode(value));
      final code =
          int.parse(decoded.replaceAll(RegExp(r'[^0-9]'), '')) - offset;
      if (code < 0 || code > 0x10ffff) throw const FormatException('视频源编码错误');
      return code;
    });
    final fragment = html.parseFragment(String.fromCharCodes(codes));
    final src = fragment.querySelector('[src]')?.attributes['src'];
    if (src == null || src.isEmpty) throw const FormatException('视频源地址为空');
    return _httpUri(page.resolve(src));
  }

  List<MediaStreamSource> _streams(Map<dynamic, dynamic> data, Uri page) {
    final result = <MediaStreamSource>[];
    final seen = <Uri>{};
    for (final quality in {'hd': '1080p', 'enc': '480p'}.entries) {
      final id = data[quality.key];
      if (id is! String || id.isEmpty) continue;
      for (final hostKey in ['server', 'cdn']) {
        final host = data[hostKey];
        if (host is! String || host.isEmpty) continue;
        final url = _httpUri(
          page.resolve(host),
        ).resolve('/getvid').replace(queryParameters: {'evid': id});
        if (!seen.add(url)) continue;
        result.add(
          MediaStreamSource(
            label: '${quality.value} · ${hostKey == 'cdn' ? '备用' : '主线路'}',
            url: url,
            headers: {'Referer': page.toString()},
          ),
        );
      }
    }
    return result;
  }

  Uri? _related(Uri page, String? value) {
    if (value == null || value.isEmpty) return null;
    return _httpUri(page.resolve(value));
  }

  Uri _httpUri(Uri uri) {
    if (!['http', 'https'].contains(uri.scheme) || uri.host.isEmpty) {
      throw const FormatException('视频地址必须使用 HTTP 或 HTTPS');
    }
    return uri;
  }

  Future<String> _get(Uri uri, {Map<String, String>? headers}) async {
    final response = await _client
        .get(_httpUri(uri), headers: headers)
        .timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw http.ClientException('视频源请求失败：HTTP ${response.statusCode}', uri);
    }
    return response.body;
  }

  void dispose() => _client.close();
}
