import 'package:dio/dio.dart';

import 'models/pixez_bookmark_detail.dart';
import 'models/pixez_illust.dart';
import 'models/pixez_novel.dart';
import 'models/pixez_search_query.dart';
import 'models/pixez_user_detail.dart';
import 'models/pixez_user_preview.dart';
import 'pixez_api_config.dart';
import 'pixez_api_headers.dart';
import 'pixez_auth_parameters.dart';
import 'pixez_auth_required_exception.dart';
import 'pixez_auth_store.dart';
import 'pixez_bookmark_tags.dart';
import 'pixez_json.dart';
import 'pixez_next_url_resolver.dart';
import 'pixez_oauth_token.dart';
import 'pixez_paged_result.dart';
import 'pixez_recommendation.dart';

/// Hand-written port of pixez `lib/network/api_client.dart` +
/// `lib/network/oauth_client.dart`.
///
/// Differences from the source are deliberate and limited to:
/// * the login token is injected through [PixezAuthStore] instead of a global
///   account database;
/// * paging/refresh-token interceptors are folded into each method;
/// * responses are parsed into the local model classes instead of
///   json_serializable.
class PixezApiClient {
  PixezApiClient({
    Dio? dio,
    PixezAuthStore? auth,
    PixezApiConfig config = const PixezApiConfig(),
    DateTime Function()? clock,
  }) : _dio = dio ?? Dio(),
       _auth = auth ?? PixezAuthStore.instance,
       _config = config,
       _clock = clock ?? DateTime.now {
    _dio.options.baseUrl = config.baseUrl;
  }

  final Dio _dio;
  final PixezAuthStore _auth;
  final PixezApiConfig _config;
  final DateTime Function() _clock;

  PixezAuthStore get auth => _auth;

  PixezNextUrlResolver get _resolver =>
      PixezNextUrlResolver(baseUrl: _config.baseUrl);

  // ---------------------------------------------------------------- auth ---

  /// Throws [PixezAuthRequiredException] before any request when no token is
  /// configured. This mirrors the source's RefreshTokenInterceptor rejecting
  /// requests with an empty account.
  Future<void> _ensureAuthorized() async {
    await _auth.ensureLoaded();
    if (!_auth.hasAccessToken) {
      throw const PixezAuthRequiredException();
    }
  }

  Options _options({bool form = false}) {
    return Options(
      headers: PixezApiHeaders.forApi(
        now: _clock(),
        accessToken: _auth.accessToken ?? '',
      ),
      contentType: form ? Headers.formUrlEncodedContentType : null,
    );
  }

  Map<String, dynamic>? _compact(Map<String, dynamic>? query) {
    if (query == null) return null;
    final result = <String, dynamic>{};
    for (final entry in query.entries) {
      final value = entry.value;
      if (value == null) continue;
      if (value is String && value.isEmpty) continue;
      result[entry.key] = value;
    }
    return result.isEmpty ? null : result;
  }

  Future<Map<String, dynamic>> _getJson(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    await _ensureAuthorized();
    final response = await _dio.get<dynamic>(
      path,
      queryParameters: _compact(query),
      options: _options(),
    );
    return pixezResponseMap(response.data);
  }

  Future<Map<String, dynamic>> _postForm(
    String path,
    Map<String, dynamic> data,
  ) async {
    await _ensureAuthorized();
    final response = await _dio.post<dynamic>(
      path,
      data: data,
      options: _options(form: true),
    );
    return pixezResponseMap(response.data);
  }

  Future<Map<String, dynamic>> _postOAuth(Map<String, String> body) async {
    final response = await _dio.post<dynamic>(
      '${_config.oauthBaseUrl}/auth/token',
      data: body,
      options: Options(
        headers: PixezApiHeaders.forOAuth(now: _clock()),
        contentType: Headers.formUrlEncodedContentType,
      ),
    );
    return pixezResponseMap(response.data);
  }

