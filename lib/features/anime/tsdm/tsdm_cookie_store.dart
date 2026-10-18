import 'dart:convert';

import 'package:dashboard/features/anime/tsdm/tsdm_http_config.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_user_login_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cookie key prefix used by the forum software.
const tsdmCookiePrefix = 'tsdm';

/// Name of the forum authentication cookie.
const tsdmAuthCookieName = '${tsdmCookiePrefix}_auth';

/// Cookie name carrying the current point change notice.
const tsdmCreditNoticeCookieName = '${tsdmCookiePrefix}_creditnotice';

/// In-memory cookie jar with optional persistence to `shared_preferences`.
///
/// Ported from `tsdm_client/lib/shared/providers/cookie_provider/cookie_provider.dart`.
/// The source implemented the `cookie_jar` `Storage` interface; the host does
/// not depend on `cookie_jar`, so this class keeps the same cookie semantics
/// (the authenticated cookie wins over anonymous writes, persistence only
/// happens while the session is authenticated) behind a small api used by
/// [TsdmHttpClient].
class TsdmCookieStore {
  /// Create a store, optionally with a shared preferences instance.
  TsdmCookieStore({SharedPreferences? preferences})
    : _preferences = preferences;

  final Map<String, String> _cookieMap = {};
  SharedPreferences? _preferences;
  TsdmUserLoginInfo _userLoginInfo = const TsdmUserLoginInfo();

  /// Current login info of the stored session.
  TsdmUserLoginInfo get userLoginInfo => _userLoginInfo;

  /// Snapshot of the current cookie map.
  Map<String, String> get cookies =>
      Map<String, String>.unmodifiable(_cookieMap);

  /// Whether the jar currently holds an authenticated session.
  bool get isAuthed =>
      _cookieMap.values.any((value) => value.contains(tsdmAuthCookieName));

  Future<SharedPreferences> get _prefs async =>
      _preferences ??= await SharedPreferences.getInstance();

  /// Build the `cookie` header value of the current session.
  String buildCookieHeader() =>
      _cookieMap.entries.map((e) => '${e.key}=${e.value}').join('; ');

  /// Read a cookie, null when absent.
  String? read(String name) => _cookieMap[name];

  /// Read all cookies.
  Map<String, String> readAll() => Map<String, String>.of(_cookieMap);

  /// Write a cookie.
  ///
  /// A write by a non authenticated response must not overwrite an existing
  /// authenticated cookie, matching the source behavior.
  Future<void> write(String key, String value) async {
    final existing = _cookieMap[key];
    if (existing != null &&
        existing.contains(tsdmAuthCookieName) &&
        !value.contains(tsdmAuthCookieName)) {
      return;
    }
    _cookieMap[key] = value;
    await _syncCookie();
  }

  /// Delete a cookie by [key].
  Future<void> delete(String key) async {
    _cookieMap.remove(key);
    if (_cookieMap.isEmpty) {
      final info = _userLoginInfo;
      if (info.isComplete) {
        await _deleteUserCookie(info);
      }
    }
  }

  /// Clear the in-memory cookie map only.
  void clearCookies() => _cookieMap.clear();

  /// Reset both the user info and the cookie map.
  Future<void> clearUserInfoAndCookie() async {
    _userLoginInfo = const TsdmUserLoginInfo();
    _cookieMap.clear();
  }

  /// Update the in-memory login info.
  void updateUserInfo(TsdmUserLoginInfo info) => _userLoginInfo = info;

  /// Persist the current cookie map under the current user info key.
  Future<void> saveCookieToStorage() async {
    final info = _userLoginInfo;
    if (!info.isComplete || !isAuthed) {
      return;
    }
    final prefs = await _prefs;
    await prefs.setString(_cookieKey(info), jsonEncode(_cookieMap));
  }

  /// Load a persisted cookie map.
  ///
  /// Tries the uid first and falls back to the username, as the source does.
  /// Returns false when neither key identifies a stored session.
  Future<bool> loadCookieFromStorage(TsdmUserLoginInfo info) async {
    if (info.uid == null && info.username == null) {
      return false;
    }
    final prefs = await _prefs;
    final keys = <String>[
      if (info.uid != null) _cookieUidKey(info.uid!),
      if (info.username != null) _cookieUsernameKey(info.username!),
    ];
    for (final key in keys) {
      final raw = prefs.getString(key);
      if (raw == null || raw.isEmpty) {
        continue;
      }
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        continue;
      }
      _cookieMap
        ..clear()
        ..addAll(decoded.map((k, v) => MapEntry('$k', '$v')));
      _userLoginInfo = info;
      return true;
    }
    return false;
  }

  /// Delete the persisted cookie of [info].
  Future<void> deleteCookieByUid(TsdmUserLoginInfo info) async {
    if (!info.isComplete) {
      return;
    }
    await _deleteUserCookie(info);
  }

  Future<void> _deleteUserCookie(TsdmUserLoginInfo info) async {
    final prefs = await _prefs;
    await prefs.remove(_cookieKey(info));
    await prefs.remove(_cookieUidKey(info.uid!));
    await prefs.remove(_cookieUsernameKey(info.username!));
  }

  Future<void> _syncCookie() async {
    final info = _userLoginInfo;
    if (!info.isComplete || !isAuthed) {
      return;
    }
    await saveCookieToStorage();
  }

  static String _cookieKey(TsdmUserLoginInfo info) => _cookieUidKey(info.uid!);

  static String _cookieUidKey(int uid) => 'tsdm_cookie_uid_$uid';

  static String _cookieUsernameKey(String username) =>
      'tsdm_cookie_username_$username';

  /// Cookie lifetime in seconds, exposed for callers building persistence.
  static int get defaultCookieTime => TsdmHttpConfig.defaultCookieTime;
}
