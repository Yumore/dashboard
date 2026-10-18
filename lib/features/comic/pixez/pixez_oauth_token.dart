import 'pixez_json.dart';

/// Parsed `POST /auth/token` response.
///
/// The source wraps the payload in `{"response": {...}}`; both the wrapped and
/// flat shapes are accepted here.
class PixezOAuthToken {
  const PixezOAuthToken({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.tokenType,
    required this.userId,
    required this.userName,
    required this.userAccount,
  });

  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final String tokenType;
  final int userId;
  final String userName;
  final String userAccount;

  bool get isValid => accessToken.isNotEmpty;

  factory PixezOAuthToken.fromJson(Map<String, dynamic> json) {
    final body = json['response'] is Map
        ? pixezMap(json['response'])
        : json;
    final user = pixezMap(body['user']);
    return PixezOAuthToken(
      accessToken: pixezString(body['access_token']),
      refreshToken: pixezString(body['refresh_token']),
      expiresIn: pixezInt(body['expires_in']),
      tokenType: pixezString(body['token_type'], fallback: 'bearer'),
      userId: pixezInt(user['id']),
      userName: pixezString(user['name']),
      userAccount: pixezString(user['account']),
    );
  }
}
