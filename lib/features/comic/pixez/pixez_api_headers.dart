import 'pixez_auth_parameters.dart';

/// The app-api / OAuth identification headers of the pixiv Android client.
///
/// Ports the headers built in pixez `lib/network/api_client.dart` and
/// `lib/network/oauth_client.dart`, including the `X-Client-Hash` derivation.
class PixezApiHeaders {
  const PixezApiHeaders._();

  static const String acceptLanguage = 'zh-CN';
  static const String appOs = 'Android';
  static const String appOsVersion = 'Android 10.0';
  static const String appVersion = '5.0.166';
  static const String userAgent =
      'PixivAndroidApp/5.0.166 (Android 10.0; Pixel C)';

  /// The OAuth client starts with the older app signature in the source.
  static const String oauthAppOsVersion = 'Android 6.0';
  static const String oauthUserAgent =
      'PixivAndroidApp/5.0.155 (Android 6.0; Pixel C)';

  static const String apiHost = 'app-api.pixiv.net';
  static const String oauthHost = 'oauth.secure.pixiv.net';

  /// Headers for pixiv app-api requests.
  ///
  /// The source's `RefreshTokenInterceptor` adds a Bearer token to every
  /// request, so [accessToken] is expected to be non-empty by the time a
  /// request is built. An empty token omits the header (the API client rejects
  /// the call before it reaches here).
  static Map<String, String> forApi({
    required DateTime now,
    required String accessToken,
  }) {
    final time = PixezAuthParameters.isoDate(now);
    return <String, String>{
      'X-Client-Time': time,
      'X-Client-Hash': PixezAuthParameters.clientHash(time),
      'User-Agent': userAgent,
      'accept-language': acceptLanguage,
      'App-OS': appOs,
      'App-OS-Version': appOsVersion,
      'App-Version': appVersion,
      'Host': apiHost,
      if (accessToken.isNotEmpty) 'Authorization': 'Bearer $accessToken',
    };
  }

  /// Headers for the OAuth token endpoint (no Authorization header).
  static Map<String, String> forOAuth({required DateTime now}) {
    final time = PixezAuthParameters.isoDate(now);
    return <String, String>{
      'X-Client-Time': time,
      'X-Client-Hash': PixezAuthParameters.clientHash(time),
      'User-Agent': oauthUserAgent,
      'accept-language': acceptLanguage,
      'App-OS': appOs,
      'App-OS-Version': oauthAppOsVersion,
      'App-Version': appVersion,
      'Host': oauthHost,
    };
  }
}
