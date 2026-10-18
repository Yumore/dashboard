import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pixez_oauth_token.dart';

/// Injectable holder of the pixiv login session.
///
/// The source app keeps accounts in a sqflite table; this port stores the
/// single active access/refresh token in shared_preferences. No token is
/// bundled with the app: an empty store is the normal logged-out state and
/// callers render "需要登录令牌".
class PixezAuthStore extends ChangeNotifier {
  PixezAuthStore({
    String? accessToken,
    String? refreshToken,
    bool persist = true,
  }) : _accessToken = accessToken,
       _refreshToken = refreshToken,
       _persist = persist,
       _loaded = !persist;

  /// Process-wide store used by the default controllers.
  static final PixezAuthStore instance = PixezAuthStore();

  static const String accessTokenKey = 'pixez_access_token';
  static const String refreshTokenKey = 'pixez_refresh_token';

  final bool _persist;
  String? _accessToken;
  String? _refreshToken;
  bool _loaded;
  Future<void>? _loadFuture;

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  bool get hasAccessToken =>
      _accessToken != null && _accessToken!.trim().isNotEmpty;

  /// Reads persisted tokens once. In-memory stores are loaded immediately.
  Future<void> ensureLoaded() {
    if (_loaded) return Future<void>.value();
    return _loadFuture ??= _load();
  }

  Future<void> _load() async {
    if (_persist) {
      final prefs = await SharedPreferences.getInstance();
      _accessToken = prefs.getString(accessTokenKey);
      _refreshToken = prefs.getString(refreshTokenKey);
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> saveToken(PixezOAuthToken token) async {
    _accessToken = token.accessToken;
    _refreshToken = token.refreshToken;
    if (_persist) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(accessTokenKey, _accessToken ?? '');
      if (_refreshToken != null && _refreshToken!.isNotEmpty) {
        await prefs.setString(refreshTokenKey, _refreshToken!);
      } else {
        await prefs.remove(refreshTokenKey);
      }
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> saveAccessToken(String token) async {
    final trimmed = token.trim();
    if (trimmed.isEmpty) return clear();
    _accessToken = trimmed;
    if (_persist) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(accessTokenKey, trimmed);
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> clear() async {
    _accessToken = null;
    _refreshToken = null;
    if (_persist) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(accessTokenKey);
      await prefs.remove(refreshTokenKey);
    }
    _loaded = true;
    notifyListeners();
  }
}