  // -------------------------------------------------------------- oauth ---

  /// `POST /auth/token` with `grant_type=password`.
  ///
  /// The returned token is not persisted automatically; pass it to
  /// `PixezAuthStore.saveToken`.
  Future<PixezOAuthToken> loginWithPassword({
    required String username,
    required String password,
    String deviceToken = PixezAuthParameters.defaultDeviceToken,
  }) async {
    final json = await _postOAuth(
      PixezAuthParameters.passwordTokenBody(
        username: username,
        password: password,
        deviceToken: deviceToken,
      ),
    );
    return PixezOAuthToken.fromJson(json);
  }

  /// `POST /auth/token` with `grant_type=refresh_token`.
  Future<PixezOAuthToken> refreshAccessToken(String refreshToken) async {
    final json = await _postOAuth(
      PixezAuthParameters.refreshTokenBody(refreshToken),
    );
    return PixezOAuthToken.fromJson(json);
  }

  /// `POST /auth/token` with `grant_type=authorization_code`.
  Future<PixezOAuthToken> exchangeAuthorizationCode({
    required String code,
    required String codeVerifier,
  }) async {
    final json = await _postOAuth(
      PixezAuthParameters.authorizationCodeBody(
        code: code,
        codeVerifier: codeVerifier,
      ),
    );
    return PixezOAuthToken.fromJson(json);
  }

  // ------------------------------------------------------------- illusts ---

  /// `GET /v1/illust/recommended?filter=for_ios&include_ranking_label=true`
  Future<PixezRecommendation> getIllustRecommended() async {
    final json = await _getJson(
      '/v1/illust/recommended?filter=for_ios&include_ranking_label=true',
    );
    return PixezRecommendation.fromJson(json);
  }

  /// `GET /v1/manga/recommended?filter=for_ios&include_ranking_label=true`
  Future<PixezRecommendation> getMangaRecommended() async {
    final json = await _getJson(
      '/v1/manga/recommended?filter=for_ios&include_ranking_label=true',
    );
    return PixezRecommendation.fromJson(json);
  }

  /// `GET /v1/illust/ranking?filter=for_android&mode=...&date=...`
  Future<PixezPagedResult<PixezIllust>> getIllustRanking({
    required String mode,
    String? date,
  }) async {
    final json = await _getJson(
      '/v1/illust/ranking?filter=for_android',
      query: <String, dynamic>{'mode': mode, 'date': date},
    );
    return _illustPage(json);
  }

  /// `GET /v1/search/illust?filter=for_android&merge_plain_keyword_results=true`
  Future<PixezPagedResult<PixezIllust>> searchIllust(
    PixezSearchQuery query,
  ) async {
    final json = await _getJson(
      '/v1/search/illust?filter=for_android&merge_plain_keyword_results=true',
      query: query.toQueryParameters(),
    );
    return _illustPage(json);
  }

  /// `GET /v1/search/novel?filter=for_android&merge_plain_keyword_results=true`
  Future<PixezPagedResult<PixezNovel>> searchNovel(
    PixezSearchQuery query,
  ) async {
    final json = await _getJson(
      '/v1/search/novel?filter=for_android&merge_plain_keyword_results=true',
      query: query.toQueryParameters(),
    );
    return _novelPage(json);
  }

  /// `GET /v1/search/user?filter=for_android&word=...`
  Future<PixezPagedResult<PixezUserPreview>> searchUser(String word) async {
    final json = await _getJson(
      '/v1/search/user?filter=for_android',
      query: <String, dynamic>{'word': word},
    );
    return _userPreviewPage(json);
  }

  /// `GET /v1/illust/detail?filter=for_android&illust_id=...`
  Future<PixezIllust> getIllustDetail(int illustId) async {
    final json = await _getJson(
      '/v1/illust/detail?filter=for_android',
      query: <String, dynamic>{'illust_id': illustId},
    );
    return PixezIllust.fromJson(pixezMap(json['illust']));
  }

