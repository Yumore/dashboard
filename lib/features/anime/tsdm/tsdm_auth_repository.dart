import 'dart:convert';

import 'package:dashboard/features/anime/tsdm/tsdm_api_urls.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_auth_status.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_cookie_store.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_exception.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_html_ext.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_http_client.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_login_result.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_string_ext.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_user_credential.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_user_login_info.dart';
import 'package:flutter/foundation.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import 'package:dashboard/features/anime/tsdm/tsdm_selector_compat.dart';

/// Forum account authentication.
///
/// Ported from `tsdm_client/lib/features/authentication/repository/authentication_repository.dart`.
/// The source pushed a `rxdart` `BehaviorSubject<AuthStatus>`; the port exposes
/// the same broadcast as a [ValueNotifier] so no extra dependency is needed.
///
/// Credentials are never hard-coded: callers inject a [TsdmUserCredential], and
/// the session is persisted through an injected [TsdmCookieStore].
class TsdmAuthRepository {
  /// Create the repository.
  TsdmAuthRepository({
    required this.client,
    TsdmCookieStore? cookieStore,
    this.loadLoginUid,
  }) : cookieStore = cookieStore ?? client.cookieStore;

  /// Transport used for all authentication requests.
  final TsdmHttpClient client;

  /// Cookie jar of the session.
  final TsdmCookieStore cookieStore;

  /// Loader of the persisted login uid, used by [restoreSession].
  final Future<int?> Function()? loadLoginUid;

  /// Current authentication status.
  final ValueNotifier<TsdmAuthStatus> authStatus = ValueNotifier(
    const TsdmAuthStatusUnknown(),
  );

  /// Regex matching the layer login hash of the login form action url.
  static final _layerLoginRe = RegExp(r'layer_login_(?<Hash>\w+)');

  /// Regex matching the `formhash` hidden input value.
  static final _formHashRe = RegExp(r'formhash" value="(?<FormHash>\w+)"');

  /// Current login info, empty when nobody is authenticated.
  TsdmUserLoginInfo userLoginInfo = const TsdmUserLoginInfo();

  /// Fetch the login form hashes.
  ///
  /// Throws [HttpRequestFailedException] for a non 200 response,
  /// [LoginFormHashNotFoundException] and [LoginInvalidFormHashException] when
  /// either hash is missing from the form.
  Future<TsdmLoginHash> fetchHash() async {
    final response = await client.buildNoCookie().get(TsdmApiUrls.fakeFormUrl);
    if (response.statusCode != 200) {
      throw HttpRequestFailedException(response.statusCode);
    }
    final loginHash = _layerLoginRe
        .firstMatch(response.data)
        ?.namedGroup('Hash');
    if (loginHash == null) {
      throw const LoginFormHashNotFoundException();
    }
    final formHash = _formHashRe
        .firstMatch(response.data)
        ?.namedGroup('FormHash');
    if (formHash == null) {
      throw const LoginInvalidFormHashException();
    }
    return TsdmLoginHash(formHash: formHash, loginHash: loginHash);
  }

  /// Try to restore a previously saved session.
  ///
  /// Returns the restored login info, or null when no session could be loaded.
  Future<TsdmUserLoginInfo?> restoreSession() async {
    final loader = loadLoginUid;
    if (loader == null) {
      return null;
    }
    final uid = await loader();
    if (uid == null || uid <= 0) {
      return null;
    }
    _markUnauthenticated();
    final info = TsdmUserLoginInfo(uid: uid);
    final loaded = await cookieStore.loadCookieFromStorage(info);
    if (!loaded) {
      return null;
    }
    final restored = await checkAuthenticationState();
    return restored;
  }

  /// Login with a password credential.
  ///
  /// Uses a no-cookie client with an injected empty cookie store so a stale
  /// cookie can never take part in the login, matching the source.
  Future<TsdmUserLoginInfo> loginWithPassword(
    TsdmUserCredential credential,
  ) async {
    _markUnauthenticated();

    final authClient = client.buildNoCookie();
    final response = await authClient.postForm(
      Uri.parse(TsdmApiUrls.loginBaseUrl),
      credential.toJson(),
    );
    if (response.statusCode != 200) {
      throw HttpRequestFailedException(response.statusCode);
    }

    try {
      final loginResult = TsdmLoginResult.fromJson(
        jsonDecode(response.data) as Map<String, dynamic>,
      );
      if (loginResult.status != 0) {
        throw LoginOtherErrorException(
          'login failed, status=${loginResult.status}',
        );
      }
      final info = loginResult.toTsdmUserLoginInfo();
      if (info == null) {
        throw const LoginUserInfoNotFoundException();
      }
      cookieStore.updateUserInfo(info);
      await cookieStore.saveCookieToStorage();
      _markAuthenticated(info);
      return info;
    } on LoginOtherErrorException {
      rethrow;
    } on LoginUserInfoNotFoundException {
      rethrow;
    } catch (_) {
      // Not a successful login body: map the server message to a typed failure.
      Object? decoded;
      try {
        decoded = jsonDecode(response.data);
      } catch (_) {
        decoded = null;
      }
      if (decoded is! Map) {
        throw const LoginOtherErrorException('message not found');
      }
      final message = decoded['message'];
      switch (message) {
        case TsdmLoginResult.messageLoginInvalid:
          throw const LoginInvalidCredentialException();
        case 'login_strike':
          throw const LoginAttemptLimitException();
        case TsdmLoginResult.messageCaptchaError:
          throw const LoginIncorrectCaptchaException();
        default:
          throw LoginOtherErrorException('unknown error message $message');
      }
    }
  }

