import 'dart:convert';
import 'dart:math' as math;

import 'package:crypto/crypto.dart';

/// Ports `lib/network/jm_network/headers.dart` from PicaComic.
///
/// The 禁漫天堂 API signs every request with an MD5 `token` derived from the
/// current unix time and the static [jmAuthKey]; `tokenparam` carries the time
/// and the app version.
class JmHeaderBuilder {
  JmHeaderBuilder._();

  static const String jmVersion = '1.7.2';
  static const String jmAuthKey = '18comicAPPContent';

  /// `md5("$time$jmAuthKey")`, lowercase hex.
  static String token(int time) =>
      md5.convert(utf8.encode('$time$jmAuthKey')).toString();

  /// `"<time>,<version>"`.
  static String tokenParam(int time) => '$time,$jmVersion';

  /// Nine random lowercase alphanumerics, stable for one client instance.
  static String deviceId([math.Random? random]) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final rng = random ?? math.Random();
    final buffer = StringBuffer();
    for (var i = 0; i < 9; i++) {
      buffer.write(chars[rng.nextInt(chars.length)]);
    }
    return buffer.toString();
  }

  /// The webview user agent template, with [device] interpolated.
  static String userAgent(String device) =>
      'Mozilla/5.0 (Linux; Android 13; $device Build/TQ1A.230305.002; wv) '
      'AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 '
      'Chrome/114.0.5735.196 Safari/537.36';

  static Map<String, String> build({
    required int time,
    required String baseUrl,
    required String device,
    Map<String, String>? headers,
    String? cookie,
    bool post = false,
  }) => {
    'token': token(time),
    'tokenparam': tokenParam(time),
    'user-agent': userAgent(device),
    'accept-encoding': 'gzip',
    'Host': baseUrl.replaceFirst('https://', '').replaceFirst('http://', ''),
    if (cookie != null && cookie.isNotEmpty) 'Cookie': cookie,
    ...?headers,
    if (post) 'Content-Type': 'application/x-www-form-urlencoded',
  };
}