  /// `GET /v2/illust/related?filter=for_android&illust_id=...`
  Future<PixezPagedResult<PixezIllust>> getRelatedIllusts(int illustId) async {
    final json = await _getJson(
      '/v2/illust/related?filter=for_android',
      query: <String, dynamic>{'illust_id': illustId},
    );
    return _illustPage(json);
  }

  // --------------------------------------------------------------- users ---

  /// `GET /v1/user/detail?filter=for_android&user_id=...`
  Future<PixezUserDetail> getUserDetail(int userId) async {
    final json = await _getJson(
      '/v1/user/detail?filter=for_android',
      query: <String, dynamic>{'user_id': userId},
    );
    return PixezUserDetail.fromJson(json);
  }

  /// `GET /v1/user/illusts?filter=for_android&user_id=...&type=...&offset=...`
  Future<PixezPagedResult<PixezIllust>> getUserIllusts(
    int userId, {
    String type = 'illust',
    int? offset,
  }) async {
    final json = await _getJson(
      '/v1/user/illusts?filter=for_android',
      query: <String, dynamic>{
        'user_id': userId,
        'type': type,
        'offset': offset,
      },
    );
    return _illustPage(json);
  }

  /// `GET /v1/user/bookmarks/illust?user_id=...&restrict=...&tag=...&offset=...`
  Future<PixezPagedResult<PixezIllust>> getUserBookmarksIllust(
    int userId, {
    String restrict = 'public',
    String? tag,
    int? offset,
  }) async {
    final json = await _getJson(
      '/v1/user/bookmarks/illust',
      query: <String, dynamic>{
        'user_id': userId,
        'restrict': restrict,
        'tag': tag,
        'offset': offset,
      },
    );
    return _illustPage(json);
  }

  /// `GET /v1/user/novels?filter=for_android&user_id=...`
  Future<PixezPagedResult<PixezNovel>> getUserNovels(int userId) async {
    final json = await _getJson(
      '/v1/user/novels?filter=for_android',
      query: <String, dynamic>{'user_id': userId},
    );
    return _novelPage(json);
  }

  // ----------------------------------------------------------- bookmarks ---

  /// `GET /v2/illust/bookmark/detail?illust_id=...`
  Future<PixezBookmarkDetail> getIllustBookmarkDetail(int illustId) async {
    final json = await _getJson(
      '/v2/illust/bookmark/detail',
      query: <String, dynamic>{'illust_id': illustId},
    );
    return PixezBookmarkDetail.fromJson(pixezMap(json['bookmark_detail']));
  }

  /// `POST /v2/illust/bookmark/add` (form encoded).
  ///
  /// pixiv expects all tags in a single `tags[]` field joined by spaces; see
  /// [pixezJoinBookmarkTags] for the source's exact join rule.
  Future<void> addIllustBookmark(
    int illustId, {
    String restrict = 'public',
    List<String> tags = const <String>[],
  }) async {
    final tagString = pixezJoinBookmarkTags(tags);
    await _postForm('/v2/illust/bookmark/add', <String, dynamic>{
      'illust_id': illustId,
      'restrict': restrict,
      'tags[]': ?tagString,
    });
  }

  /// `POST /v1/illust/bookmark/delete` (form encoded).
  Future<void> deleteIllustBookmark(int illustId) async {
    await _postForm('/v1/illust/bookmark/delete', <String, dynamic>{
      'illust_id': illustId,
    });
  }

  /// `POST /v1/user/follow/add` (form encoded).
  Future<void> followUser(int userId, {String restrict = 'public'}) async {
    await _postForm('/v1/user/follow/add', <String, dynamic>{
      'user_id': userId,
      'restrict': restrict,
    });
  }

  /// `POST /v1/user/follow/delete` (form encoded).
  Future<void> unfollowUser(int userId) async {
    await _postForm('/v1/user/follow/delete', <String, dynamic>{
      'user_id': userId,
    });
  }