  /// Login from a response document that already carries a valid session.
  Future<TsdmUserLoginInfo> loginWithDocument(dom.Document document) async {
    final info = parseUserInfoFromDocument(document);
    if (info == null) {
      throw const LoginUserInfoNotFoundException();
    }
    cookieStore.updateUserInfo(info);
    await cookieStore.saveCookieToStorage();
    _markAuthenticated(info);
    return info;
  }

  /// Check the current authentication state of the stored session.
  ///
  /// Returns the parsed login info, or null when the session is invalid.
  Future<TsdmUserLoginInfo?> checkAuthenticationState() async {
    final response = await client.get(TsdmApiUrls.checkAuthUrl);
    if (response.statusCode != 200) {
      throw HttpRequestFailedException(response.statusCode);
    }
    final document = html_parser.parse(response.data);
    final info = parseUserInfoFromDocument(document);
    if (info == null) {
      _markUnauthenticated();
      return null;
    }
    userLoginInfo = info;
    return info;
  }

  /// Check the authentication state through the mobile json endpoint.
  ///
  /// Throws [SwitchUserNotAuthedException] when the server reports a non zero
  /// status for the switched session.
  Future<TsdmUserLoginInfo> checkAuthenticationStateV2() async {
    final response = await client.get(TsdmApiUrls.checkAuthUrlV2);
    if (response.statusCode != 200) {
      throw HttpRequestFailedException(response.statusCode);
    }
    final decoded = jsonDecode(response.data);
    if (decoded is! Map || decoded['status'] != 0) {
      throw const SwitchUserNotAuthedException();
    }
    final info = userLoginInfo;
    _markAuthenticated(info);
    return info;
  }

  /// Logout the current session.
  Future<void> logout() async {
    if (userLoginInfo.isEmpty) {
      return;
    }

    final authResponse = await client.get(TsdmApiUrls.checkAuthUrl);
    if (authResponse.statusCode != 200) {
      throw HttpRequestFailedException(authResponse.statusCode);
    }
    final authDocument = html_parser.parse(authResponse.data);
    final info = parseUserInfoFromDocument(authDocument);
    if (info == null) {
      _markUnauthenticated();
      return;
    }

    final formHash = _formHashRe
        .firstMatch(authDocument.body?.innerHtml ?? '')
        ?.namedGroup('FormHash');
    if (formHash == null) {
      throw const LogoutFormHashNotFoundException();
    }

    final logoutResponse = await client.get(TsdmApiUrls.logoutUrl(formHash));
    if (logoutResponse.statusCode != 200) {
      throw HttpRequestFailedException(logoutResponse.statusCode);
    }
    final logoutDocument = html_parser.parse(logoutResponse.data);
    final messageNode = logoutDocument.getElementById('messagetext');
    if (messageNode == null || !messageNode.innerHtml.contains('已退出')) {
      throw const LogoutFailedException();
    }

    await cookieStore.deleteCookieByUid(userLoginInfo);
    await cookieStore.clearUserInfoAndCookie();
    _markUnauthenticated();
  }

  /// Switch to the session of [info].
  Future<void> switchUser(TsdmUserLoginInfo info) async {
    final loaded = await cookieStore.loadCookieFromStorage(info);
    if (!loaded) {
      throw const LoginInvalidCredentialException();
    }
    userLoginInfo = info;
    try {
      await checkAuthenticationStateV2();
    } on SwitchUserNotAuthedException {
      _markUnauthenticated();
      rethrow;
    }
    await cookieStore.saveCookieToStorage();
    _markAuthenticated(info);
  }

  /// Parse the logged user info from a forum document.
  ///
  /// Understands both the layout with an avatar and the layout without one.
  /// Returns null when the username or the uid is missing. The username text is
  /// taken by walking to the deepest first child, matching the source.
  static TsdmUserLoginInfo? parseUserInfoFromDocument(dom.Document document) {
    final userNode =
        document.q('div#hd div.wp div.hdc.cl div#um p strong.vwmy a') ??
        document.q('div#inner_stat > strong > a');
    if (userNode == null) {
      return null;
    }
    final username = userNode.firstEndDeepText();
    final href = userNode.firstHref();
    final uid = href?.split('uid=').lastOrNull?.parseToInt();
    if (username == null || username.isEmpty || uid == null) {
      return null;
    }
    return TsdmUserLoginInfo(username: username, uid: uid);
  }

  void _markAuthenticated(TsdmUserLoginInfo info) {
    userLoginInfo = info;
    cookieStore.updateUserInfo(info);
    authStatus.value = TsdmAuthStatusAuthed(info);
  }

  void _markUnauthenticated() {
    userLoginInfo = const TsdmUserLoginInfo();
    authStatus.value = const TsdmAuthStatusNotAuthed();
  }
}
