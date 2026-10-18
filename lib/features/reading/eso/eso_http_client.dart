import 'dart:convert';

import 'package:http/http.dart' as http;

/// eso 的 HTTP 客户端封装（移植 `lib/api/analyze_url_client.dart`）。
///
/// 宿主不再使用 `IOClient` + `badCertificateCallback`（会引入 `dart:io`，
/// 破坏 Web 平台编译），自签名证书站点因此不支持——见交付说明。
/// [client] 可注入，测试里传入假的 `http.Client` 即可完全离线。
class EsoHttpClient {
  EsoHttpClient({http.Client? client}) : client = client ?? http.Client();

  final http.Client client;

  Future<http.Response> get(String url, {Map<String, String>? headers}) =>
      client.get(Uri.parse(url), headers: headers);

  Future<http.Response> put(String url,
          {Map<String, String>? headers, Object? body}) =>
      client.put(Uri.parse(url), headers: headers, body: body);

  /// POST；源实现会在 301/302 时改用 GET 跟随 `location`。
  Future<http.Response> post(String url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    final response =
        await client.post(Uri.parse(url), headers: headers, body: body, encoding: encoding);
    if (response.statusCode == 302 || response.statusCode == 301) {
      final location = response.headers['location'];
      if (location != null) {
        return get(Uri.parse(url).resolve(location).toString(), headers: headers);
      }
    }
    return response;
  }
}
