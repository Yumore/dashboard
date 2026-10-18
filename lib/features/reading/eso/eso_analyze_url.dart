import 'dart:convert';

import 'package:dashboard/features/reading/eso/eso_http_client.dart';
import 'package:dashboard/features/reading/eso/eso_rule.dart';
import 'package:dashboard/features/reading/eso/eso_rule_exception.dart';
import 'package:enough_convert/enough_convert.dart';
import 'package:http/http.dart' as http;

/// 书源请求构造（移植 eso `lib/api/analyze_url.dart`）。
///
/// 负责把规则里的 `$keyword` `$page` `$host` `$result` `$pageSize`
/// `searchKey` `searchPage` 占位符替换成真实值，并按规则里的
/// `url / method / headers / body / encoding` 发请求。
class EsoAnalyzeUrl {
  /// 规则 URL 里的占位符。
  static final RegExp placeholderPattern = RegExp(
      r'\$keyword|\$page|\$host|\$result|\$pageSize|searchKey|searchPage');

  /// 默认 UA（逐字移植）。
  static const String defaultUserAgent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) '
      'Chrome/98.0.4758.80 Safari/537.36 Edg/98.0.1108.50';

  static Future<http.Response> urlRuleParser(
    String url,
    EsoRule rule,
    EsoHttpClient client, {
    String keyword = '',
    String result = '',
    int? page,
    int? pageSize,
  }) async {
    url = url.trim();
    if (url == 'null') return http.Response('', 200);
    if (url.startsWith('@js:')) {
      throw EsoRuleException('宿主未移植 @js: 规则引擎', rule: url.substring(4));
    }
    final values = <String, dynamic>{
      r'$keyword': keyword,
      r'$page': page,
      r'$host': rule.host,
      r'$result': result,
      r'$pageSize': pageSize,
      'searchKey': keyword,
      'searchPage': page,
    };
    return parser(
      url.replaceAllMapped(placeholderPattern, (m) => '${values[m.group(0)]}'),
      rule,
      client,
    );
  }

  static Future<http.Response> parser(
      dynamic url, EsoRule rule, EsoHttpClient client) async {
    if (url is String) {
      url = url.trim();
      if (url.isEmpty) return client.get(rule.host);
      if (url.startsWith('{')) {
        url = jsonDecode(url);
      }
    }

    final headers = <String, String>{'user-agent': defaultUserAgent};
    if (rule.cookies.trim().isNotEmpty) {
      headers['cookie'] = rule.cookies;
    }
    if (rule.userAgent.trim().isNotEmpty) {
      final ua = rule.userAgent.trim();
      if (ua.startsWith('{') && ua.endsWith('}')) {
        headers.addAll((jsonDecode(ua) as Map)
            .map((k, v) => MapEntry(k.toString().toLowerCase(), '$v')));
      } else {
        headers['user-agent'] = ua;
      }
    }

    if (url is Map) {
      final r = url.map((k, v) => MapEntry(k.toString().toLowerCase(), v));
      final rawHeaders = r['headers'];
      if (rawHeaders is Map) {
        headers.addAll(rawHeaders.map((k, v) => MapEntry('$k', '$v')));
      }

      dynamic body = r['body'];
      final method = r['method']?.toString().toLowerCase();
      final rEncoding = r['encoding'] == null ? null : '${r['encoding']}';
      var u = urlFix('${r['url']}', rule.host);
      if (rEncoding != null) {
        final encoding =
            rEncoding.contains('gb') ? gbk : (Encoding.getByName(rEncoding) ?? utf8);
        String encode(String value) => value.replaceAllMapped(
            RegExp(r'[^\x00-\x7F]+'),
            (match) => encoding
                .encode(match.group(0)!)
                .map((code) => _urlEncode(code.toRadixString(16).toUpperCase()))
                .join());
        u = encode(u);
        if (body is String) {
          body = encode(body);
        }
      }
      if (method == null || method == 'get') {
        return client.get(u, headers: headers);
      }
      if (method == 'put') {
        return client.put(u, headers: headers, body: body);
      }
      if (method == 'post') {
        return client.post(
          u,
          headers: headers,
          body: body,
          encoding: rEncoding != null && body is Map
              ? (rEncoding.contains('gb')
                  ? gbk
                  : (Encoding.getByName(rEncoding) ?? utf8))
              : null,
        );
      }
      throw const EsoRuleException('url 规则的 method 只支持 get/put/post');
    }
    return client.get(urlFix('$url', rule.host), headers: headers);
  }

  static String _urlEncode(String s) {
    var value = s;
    if (value.length.isOdd) value = '0$value';
    final sb = StringBuffer();
    for (var i = 0; i < value.length; i += 2) {
      sb.write('%${value[i]}${value[i + 1]}');
    }
    return sb.toString();
  }

  /// 相对地址补全：`//x` 沿用 host 协议，`/x` 拼 host，其余原样。
  static String urlFix(String url, String host) {
    url = url.trim();
    host = host.trim();
    if (url.startsWith('//')) {
      return host.startsWith('https') ? 'https:$url' : 'http:$url';
    } else if (!url.startsWith('http') && !url.startsWith('ftp')) {
      return host + url;
    }
    return url;
  }
}
