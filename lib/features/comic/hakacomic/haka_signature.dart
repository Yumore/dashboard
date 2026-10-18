import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dashboard/features/comic/hakacomic/haka_config.dart';
import 'package:dashboard/features/comic/hakacomic/haka_method.dart';

/// HMAC-SHA256 signature over `lowercase(url + timestamp + nonce + method + apiKey)`.
///
/// Ported from `haka_comic/lib/network/utils.dart:69-74`.
String hakaSignature({
  required String url,
  required String timestamp,
  required String nonce,
  required HakaMethod method,
}) {
  final key = (url + timestamp + nonce + method.value + HakaConfig.apiKey)
      .toLowerCase();
  final hmac = Hmac(sha256, utf8.encode(HakaConfig.secretKey));
  return hmac.convert(utf8.encode(key)).toString();
}

/// Unix seconds as a string (`haka_comic/lib/network/utils.dart:76-78`).
String hakaTimestamp([DateTime? now]) {
  return ((now ?? DateTime.now()).millisecondsSinceEpoch ~/ 1000).toString();
}

/// GET requests are signed over `path?queryString`, every other verb over the
/// bare [path] (`haka_comic/lib/network/client.dart:66-77`).
String hakaSignedUrl({
  required HakaMethod method,
  required String path,
  Map<String, dynamic>? query,
}) {
  if (method != HakaMethod.get) return path;
  final queryString = Uri(
    queryParameters: (query ?? const {}).map(
      (key, value) => MapEntry(key, value.toString()),
    ),
  ).query;
  return queryString.isEmpty ? path : '$path?$queryString';
}

/// Complete header set, including the four signed/dynamic entries
/// (`haka_comic/lib/network/utils.dart:80-91`).
Map<String, String> hakaHeaders({
  required String url,
  required HakaMethod method,
  required HakaConfig config,
  DateTime? now,
}) {
  final timestamp = hakaTimestamp(now);
  return {
    ...config.defaultHeaders,
    'time': timestamp,
    'signature': hakaSignature(
      url: url,
      timestamp: timestamp,
      nonce: HakaConfig.nonce,
      method: method,
    ),
    'authorization': config.token,
    'image-quality': config.imageQuality.name,
  };
}
