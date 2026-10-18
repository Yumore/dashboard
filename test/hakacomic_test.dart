import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dashboard/features/comic/hakacomic/haka_action_response.dart';
import 'package:dashboard/features/comic/hakacomic/haka_api.dart';
import 'package:dashboard/features/comic/hakacomic/haka_api_exception.dart';
import 'package:dashboard/features/comic/hakacomic/haka_base_response.dart';
import 'package:dashboard/features/comic/hakacomic/haka_cache.dart';
import 'package:dashboard/features/comic/hakacomic/haka_categories_response.dart';
import 'package:dashboard/features/comic/hakacomic/haka_category.dart';
import 'package:dashboard/features/comic/hakacomic/haka_chapter.dart';
import 'package:dashboard/features/comic/hakacomic/haka_chapter_image.dart';
import 'package:dashboard/features/comic/hakacomic/haka_chapters.dart';
import 'package:dashboard/features/comic/hakacomic/haka_client.dart';
import 'package:dashboard/features/comic/hakacomic/haka_comic.dart';
import 'package:dashboard/features/comic/hakacomic/haka_comic_detail_controller.dart';
import 'package:dashboard/features/comic/hakacomic/haka_comic_details_response.dart';
import 'package:dashboard/features/comic/hakacomic/haka_comic_list_controller.dart';
import 'package:dashboard/features/comic/hakacomic/haka_comic_sort_type.dart';
import 'package:dashboard/features/comic/hakacomic/haka_comics_payload.dart';
import 'package:dashboard/features/comic/hakacomic/haka_comics_response.dart';
import 'package:dashboard/features/comic/hakacomic/haka_config.dart';
import 'package:dashboard/features/comic/hakacomic/haka_doc.dart';
import 'package:dashboard/features/comic/hakacomic/haka_endpoints.dart';
import 'package:dashboard/features/comic/hakacomic/haka_entry.dart';
import 'package:dashboard/features/comic/hakacomic/haka_entry_page.dart';
import 'package:dashboard/features/comic/hakacomic/haka_failure.dart';
import 'package:dashboard/features/comic/hakacomic/haka_favorite_store.dart';
import 'package:dashboard/features/comic/hakacomic/haka_fetch_chapter_images_payload.dart';
import 'package:dashboard/features/comic/hakacomic/haka_fetch_chapter_images_response.dart';
import 'package:dashboard/features/comic/hakacomic/haka_history_entry.dart';
import 'package:dashboard/features/comic/hakacomic/haka_history_store.dart';
import 'package:dashboard/features/comic/hakacomic/haka_image_detail.dart';
import 'package:dashboard/features/comic/hakacomic/haka_image_quality.dart';
import 'package:dashboard/features/comic/hakacomic/haka_loading.dart';
import 'package:dashboard/features/comic/hakacomic/haka_method.dart';
import 'package:dashboard/features/comic/hakacomic/haka_read_record.dart';
import 'package:dashboard/features/comic/hakacomic/haka_read_record_store.dart';
import 'package:dashboard/features/comic/hakacomic/haka_reader_controller.dart';
import 'package:dashboard/features/comic/hakacomic/haka_repository.dart';
import 'package:dashboard/features/comic/hakacomic/haka_search_comic.dart';
import 'package:dashboard/features/comic/hakacomic/haka_search_controller.dart';
import 'package:dashboard/features/comic/hakacomic/haka_search_history_store.dart';
import 'package:dashboard/features/comic/hakacomic/haka_search_payload.dart';
import 'package:dashboard/features/comic/hakacomic/haka_search_response.dart';
import 'package:dashboard/features/comic/hakacomic/haka_signature.dart';
import 'package:dashboard/features/comic/hakacomic/haka_state_view.dart';
import 'package:dashboard/features/comic/hakacomic/haka_success.dart';
import 'package:dashboard/features/comic/hakacomic/haka_user_favorite_payload.dart';