  // --------------------------------------------------------------- novels ---

  /// `GET /v1/novel/recommended?include_privacy_policy=true&filter=for_android&include_ranking_novels=true`
  Future<PixezPagedResult<PixezNovel>> getNovelRecommended() async {
    final json = await _getJson(
      '/v1/novel/recommended?include_privacy_policy=true&filter=for_android&include_ranking_novels=true',
    );
    return _novelPage(json);
  }

  /// `GET /v2/novel/detail?novel_id=...`
  Future<PixezNovel> getNovelDetail(int novelId) async {
    final json = await _getJson(
      '/v2/novel/detail',
      query: <String, dynamic>{'novel_id': novelId},
    );
    return PixezNovel.fromJson(pixezMap(json['novel']));
  }

  /// `GET /v1/novel/ranking?filter=for_android&mode=...&date=...`
  Future<PixezPagedResult<PixezNovel>> getNovelRanking({
    required String mode,
    String? date,
  }) async {
    final json = await _getJson(
      '/v1/novel/ranking?filter=for_android',
      query: <String, dynamic>{'mode': mode, 'date': date},
    );
    return _novelPage(json);
  }

  /// `GET /v1/novel/text?novel_id=...`
  Future<String> getNovelText(int novelId) async {
    final json = await _getJson(
      '/v1/novel/text',
      query: <String, dynamic>{'novel_id': novelId},
    );
    return pixezString(json['novel_text']);
  }

  // -------------------------------------------------------------- paging ---

  /// Follows an illust `next_url`, rewriting the pixiv host to the configured
  /// base URL (source `getNext`).
  Future<PixezPagedResult<PixezIllust>> getNextIllusts(String nextUrl) async {
    final json = await _getNextJson(nextUrl);
    if (json == null) {
      return const PixezPagedResult<PixezIllust>(items: [], nextUrl: null);
    }
    return _illustPage(json);
  }

  /// Follows a novel `next_url`.
  Future<PixezPagedResult<PixezNovel>> getNextNovels(String nextUrl) async {
    final json = await _getNextJson(nextUrl);
    if (json == null) {
      return const PixezPagedResult<PixezNovel>(items: [], nextUrl: null);
    }
    return _novelPage(json);
  }

  /// Follows a `next_url` whose items are `user_previews`.
  Future<PixezPagedResult<PixezUserPreview>> getNextUserPreviews(
    String nextUrl,
  ) async {
    final json = await _getNextJson(nextUrl);
    if (json == null) {
      return const PixezPagedResult<PixezUserPreview>(items: [], nextUrl: null);
    }
    return _userPreviewPage(json);
  }

  Future<Map<String, dynamic>?> _getNextJson(String nextUrl) async {
    final resolved = _resolver.resolve(nextUrl);
    if (resolved == null) return null;
    await _ensureAuthorized();
    final response = await _dio.get<dynamic>(resolved, options: _options());
    return pixezResponseMap(response.data);
  }

  // ------------------------------------------------------------- parsing ---

  PixezPagedResult<PixezIllust> _illustPage(Map<String, dynamic> json) {
    return PixezPagedResult<PixezIllust>.fromJson(
      json,
      itemsKey: 'illusts',
      itemParser: PixezIllust.fromJson,
    );
  }

  PixezPagedResult<PixezNovel> _novelPage(Map<String, dynamic> json) {
    return PixezPagedResult<PixezNovel>.fromJson(
      json,
      itemsKey: 'novels',
      itemParser: PixezNovel.fromJson,
    );
  }

  PixezPagedResult<PixezUserPreview> _userPreviewPage(
    Map<String, dynamic> json,
  ) {
    return PixezPagedResult<PixezUserPreview>.fromJson(
      json,
      itemsKey: 'user_previews',
      itemParser: PixezUserPreview.fromJson,
    );
  }
}
