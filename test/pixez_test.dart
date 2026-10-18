import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dashboard/features/comic/pixez/controllers/pixez_detail_controller.dart';
import 'package:dashboard/features/comic/pixez/controllers/pixez_home_controller.dart';
import 'package:dashboard/features/comic/pixez/controllers/pixez_rank_controller.dart';
import 'package:dashboard/features/comic/pixez/controllers/pixez_search_controller.dart';
import 'package:dashboard/features/comic/pixez/controllers/pixez_user_controller.dart';
import 'package:dashboard/features/comic/pixez/models/pixez_bookmark_detail.dart';
import 'package:dashboard/features/comic/pixez/models/pixez_illust.dart';
import 'package:dashboard/features/comic/pixez/models/pixez_novel.dart';
import 'package:dashboard/features/comic/pixez/models/pixez_rank_mode.dart';
import 'package:dashboard/features/comic/pixez/models/pixez_search_options.dart';
import 'package:dashboard/features/comic/pixez/models/pixez_search_query.dart';
import 'package:dashboard/features/comic/pixez/models/pixez_user_detail.dart';
import 'package:dashboard/features/comic/pixez/models/pixez_user_preview.dart';
import 'package:dashboard/features/comic/pixez/pages/pixez_home_page.dart';
import 'package:dashboard/features/comic/pixez/pixez_api_client.dart';
import 'package:dashboard/features/comic/pixez/pixez_api_config.dart';
import 'package:dashboard/features/comic/pixez/pixez_api_headers.dart';
import 'package:dashboard/features/comic/pixez/pixez_auth_parameters.dart';
import 'package:dashboard/features/comic/pixez/pixez_auth_required_exception.dart';
import 'package:dashboard/features/comic/pixez/pixez_auth_store.dart';
import 'package:dashboard/features/comic/pixez/pixez_bookmark_tags.dart';
import 'package:dashboard/features/comic/pixez/pixez_entry.dart';
import 'package:dashboard/features/comic/pixez/pixez_error.dart';
import 'package:dashboard/features/comic/pixez/pixez_json.dart';
import 'package:dashboard/features/comic/pixez/pixez_load_status.dart';
import 'package:dashboard/features/comic/pixez/pixez_next_url_resolver.dart';
import 'package:dashboard/features/comic/pixez/pixez_oauth_token.dart';
import 'package:dashboard/features/comic/pixez/pixez_paged_result.dart';
import 'package:dashboard/features/comic/pixez/pixez_recommendation.dart';
import 'package:dashboard/features/comic/pixez/widgets/pixez_login_required_view.dart';
import 'package:dashboard/features/comic/pixez/widgets/pixez_token_dialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Test clock: 2026-10-17 09:05:06 in the host time zone (Asia/Shanghai).
/// The app-api time header keeps the local fields and appends a literal
/// `+00:00`, so the expected hash is the md5 of this exact string.
final DateTime _now = DateTime(2026, 10, 17, 9, 5, 6);
const String _clientTime = '2026-10-17T09:05:06+00:00';
const String _clientHash = 'e4de1646cd0a15bb2a987cbba278d33a';