// ---------------------------------------------------------------------------
// Network-free plumbing: a Dio adapter that answers from a local handler and
// records every request, so the port can be asserted without touching the
// picacomic API.
// ---------------------------------------------------------------------------

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.handler);

  final Future<ResponseBody> Function(RequestOptions options) handler;

  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    requests.add(options);
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _body(Object? payload, {int statusCode = 200}) {
  return ResponseBody.fromString(
    jsonEncode(payload),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

Map<String, dynamic> _envelope(Object? data, {String message = 'ok'}) {
  return {'code': 200, 'message': message, 'data': data};
}

HakaClient _client(
  _FakeAdapter adapter, {
  HakaConfig config = const HakaConfig(),
}) {
  final dio = Dio();
  dio.httpClientAdapter = adapter;
  return HakaClient(config: config, dio: dio, retryDelay: Duration.zero);
}

HakaRepository _repo(
  _FakeAdapter adapter, {
  HakaConfig config = const HakaConfig(),
  HakaCache? cache,
}) {
  return HakaRepository(
    client: _client(adapter, config: config),
    cache: cache,
  );
}

int _pageOf(RequestOptions options) {
  final value = options.queryParameters['page'];
  return value is int ? value : int.parse('$value');
}

// ---------------------------------------------------------------------------
// Hand-written fixtures: exact JSON field names of the picacomic schema.
// ---------------------------------------------------------------------------

Map<String, dynamic> imageJson({
  String fileServer = 'https://storage1.picacomic.com',
  String path = 'a/b.jpg',
}) {
  return {'fileServer': fileServer, 'path': path, 'originalName': 'b.jpg'};
}

Map<String, dynamic> docJson(String id, {String title = '漫画'}) {
  return {
    '_id': id,
    'title': title,
    'author': '作者',
    'totalViews': 11,
    'totalLikes': 3,
    'pagesCount': 20,
    'epsCount': 2,
    'finished': true,
    'categories': ['类别'],
    'thumb': imageJson(),
    'id': 'doc-$id',
    'likesCount': 7,
    'tags': ['标签'],
  };
}

Map<String, dynamic> chapterJson(String id, num order) {
  return {
    '_id': id,
    'title': '第$order话',
    'order': order,
    'updated_at': '2024-01-02T03:04:05.000Z',
    'id': 'ep-${order.toInt()}',
  };
}

Map<String, dynamic> chapterImageJson(String id, {String path = 'p/1.jpg'}) {
  return {'_id': id, 'id': 'img-$id', 'media': imageJson(path: path)};
}

Map<String, dynamic> comicsBody(
  List<Map<String, dynamic>> docs, {
  int page = 1,
  int pages = 1,
}) {
  return {
    'docs': docs,
    'limit': 20,
    'page': page,
    'pages': pages,
    'total': docs.length,
  };
}

Map<String, dynamic> chaptersBody(
  List<Map<String, dynamic>> docs, {
  int page = 1,
  int pages = 1,
}) {
  return {
    'docs': docs,
    'total': docs.length,
    'limit': 20,
    'page': page,
    'pages': pages,
  };
}

Map<String, dynamic> chapterImagesBody(
  List<Map<String, dynamic>> docs, {
  int page = 1,
  int pages = 1,
}) {
  return {
    'pages': {
      'docs': docs,
      'total': docs.length,
      'limit': 20,
      'page': page,
      'pages': pages,
    },
    'ep': {'_id': 'ch-1', 'title': '第1话'},
  };
}

Map<String, dynamic> comicDetailJson() {
  return {
    '_id': 'abc',
    '_creator': {
      '_id': 'u1',
      'gender': 'm',
      'name': '作者名',
      'exp': 120,
      'level': 5,
      'role': 'admin',
      'avatar': imageJson(path: 'avatar.jpg'),
      'characters': ['角色'],
      'title': '萌新',
      'slogan': '你好',
    },
    'title': '测试漫画',
    'description': '简介',
    'thumb': imageJson(),
    'author': '作者名',
    'categories': ['类别'],
    'chineseTeam': '汉化组',
    'tags': ['标签'],
    'pagesCount': 20,
    'epsCount': 2,
    'finished': false,
    'updated_at': '2024-01-01T00:00:00.000Z',
    'created_at': '2023-01-01T00:00:00.000Z',
    'allowDownload': true,
    'allowComment': true,
    'totalLikes': 9,
    'totalViews': 90,
    'viewsCount': 80,
    'likesCount': 7,
    'isFavourite': false,
    'isLiked': false,
  };
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  // -------------------------------------------------------------------------
  // Signing constants, headers and URL rules
  // -------------------------------------------------------------------------

  group('HakaConfig', () {
    test('defaults to the public picacomic endpoint, not the operator relay',
        () {
      const config = HakaConfig();
      expect(config.resolvedBaseUrl, 'https://picaapi.picacomic.com/');
      expect(HakaApi.picacomic.host, 'https://picaapi.picacomic.com/');
      expect(HakaApi.go2778.host, 'https://picaapi.go2778.com/');
    });

    test('fromName falls back to the public host for unknown names', () {
      expect(HakaApi.fromName('go2778'), HakaApi.go2778);
      expect(HakaApi.fromName('picacomic'), HakaApi.picacomic);
      // Upstream defaulted to the go2778 relay (app_config.dart:63); the port
      // deliberately defaults to picacomic.
      expect(HakaApi.fromName(null), HakaApi.picacomic);
      expect(HakaApi.fromName('nope'), HakaApi.picacomic);
    });

    test('carries the public picacomic signing constants', () {
      expect(HakaConfig.apiKey, 'C69BAF41DA5ABD1FFEDC6D2FEA56B');
      expect(HakaConfig.nonce, '4ce7a7aa759b40f794d189a88b84aba8');
      expect(HakaConfig.appVersion, '2.2.1.3.3.4');
      expect(HakaConfig.appBuildVersion, '45');
      expect(HakaConfig.accept, 'application/vnd.picacomic.com.v1+json');
      expect(
        HakaConfig.secretKey,
        r'~d}$Q7$eIni=V)9\RK/P.RM4;9[7|@/CA}b~OW!3?EV`:<>M7pddUBL5n|0/*Cn',
      );
    });

    test('default headers match the upstream android client', () {
      final headers = const HakaConfig().defaultHeaders;
      expect(headers.length, 10);
      expect(headers['accept'], 'application/vnd.picacomic.com.v1+json');
      expect(headers['User-Agent'], 'okhttp/3.8.1');
      expect(headers['Content-Type'], 'application/json; charset=UTF-8');
      expect(headers['api-key'], 'C69BAF41DA5ABD1FFEDC6D2FEA56B');
      expect(headers['app-build-version'], '45');
      expect(headers['app-platform'], 'android');
      expect(headers['app-uuid'], 'defaultUuid');
      expect(headers['app-version'], '2.2.1.3.3.4');
      expect(headers['nonce'], '4ce7a7aa759b40f794d189a88b84aba8');
      expect(headers['app-channel'], '1');
    });

    test('base URL is injectable and normalised to a trailing slash', () {
      const injected = HakaConfig(baseUrl: 'http://127.0.0.1:9999');
      expect(injected.resolvedBaseUrl, 'http://127.0.0.1:9999/');
      const withSlash = HakaConfig(baseUrl: 'http://127.0.0.1:9999/');
      expect(withSlash.resolvedBaseUrl, 'http://127.0.0.1:9999/');
      expect(
        withSlash.copyWith(api: HakaApi.go2778).resolvedBaseUrl,
        'http://127.0.0.1:9999/',
      );
      expect(
        const HakaConfig().copyWith(api: HakaApi.go2778).resolvedBaseUrl,
        'https://picaapi.go2778.com/',
      );
    });

    test('image quality names and upstream labels', () {
      expect(HakaImageQuality.low.displayName, '低');
      expect(HakaImageQuality.medium.displayName, '中');
      expect(HakaImageQuality.high.displayName, '高');
      expect(HakaImageQuality.original.displayName, '原画');
      expect(HakaImageQuality.fromName('high'), HakaImageQuality.high);
      expect(HakaImageQuality.fromName(null), HakaImageQuality.original);
    });
  });

  group('hakaSignature', () {
    test('lowercase HMAC-SHA256 over url+timestamp+nonce+method+apiKey', () {
      // Fixed vector computed independently from the documented rule with a
      // Python hmac-sha256 implementation.
      expect(
        hakaSignature(
          url: 'comics',
          timestamp: '1700000000',
          nonce: HakaConfig.nonce,
          method: HakaMethod.get,
        ),
        '941ae5c5a63f6245f37d77b131852ccadb4c6489012e581ce08f06260be33d68',
      );
    });

    test('POST vectors sign the bare path', () {
      expect(
        hakaSignature(
          url: 'comics/advanced-search?page=2',
          timestamp: '1700000000',
          nonce: HakaConfig.nonce,
          method: HakaMethod.post,
        ),
        '52ac439f00cbbf211fb5578a90c7ba03ad573a8ea36e714c2c6fa5e3f383ebb0',
      );
    });

    test('GET vectors include the query string', () {
      expect(
        hakaSignature(
          url: 'comics?page=1&s=dd',
          timestamp: '1700000000',
          nonce: HakaConfig.nonce,
          method: HakaMethod.get,
        ),
        'e38fa48ccfaf6a6c7933f6fc67de679d11342feb2aee668b2235a2d749883a03',
      );
    });

    test('signed url keeps query for GET and drops it for POST', () {
      expect(
        hakaSignedUrl(
          method: HakaMethod.get,
          path: 'comics',
          query: {'page': 1, 's': 'dd'},
        ),
        'comics?page=1&s=dd',
      );
      expect(
        hakaSignedUrl(method: HakaMethod.get, path: 'categories'),
        'categories',
      );
      expect(
        hakaSignedUrl(
          method: HakaMethod.post,
          path: 'comics/advanced-search?page=2',
          query: {'page': 2},
        ),
        'comics/advanced-search?page=2',
      );
    });

    test('timestamp is unix seconds', () {
      expect(
        hakaTimestamp(DateTime.fromMillisecondsSinceEpoch(1700000000123)),
        '1700000000',
      );
    });

    test('headers add time, signature, authorization and image-quality', () {
      final headers = hakaHeaders(
        url: 'comics',
        method: HakaMethod.get,
        config: const HakaConfig(
          token: 'tok-123',
          imageQuality: HakaImageQuality.high,
        ),
        now: DateTime.fromMillisecondsSinceEpoch(1700000000000),
      );
      expect(headers.length, 14);
      expect(headers['time'], '1700000000');
      expect(headers['authorization'], 'tok-123');
      expect(headers['image-quality'], 'high');
      expect(
        headers['signature'],
        hakaSignature(
          url: 'comics',
          timestamp: '1700000000',
          nonce: HakaConfig.nonce,
          method: HakaMethod.get,
        ),
      );
    });
  });

  group('HakaEndpoints', () {
    test('static paths match the schema', () {
      expect(HakaEndpoints.categories, 'categories');
      expect(HakaEndpoints.comics, 'comics');
      expect(HakaEndpoints.favouriteComics, 'users/favourite');
      expect(HakaEndpoints.hotSearchWords, 'keywords');
      expect(HakaEndpoints.signIn, 'auth/sign-in');
      expect(HakaEndpoints.profile, 'users/profile');
      expect(HakaEndpoints.leaderboard, 'comics/leaderboard');
      expect(HakaEndpoints.randomComics, 'comics/random');
    });

    test('path templates match the schema', () {
      expect(HakaEndpoints.searchComics(2), 'comics/advanced-search?page=2');
      expect(HakaEndpoints.comicDetails('abc'), 'comics/abc');
      expect(HakaEndpoints.comicChapters('abc'), 'comics/abc/eps');
      expect(HakaEndpoints.chapterImages('abc', 3), 'comics/abc/order/3/pages');
      expect(HakaEndpoints.comicLike('abc'), 'comics/abc/like');
      expect(HakaEndpoints.comicFavourite('abc'), 'comics/abc/favourite');
      expect(
        HakaEndpoints.comicRecommendation('abc'),
        'comics/abc/recommendation',
      );
    });
  });

  // -------------------------------------------------------------------------
  // Image URL rules
  // -------------------------------------------------------------------------

  group('HakaImageDetail', () {
    test('directUrl inserts the missing static segment', () {
      const detail = HakaImageDetail(
        fileServer: 'https://storage1.picacomic.com',
        path: 'a/b.jpg',
        originalName: 'b.jpg',
      );
      expect(
        detail.directUrl,
        'https://storage1.picacomic.com/static/a/b.jpg',
      );
    });

    test('directUrl keeps an existing static segment', () {
      const detail = HakaImageDetail(
        fileServer: 'https://static.picacomic.com',
        path: 'a/b.jpg',
        originalName: 'b.jpg',
      );
      expect(detail.directUrl, 'https://static.picacomic.com/a/b.jpg');
    });

    test('normalizeUrl collapses repeated slashes', () {
      expect(
        HakaImageDetail.normalizeUrl('https://x.com//a///b.jpg'),
        'https://x.com/a/b.jpg',
      );
    });

    test('proxyUrl rewrites the picacomic host to go2778', () {
      const detail = HakaImageDetail(
        fileServer: 'https://storage1.picacomic.com',
        path: 'a/b.jpg',
        originalName: 'b.jpg',
      );
      expect(
        detail.proxyUrl,
        'https://storage1.go2778.com/static/a/b.jpg',
      );
    });

    test('urlFor switches on the configured host', () {
      const detail = HakaImageDetail(
        fileServer: 'https://storage1.picacomic.com',
        path: 'a/b.jpg',
        originalName: 'b.jpg',
      );
      expect(detail.urlFor(HakaApi.picacomic), detail.directUrl);
      expect(detail.urlFor(HakaApi.go2778), detail.proxyUrl);
      expect(detail.cacheKey, 'a/b.jpg');
    });

    test('tryParse accepts map, json string and null', () {
      expect(HakaImageDetail.tryParse(null), isNull);
      const detail = HakaImageDetail(
        fileServer: 'fs',
        path: 'p',
        originalName: 'o',
      );
      expect(HakaImageDetail.tryParse(detail), same(detail));
      expect(HakaImageDetail.tryParse(jsonEncode(imageJson()))?.path, 'a/b.jpg');
      expect(HakaImageDetail.tryParse(imageJson())?.path, 'a/b.jpg');
      expect(HakaImageDetail.tryParse(42), isNull);
      // Faithful to the source: jsonDecode is not guarded.
      expect(() => HakaImageDetail.tryParse('{oops'), throwsFormatException);
    });
  });

  // -------------------------------------------------------------------------
  // Model mapping
  // -------------------------------------------------------------------------

  group('model mapping', () {
    test('HakaBaseResponse reads code, message and data', () {
      final response = HakaBaseResponse<HakaCategoriesResponse>.fromJson(
        {
          'code': 200,
          'message': 'ok',
          'data': {
            'categories': [
              {
                '_id': 'c1',
                'thumb': imageJson(),
                'title': '类别',
                'description': '描述',
                'isWeb': true,
              },
            ],
          },
        },
        (data) => HakaCategoriesResponse.fromJson(
          data as Map<String, dynamic>,
        ),
      );
      expect(response.code, 200);
      expect(response.message, 'ok');
      expect(response.data.categories.single.title, '类别');
      expect(response.data.categories.single.isWeb, isTrue);
    });

    test('HakaCategory defaults description and keeps web flag', () {
      final category = HakaCategory.fromJson({
        '_id': 'c1',
        'thumb': imageJson(),
        'title': '类别',
      });
      expect(category.id, 'c1');
      expect(category.description, '');
      expect(category.isWeb, isNull);
      expect(category.toJson()['isWeb'], isNull);
    });

    test('HakaDoc maps _id to uid and defaults author/likesCount', () {
      final doc = HakaDoc.fromJson({
        '_id': 'd1',
        'title': '漫画',
        'pagesCount': 20,
        'epsCount': 2,
        'finished': false,
        'categories': ['类别'],
        'thumb': imageJson(),
      });
      expect(doc.uid, 'd1');
      expect(doc.author, '');
      expect(doc.totalViews, 0);
      expect(doc.totalLikes, isNull);
      expect(doc.likesCount, 0);
      expect(doc.tags, isEmpty);
      expect(doc.finished, isFalse);
      expect(doc.id, isNull);
    });

    test('HakaSearchComic parses string numerics and defaults author to ??', () {
      final comic = HakaSearchComic.fromJson({
        '_id': 's1',
        'title': '漫画',
        'updated_at': '2024-01-01T00:00:00.000Z',
        'created_at': '2023-01-01T00:00:00.000Z',
        'thumb': imageJson(),
        'finished': true,
        'categories': ['类别'],
        'tags': ['标签'],
        'totalLikes': '9',
        'likesCount': '7',
      });
      expect(comic.uid, 's1');
      expect(comic.author, '??');
      expect(comic.totalLikes, 9);
      expect(comic.likesCount, 7);
      expect(comic.description, isNull);
      expect(comic.chineseTeam, isNull);
      // Unparseable numeric strings fall back to 0 / null like the generator.
      expect(HakaSearchComic.likesCountFromJson('nope'), 0);
      expect(HakaSearchComic.likesCountFromJson(null), 0);
      expect(HakaSearchComic.totalLikesFromJson('nope'), isNull);
      expect(HakaSearchComic.totalLikesFromJson(4.0), 4);
    });

    test('HakaComic maps the detail document', () {
      final comic = HakaComic.fromJson(comicDetailJson());
      expect(comic.id, 'abc');
      expect(comic.creator.name, '作者名');
      expect(comic.creator.avatar?.path, 'avatar.jpg');
      expect(comic.title, '测试漫画');
      expect(comic.chineseTeam, '汉化组');
      expect(comic.updatedAt, '2024-01-01T00:00:00.000Z');
      expect(comic.createdAt, '2023-01-01T00:00:00.000Z');
      expect(comic.commentsCount, 0);
      expect(comic.totalComments, isNull);
      expect(comic.isFavourite, isFalse);
      expect(comic.toJson()['_id'], 'abc');
      expect(comic.toJson()['_creator'], isA<Map<String, dynamic>>());
      expect(
        HakaComicDetailsResponse.fromJson({'comic': comicDetailJson()})
            .comic
            .id,
        'abc',
      );
      expect(comic.copyWith(isFavourite: true).isFavourite, isTrue);
      expect(comic.copyWith(isFavourite: true).isLiked, isFalse);
    });

    test('HakaChapter and HakaChapters map paging fields', () {
      final chapters = HakaChapters.fromJson(
        chaptersBody([chapterJson('ch1', 3.0)], page: 2, pages: 4),
      );
      expect(chapters.docs.single.uid, 'ch1');
      expect(chapters.docs.single.order, 3);
      expect(chapters.docs.single.id, 'ep-3');
      expect(chapters.docs.single.updatedAt, '2024-01-02T03:04:05.000Z');
      expect(chapters.page, 2);
      expect(chapters.pages, 4);
      expect(chapters.total, 1);
      expect(
        HakaChapter.fromJson(chapterJson('c', 1)).title,
        '第1话',
      );
    });

    test('HakaChapterImage resolves media urls', () {
      final image = HakaChapterImage.fromJson(chapterImageJson('p1'));
      expect(image.uid, 'p1');
      expect(image.id, 'img-p1');
      expect(image.url, 'https://storage1.picacomic.com/static/p/1.jpg');
      expect(
        image.urlFor(HakaApi.go2778),
        'https://storage1.go2778.com/static/p/1.jpg',
      );
      expect(image.cacheKey, 'p/1.jpg');
    });

    test('HakaFetchChapterImagesResponse reads pages.docs and ep', () {
      final response = HakaFetchChapterImagesResponse.fromJson(
        chapterImagesBody(
          [chapterImageJson('p1'), chapterImageJson('p2')],
          page: 1,
          pages: 2,
        ),
      );
      expect(response.pages.docs.length, 2);
      expect(response.pages.pages, 2);
      expect(response.ep.id, 'ch-1');
      expect(response.ep.title, '第1话');
    });
  });

  group('payloads and empty envelopes', () {
    test('HakaComicsPayload omits nulls and sends the sort name', () {
      expect(
        const HakaComicsPayload(
          page: 1,
          c: 'cat',
          s: HakaComicSortType.ld,
        ).toJson(),
        {'page': 1, 'c': 'cat', 's': 'ld'},
      );
      expect(const HakaComicsPayload().toJson(), isEmpty);
      expect(
        const HakaComicsPayload(
          page: 2,
          a: '作者',
          ca: '上传者',
          ct: '汉化组',
          t: '标签',
        ).toJson(),
        {
          'page': 2,
          'a': '作者',
          'ca': '上传者',
          'ct': '汉化组',
          't': '标签',
        },
      );
    });

    test('HakaSearchPayload only adds categories when non-empty', () {
      expect(
        const HakaSearchPayload(
          keyword: '猫',
          page: 1,
          sort: HakaComicSortType.dd,
        ).toJson(),
        {'keyword': '猫', 'sort': 'dd'},
      );
      expect(
        const HakaSearchPayload(
          keyword: '猫',
          page: 2,
          sort: HakaComicSortType.vd,
          categories: {'c1', 'c2'},
        ).toJson(),
        {
          'keyword': '猫',
          'sort': 'vd',
          'categories': ['c1', 'c2'],
        },
      );
    });

    test('HakaUserFavoritePayload uses the s key', () {
      expect(
        const HakaUserFavoritePayload(
          page: 3,
          sort: HakaComicSortType.da,
        ).toJson(),
        {'page': 3, 's': 'da'},
      );
    });

    test('empty list envelopes are usable constants', () {
      expect(HakaComicsResponse.empty.comics.docs, isEmpty);
      expect(HakaComicsResponse.empty.comics.pages, 0);
      expect(HakaSearchResponse.empty.comics.docs, isEmpty);
      expect(HakaSearchResponse.empty.comics.total, 0);
      expect(HakaComicSortType.dd.title, '新到旧');
      expect(HakaComicSortType.vd.name, 'vd');
    });
  });

  // -------------------------------------------------------------------------
  // Client + repository over a fake adapter
  // -------------------------------------------------------------------------

  group('HakaClient', () {
    test('sends signed headers to the public base URL by default', () async {
      final adapter = _FakeAdapter((options) async => _body(_envelope({})));
      final client = _client(adapter);
      await client.get('categories');

      expect(adapter.requests.single.baseUrl, 'https://picaapi.picacomic.com/');
      final headers = adapter.requests.single.headers;
      expect(headers['api-key'], 'C69BAF41DA5ABD1FFEDC6D2FEA56B');
      expect(headers['nonce'], HakaConfig.nonce);
      expect(headers['app-channel'], '1');
      expect(headers['image-quality'], 'original');
      expect(headers['authorization'], '');
      expect(HakaClient.maxRetries, 3);
    });

    test('on-the-wire signature is the documented HMAC over the bare path',
        () async {
      final adapter = _FakeAdapter((options) async => _body(_envelope({})));
      final client = _client(adapter);
      await client.get('categories');

      final options = adapter.requests.single;
      final stamp = options.headers['time'] as String;
      final signed =
          'categories$stamp${HakaConfig.nonce}GET${HakaConfig.apiKey}'
              .toLowerCase();
      final expected = Hmac(
        sha256,
        utf8.encode(HakaConfig.secretKey),
      ).convert(utf8.encode(signed)).toString();
      expect(options.headers['signature'], expected);
    });

    test('GET signature includes the stringified query string', () async {
      final adapter = _FakeAdapter((options) async => _body(_envelope({})));
      final client = _client(adapter);
      await client.get('comics', query: {'page': 1});

      final options = adapter.requests.single;
      final stamp = options.headers['time'] as String;
      final signed =
          'comics?page=1$stamp${HakaConfig.nonce}GET${HakaConfig.apiKey}'
              .toLowerCase();
      final expected = Hmac(
        sha256,
        utf8.encode(HakaConfig.secretKey),
      ).convert(utf8.encode(signed)).toString();
      expect(options.headers['signature'], expected);
      expect(options.queryParameters, {'page': 1});
    });

    test('token and image quality reach the headers', () async {
      final adapter = _FakeAdapter((options) async => _body(_envelope({})));
      final client = _client(
        adapter,
        config: const HakaConfig(
          token: 'tok-1',
          imageQuality: HakaImageQuality.low,
          baseUrl: 'http://localhost:8080',
        ),
      );
      await client.get('categories');
      expect(adapter.requests.single.baseUrl, 'http://localhost:8080/');
      expect(adapter.requests.single.headers['authorization'], 'tok-1');
      expect(adapter.requests.single.headers['image-quality'], 'low');
    });

    test('400 surfaces the server message', () async {
      final adapter = _FakeAdapter(
        (options) async => _body(
          {'message': '用户名或密码错误'},
          statusCode: 400,
        ),
      );
      final client = _client(adapter);
      await expectLater(
        client.post('auth/sign-in', data: {'email': 'a', 'password': 'b'}),
        throwsA(
          isA<HakaApiException>()
              .having((e) => e.message, 'message', '用户名或密码错误')
              .having((e) => e.statusCode, 'statusCode', 400),
        ),
      );
      expect(adapter.requests.length, 1);
    });

    test('401 invalidates the token through onUnauthorized', () async {
      var unauthorized = 0;
      final adapter = _FakeAdapter(
        (options) async => _body({'message': 'unauthorized'}, statusCode: 401),
      );
      final client = _client(adapter)..onUnauthorized = () => unauthorized++;
      await expectLater(
        client.get('users/profile'),
        throwsA(
          isA<HakaApiException>()
              .having((e) => e.message, 'message', '登录失效')
              .having((e) => e.isUnauthorized, 'isUnauthorized', isTrue),
        ),
      );
      expect(unauthorized, 1);
    });

    test('5xx responses are retried up to maxRetries and can recover',
        () async {
      var attempts = 0;
      final adapter = _FakeAdapter((options) async {
        attempts++;
        if (attempts < 3) return _body({'message': 'boom'}, statusCode: 500);
        return _body(_envelope({'ok': true}));
      });
      final client = _client(adapter);
      final data = await client.get('comics');
      expect(attempts, 3);
      expect(data['code'], 200);
    });

    test('a persistent 500 gives up after three attempts', () async {
      final adapter = _FakeAdapter(
        (options) async => _body({'message': 'boom'}, statusCode: 500),
      );
      final client = _client(adapter);
      await expectLater(
        client.get('comics'),
        throwsA(isA<HakaApiException>()),
      );
      expect(adapter.requests.length, 3);
    });

    test('4xx other than 400/401 is not retried', () async {
      final adapter = _FakeAdapter(
        (options) async => _body({'message': 'nope'}, statusCode: 404),
      );
      final client = _client(adapter);
      await expectLater(
        client.get('comics/none'),
        throwsA(isA<HakaApiException>()),
      );
      expect(adapter.requests.length, 1);
    });

    test('a null body raises Empty data', () async {
      final adapter = _FakeAdapter((options) async => _body(null));
      final client = _client(adapter);
      await expectLater(
        client.get('comics'),
        throwsA(
          isA<HakaApiException>().having((e) => e.message, 'message',
              'Empty data'),
        ),
      );
    });
  });

  group('HakaRepository', () {
    test('fetchCategories drops web-only categories', () async {
      final adapter = _FakeAdapter(
        (options) async => _body(
          _envelope({
            'categories': [
              {'_id': 'c1', 'thumb': imageJson(), 'title': '可见'},
              {'_id': 'c2', 'thumb': imageJson(), 'title': '网页', 'isWeb': true},
            ],
          }),
        ),
      );
      final categories = await _repo(adapter).fetchCategories();
      expect(categories.map((c) => c.title), ['可见']);
      expect(adapter.requests.single.path, 'categories');
      expect(adapter.requests.single.method, 'GET');
    });

    test('fetchComics sends the short query keys', () async {
      final adapter = _FakeAdapter(
        (options) async => _body(
          _envelope({
            'comics': comicsBody([docJson('d1')], page: 2, pages: 5),
          }),
        ),
      );
      final comics = await _repo(adapter).fetchComics(
        const HakaComicsPayload(
          page: 2,
          c: 'cat',
          s: HakaComicSortType.dd,
          t: '标签',
        ),
      );
      expect(adapter.requests.single.queryParameters, {
        'page': 2,
        'c': 'cat',
        's': 'dd',
        't': '标签',
      });
      expect(comics.docs.single.title, '漫画');
      expect(comics.page, 2);
      expect(comics.pages, 5);
    });

    test('fetchChapters stops after page 1 when pages == 1', () async {
      final adapter = _FakeAdapter(
        (options) async => _body(
          _envelope({
            'eps': chaptersBody([chapterJson('ch1', 1)], pages: 1),
          }),
        ),
      );
      final chapters = await _repo(adapter).fetchChapters('abc');
      expect(chapters.single.uid, 'ch1');
      expect(adapter.requests.length, 1);
      expect(adapter.requests.single.path, 'comics/abc/eps');
      expect(adapter.requests.single.queryParameters, {'page': 1});
    });

    test('fetchChapters fans out over 2..pages and concatenates in order',
        () async {
      final adapter = _FakeAdapter((options) async {
        final page = _pageOf(options);
        return _body(
          _envelope({
            'eps': chaptersBody(
              [chapterJson('ch$page', page)],
              page: page,
              pages: 3,
            ),
          }),
        );
      });
      final chapters = await _repo(adapter).fetchChapters('abc');
      expect(chapters.map((c) => c.uid), ['ch1', 'ch2', 'ch3']);
      expect(adapter.requests.map(_pageOf).toSet(), {1, 2, 3});
      expect(adapter.requests.length, 3);
    });

    test('fetchChapterImages fans out under pages.docs', () async {
      final adapter = _FakeAdapter((options) async {
        final page = _pageOf(options);
        return _body(
          _envelope(
            chapterImagesBody(
              [chapterImageJson('p$page')],
              page: page,
              pages: 2,
            ),
          ),
        );
      });
      final images = await _repo(adapter).fetchChapterImages(
        const HakaFetchChapterImagesPayload(id: 'abc', order: 4),
      );
      expect(images.map((image) => image.uid), ['p1', 'p2']);
      expect(adapter.requests.length, 2);
      expect(
        adapter.requests.first.path,
        'comics/abc/order/4/pages',
      );
    });

    test('fetchComicDetails reads the comic envelope', () async {
      final adapter = _FakeAdapter(
        (options) async => _body(_envelope({'comic': comicDetailJson()})),
      );
      final comic = await _repo(adapter).fetchComicDetails('abc');
      expect(comic.title, '测试漫画');
      expect(adapter.requests.single.path, 'comics/abc');
    });

    test('searchComics posts the body with the page in the path', () async {
      final adapter = _FakeAdapter(
        (options) async => _body(
          _envelope({
            'comics': {
              'docs': [
                {
                  '_id': 's1',
                  'title': '命中',
                  'updated_at': '2024-01-01T00:00:00.000Z',
                  'created_at': '2023-01-01T00:00:00.000Z',
                  'thumb': imageJson(),
                  'finished': true,
                  'categories': <String>[],
                  'tags': <String>[],
                },
              ],
              'total': 1,
              'limit': 20,
              'page': 2,
              'pages': 3,
            },
          }),
        ),
      );
      final result = await _repo(adapter).searchComics(
        const HakaSearchPayload(
          keyword: '猫',
          page: 2,
          sort: HakaComicSortType.ld,
          categories: {'c1'},
        ),
      );
      final options = adapter.requests.single;
      expect(options.path, 'comics/advanced-search?page=2');
      expect(options.method, 'POST');
      expect(options.data, {
        'keyword': '猫',
        'sort': 'ld',
        'categories': ['c1'],
      });
      expect(result.page, 2);
      expect(result.docs.single.uid, 's1');
      expect(result.docs.single.author, '??');
    });

    test('fetchFavoriteComics sends page and s', () async {
      final adapter = _FakeAdapter(
        (options) async => _body(
          _envelope({'comics': comicsBody([docJson('d1')], pages: 2)}),
        ),
      );
      final comics = await _repo(adapter).fetchFavoriteComics(
        const HakaUserFavoritePayload(page: 1, sort: HakaComicSortType.da),
      );
      expect(adapter.requests.single.path, 'users/favourite');
      expect(adapter.requests.single.queryParameters, {'page': 1, 's': 'da'});
      expect(comics.docs.length, 1);
    });

    test('like and favourite post to the action endpoints', () async {
      final called = <String>[];
      final adapter = _FakeAdapter((options) async {
        called.add(options.path);
        return _body(_envelope({'action': 'favourite'}));
      });
      final repository = _repo(adapter);
      expect(await repository.likeComic('abc'), 'favourite');
      expect(await repository.favoriteComic('abc'), 'favourite');
      expect(called, ['comics/abc/like', 'comics/abc/favourite']);
      expect(adapter.requests.every((r) => r.method == 'POST'), isTrue);
      expect(HakaActionResponse.fromJson({'action': 'like'}).action, 'like');
    });

    test('fetchHotSearchWords memoizes under the keywords cache key', () async {
      final adapter = _FakeAdapter(
        (options) async => _body(
          _envelope({'keywords': ['猫', 42]}),
        ),
      );
      final cache = HakaCache();
      final repository = _repo(adapter, cache: cache);
      final first = await repository.fetchHotSearchWords();
      final second = await repository.fetchHotSearchWords();
      expect(first, ['猫', '42']);
      expect(second, first);
      expect(adapter.requests.length, 1);
      expect(HakaRepository.hotSearchKey, 'keywords');
      expect(cache.contains('keywords'), isTrue);
      expect(cache.get('keywords')?['code'], 200);
      cache.clear();
      expect(cache.contains('keywords'), isFalse);
    });

    test('network failures surface as HakaApiException', () async {
      final adapter = _FakeAdapter(
        (options) async => _body({'message': 'server down'}, statusCode: 500),
      );
      await expectLater(
        _repo(adapter).fetchCategories(),
        throwsA(isA<HakaApiException>()),
      );
      expect(adapter.requests.length, HakaClient.maxRetries);
    });
  });

  // -------------------------------------------------------------------------
  // Controllers
  // -------------------------------------------------------------------------

  group('HakaComicListController', () {
    test('loads the first page and pages forward until exhausted', () async {
      final adapter = _FakeAdapter((options) async {
        final page = _pageOf(options);
        return _body(
          _envelope({
            'comics': comicsBody([docJson('d$page')], page: page, pages: 2),
          }),
        );
      });
      final controller = HakaComicListController.category(
        repository: _repo(adapter),
        category: 'cat',
      );
      await controller.load();
      expect(controller.items.map((item) => item.uid), ['d1']);
      expect(controller.page, 1);
      expect(controller.pages, 2);
      expect(controller.hasMore, isTrue);
      expect(adapter.requests.single.queryParameters['c'], 'cat');

      await controller.loadMore();
      expect(controller.items.map((item) => item.uid), ['d1', 'd2']);
      expect(controller.hasMore, isFalse);

      await controller.loadMore();
      expect(adapter.requests.length, 2);
      controller.dispose();
    });

    test('refresh clears the accumulated pages', () async {
      var calls = 0;
      final adapter = _FakeAdapter((options) async {
        calls++;
        return _body(
          _envelope({
            'comics': comicsBody(
              [docJson('d$calls')],
              page: 1,
              pages: 3,
            ),
          }),
        );
      });
      final controller = HakaComicListController.favourites(
        repository: _repo(adapter),
      );
      await controller.load();
      await controller.loadMore();
      expect(controller.items.length, 2);
      await controller.refresh();
      expect(controller.items.map((item) => item.uid), ['d3']);
      expect(controller.page, 1);
      expect(controller.hasMore, isTrue);
      controller.dispose();
    });

    test('search mode posts the keyword body', () async {
      final adapter = _FakeAdapter(
        (options) async => _body(
          _envelope({
            'comics': {
              'docs': [
                {
                  '_id': 's1',
                  'title': '命中',
                  'updated_at': 'u',
                  'created_at': 'c',
                  'thumb': imageJson(),
                  'finished': false,
                  'categories': <String>[],
                  'tags': <String>[],
                },
              ],
              'total': 1,
              'limit': 20,
              'page': 1,
              'pages': 1,
            },
          }),
        ),
      );
      final controller = HakaComicListController.search(
        repository: _repo(adapter),
        keyword: '猫',
        categories: {'c1'},
      );
      await controller.load();
      expect(adapter.requests.single.path, 'comics/advanced-search?page=1');
      expect(adapter.requests.single.data, {
        'keyword': '猫',
        'sort': 'dd',
        'categories': ['c1'],
      });
      expect(controller.items.single.uid, 's1');
      expect(controller.hasMore, isFalse);
      controller.dispose();
    });

    test('a failed load leaves an error state and no items', () async {
      final adapter = _FakeAdapter(
        (options) async => _body({'message': 'boom'}, statusCode: 500),
      );
      final controller = HakaComicListController.category(
        repository: _repo(adapter),
        category: 'cat',
      );
      await controller.load();
      expect(controller.state.hasError, isTrue);
      expect(controller.items, isEmpty);
      controller.dispose();
    });
  });

  group('HakaComicDetailController', () {
    test('loads detail, chapters and history', () async {
      final prefs = await SharedPreferences.getInstance();
      final history = HakaHistoryStore(prefs);
      final adapter = _FakeAdapter((options) async {
        if (options.path == 'comics/abc/favourite') {
          return _body(_envelope({'action': 'favourite'}));
        }
        if (options.path == 'comics/abc/eps') {
          return _body(
            _envelope({
              'eps': chaptersBody([
                chapterJson('ch2', 2),
                chapterJson('ch1', 1),
              ]),
            }),
          );
        }
        return _body(_envelope({'comic': comicDetailJson()}));
      });
      final controller = HakaComicDetailController(
        repository: _repo(adapter),
        comicId: 'abc',
        readRecords: HakaReadRecordStore(prefs),
        history: history,
      );
      await controller.load();

      expect(controller.state.data?.title, '测试漫画');
      expect(controller.chapters.map((c) => c.uid), ['ch2', 'ch1']);
      expect(controller.orderedChapters.map((c) => c.order), [1, 2]);
      expect(controller.chaptersError, isNull);
      expect(controller.isFavourite, isFalse);
      expect(await history.getFirstId(), 'abc');
      expect((await history.getPage(0)).single.doc['title'], '测试漫画');

      expect(await controller.toggleFavourite(), 'favourite');
      expect(controller.isFavourite, isTrue);
      controller.dispose();
    });

    test('resumes the stored chapter and page', () async {
      final prefs = await SharedPreferences.getInstance();
      final records = HakaReadRecordStore(prefs);
      await records.save(
        const HakaReadRecord(
          comicId: 'abc',
          chapterId: 'ch2',
          chapterOrder: 2,
          chapterTitle: '第2话',
          pageNo: 3,
        ),
      );
      final adapter = _FakeAdapter((options) async {
        if (options.path == 'comics/abc/eps') {
          return _body(
            _envelope({
              'eps': chaptersBody([
                chapterJson('ch1', 1),
                chapterJson('ch2', 2),
              ]),
            }),
          );
        }
        return _body(_envelope({'comic': comicDetailJson()}));
      });
      final controller = HakaComicDetailController(
        repository: _repo(adapter),
        comicId: 'abc',
        readRecords: records,
      );
      await controller.load();
      expect(controller.record?.pageNo, 3);
      expect(controller.startChapter?.uid, 'ch2');
      expect(controller.startPage, 3);
      controller.dispose();
    });

    test('a chapter failure keeps the detail usable', () async {
      final prefs = await SharedPreferences.getInstance();
      final adapter = _FakeAdapter((options) async {
        if (options.path == 'comics/abc/eps') {
          return _body({'message': 'boom'}, statusCode: 500);
        }
        return _body(_envelope({'comic': comicDetailJson()}));
      });
      final controller = HakaComicDetailController(
        repository: _repo(adapter),
        comicId: 'abc',
        readRecords: HakaReadRecordStore(prefs),
      );
      await controller.load();
      expect(controller.state.hasData, isTrue);
      expect(controller.chapters, isEmpty);
      expect(controller.chaptersError, isA<HakaApiException>());
      controller.dispose();
    });
  });

  group('HakaReaderController', () {
    _FakeAdapter imageAdapter({int pages = 1, int perPage = 2}) {
      return _FakeAdapter((options) async {
        final page = _pageOf(options);
        return _body(
          _envelope(
            chapterImagesBody(
              [
                for (var i = 0; i < perPage; i++)
                  chapterImageJson('p${page}_$i'),
              ],
              page: page,
              pages: pages,
            ),
          ),
        );
      });
    }

    test('sorts chapters and loads the requested chapter', () async {
      final prefs = await SharedPreferences.getInstance();
      final adapter = imageAdapter();
      final controller = HakaReaderController(
        repository: _repo(adapter),
        comicId: 'abc',
        chapters: [
          HakaChapter.fromJson(chapterJson('ch3', 3)),
          HakaChapter.fromJson(chapterJson('ch1', 1)),
          HakaChapter.fromJson(chapterJson('ch2', 2)),
        ],
        readRecords: HakaReadRecordStore(prefs),
        initialOrder: 2,
      );
      await controller.load();
      expect(controller.chapters.map((c) => c.order), [1, 2, 3]);
      expect(controller.chapter?.uid, 'ch2');
      expect(controller.order, 2);
      expect(controller.totalPages, 2);
      expect(controller.displayPage, 1);
      expect(controller.progress, 0.5);
      expect(controller.hasPreviousChapter, isTrue);
      expect(controller.hasNextChapter, isTrue);
      expect(adapter.requests.single.path, 'comics/abc/order/2/pages');
      controller.dispose();
    });

    test('resumes the stored page and persists page turns', () async {
      final prefs = await SharedPreferences.getInstance();
      final records = HakaReadRecordStore(prefs);
      final controller = HakaReaderController(
        repository: _repo(imageAdapter(perPage: 4)),
        comicId: 'abc',
        chapters: [HakaChapter.fromJson(chapterJson('ch1', 1))],
        readRecords: records,
        initialOrder: 1,
      );
      await controller.load(resumePage: 2);
      expect(controller.displayPage, 2);
      expect(controller.currentIndex, 1);

      await controller.turnPage(1);
      expect(controller.displayPage, 3);
      final record = await records.get('abc');
      expect(record?.pageNo, 3);
      expect(record?.chapterOrder, 1);
      expect(record?.chapterId, 'ch1');
      expect(record?.finished, isFalse);

      // Reaching the last page of the only chapter finishes the record.
      await controller.turnPage(1);
      expect(controller.displayPage, 4);
      expect(controller.isFinishedChapter, isTrue);
      expect((await records.get('abc'))?.finished, isTrue);

      // Already at the last page: turning again is a no-op.
      await controller.turnPage(1);
      expect(controller.displayPage, 4);
      controller.dispose();
    });

    test('marks finished on the last page of the last chapter', () async {
      final prefs = await SharedPreferences.getInstance();
      final records = HakaReadRecordStore(prefs);
      final controller = HakaReaderController(
        repository: _repo(imageAdapter(perPage: 2)),
        comicId: 'abc',
        chapters: [HakaChapter.fromJson(chapterJson('ch1', 1))],
        readRecords: records,
        initialOrder: 1,
      );
      await controller.load();
      expect(controller.isFinishedChapter, isFalse);
      await controller.onPageChanged(1);
      expect(controller.isLastPage, isTrue);
      expect(controller.isFinishedChapter, isTrue);
      final record = await records.get('abc');
      expect(record?.finished, isTrue);
      expect(record?.pageNo, 2);
      controller.dispose();
    });

    test('nextChapter moves to the following order and resets the page',
        () async {
      final prefs = await SharedPreferences.getInstance();
      final records = HakaReadRecordStore(prefs);
      final adapter = imageAdapter();
      final controller = HakaReaderController(
        repository: _repo(adapter),
        comicId: 'abc',
        chapters: [
          HakaChapter.fromJson(chapterJson('ch1', 1)),
          HakaChapter.fromJson(chapterJson('ch2', 2)),
        ],
        readRecords: records,
        initialOrder: 1,
      );
      await controller.load();
      await controller.onPageChanged(1);
      await controller.nextChapter();
      expect(controller.order, 2);
      expect(controller.displayPage, 1);
      expect(controller.hasNextChapter, isFalse);
      expect(controller.hasPreviousChapter, isTrue);
      expect(adapter.requests.last.path, 'comics/abc/order/2/pages');
      expect((await records.get('abc'))?.chapterOrder, 2);

      await controller.previousChapter();
      expect(controller.order, 1);
      controller.dispose();
    });

    test('a failed image load surfaces an error state', () async {
      final prefs = await SharedPreferences.getInstance();
      final adapter = _FakeAdapter(
        (options) async => _body({'message': 'boom'}, statusCode: 500),
      );
      final controller = HakaReaderController(
        repository: _repo(adapter),
        comicId: 'abc',
        chapters: [HakaChapter.fromJson(chapterJson('ch1', 1))],
        readRecords: HakaReadRecordStore(prefs),
      );
      await controller.load();
      expect(controller.state.hasError, isTrue);
      expect(controller.images, isEmpty);
      expect(controller.totalPages, 0);
      expect(controller.progress, 0);
      controller.dispose();
    });
  });

  group('HakaSearchController', () {
    test('falls back to hot words while history is empty', () async {
      final prefs = await SharedPreferences.getInstance();
      final adapter = _FakeAdapter(
        (options) async => _body(_envelope({'keywords': ['猫', '狗']})),
      );
      final controller = HakaSearchController(
        repository: _repo(adapter),
        historyStore: HakaSearchHistoryStore(prefs),
      );
      controller.loadHistory();
      expect(controller.suggestions, isEmpty);
      await controller.loadHotWords();
      expect(controller.suggestions, ['猫', '狗']);
      expect(controller.hotWordsState, isA<HakaSuccess<List<String>>>());
      controller.dispose();
    });

    test('recorded terms win over hot words and de-duplicate', () async {
      final prefs = await SharedPreferences.getInstance();
      final store = HakaSearchHistoryStore(prefs);
      final controller = HakaSearchController(
        repository: _repo(
          _FakeAdapter((options) async => _body(_envelope({'keywords': []}))),
        ),
        historyStore: store,
      );
      await controller.record(' 猫 ');
      await controller.record('狗');
      await controller.record('猫');
      expect(controller.history, ['猫', '狗']);
      expect(controller.suggestions, ['猫', '狗']);
      expect(store.read(), ['猫', '狗']);

      await controller.removeHistory('猫');
      expect(controller.history, ['狗']);
      await controller.clearHistory();
      expect(controller.history, isEmpty);
      controller.dispose();
    });
  });

  // -------------------------------------------------------------------------
  // Local persistence (shared_preferences)
  // -------------------------------------------------------------------------

  group('HakaSearchHistoryStore', () {
    test('trims, de-duplicates and caps at 20 terms', () async {
      final prefs = await SharedPreferences.getInstance();
      final store = HakaSearchHistoryStore(prefs);
      expect(HakaSearchHistoryStore.maxEntries, 20);
      expect(await store.add('   '), isEmpty);

      for (var i = 0; i < 25; i++) {
        await store.add('term$i');
      }
      final kept = store.read();
      expect(kept.length, 20);
      expect(kept.first, 'term24');
      expect(kept.last, 'term5');
      expect(kept.contains('term4'), isFalse);

      await store.add('term10');
      expect(store.read().first, 'term10');
      expect(store.read().length, 20);
      await store.remove('term10');
      expect(store.read().contains('term10'), isFalse);
      await store.clear();
      expect(store.read(), isEmpty);
    });
  });

  group('HakaHistoryStore', () {
    test('deduplicates by comic id, most-recent-first', () async {
      final prefs = await SharedPreferences.getInstance();
      final store = HakaHistoryStore(prefs);
      expect(HakaHistoryStore.pageSize, 20);
      expect(await store.getFirstId(), isNull);

      await store.insert('a', docJson('a', title: 'A'));
      await store.insert('b', docJson('b', title: 'B'));
      await store.insert('a', docJson('a', title: 'A2'));
      expect(await store.count(), 2);
      expect(await store.getFirstId(), 'a');
      final page = await store.getPage(0);
      expect(page.map((entry) => entry.comicId), ['a', 'b']);
      expect(page.first.doc['title'], 'A2');

      await store.delete('a');
      expect(await store.count(), 1);
      await store.clear();
      expect(await store.count(), 0);
    });

    test('pages in windows of 20', () async {
      final prefs = await SharedPreferences.getInstance();
      final store = HakaHistoryStore(prefs);
      for (var i = 0; i < 25; i++) {
        await store.insert('c$i', docJson('c$i'));
      }
      expect((await store.getPage(0)).length, 20);
      expect((await store.getPage(1)).length, 5);
      expect(await store.getPage(2), isEmpty);
      expect(HakaHistoryEntry.fromJson({
        'comic_id': 'c1',
        'doc': {'_id': 'c1'},
        'created_at': 5,
      }).createdAt, 5);
    });
  });

  group('HakaFavoriteStore', () {
    test('seeds the default folder and protects it', () async {
      final prefs = await SharedPreferences.getInstance();
      final store = HakaFavoriteStore(prefs);
      expect(HakaFavoriteStore.defaultFolderName, 'default');
      expect((await store.folders()).single.name, 'default');
      expect(await store.deleteFolder('default'), isFalse);
      expect(await store.renameFolder('default', 'x'), isFalse);
      expect(await store.createFolder('收藏夹'), isTrue);
      expect(await store.createFolder('收藏夹'), isFalse);
      expect(await store.createFolder(''), isFalse);
      expect((await store.folders()).map((f) => f.name), [
        'default',
        '收藏夹',
      ]);
    });

    test('adds comics once, lists and removes them', () async {
      final prefs = await SharedPreferences.getInstance();
      final store = HakaFavoriteStore(prefs);
      expect(await store.addComic('default', docJson('a'), 'a'), isTrue);
      expect(await store.addComic('default', docJson('a'), 'a'), isFalse);
      expect(await store.addComic('missing', docJson('b'), 'b'), isFalse);
      expect(await store.contains('default', 'a'), isTrue);
      expect(await store.contains('default', 'b'), isFalse);
      expect((await store.comicsIn('default')).single['_id'], 'a');

      expect(await store.removeComic('default', 'a'), isTrue);
      expect(await store.removeComic('default', 'a'), isFalse);
      expect(await store.comicsIn('default'), isEmpty);

      expect(await store.renameFolder('default', 'x'), isFalse);
      await store.createFolder('f1');
      expect(await store.renameFolder('f1', 'f2'), isTrue);
      expect(await store.renameFolder('f2', 'default'), isFalse);
      expect(await store.deleteFolder('f2'), isTrue);
      await store.clear();
      expect((await store.folders()).single.name, 'default');
    });
  });

  group('HakaReadRecordStore', () {
    test('upserts one record per comic', () async {
      final prefs = await SharedPreferences.getInstance();
      final store = HakaReadRecordStore(prefs);
      expect(await store.get('abc'), isNull);

      await store.save(
        const HakaReadRecord(
          comicId: 'abc',
          chapterId: 'ch1',
          chapterOrder: 1,
          chapterTitle: '第1话',
          pageNo: 2,
        ),
      );
      expect((await store.get('abc'))?.pageNo, 2);
      expect((await store.get('abc'))?.chapterTitle, '第1话');

      await store.save(
        const HakaReadRecord(
          comicId: 'abc',
          chapterId: 'ch2',
          chapterOrder: 2,
          chapterTitle: '第2话',
          pageNo: 5,
        ),
      );
      expect((await store.get('abc'))?.pageNo, 5);
      expect((await store.get('abc'))?.chapterOrder, 2);

      await store.remove('abc');
      expect(await store.get('abc'), isNull);
      await store.clear();
    });

    test('savePage keeps the chapter and markFinished stamps the record',
        () async {
      final prefs = await SharedPreferences.getInstance();
      final store = HakaReadRecordStore(prefs);
      final created = await store.savePage('abc', 3);
      expect(created.pageNo, 3);
      expect(created.chapterId, '');
      expect(created.chapterOrder, 1);
      expect(created.finished, isFalse);

      await store.save(
        const HakaReadRecord(
          comicId: 'abc',
          chapterId: 'ch1',
          chapterOrder: 1,
          chapterTitle: '第1话',
          pageNo: 3,
        ),
      );
      await store.savePage('abc', 4);
      expect((await store.get('abc'))?.pageNo, 4);
      expect((await store.get('abc'))?.chapterId, 'ch1');

      await store.markFinished('abc');
      expect((await store.get('abc'))?.finished, isTrue);
      // Unknown comics cannot be marked.
      await store.markFinished('nope');
      expect(await store.get('nope'), isNull);
    });

    test('record JSON keeps the snake_case wire keys', () {
      final json = const HakaReadRecord(
        comicId: 'abc',
        chapterId: 'ch1',
        chapterOrder: 2,
        chapterTitle: '第2话',
        pageNo: 9,
        finished: true,
      ).toJson();
      expect(json, {
        'comic_id': 'abc',
        'chapter_id': 'ch1',
        'chapter_order': 2,
        'chapter_title': '第2话',
        'page_no': 9,
        'finished': true,
      });
      final restored = HakaReadRecord.fromJson(json);
      expect(restored.chapterOrder, 2);
      expect(restored.copyWith(pageNo: 10).pageNo, 10);
    });
  });

  // -------------------------------------------------------------------------
  // State rendering contract
  // -------------------------------------------------------------------------

  group('HakaStateView', () {
    testWidgets('renders data through the builder', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HakaStateView<String>(
              state: const HakaSuccess<String>('内容'),
              onRetry: () {},
              builder: (context, data) => Text(data),
            ),
          ),
        ),
      );
      expect(find.text('内容'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('shows a failure state with a working retry', (tester) async {
      var retries = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HakaStateView<String>(
              state: const HakaFailure<String>('网络错误'),
              onRetry: () => retries++,
              builder: (context, data) => Text(data),
            ),
          ),
        ),
      );
      expect(find.text('加载失败'), findsOneWidget);
      expect(find.text('网络错误'), findsOneWidget);
      await tester.tap(find.text('重试'));
      expect(retries, 1);
    });

    testWidgets('spins while the first load is in flight', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HakaStateView<String>(
              state: const HakaLoading<String>(),
              onRetry: () {},
              builder: (context, data) => Text(data),
            ),
          ),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // Feature entry metadata (snippet consumed by the host module page)
  // -------------------------------------------------------------------------

  group('HakaEntry', () {
    test('exposes the module metadata the host lists', () {
      expect(HakaEntry.title, 'Haka 漫画');
      expect(HakaEntry.subtitle, contains('picacomic'));
      expect(HakaEntry.icon, Icons.auto_stories_outlined);
      expect(HakaEntry.page(), isA<HakaEntryPage>());
    });

    test('entry page keeps the public base URL unless injected', () {
      const defaulted = HakaEntryPage();
      expect(defaulted.baseUrl, isNull);
      const injected = HakaEntryPage(baseUrl: 'http://127.0.0.1:1/', token: 't');
      expect(injected.baseUrl, 'http://127.0.0.1:1/');
      expect(injected.token, 't');
    });
  });
}
