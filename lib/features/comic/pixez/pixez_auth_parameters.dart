import 'dart:convert';

import 'package:crypto/crypto.dart';

/// The public OAuth client pair and request signing parameters shipped in the
/// open-source pixez client (`lib/network/oauth_client.dart`).
///
/// These are the application's public client id/secret, not a user's login
/// token. A user's `access_token` is never hard-coded here; it is injected via
/// `PixezAuthStore`.
class PixezAuthParameters {
  const PixezAuthParameters._();

  /// Salt appended to `X-Client-Time` before hashing.
  static const String hashSalt =
      '28c1fdd170a5204386cb1313c7077b34f83e4aaf4aa829ce78c231e05b0bae2c';

  /// Public pixiv Android OAuth client id.
  static const String clientId = 'MOBrBDS8blbauoSck0ZfDbtuzpyT';

  /// Public pixiv Android OAuth client secret.
  static const String clientSecret =
      'lsACyCD94FhDUtGTXi3QzcFE2uU1hqtDaKeqrdwj';

  /// Device token the source uses for password grant.
  static const String defaultDeviceToken = 'pixiv';

  /// Redirect URI registered for the Android client.
  static const String redirectUri =
      'https://app-api.pixiv.net/web/v1/users/auth/pixiv/callback';

  /// `yyyy-MM-dd'T'HH:mm:ss'+00:00'`, matching the source's DateFormat.
  ///
  /// The source formats `DateTime.now()` (local time) but appends a literal
  /// `+00:00`; that quirk is preserved because pixiv validates the hash pair.
  static String isoDate(DateTime now) {
    String two(int value) => value.toString().padLeft(2, '0');
    final year = now.year.toString().padLeft(4, '0');
    return '$year-${two(now.month)}-${two(now.day)}'
        'T${two(now.hour)}:${two(now.minute)}:${two(now.second)}+00:00';
  }

  /// `md5(time + hashSalt)`, lowercase hex.
  static String clientHash(String time) =>
      md5.convert(utf8.encode('$time$hashSalt')).toString();

  /// Body of `POST /auth/token` with `grant_type=password`.
  static Map<String, String> passwordTokenBody({
    required String username,
    required String password,
    String deviceToken = defaultDeviceToken,
  }) {
    return <String, String>{
      'client_id': clientId,
      'client_secret': clientSecret,
      'grant_type': 'password',
      'username': username,
      'password': password,
      // The capital D is what the source sends.
      'Device_token': deviceToken,
      'get_secure_url': 'true',
      'include_policy': 'true',
    };
  }

  /// Body of `POST /auth/token` with `grant_type=refresh_token`.
  ///
  /// The source defines REFRESH_CLIENT_ID/SECRET but its
  /// `postRefreshAuthToken` actually sends the normal client pair.
  static Map<String, String> refreshTokenBody(String refreshToken) {
    return <String, String>{
      'client_id': clientId,
      'client_secret': clientSecret,
      'grant_type': 'refresh_token',
      'refresh_token': refreshToken,
      'include_policy': 'true',
    };
  }

  /// Body of `POST /auth/token` with `grant_type=authorization_code`.
  static Map<String, String> authorizationCodeBody({
    required String code,
    required String codeVerifier,
  }) {
    return <String, String>{
      'code': code,
      'redirect_uri': redirectUri,
      'grant_type': 'authorization_code',
      'include_policy': 'true',
      'client_id': clientId,
      'code_verifier': codeVerifier,
      'client_secret': clientSecret,
    };
  }

  /// URL opened in the source's login WebView.
  static String webLoginUrl({
    required String codeChallenge,
    bool createAccount = false,
  }) {
    final path = createAccount
        ? 'provisional-accounts/create'
        : 'login';
    return Uri.https('app-api.pixiv.net', '/web/v1/$path', {
      'code_challenge': codeChallenge,
      'code_challenge_method': 'S256',
      'client': 'pixiv-android',
    }).toString();
  }
}