typedef _Responder =
    FutureOr<Map<String, dynamic>> Function(RequestOptions request);

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter([this._responder]);

  final _Responder? _responder;
  final List<RequestOptions> requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final body = _responder == null
        ? <String, dynamic>{}
        : await _responder(options);
    return ResponseBody.fromString(
      jsonEncode(body),
      200,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

PixezApiClient _api(
  _FakeAdapter adapter, {
  String? token = 'token-123',
  PixezApiConfig config = const PixezApiConfig(),
  DateTime? now,
}) {
  final dio = Dio()..httpClientAdapter = adapter;
  return PixezApiClient(
    dio: dio,
    auth: PixezAuthStore(accessToken: token, persist: false),
    config: config,
    clock: () => now ?? _now,
  );
}

RequestOptions _single(_FakeAdapter adapter) {
  expect(adapter.requests, hasLength(1));
  return adapter.requests.single;
}

Map<String, dynamic> _imageUrls(int id) => <String, dynamic>{
  'square_medium': 'https://i.pximg.net/c/360x360_70/$id-square.jpg',
  'medium': 'https://i.pximg.net/c/540x540_70/$id-medium.jpg',
  'large': 'https://i.pximg.net/c/1200x1200_90/$id-large.jpg',
};

Map<String, dynamic> _userJson({
  int id = 7,
  String name = '作者',
  bool? followed = false,
}) => <String, dynamic>{
  'id': id,
  'name': name,
  'account': 'creator_$id',
  'profile_image_urls': <String, dynamic>{
    'medium': 'https://i.pximg.net/user-profile/$id.jpg',
  },
  'comment': 'よろしく',
  'is_followed': ?followed,
};

Map<String, dynamic> _illustJson({
  int id = 1,
  String title = 'サンプル作品',
  String type = 'illust',
  bool bookmarked = false,
  bool? followed = false,
  bool singlePage = true,
  int metaPageCount = 0,
  int totalBookmarks = 12,
}) => <String, dynamic>{
  'id': id,
  'title': title,
  'type': type,
  'image_urls': _imageUrls(id),
  'caption': '<p>説明</p>',
  'restrict': 0,
  'user': _userJson(followed: followed),
  'tags': <Map<String, dynamic>>[
    <String, dynamic>{'name': 'tagA', 'translated_name': '标签A'},
    <String, dynamic>{'name': 'tagB'},
  ],
  'tools': <String>['Photoshop', 'SAI'],
  'create_date': '2026-10-01T12:00:00+09:00',
  'page_count': metaPageCount > 0 ? metaPageCount : 1,
  'width': 1200,
  'height': 1600,
  'sanity_level': 2,
  'x_restrict': 0,
  'meta_single_page': singlePage
      ? <String, dynamic>{
          'original_image_url': 'https://i.pximg.net/img-original/$id-p0.jpg',
        }
      : null,
  'meta_pages': <Map<String, dynamic>>[
    for (var i = 0; i < metaPageCount; i++)
      <String, dynamic>{
        'image_urls': <String, dynamic>{
          'square_medium': 'https://i.pximg.net/original/$id-p$i-square.jpg',
          'medium': 'https://i.pximg.net/original/$id-p$i-medium.jpg',
          'large': 'https://i.pximg.net/original/$id-p$i-large.jpg',
        },
      },
  ],
  'total_view': 1000,
  'total_bookmarks': totalBookmarks,
  'is_bookmarked': bookmarked,
  'visible': true,
  'is_muted': false,
  'illust_ai_type': 0,
};

Map<String, dynamic> _novelJson({int id = 21}) => <String, dynamic>{
  'id': id,
  'title': 'サンプル小説',
  'caption': 'あらすじ',
  'restrict': 0,
  'x_restrict': 0,
  'is_original': true,
  'image_urls': _imageUrls(id),
  'create_date': '2026-10-01T08:00:00+09:00',
  'tags': <Map<String, dynamic>>[
    <String, dynamic>{
      'name': 'novelTag',
      'translated_name': '小説タグ',
      'added_by_uploaded_user': true,
    },
  ],
  'page_count': 3,
  'text_length': 4321,
  'user': _userJson(),
  'series': <String, dynamic>{'id': 88, 'title': 'シリーズ'},
  'is_bookmarked': true,
  'total_bookmarks': 9,
  'total_view': 500,
  'visible': true,
  'total_comments': 4,
  'is_muted': false,
  'is_mypixiv_only': false,
  'is_x_restricted': false,
  'novel_ai_type': 0,
};

Map<String, dynamic> _userPreviewJson({
  int userId = 7,
  int illustId = 11,
  int novelId = 21,
}) => <String, dynamic>{
  'user': _userJson(id: userId),
  'illusts': <Map<String, dynamic>>[_illustJson(id: illustId)],
  'novels': <Map<String, dynamic>>[
    <String, dynamic>{
      'id': novelId,
      'title': '小説見出し',
      'caption': 'あらすじ',
      'image_urls': _imageUrls(novelId),
    },
  ],
  'is_muted': false,
};

Map<String, dynamic> _userDetailJson() => <String, dynamic>{
  'user': _userJson(followed: true),
  'profile': <String, dynamic>{
    'webpage': 'https://example.com/u/7',
    'gender': 'male',
    'birth': '',
    'birth_day': '01-02',
    'birth_year': 1990,
    'region': 'Tokyo',
    'address_id': 10,
    'country_code': 'JP',
    'job': 'engineer',
    'job_id': 5,
    'total_follow_users': 3,
    'total_mypixiv_users': 4,
    'total_illusts': 100,
    'total_manga': 20,
    'total_novels': 5,
    'total_illust_bookmarks_public': 300,
    'total_illust_series': 6,
    'total_novel_series': 1,
    'background_image_url': 'https://i.pximg.net/bg.jpg',
    'twitter_account': 'tw_account',
    'is_premium': true,
    'is_using_custom_profile_image': false,
  },
  'profile_publicity': <String, dynamic>{
    'gender': 'male',
    'region': 'Tokyo',
    'birth_day': '01-02',
    'birth_year': '1990',
    'job': 'engineer',
    'pawoo': true,
  },
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('auth parameters', () {
    test('client hash is md5 of the time header plus the public salt', () {
      expect(PixezAuthParameters.clientHash(_clientTime), _clientHash);
      expect(
        PixezAuthParameters.clientHash('different-time'),
        isNot(_clientHash),
      );
    });

    test('time header keeps local fields with a literal +00:00 suffix', () {
      expect(
        PixezAuthParameters.isoDate(DateTime(2026, 1, 2, 3, 4, 5)),
        '2026-01-02T03:04:05+00:00',
      );
      expect(PixezAuthParameters.isoDate(_now), _clientTime);
    });

    test('password grant body matches the pixiv Android client', () {
      expect(
        PixezAuthParameters.passwordTokenBody(
          username: 'user@example.com',
          password: 'secret',
        ),
        <String, String>{
          'client_id': 'MOBrBDS8blbauoSck0ZfDbtuzpyT',
          'client_secret': 'lsACyCD94FhDUtGTXi3QzcFE2uU1hqtDaKeqrdwj',
          'grant_type': 'password',
          'username': 'user@example.com',
          'password': 'secret',
          'Device_token': 'pixiv',
          'get_secure_url': 'true',
          'include_policy': 'true',
        },
      );
    });

    test('refresh grant body keeps grant_type and refresh_token', () {
      final body = PixezAuthParameters.refreshTokenBody('refresh-xyz');
      expect(body['grant_type'], 'refresh_token');
      expect(body['refresh_token'], 'refresh-xyz');
      expect(body['client_id'], PixezAuthParameters.clientId);
      expect(body['client_secret'], PixezAuthParameters.clientSecret);
    });

    test('authorization-code grant body carries code and verifier', () {
      final body = PixezAuthParameters.authorizationCodeBody(
        code: 'code-1',
        codeVerifier: 'verifier-1',
      );
      expect(body['grant_type'], 'authorization_code');
      expect(body['code'], 'code-1');
      expect(body['code_verifier'], 'verifier-1');
      expect(body['redirect_uri'], PixezAuthParameters.redirectUri);
    });

    test('web login URL uses S256 and the pixiv-android client', () {
      expect(
        PixezAuthParameters.webLoginUrl(codeChallenge: 'abc'),
        'https://app-api.pixiv.net/web/v1/login'
        '?code_challenge=abc&code_challenge_method=S256&client=pixiv-android',
      );
      expect(
        PixezAuthParameters.webLoginUrl(
          codeChallenge: 'abc',
          createAccount: true,
        ),
        contains('/web/v1/provisional-accounts/create?'),
      );
    });
  });

  group('app-api headers', () {
    test('forApi sends the Android app signature and bearer token', () {
      final headers = PixezApiHeaders.forApi(
        now: _now,
        accessToken: 'access-123',
      );
      expect(headers['X-Client-Time'], _clientTime);
      expect(headers['X-Client-Hash'], _clientHash);
      expect(headers['User-Agent'], 'PixivAndroidApp/5.0.166 (Android 10.0; Pixel C)');
      expect(headers['accept-language'], 'zh-CN');
      expect(headers['App-OS'], 'Android');
      expect(headers['App-OS-Version'], 'Android 10.0');
      expect(headers['App-Version'], '5.0.166');
      expect(headers['Host'], 'app-api.pixiv.net');
      expect(headers['Authorization'], 'Bearer access-123');
    });

    test('forApi omits Authorization when the token is empty', () {
      final headers = PixezApiHeaders.forApi(now: _now, accessToken: '');
      expect(headers.containsKey('Authorization'), isFalse);
    });

    test('forOAuth uses the older client signature and no bearer token', () {
      final headers = PixezApiHeaders.forOAuth(now: _now);
      expect(headers['User-Agent'], 'PixivAndroidApp/5.0.155 (Android 6.0; Pixel C)');
      expect(headers['App-OS-Version'], 'Android 6.0');
      expect(headers['Host'], 'oauth.secure.pixiv.net');
      expect(headers.containsKey('Authorization'), isFalse);
      expect(headers['X-Client-Hash'], _clientHash);
    });

    test('requests carry the exact headers built from the injected clock', () async {
      final adapter = _FakeAdapter();
      final client = _api(adapter);
      await client.getIllustRanking(mode: 'day');
      final request = _single(adapter);
      expect(request.headers['X-Client-Time'], _clientTime);
      expect(request.headers['X-Client-Hash'], _clientHash);
      expect(request.headers['Authorization'], 'Bearer token-123');
      expect(request.headers['App-Version'], '5.0.166');
      expect(adapter.requests, hasLength(1));
    });

    test('dnsBypass config points at the documented pixiv bypass IPs', () {
      expect(PixezApiConfig.dnsBypass.baseUrl, 'https://210.140.131.199');
      expect(PixezApiConfig.dnsBypass.oauthBaseUrl, 'https://210.140.131.219');
    });
  });

  group('api endpoints', () {
    test('recommended illusts use the for_ios filter', () async {
      final adapter = _FakeAdapter(
        (_) => <String, dynamic>{
          'illusts': <Map<String, dynamic>>[_illustJson(id: 1)],
          'ranking_illusts': <Map<String, dynamic>>[_illustJson(id: 2)],
          'next_url': 'https://app-api.pixiv.net/v1/illust/recommended?page=2',
          'contest_exists': true,
        },
      );
      final result = await _api(adapter).getIllustRecommended();
      final request = _single(adapter);
      expect(request.method, 'GET');
      expect(request.uri.path, '/v1/illust/recommended');
      expect(request.uri.queryParameters, <String, String>{
        'filter': 'for_ios',
        'include_ranking_label': 'true',
      });
      expect(result.illusts.single.id, 1);
      expect(result.rankingIllusts.single.id, 2);
      expect(result.nextUrl, contains('page=2'));
    });

    test('ranking sends mode and drops a null date', () async {
      final adapter = _FakeAdapter();
      await _api(adapter).getIllustRanking(mode: 'week');
      final request = _single(adapter);
      expect(request.uri.path, '/v1/illust/ranking');
      expect(request.uri.queryParameters, <String, String>{
        'filter': 'for_android',
        'mode': 'week',
      });
      expect(request.uri.queryParameters.containsKey('date'), isFalse);
    });

    test('ranking forwards the unpadded request date', () async {
      final adapter = _FakeAdapter();
      await _api(adapter).getIllustRanking(mode: 'day', date: '2026-9-8');
      expect(
        _single(adapter).uri.queryParameters['date'],
        '2026-9-8',
      );
    });

    test('illust search sends word, sort and search_target', () async {
      final adapter = _FakeAdapter();
      await _api(adapter).searchIllust(
        const PixezSearchQuery(
          word: 'blue sky',
          sort: 'popular_desc',
          searchTarget: 'title_and_caption',
        ),
      );
      final request = _single(adapter);
      expect(request.uri.path, '/v1/search/illust');
      expect(request.uri.queryParameters['word'], 'blue sky');
      expect(request.uri.queryParameters['sort'], 'popular_desc');
      expect(request.uri.queryParameters['search_target'], 'title_and_caption');
      expect(request.uri.queryParameters['filter'], 'for_android');
      expect(
        request.uri.queryParameters['merge_plain_keyword_results'],
        'true',
      );
    });

    test('novel search uses /v1/search/novel and parses novels', () async {
      final adapter = _FakeAdapter(
        (_) => <String, dynamic>{
          'novels': <Map<String, dynamic>>[_novelJson()],
        },
      );
      final result = await _api(
        adapter,
      ).searchNovel(const PixezSearchQuery(word: '小説'));
      final request = _single(adapter);
      expect(request.uri.path, '/v1/search/novel');
      expect(request.uri.queryParameters['word'], '小説');
      expect(result.items.single.title, 'サンプル小説');
    });

    test('user search sends the word and reads user_previews', () async {
      final adapter = _FakeAdapter(
        (_) => <String, dynamic>{
          'user_previews': <Map<String, dynamic>>[_userPreviewJson()],
          'next_url': null,
        },
      );
      final result = await _api(adapter).searchUser('作者');
      final request = _single(adapter);
      expect(request.uri.path, '/v1/search/user');
      expect(request.uri.queryParameters, <String, String>{
        'filter': 'for_android',
        'word': '作者',
      });
      expect(result.items.single.user.id, 7);
    });

    test('illust detail unwraps the illust object', () async {
      final adapter = _FakeAdapter(
        (_) => <String, dynamic>{'illust': _illustJson(id: 77)},
      );
      final illust = await _api(adapter).getIllustDetail(77);
      final request = _single(adapter);
      expect(request.uri.path, '/v1/illust/detail');
      expect(request.uri.queryParameters['illust_id'], '77');
      expect(illust.id, 77);
    });

    test('related illusts use the v2 endpoint', () async {
      final adapter = _FakeAdapter(
        (_) => <String, dynamic>{
          'illusts': <Map<String, dynamic>>[_illustJson(id: 78)],
        },
      );
      final result = await _api(adapter).getRelatedIllusts(77);
      final request = _single(adapter);
      expect(request.uri.path, '/v2/illust/related');
      expect(request.uri.queryParameters['illust_id'], '77');
      expect(result.items.single.id, 78);
    });

    test('user detail maps the profile and profile_publicity blocks', () async {
      final adapter = _FakeAdapter((_) => _userDetailJson());
      final detail = await _api(adapter).getUserDetail(7);
      final request = _single(adapter);
      expect(request.uri.path, '/v1/user/detail');
      expect(request.uri.queryParameters['user_id'], '7');
      expect(detail.user.account, 'creator_7');
      expect(detail.profile.totalIllusts, 100);
      expect(detail.profile.totalManga, 20);
      expect(detail.profile.birthYear, 1990);
      expect(detail.profilePublicity.birthYear, '1990');
      expect(detail.profilePublicity.pawoo, isTrue);
    });

    test('user illusts sends type and offset', () async {
      final adapter = _FakeAdapter(
        (_) => <String, dynamic>{
          'illusts': <Map<String, dynamic>>[_illustJson(id: 3)],
        },
      );
      await _api(adapter).getUserIllusts(7, type: 'manga', offset: 30);
      final request = _single(adapter);
      expect(request.uri.path, '/v1/user/illusts');
      expect(request.uri.queryParameters, <String, String>{
        'filter': 'for_android',
        'user_id': '7',
        'type': 'manga',
        'offset': '30',
      });
    });

    test('user bookmarks send restrict, tag and offset', () async {
      final adapter = _FakeAdapter();
      await _api(adapter).getUserBookmarksIllust(
        7,
        restrict: 'private',
        tag: 'tagA',
        offset: 10,
      );
      final request = _single(adapter);
      expect(request.uri.path, '/v1/user/bookmarks/illust');
      expect(request.uri.queryParameters, <String, String>{
        'user_id': '7',
        'restrict': 'private',
        'tag': 'tagA',
        'offset': '10',
      });
    });

    test('bookmark detail unwraps bookmark_detail', () async {
      final adapter = _FakeAdapter(
        (_) => <String, dynamic>{
          'bookmark_detail': <String, dynamic>{
            'is_bookmarked': true,
            'restrict': 'private',
            'tags': <Map<String, dynamic>>[
              <String, dynamic>{'name': 'tagA'},
            ],
          },
        },
      );
      final detail = await _api(adapter).getIllustBookmarkDetail(5);
      expect(_single(adapter).uri.path, '/v2/illust/bookmark/detail');
      expect(detail.isBookmarked, isTrue);
      expect(detail.restrict, 'private');
      expect(detail.tags, <String>['tagA']);
    });

    test('bookmark add posts form data and the joined tags[] field', () async {
      final adapter = _FakeAdapter();
      await _api(adapter).addIllustBookmark(
        55,
        restrict: 'private',
        tags: <String>[' first ', ' second ', 'third'],
      );
      final request = _single(adapter);
      expect(request.method, 'POST');
      expect(request.uri.path, '/v2/illust/bookmark/add');
      expect(request.contentType, Headers.formUrlEncodedContentType);
      expect(request.data, <String, dynamic>{
        'illust_id': 55,
        'restrict': 'private',
        'tags[]': ' first  second third',
      });
    });

    test('bookmark add omits tags[] when no tags are given', () async {
      final adapter = _FakeAdapter();
      await _api(adapter).addIllustBookmark(55);
      final data = _single(adapter).data as Map<String, dynamic>;
      expect(data, <String, dynamic>{'illust_id': 55, 'restrict': 'public'});
      expect(data.containsKey('tags[]'), isFalse);
    });

    test('bookmark delete and follow endpoints match the source', () async {
      final adapter = _FakeAdapter();
      final client = _api(adapter);
      await client.deleteIllustBookmark(55);
      await client.followUser(7);
      await client.unfollowUser(7);
      expect(adapter.requests, hasLength(3));
      expect(adapter.requests[0].uri.path, '/v1/illust/bookmark/delete');
      expect(adapter.requests[0].data, <String, dynamic>{'illust_id': 55});
      expect(adapter.requests[1].uri.path, '/v1/user/follow/add');
      expect(adapter.requests[1].data, <String, dynamic>{
        'user_id': 7,
        'restrict': 'public',
      });
      expect(adapter.requests[2].uri.path, '/v1/user/follow/delete');
      expect(adapter.requests[2].data, <String, dynamic>{'user_id': 7});
    });

    test('novel recommended keeps the privacy and ranking flags', () async {
      final adapter = _FakeAdapter();
      await _api(adapter).getNovelRecommended();
      final request = _single(adapter);
      expect(request.uri.path, '/v1/novel/recommended');
      expect(request.uri.queryParameters, <String, String>{
        'include_privacy_policy': 'true',
        'filter': 'for_android',
        'include_ranking_novels': 'true',
      });
    });

    test('novel detail unwraps novel and parses its text endpoint', () async {
      final adapter = _FakeAdapter((request) {
        if (request.uri.path == '/v2/novel/detail') {
          return <String, dynamic>{'novel': _novelJson()};
        }
        return <String, dynamic>{'novel_text': '本文です'};
      });
      final client = _api(adapter);
      final novel = await client.getNovelDetail(21);
      final text = await client.getNovelText(21);
      expect(adapter.requests[0].uri.path, '/v2/novel/detail');
      expect(adapter.requests[0].uri.queryParameters['novel_id'], '21');
      expect(novel.id, 21);
      expect(adapter.requests[1].uri.path, '/v1/novel/text');
      expect(text, '本文です');
    });

    test('next URLs are rewritten to the configured bypass host', () async {
      final adapter = _FakeAdapter(
        (_) => <String, dynamic>{
          'illusts': <Map<String, dynamic>>[_illustJson(id: 99)],
          'next_url': null,
        },
      );
      final client = _api(adapter, config: PixezApiConfig.dnsBypass);
      final result = await client.getNextIllusts(
        'https://app-api.pixiv.net/v1/illust/recommended?page=2&filter=for_ios',
      );
      final request = _single(adapter);
      expect(request.uri.host, '210.140.131.199');
      expect(request.uri.path, '/v1/illust/recommended');
      expect(request.uri.queryParameters, <String, String>{
        'page': '2',
        'filter': 'for_ios',
      });
      expect(result.items.single.id, 99);
    });

    test('a blank next URL does not issue a request', () async {
      final adapter = _FakeAdapter();
      final result = await _api(adapter).getNextIllusts('   ');
      expect(adapter.requests, isEmpty);
      expect(result.items, isEmpty);
      expect(result.hasMore, isFalse);
    });

    test('loginWithPassword posts the OAuth form to the oauth host', () async {
      final adapter = _FakeAdapter(
        (_) => <String, dynamic>{
          'response': <String, dynamic>{
            'access_token': 'access-1',
            'refresh_token': 'refresh-1',
            'expires_in': 3600,
            'token_type': 'bearer',
            'user': <String, dynamic>{
              'id': 42,
              'name': 'Name',
              'account': 'acct',
            },
          },
        },
      );
      final token = await _api(
        adapter,
      ).loginWithPassword(username: 'user@example.com', password: 'secret');
      final request = _single(adapter);
      expect(
        request.uri.toString(),
        'https://oauth.secure.pixiv.net/auth/token',
      );
      expect(request.method, 'POST');
      expect(request.contentType, Headers.formUrlEncodedContentType);
      expect(request.headers['Host'], 'oauth.secure.pixiv.net');
      expect(request.headers.containsKey('Authorization'), isFalse);
      expect(request.data, PixezAuthParameters.passwordTokenBody(
        username: 'user@example.com',
        password: 'secret',
      ));
      expect(token.accessToken, 'access-1');
      expect(token.refreshToken, 'refresh-1');
      expect(token.userId, 42);
      expect(token.isValid, isTrue);
    });

    test('refresh and authorization-code grants keep their body keys', () async {
      final adapter = _FakeAdapter(
        (_) => <String, dynamic>{
          'access_token': 'a',
          'refresh_token': 'r',
          'expires_in': 1,
        },
      );
      final client = _api(adapter);
      await client.refreshAccessToken('refresh-xyz');
      await client.exchangeAuthorizationCode(
        code: 'code-1',
        codeVerifier: 'verifier-1',
      );
      expect(adapter.requests, hasLength(2));
      expect(
        (adapter.requests[0].data as Map<String, dynamic>)['grant_type'],
        'refresh_token',
      );
      expect(
        (adapter.requests[0].data as Map<String, dynamic>)['refresh_token'],
        'refresh-xyz',
      );
      expect(
        (adapter.requests[1].data as Map<String, dynamic>)['code_verifier'],
        'verifier-1',
      );
      expect(
        (adapter.requests[1].data as Map<String, dynamic>)['redirect_uri'],
        PixezAuthParameters.redirectUri,
      );
    });

    test('requests are rejected with the login message before HTTP', () async {
      final adapter = _FakeAdapter();
      final client = _api(adapter, token: null);
      await expectLater(
        client.getIllustRecommended(),
        throwsA(isA<PixezAuthRequiredException>()),
      );
      expect(adapter.requests, isEmpty);
    });
  });

  group('auth store', () {
    test('saved tokens are persisted and reloaded from shared_preferences', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final store = PixezAuthStore();
      await store.saveToken(
        const PixezOAuthToken(
          accessToken: 'persisted-token',
          refreshToken: 'persisted-refresh',
          expiresIn: 3600,
          tokenType: 'bearer',
          userId: 42,
          userName: 'Name',
          userAccount: 'acct',
        ),
      );
      expect(store.hasAccessToken, isTrue);
      final prefs = await SharedPreferences.getInstance();
      expect(
        prefs.getString(PixezAuthStore.accessTokenKey),
        'persisted-token',
      );
      final reloaded = PixezAuthStore();
      expect(reloaded.hasAccessToken, isFalse);
      await reloaded.ensureLoaded();
      expect(reloaded.accessToken, 'persisted-token');
      expect(reloaded.refreshToken, 'persisted-refresh');
    });

    test('saveAccessToken trims and empty input clears the session', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final store = PixezAuthStore();
      await store.saveAccessToken('  injected-token  ');
      expect(store.accessToken, 'injected-token');
      await store.saveAccessToken('   ');
      expect(store.hasAccessToken, isFalse);
      await store.saveAccessToken('second');
      await store.clear();
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(PixezAuthStore.accessTokenKey), isNull);
    });

    test('an in-memory store can be injected without touching prefs', () async {
      final store = PixezAuthStore(accessToken: 'token-123', persist: false);
      await store.ensureLoaded();
      expect(store.hasAccessToken, isTrue);
      expect(store.accessToken, 'token-123');
    });
  });

  group('models', () {
    test('illust maps ids, urls, tags, meta pages and stats', () {
      final illust = PixezIllust.fromJson(
        _illustJson(id: 5, metaPageCount: 2, bookmarked: true, followed: true),
      );
      expect(illust.id, 5);
      expect(illust.title, 'サンプル作品');
      expect(illust.imageUrls.squareMedium, contains('5-square.jpg'));
      expect(illust.imageUrls.large, contains('5-large.jpg'));
      expect(illust.tags.first.name, 'tagA');
      expect(illust.tags.first.translatedName, '标签A');
      expect(illust.tags[1].translatedName, isNull);
      expect(illust.tools, <String>['Photoshop', 'SAI']);
      expect(illust.pageCount, 2);
      expect(illust.metaPages, hasLength(2));
      expect(illust.metaPages.first.imageUrls.large, contains('5-p0-large.jpg'));
      expect(illust.displayImageUrl, 'https://i.pximg.net/img-original/5-p0.jpg');
      expect(illust.totalBookmarks, 12);
      expect(illust.isBookmarked, isTrue);
      expect(illust.user.isFollowed, isTrue);
      expect(illust.isManga, isFalse);
    });

    test('illust display falls back to the large URL without a single page', () {
      final illust = PixezIllust.fromJson(_illustJson(id: 6, singlePage: false));
      expect(illust.metaSinglePage, isNull);
      expect(illust.displayImageUrl, contains('6-large.jpg'));
    });

    test('manga type is exposed by isManga', () {
      final illust = PixezIllust.fromJson(_illustJson(type: 'manga'));
      expect(illust.isManga, isTrue);
    });

    test('novel maps dates, series, tags and flags', () {
      final novel = PixezNovel.fromJson(_novelJson());
      expect(novel.id, 21);
      expect(novel.isOriginal, isTrue);
      expect(novel.pageCount, 3);
      expect(novel.textLength, 4321);
      expect(novel.createDate.toUtc(), DateTime.utc(2026, 9, 30, 23));
      expect(novel.series?.id, 88);
      expect(novel.series?.title, 'シリーズ');
      expect(novel.tags.single.name, 'novelTag');
      expect(novel.tags.single.addedByUploadedUser, isTrue);
      expect(novel.isBookmarked, isTrue);
      expect(novel.totalComments, 4);
    });

    test('novel without create_date falls back to the epoch', () {
      final json = _novelJson()..remove('create_date');
      final novel = PixezNovel.fromJson(json);
      expect(novel.createDate.millisecondsSinceEpoch, 0);
    });

    test('user preview maps user, illusts and novels', () {
      final preview = PixezUserPreview.fromJson(_userPreviewJson());
      expect(preview.user.id, 7);
      expect(preview.illusts.single.id, 11);
      expect(preview.novels.single.id, 21);
      expect(preview.novels.single.title, '小説見出し');
      expect(preview.novels.single.caption, 'あらすじ');
      expect(preview.isMuted, isFalse);
    });

    test('user detail maps profile counts and publicity strings', () {
      final detail = PixezUserDetail.fromJson(_userDetailJson());
      expect(detail.user.name, '作者');
      expect(detail.profile.webpage, 'https://example.com/u/7');
      expect(detail.profile.gender, 'male');
      expect(detail.profile.birthDay, '01-02');
      expect(detail.profile.birthYear, 1990);
      expect(detail.profile.totalFollowUsers, 3);
      expect(detail.profile.totalNovels, 5);
      expect(detail.profile.totalIllustBookmarksPublic, 300);
      expect(detail.profile.isPremium, isTrue);
      expect(detail.profilePublicity.birthYear, '1990');
      expect(detail.profilePublicity.job, 'engineer');
    });

    test('bookmark detail keeps the restrict and raw tag names', () {
      final detail = PixezBookmarkDetail.fromJson(<String, dynamic>{
        'is_bookmarked': true,
        'restrict': 'private',
        'tags': <Map<String, dynamic>>[
          <String, dynamic>{'name': ' tagA '},
          <String, dynamic>{'name': 'tagB'},
        ],
      });
      expect(detail.isBookmarked, isTrue);
      expect(detail.restrict, 'private');
      expect(detail.tags, <String>[' tagA ', 'tagB']);
    });

    test('search query formats unpadded dates and omits null filters', () {
      final params = PixezSearchQuery(
        word: 'w',
        startDate: DateTime(2026, 1, 2),
        endDate: DateTime(2026, 12, 31),
        bookmarkNum: 500,
      ).toQueryParameters();
      expect(params, <String, dynamic>{
        'sort': 'date_desc',
        'search_target': 'partial_match_for_tags',
        'start_date': '2026-1-2',
        'end_date': '2026-12-31',
        'bookmark_num': 500,
        'word': 'w',
      });
      expect(
        const PixezSearchQuery(word: 'w', sort: '', searchTarget: '')
            .toQueryParameters(),
        <String, dynamic>{'word': 'w'},
      );
    });

    test('rank modes keep the source order and labels', () {
      expect(PixezRankMode.all, hasLength(12));
      expect(
        PixezRankMode.all.map((mode) => mode.code).toList(),
        <String>[
          'day',
          'day_male',
          'day_female',
          'week_original',
          'week_rookie',
          'week',
          'month',
          'day_ai',
          'day_r18_ai',
          'day_r18',
          'week_r18',
          'week_r18g',
        ],
      );
      expect(PixezRankMode.labelOf('week'), '周榜');
      expect(PixezRankMode.labelOf('unknown'), 'unknown');
    });

    test('search options expose the accepted sorts and targets', () {
      expect(PixezSearchOptions.defaultSort, 'date_desc');
      expect(PixezSearchOptions.defaultTarget, 'partial_match_for_tags');
      expect(PixezSearchOptions.sorts, contains('popular_desc'));
      expect(PixezSearchOptions.targets, contains('title_and_caption'));
      expect(PixezSearchOptions.sortLabels['popular_desc'], '热门');
      expect(PixezSearchOptions.targetLabels['exact_match_for_tags'], '标签完全匹配');
    });

    test('lenient JSON helpers accept numbers, strings and booleans', () {
      expect(pixezInt('12'), 12);
      expect(pixezInt(null, fallback: 3), 3);
      expect(pixezIntOrNull('8'), 8);
      expect(pixezString(null), '');
      expect(pixezStringOrNull(''), isNull);
      expect(pixezBool(1), isTrue);
      expect(pixezBool('false'), isFalse);
      expect(pixezBool(null, fallback: true), isTrue);
      expect(pixezResponseMap('{"a":1}'), <String, dynamic>{'a': 1});
    });

    test('paged result exposes hasMore from next_url', () {
      final withNext = PixezPagedResult<PixezIllust>.fromJson(
        <String, dynamic>{
          'illusts': <Map<String, dynamic>>[_illustJson()],
          'next_url': 'https://app-api.pixiv.net/v1/illust/recommended?page=2',
        },
        itemsKey: 'illusts',
        itemParser: PixezIllust.fromJson,
      );
      expect(withNext.hasMore, isTrue);
      final end = PixezPagedResult<PixezIllust>.fromJson(
        <String, dynamic>{'illusts': <Map<String, dynamic>>[], 'next_url': ''},
        itemsKey: 'illusts',
        itemParser: PixezIllust.fromJson,
      );
      expect(end.hasMore, isFalse);
      expect(end.nextUrl, isNull);
    });

    test('recommendation parses ranking illusts and contest flag', () {
      final recommendation = PixezRecommendation.fromJson(<String, dynamic>{
        'illusts': <Map<String, dynamic>>[_illustJson(id: 1)],
        'ranking_illusts': <Map<String, dynamic>>[_illustJson(id: 2)],
        'next_url': null,
        'contest_exists': true,
      });
      expect(recommendation.illusts.single.id, 1);
      expect(recommendation.rankingIllusts.single.id, 2);
      expect(recommendation.contestExists, isTrue);
      expect(recommendation.hasMore, isFalse);
    });

    test('OAuth token accepts both wrapped and flat responses', () {
      final wrapped = PixezOAuthToken.fromJson(<String, dynamic>{
        'response': <String, dynamic>{
          'access_token': 'wrapped',
          'refresh_token': 'r',
          'expires_in': 3600,
          'user': <String, dynamic>{'id': 9, 'name': 'N', 'account': 'a'},
        },
      });
      expect(wrapped.accessToken, 'wrapped');
      expect(wrapped.tokenType, 'bearer');
      expect(wrapped.userId, 9);
      final flat = PixezOAuthToken.fromJson(<String, dynamic>{
        'access_token': 'flat',
        'token_type': 'Bearer',
      });
      expect(flat.accessToken, 'flat');
      expect(flat.tokenType, 'Bearer');
      expect(flat.isValid, isTrue);
    });
  });

  group('paging helpers', () {
    test('next_url resolver rewrites the pixiv host only', () {
      const resolver = PixezNextUrlResolver(
        baseUrl: 'https://210.140.131.199',
      );
      expect(
        resolver.resolve('https://app-api.pixiv.net/v1/illust/ranking?mode=day'),
        'https://210.140.131.199/v1/illust/ranking?mode=day',
      );
      expect(
        resolver.resolve(
          'https://app-api.pixiv.net/v1/illust/ranking?mode=day&page=2',
        ),
        'https://210.140.131.199/v1/illust/ranking?mode=day&page=2',
      );
      expect(
        resolver.resolve('https://example.com/next?page=2'),
        'https://example.com/next?page=2',
      );
      expect(resolver.resolve('  '), isNull);
      expect(resolver.resolve(null), isNull);
    });

    test('bookmark tags keep the first tag verbatim and trim later ones', () {
      expect(pixezJoinBookmarkTags(<String>[]), isNull);
      expect(pixezJoinBookmarkTags(<String>['only']), 'only');
      expect(
        pixezJoinBookmarkTags(<String>[' first ', ' second ', 'third']),
        ' first  second third',
      );
    });

    test('error helpers distinguish auth, HTTP and network failures', () {
      expect(
        pixezErrorMessage(const PixezAuthRequiredException()),
        '需要登录令牌',
      );
      final request = RequestOptions(path: '/v1/illust/recommended');
      expect(
        pixezErrorMessage(
          DioException(
            requestOptions: request,
            response: Response<void>(
              requestOptions: request,
              statusCode: 500,
            ),
          ),
        ),
        '请求失败（HTTP 500）',
      );
      expect(pixezIsAuthFailure(const PixezAuthRequiredException()), isTrue);
      expect(
        pixezIsAuthFailure(
          DioException(
            requestOptions: request,
            response: Response<void>(
              requestOptions: request,
              statusCode: 401,
            ),
          ),
        ),
        isTrue,
      );
      expect(
        pixezIsAuthFailure(DioException(requestOptions: request)),
        isFalse,
      );
    });
  });

  group('home controller', () {
    test('loads the first page and dedupes subsequent pages by illust id', () async {
      final adapter = _FakeAdapter((request) {
        if (request.uri.path == '/v1/illust/recommended' &&
            !request.uri.queryParameters.containsKey('page')) {
          return <String, dynamic>{
            'illusts': <Map<String, dynamic>>[
              _illustJson(id: 1),
              _illustJson(id: 2),
            ],
            'next_url':
                'https://app-api.pixiv.net/v1/illust/recommended?page=2',
          };
        }
        return <String, dynamic>{
          'illusts': <Map<String, dynamic>>[
            _illustJson(id: 2),
            _illustJson(id: 3),
          ],
          'next_url': null,
        };
      });
      final controller = PixezHomeController(client: _api(adapter));
      addTearDown(controller.dispose);
      await controller.load();
      expect(controller.status, PixezLoadStatus.ready);
      expect(controller.illusts.map((illust) => illust.id), <int>[1, 2]);
      expect(controller.hasMore, isTrue);
      await controller.loadMore();
      expect(controller.illusts.map((illust) => illust.id), <int>[1, 2, 3]);
      expect(controller.hasMore, isFalse);
      expect(controller.loadingMore, isFalse);
      expect(adapter.requests, hasLength(2));
      expect(adapter.requests[1].uri.queryParameters['page'], '2');
    });

    test('loadMore is a no-op when there is no next_url', () async {
      final adapter = _FakeAdapter(
        (_) => <String, dynamic>{
          'illusts': <Map<String, dynamic>>[_illustJson()],
          'next_url': null,
        },
      );
      final controller = PixezHomeController(client: _api(adapter));
      addTearDown(controller.dispose);
      await controller.load();
      await controller.loadMore();
      expect(adapter.requests, hasLength(1));
      expect(controller.hasMore, isFalse);
    });

    test('a missing token degrades to loginRequired without a request', () async {
      final adapter = _FakeAdapter();
      final controller = PixezHomeController(client: _api(adapter, token: null));
      addTearDown(controller.dispose);
      await controller.load();
      expect(controller.status, PixezLoadStatus.loginRequired);
      expect(controller.error, '需要登录令牌');
      expect(adapter.requests, isEmpty);
    });

    test('refresh reloads page one', () async {
      final adapter = _FakeAdapter(
        (_) => <String, dynamic>{
          'illusts': <Map<String, dynamic>>[_illustJson(id: 1)],
        },
      );
      final controller = PixezHomeController(client: _api(adapter));
      addTearDown(controller.dispose);
      await controller.load();
      await controller.refresh();
      expect(adapter.requests, hasLength(2));
      expect(controller.illusts.single.id, 1);
    });
  });

  group('rank controller', () {
    test('defaults to the day mode and sends its code', () async {
      final adapter = _FakeAdapter();
      final controller = PixezRankController(client: _api(adapter));
      addTearDown(controller.dispose);
      await controller.load();
      expect(controller.mode.code, 'day');
      expect(controller.modes, hasLength(12));
      final request = _single(adapter);
      expect(request.uri.path, '/v1/illust/ranking');
      expect(request.uri.queryParameters['mode'], 'day');
      expect(request.uri.queryParameters.containsKey('date'), isFalse);
    });

    test('selectMode issues the new code and selectDate the unpadded date', () async {
      final adapter = _FakeAdapter();
      final controller = PixezRankController(client: _api(adapter));
      addTearDown(controller.dispose);
      await controller.load();
      await controller.selectMode(5);
      expect(controller.mode.code, 'week');
      expect(adapter.requests.last.uri.queryParameters['mode'], 'week');
      await controller.selectDate(DateTime(2026, 9, 8));
      expect(controller.requestDate, '2026-9-8');
      expect(adapter.requests.last.uri.queryParameters['date'], '2026-9-8');
      expect(controller.date, DateTime(2026, 9, 8));
    });

    test('out-of-range mode indexes are ignored', () async {
      final adapter = _FakeAdapter();
      final controller = PixezRankController(client: _api(adapter));
      addTearDown(controller.dispose);
      await controller.load();
      await controller.selectMode(99);
      expect(controller.modeIndex, 0);
      expect(adapter.requests, hasLength(1));
    });
  });

  group('search controller', () {
    test('an empty word shows the validation message without a request', () async {
      final adapter = _FakeAdapter();
      final controller = PixezSearchController(client: _api(adapter));
      addTearDown(controller.dispose);
      await controller.search('   ');
      expect(controller.hasSearched, isFalse);
      expect(controller.status, PixezLoadStatus.error);
      expect(controller.error, '请输入搜索关键词');
      expect(adapter.requests, isEmpty);
    });

    test('illust search trims the word and forwards sort/target', () async {
      final adapter = _FakeAdapter(
        (_) => <String, dynamic>{
          'illusts': <Map<String, dynamic>>[_illustJson(id: 4)],
        },
      );
      final controller = PixezSearchController(client: _api(adapter));
      addTearDown(controller.dispose);
      controller.setSort('popular_desc');
      controller.setSearchTarget('title_and_caption');
      await controller.search('  blue sky  ');
      expect(controller.word, 'blue sky');
      expect(controller.hasSearched, isTrue);
      expect(controller.illusts.single.id, 4);
      final request = _single(adapter);
      expect(request.uri.path, '/v1/search/illust');
      expect(request.uri.queryParameters['word'], 'blue sky');
      expect(request.uri.queryParameters['sort'], 'popular_desc');
      expect(request.uri.queryParameters['search_target'], 'title_and_caption');
    });

    test('invalid sort/target values are ignored', () {
      final controller = PixezSearchController(client: _api(_FakeAdapter()));
      addTearDown(controller.dispose);
      controller.setSort('bogus');
      controller.setSearchTarget('bogus');
      expect(controller.sort, PixezSearchOptions.defaultSort);
      expect(controller.searchTarget, PixezSearchOptions.defaultTarget);
    });

    test('user search pages by user_previews and dedupes user ids', () async {
      final adapter = _FakeAdapter((request) {
        if (request.uri.queryParameters.containsKey('page')) {
          return <String, dynamic>{
            'user_previews': <Map<String, dynamic>>[
              _userPreviewJson(userId: 7),
              _userPreviewJson(userId: 8),
            ],
            'next_url': null,
          };
        }
        return <String, dynamic>{
          'user_previews': <Map<String, dynamic>>[_userPreviewJson(userId: 7)],
          'next_url': 'https://app-api.pixiv.net/v1/search/user?page=2',
        };
      });
      final controller = PixezSearchController(client: _api(adapter));
      addTearDown(controller.dispose);
      controller.setShowUsers(true);
      await controller.search('作者');
      expect(controller.users.single.user.id, 7);
      await controller.loadMore();
      expect(
        controller.users.map((preview) => preview.user.id),
        <int>[7, 8],
      );
      expect(adapter.requests.last.uri.queryParameters['page'], '2');
    });

    test('a missing token degrades to loginRequired', () async {
      final adapter = _FakeAdapter();
      final controller = PixezSearchController(
        client: _api(adapter, token: null),
      );
      addTearDown(controller.dispose);
      await controller.search('blue');
      expect(controller.status, PixezLoadStatus.loginRequired);
      expect(controller.error, '需要登录令牌');
      expect(adapter.requests, isEmpty);
    });
  });

  group('detail controller', () {
    _FakeAdapter detailAdapter() => _FakeAdapter((request) {
      switch (request.uri.path) {
        case '/v1/illust/detail':
          return <String, dynamic>{
            'illust': _illustJson(id: 77, bookmarked: false, followed: false),
          };
        case '/v2/illust/related':
          return <String, dynamic>{
            'illusts': <Map<String, dynamic>>[_illustJson(id: 78)],
            'next_url': null,
          };
        case '/v2/illust/bookmark/detail':
          return <String, dynamic>{
            'bookmark_detail': <String, dynamic>{
              'is_bookmarked': false,
              'restrict': 'private',
              'tags': <Map<String, dynamic>>[
                <String, dynamic>{'name': ' tag1 '},
                <String, dynamic>{'name': 'tag2'},
              ],
            },
          };
        default:
          return <String, dynamic>{};
      }
    });

    test('load fetches detail, related and optional bookmark state', () async {
      final adapter = detailAdapter();
      final controller = PixezDetailController(
        illustId: 77,
        client: _api(adapter),
      );
      addTearDown(controller.dispose);
      await controller.load();
      expect(controller.status, PixezLoadStatus.ready);
      expect(controller.illust?.id, 77);
      expect(controller.related.single.id, 78);
      expect(controller.bookmarkDetail?.restrict, 'private');
      expect(controller.bookmarked, isFalse);
      expect(controller.following, isFalse);
      expect(adapter.requests, hasLength(3));
      expect(adapter.requests[0].uri.queryParameters['illust_id'], '77');
    });

    test('toggleBookmark posts tags[] and flips the state', () async {
      final adapter = detailAdapter();
      final controller = PixezDetailController(
        illustId: 77,
        client: _api(adapter),
      );
      addTearDown(controller.dispose);
      await controller.load();
      await controller.toggleBookmark();
      expect(controller.bookmarked, isTrue);
      final add = adapter.requests.last;
      expect(add.uri.path, '/v2/illust/bookmark/add');
      expect(add.data, <String, dynamic>{
        'illust_id': 77,
        'restrict': 'private',
        'tags[]': ' tag1  tag2',
      });
      await controller.toggleBookmark();
      expect(controller.bookmarked, isFalse);
      expect(adapter.requests.last.uri.path, '/v1/illust/bookmark/delete');
    });

    test('toggleFollow posts follow/add then follow/delete', () async {
      final adapter = detailAdapter();
      final controller = PixezDetailController(
        illustId: 77,
        client: _api(adapter),
      );
      addTearDown(controller.dispose);
      await controller.load();
      await controller.toggleFollow();
      expect(controller.following, isTrue);
      expect(adapter.requests.last.uri.path, '/v1/user/follow/add');
      expect(adapter.requests.last.data, <String, dynamic>{
        'user_id': 7,
        'restrict': 'public',
      });
      await controller.toggleFollow();
      expect(controller.following, isFalse);
      expect(adapter.requests.last.uri.path, '/v1/user/follow/delete');
    });

    test('actions without a token report the login message', () async {
      final adapter = _FakeAdapter();
      final controller = PixezDetailController(
        illustId: 77,
        client: _api(adapter, token: null),
      );
      addTearDown(controller.dispose);
      await controller.toggleBookmark();
      expect(controller.actionError, '需要登录令牌');
      expect(adapter.requests, isEmpty);
    });
  });

  group('user controller', () {
    _FakeAdapter userAdapter() => _FakeAdapter((request) {
      switch (request.uri.path) {
        case '/v1/user/detail':
          return _userDetailJson();
        case '/v1/user/bookmarks/illust':
          return <String, dynamic>{
            'illusts': <Map<String, dynamic>>[_illustJson(id: 9)],
          };
        default:
          return <String, dynamic>{
            'illusts': <Map<String, dynamic>>[
              _illustJson(id: request.uri.queryParameters['type'] == 'manga' ? 2 : 1),
            ],
          };
      }
    });

    test('load fetches the profile and first illust page', () async {
      final adapter = userAdapter();
      final controller = PixezUserController(userId: 7, client: _api(adapter));
      addTearDown(controller.dispose);
      await controller.load();
      expect(controller.status, PixezLoadStatus.ready);
      expect(controller.detail?.profile.totalIllusts, 100);
      expect(controller.works.single.id, 1);
      expect(adapter.requests, hasLength(2));
      expect(adapter.requests[1].uri.queryParameters, <String, String>{
        'filter': 'for_android',
        'user_id': '7',
        'type': 'illust',
        'offset': '0',
      });
    });

    test('tabs load manga and public bookmarks with the right queries', () async {
      final adapter = userAdapter();
      final controller = PixezUserController(userId: 7, client: _api(adapter));
      addTearDown(controller.dispose);
      await controller.load();
      await controller.selectTab(1);
      expect(controller.worksType, 'manga');
      expect(controller.works.single.id, 2);
      expect(adapter.requests.last.uri.queryParameters['type'], 'manga');
      await controller.selectTab(2);
      expect(controller.bookmarks.single.id, 9);
      expect(adapter.requests.last.uri.path, '/v1/user/bookmarks/illust');
      expect(adapter.requests.last.uri.queryParameters['restrict'], 'public');
      expect(adapter.requests.last.uri.queryParameters['offset'], '0');
      await controller.loadMore();
      expect(adapter.requests.last.uri.queryParameters['offset'], '1');
    });

    test('selectTab bounds-checks the index', () async {
      final adapter = userAdapter();
      final controller = PixezUserController(userId: 7, client: _api(adapter));
      addTearDown(controller.dispose);
      await controller.load();
      await controller.selectTab(5);
      expect(controller.tabIndex, 0);
      expect(adapter.requests, hasLength(2));
    });
  });

  group('widgets', () {
    testWidgets('login-required view shows the exact message and button', (
      tester,
    ) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PixezLoginRequiredView(
              onEnterToken: () => tapped = true,
            ),
          ),
        ),
      );
      expect(find.text('需要登录令牌'), findsOneWidget);
      expect(find.byKey(PixezLoginRequiredView.titleKey), findsOneWidget);
      await tester.tap(find.byKey(PixezLoginRequiredView.buttonKey));
      expect(tapped, isTrue);
    });

    testWidgets('token dialog returns the trimmed token', (tester) async {
      String? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  result = await showPixezTokenDialog(context);
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('输入 Pixiv 登录令牌'), findsOneWidget);
      await tester.enterText(find.byType(TextField), '  token-abc  ');
      await tester.tap(find.text('保存'));
      await tester.pumpAndSettle();
      expect(result, 'token-abc');
    });

    testWidgets('home page degrades to the login state without any HTTP call', (
      tester,
    ) async {
      final adapter = _FakeAdapter();
      final auth = PixezAuthStore(persist: false);
      final controller = PixezHomeController(
        client: _api(adapter, token: null),
        auth: auth,
      );
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        MaterialApp(home: PixezHomePage(controller: controller)),
      );
      await tester.pumpAndSettle();
      expect(find.text('Pixiv 推荐'), findsOneWidget);
      expect(find.text('需要登录令牌'), findsOneWidget);
      expect(adapter.requests, isEmpty);
    });

    test('entry constants match the module tile contract', () {
      expect(PixezEntry.title, 'Pixiv（Pixez）');
      expect(PixezEntry.subtitle, contains('登录令牌'));
      expect(PixezEntry.icon, Icons.photo_library_outlined);
      expect(PixezEntry.page(), isA<PixezHomePage>());
    });
  });
}
