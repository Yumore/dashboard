// Network-free tests for the 开眼 (Eyepetizer / Kaiyan) port.
//
// Everything here runs against hand-written fixtures shaped like the real
// `baobab.kaiyanapp.com/api/` payloads, plus a Dio whose interceptor resolves or
// rejects synchronously — no socket, no disk cache, no native plugin.
import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:dashboard/features/media/media_playback_page.dart';
import 'package:dashboard/features/media/media_stream_source.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_api.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_banner.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_category.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_category_detail_page.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_category_page.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_collapse.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_data.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_duration.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_endpoint.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_exception.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_home_feed.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_home_page.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_image.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_issue.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_issue_entity.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_item.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_playback.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_search_page.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_thumbnail.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_video_card.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_video_detail_page.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Fixtures — trimmed copies of real payload shapes.
// ---------------------------------------------------------------------------

/// `v2/feed?num=1`. Page 1 carries a `banner2` row, a video and a `textHeader`;
/// `nextPageUrl` is absolute, exactly as the server sends it.
const String _feedPage1Json = r'''
{
  "nextPageUrl": "http://baobab.kaiyanapp.com/api/v2/feed?date=1508412029000&num=1&udid=d2807c895f0348a180148c9dfa6f2feeac0781b5",
  "nextPublishTime": 1508498429000,
  "newestIssueType": "morning",
  "issueList": [
    {
      "total": 6,
      "count": 3,
      "date": 20171019,
      "publishTime": 1508412029000,
      "releaseTime": 1508412029000,
      "type": "morning",
      "itemList": [
        {
          "type": "banner2",
          "id": 1001,
          "adIndex": -1,
          "data": {
            "id": 1001,
            "title": "横幅 · 冰川之上",
            "description": "冰川退缩的十年",
            "category": "旅行",
            "playUrl": "http://baobab.kaiyanapp.com/video/glacier.mp4",
            "duration": 95000,
            "date": 20171019,
            "cover": {
              "feed": "http://img.kaiyanapp.com/glacier-feed.jpeg",
              "detail": "http://img.kaiyanapp.com/glacier-detail.jpeg",
              "blurred": "http://img.kaiyanapp.com/glacier-blurred.jpeg",
              "homepage": "http://img.kaiyanapp.com/glacier-home.jpeg"
            },
            "author": {
              "id": 7,
              "name": "开眼精选",
              "icon": "http://img.kaiyanapp.com/eyepetizer.jpeg",
              "description": "每日精选",
              "latestReleaseTime": 1508412029000,
              "videoNum": 233,
              "expert": true,
              "ifPgc": true
            },
            "consumption": {"collectionCount": 3, "shareCount": 9, "replyCount": 1}
          }
        },
        {
          "type": "video",
          "id": 1002,
          "adIndex": -1,
          "data": {
            "id": 1002,
            "title": "用 120 帧看一只蜂鸟振翅",
            "description": "蜂鸟每秒振翅 50 次，高速摄影让它们慢下来。",
            "category": "自然",
            "playUrl": "http://baobab.kaiyanapp.com/video/hummingbird.mp4",
            "duration": 155000,
            "date": 20171019,
            "releaseTime": 1508412029000,
            "library": "PARAMOUNT",
            "collected": false,
            "ifLimitVideo": true,
            "cover": {
              "feed": "http://img.kaiyanapp.com/hummingbird-feed.jpeg",
              "detail": "http://img.kaiyanapp.com/hummingbird-detail.jpeg",
              "blurred": "http://img.kaiyanapp.com/hummingbird-blurred.jpeg",
              "homepage": "http://img.kaiyanapp.com/hummingbird-home.jpeg"
            },
            "author": {
              "id": 12,
              "name": "Deep Look",
              "icon": "http://img.kaiyanapp.com/deeplook.jpeg",
              "description": "PBS 自然短片",
              "latestReleaseTime": 1508412029000,
              "videoNum": 88,
              "expert": true,
              "ifPgc": true
            },
            "consumption": {"collectionCount": 12, "shareCount": 34, "replyCount": 5},
            "playInfo": [
              {
                "name": "标清",
                "type": "video/mp4",
                "url": "http://baobab.kaiyanapp.com/video/hummingbird-480.mp4",
                "width": 854,
                "height": 480,
                "urlList": [
                  {"name": "480p", "size": 480, "url": "http://baobab.kaiyanapp.com/video/hummingbird-480.mp4"},
                  {"name": "720p", "size": 720, "url": "http://baobab.kaiyanapp.com/video/hummingbird-720.mp4"}
                ]
              }
            ],
            "webUrl": {
              "raw": "http://www.kaiyanapp.com/detail.html?vid=1002",
              "forWeibo": "http://www.kaiyanapp.com/detail.html?vid=1002&weibo=1"
            },
            "tags": [{"id": 31, "name": "自然", "tagRecType": "1", "bgPicture": "http://img.kaiyanapp.com/tag-nature.jpeg"}]
          }
        },
        {
          "type": "textHeader",
          "id": 1003,
          "adIndex": -1,
          "data": {"id": 1003, "text": "今日精选", "type": "textHeader", "dataType": "TextHeader"}
        }
      ]
    }
  ]
}
''';

/// The `nextPageUrl` above, served verbatim as page 2 (no more pages).
const String _feedPage2Json = r'''
{
  "nextPageUrl": null,
  "nextPublishTime": 1508584829000,
  "newestIssueType": "evening",
  "issueList": [
    {
      "total": 3,
      "count": 1,
      "date": 20171019,
      "type": "evening",
      "itemList": [
        {
          "type": "video",
          "id": 1009,
          "adIndex": -1,
          "data": {
            "id": 1009,
            "title": "深夜书店里的猫",
            "description": "凌晨两点，猫在看店。",
            "category": "生活",
            "playUrl": "http://baobab.kaiyanapp.com/video/bookstore-cat.mp4",
            "duration": 62000,
            "date": 20171020,
            "cover": {"feed": "http://img.kaiyanapp.com/cat-feed.jpeg", "detail": "http://img.kaiyanapp.com/cat-detail.jpeg"},
            "author": {"id": 44, "name": "一条", "icon": "http://img.kaiyanapp.com/yitiao.jpeg"},
            "consumption": {"collectionCount": 1, "shareCount": 2, "replyCount": 3}
          }
        }
      ]
    }
  ]
}
''';

/// `v4/video/related?id=1002` — a header row plus one playable card.
const String _relatedJson = r'''
{
  "total": 2,
  "count": 2,
  "nextPageUrl": null,
  "itemList": [
    {"type": "textHeader", "id": 2001, "adIndex": -1, "data": {"id": 2001, "text": "相关推荐", "type": "textHeader"}},
    {
      "type": "videoSmallCard",
      "id": 2002,
      "adIndex": -1,
      "data": {
        "id": 2002,
        "title": "蜂鸟之外，还有蜂鸟鹰蛾",
        "category": "自然",
        "playUrl": "http://baobab.kaiyanapp.com/video/hawkmoth.mp4",
        "duration": 128000,
        "cover": {"feed": "http://img.kaiyanapp.com/moth-feed.jpeg", "detail": "http://img.kaiyanapp.com/moth-detail.jpeg"},
        "author": {"id": 12, "name": "Deep Look", "icon": "http://img.kaiyanapp.com/deeplook.jpeg"},
        "consumption": {"collectionCount": 0, "shareCount": 0, "replyCount": 0}
      }
    }
  ]
}
''';

/// `v4/categories` — a bare JSON array; the second row has a null `alias`.
const String _categoriesJson = r'''
[
  {
    "id": 14,
    "name": "广告",
    "alias": "广告",
    "description": "创意广告",
    "bgPicture": "http://img.kaiyanapp.com/cat-ad.jpeg",
    "bgColor": "#000000",
    "headerImage": "http://img.kaiyanapp.com/cat-ad-header.jpeg",
    "defaultAuthorId": 0,
    "tagId": 0
  },
  {
    "id": 2,
    "name": "创意",
    "alias": null,
    "description": "脑洞大开",
    "bgPicture": "http://img.kaiyanapp.com/cat-creative.jpeg",
    "bgColor": "#111111",
    "headerImage": "http://img.kaiyanapp.com/cat-creative-header.jpeg",
    "defaultAuthorId": 5,
    "tagId": 9
  }
]
''';

/// `v4/categories/videoList?id=14&udid=..&deviceModel=Android`.
const String _categoryVideosJson = r'''
{
  "total": 1,
  "count": 1,
  "nextPageUrl": null,
  "itemList": [
    {
      "type": "video",
      "id": 3001,
      "adIndex": -1,
      "data": {
        "id": 3001,
        "title": "把 40 秒广告拍成一部短片",
        "category": "广告",
        "playUrl": "http://baobab.kaiyanapp.com/video/ad.mp4",
        "duration": 40000,
        "cover": {"feed": "http://img.kaiyanapp.com/ad-feed.jpeg", "detail": "http://img.kaiyanapp.com/ad-detail.jpeg"},
        "author": {"id": 61, "name": "Nowness", "icon": "http://img.kaiyanapp.com/nowness.jpeg"}
      }
    }
  ]
}
''';

/// `v1/search?query=蜂鸟` — three hits, the middle one without a cover (the
/// source dropped exactly these).
const String _searchJson = r'''
{
  "total": 3,
  "count": 3,
  "nextPageUrl": "http://baobab.kaiyanapp.com/api/v1/search?query=%E8%9C%82%E9%B8%9F&start=10",
  "itemList": [
    {
      "type": "videoSmallCard",
      "id": 4001,
      "adIndex": -1,
      "data": {
        "id": 4001,
        "title": "蜂鸟的悬停",
        "category": "自然",
        "duration": 61000,
        "playUrl": "http://baobab.kaiyanapp.com/video/hover.mp4",
        "cover": {"feed": "http://img.kaiyanapp.com/hover-feed.jpeg", "detail": "http://img.kaiyanapp.com/hover-detail.jpeg"},
        "author": {"id": 12, "name": "Deep Look", "icon": "http://img.kaiyanapp.com/deeplook.jpeg"}
      }
    },
    {
      "type": "videoSmallCard",
      "id": 4002,
      "adIndex": -1,
      "data": {"id": 4002, "title": "无封面的条目", "category": "自然", "duration": 1000, "cover": null}
    },
    {
      "type": "videoSmallCard",
      "id": 4003,
      "adIndex": -1,
      "data": {
        "id": 4003,
        "title": "蜂鸟与花",
        "category": "自然",
        "duration": 72000,
        "playUrl": "http://baobab.kaiyanapp.com/video/flower.mp4",
        "cover": {"feed": "http://img.kaiyanapp.com/flower-feed.jpeg", "detail": "http://img.kaiyanapp.com/flower-detail.jpeg"},
        "author": {"id": 12, "name": "Deep Look", "icon": "http://img.kaiyanapp.com/deeplook.jpeg"}
      }
    }
  ]
}
''';

/// The search's own page 2.
const String _searchPage2Json = r'''
{
  "total": 3,
  "count": 1,
  "nextPageUrl": null,
  "itemList": [
    {
      "type": "videoSmallCard",
      "id": 4004,
      "adIndex": -1,
      "data": {
        "id": 4004,
        "title": "蜂鸟的迁徙路线",
        "category": "自然",
        "duration": 90000,
        "playUrl": "http://baobab.kaiyanapp.com/video/migration.mp4",
        "cover": {"feed": "http://img.kaiyanapp.com/migration-feed.jpeg", "detail": "http://img.kaiyanapp.com/migration-detail.jpeg"},
        "author": {"id": 12, "name": "Deep Look", "icon": "http://img.kaiyanapp.com/deeplook.jpeg"}
      }
    }
  ]
}
''';

/// `v3/queries/hot` — a bare array of strings.
const String _hotKeywordsJson = r'["蜂鸟","开眼","旅行","纪录片","美食"]';

Map<String, dynamic> _map(String source) =>
    jsonDecode(source) as Map<String, dynamic>;

Object? _json(String source) => jsonDecode(source);

// ---------------------------------------------------------------------------
// Fake transport.
// ---------------------------------------------------------------------------

Response<dynamic> _response(
  int statusCode,
  Object? data,
  RequestOptions options,
) => Response<dynamic>(
  requestOptions: options,
  statusCode: statusCode,
  data: data,
);

Response<dynamic> _ok(Object? data, RequestOptions options) =>
    _response(200, data, options);

Dio _fakeDio(Response<dynamic> Function(RequestOptions options) respond) {
  final dio = Dio(BaseOptions(baseUrl: EyepetizerEndpoint.baseUrl));
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) => handler.resolve(respond(options)),
    ),
  );
  return dio;
}

Dio _statusDio(int statusCode, Object? data) =>
    _fakeDio((options) => _response(statusCode, data, options));

Dio _rejectingDio(DioException Function(RequestOptions options) build) {
  final dio = Dio(BaseOptions(baseUrl: EyepetizerEndpoint.baseUrl));
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) => handler.reject(build(options)),
    ),
  );
  return dio;
}

/// Routes by path so a single fake can serve a whole screen flow.
Dio _routedDio(Object? Function(RequestOptions options) route) =>
    _fakeDio((options) => _ok(route(options), options));

void main() {
  setUp(() {
    // Widget tests never touch the network or the image cache.
    EyepetizerThumbnail.builderOverride = (context, url) =>
        const SizedBox.shrink();
  });

  tearDown(() => EyepetizerThumbnail.builderOverride = null);

  group('EyepetizerEndpoint', () {
    test('keeps the verified Kaiyan base URL and source headers', () {
      expect(EyepetizerEndpoint.baseUrl, 'http://baobab.kaiyanapp.com/api/');
      expect(
        EyepetizerEndpoint.httpHeaders['Content-Type'],
        'application/json',
      );
      expect(
        EyepetizerEndpoint.httpHeaders['Accept-Language'],
        'zh-CN,zh;q=0.9',
      );
      // The source's iPhone User-Agent, verbatim from http_constant.dart.
      expect(
        EyepetizerEndpoint.httpHeaders['User-Agent'],
        contains('iPhone; CPU iPhone OS 11_0 like Mac OS X'),
      );
    });

    test('appends the hard-coded udid/deviceModel to a category next page', () {
      expect(
        EyepetizerEndpoint.categoryNextPage('http://b/api/v4/categories/videoList?id=14'),
        'http://b/api/v4/categories/videoList?id=14'
        '&udid=d2807c895f0348a180148c9dfa6f2feeac0781b5&deviceModel=Android',
      );
    });
  });

  group('EyepetizerApi · request building', () {
    test('feed() GETs v2/feed?num=1', () async {
      RequestOptions? seen;
      final api = EyepetizerApi(
        dio: _routedDio((options) {
          seen = options;
          return _map(_feedPage1Json);
        }),
      );
      await api.feed();
      expect(seen!.method, 'GET');
      expect(seen!.uri.path, '/api/v2/feed');
      expect(seen!.uri.queryParameters, <String, String>{'num': '1'});
      expect(
        seen!.uri.toString(),
        'http://baobab.kaiyanapp.com/api/v2/feed?num=1',
      );
    });

    test('feedPage() reuses the absolute nextPageUrl untouched', () async {
      RequestOptions? seen;
      final api = EyepetizerApi(
        dio: _routedDio((options) {
          seen = options;
          return _map(_feedPage2Json);
        }),
      );
      await api.feedPage(
        'http://baobab.kaiyanapp.com/api/v2/feed'
        '?date=1508412029000&num=1&udid=d2807c895f0348a180148c9dfa6f2feeac0781b5',
      );
      expect(seen!.uri.path, '/api/v2/feed');
      expect(seen!.uri.queryParameters['date'], '1508412029000');
      expect(
        seen!.uri.queryParameters['udid'],
        'd2807c895f0348a180148c9dfa6f2feeac0781b5',
      );
    });

    test('search() GETs v1/search?query= with the query encoded', () async {
      RequestOptions? seen;
      final api = EyepetizerApi(
        dio: _routedDio((options) {
          seen = options;
          return _map(_searchJson);
        }),
      );
      await api.search('  蜂鸟  ');
      expect(seen!.uri.path, '/api/v1/search');
      expect(seen!.uri.queryParameters['query'], '蜂鸟');
      expect(seen!.uri.query, 'query=%E8%9C%82%E9%B8%9F');
    });

    test('search() rejects a blank query', () {
      final api = EyepetizerApi(
        dio: _routedDio((options) => _map(_searchJson)),
      );
      expect(() => api.search('   '), throwsArgumentError);
    });

    test('hotKeywords() GETs v3/queries/hot', () async {
      RequestOptions? seen;
      final api = EyepetizerApi(
        dio: _routedDio((options) {
          seen = options;
          return _json(_hotKeywordsJson);
        }),
      );
      await api.hotKeywords();
      expect(seen!.uri.path, '/api/v3/queries/hot');
    });

    test('categories() GETs v4/categories', () async {
      RequestOptions? seen;
      final api = EyepetizerApi(
        dio: _routedDio((options) {
          seen = options;
          return _json(_categoriesJson);
        }),
      );
      await api.categories();
      expect(seen!.uri.path, '/api/v4/categories');
    });

    test('categoryVideos() sends id, udid and deviceModel', () async {
      RequestOptions? seen;
      final api = EyepetizerApi(
        dio: _routedDio((options) {
          seen = options;
          return _map(_categoryVideosJson);
        }),
      );
      await api.categoryVideos(14);
      expect(seen!.uri.path, '/api/v4/categories/videoList');
      expect(seen!.uri.queryParameters, <String, String>{
        'id': '14',
        'udid': 'd2807c895f0348a180148c9dfa6f2feeac0781b5',
        'deviceModel': 'Android',
      });
    });

    test('categoryVideosPage() keeps the udid/deviceModel suffix', () async {
      RequestOptions? seen;
      final api = EyepetizerApi(
        dio: _routedDio((options) {
          seen = options;
          return _map(_categoryVideosJson);
        }),
      );
      await api.categoryVideosPage(
        'http://baobab.kaiyanapp.com/api/v4/categories/videoList?id=14&start=10',
      );
      expect(seen!.uri.queryParameters['id'], '14');
      expect(seen!.uri.queryParameters['start'], '10');
      expect(seen!.uri.queryParameters['deviceModel'], 'Android');
    });

    test('related() GETs v4/video/related?id=', () async {
      RequestOptions? seen;
      final api = EyepetizerApi(
        dio: _routedDio((options) {
          seen = options;
          return _map(_relatedJson);
        }),
      );
      await api.related(1002);
      expect(seen!.uri.path, '/api/v4/video/related');
      expect(seen!.uri.queryParameters['id'], '1002');
    });

    test('rankList() GETs v4/rankList', () async {
      RequestOptions? seen;
      final api = EyepetizerApi(
        dio: _routedDio((options) {
          seen = options;
          return _map(_relatedJson);
        }),
      );
      await api.rankList();
      expect(seen!.uri.path, '/api/v4/rankList');
    });
  });

  group('EyepetizerApi · errors', () {
    test('a 500 response becomes an EyepetizerException with the status', () async {
      final api = EyepetizerApi(dio: _statusDio(500, <String, dynamic>{}));
      await expectLater(
        api.feed(),
        throwsA(
          isA<EyepetizerException>()
              .having((e) => e.message, 'message', '请求失败：HTTP 500')
              .having((e) => e.statusCode, 'statusCode', 500),
        ),
      );
    });

    test('a transport failure becomes a retryable message', () async {
      final api = EyepetizerApi(
        dio: _rejectingDio(
          (options) => DioException(
            requestOptions: options,
            type: DioExceptionType.connectionError,
            error: 'SocketException: Connection refused',
          ),
        ),
      );
      await expectLater(
        api.categories(),
        throwsA(
          isA<EyepetizerException>().having(
            (e) => e.message,
            'message',
            '网络连接失败，请检查网络',
          ),
        ),
      );
    });

    test('a timeout becomes its own message', () async {
      final api = EyepetizerApi(
        dio: _rejectingDio(
          (options) => DioException(
            requestOptions: options,
            type: DioExceptionType.receiveTimeout,
          ),
        ),
      );
      await expectLater(
        api.related(1),
        throwsA(
          isA<EyepetizerException>().having((e) => e.message, 'message', '请求超时，请重试'),
        ),
      );
    });

    test('a rejected 503 keeps the upstream status', () async {
      final api = EyepetizerApi(
        dio: _rejectingDio(
          (options) => DioException(
            requestOptions: options,
            type: DioExceptionType.badResponse,
            response: Response<dynamic>(
              requestOptions: options,
              statusCode: 503,
            ),
          ),
        ),
      );
      await expectLater(
        api.feed(),
        throwsA(
          isA<EyepetizerException>()
              .having((e) => e.message, 'message', '请求失败：HTTP 503')
              .having((e) => e.statusCode, 'statusCode', 503),
        ),
      );
    });

    test('a non-JSON root is reported as unparseable', () async {
      final api = EyepetizerApi(
        dio: _statusDio(200, <Object?>[1, 2, 3]),
      );
      await expectLater(
        api.feed(),
        throwsA(
          isA<EyepetizerException>().having(
            (e) => e.message,
            'message',
            '开眼返回的数据格式无法解析',
          ),
        ),
      );
    });
  });

  group('EyepetizerApi · JSON to model', () {
    EyepetizerApi apiReturning(Object? data) =>
        EyepetizerApi(dio: _statusDio(200, data));

    test('feed maps the envelope and flattens issueList[0]', () async {
      final entity = await apiReturning(_map(_feedPage1Json)).feed();
      expect(entity, isA<EyepetizerIssueEntity>());
      expect(entity.nextPublishTime, 1508498429000);
      expect(entity.newestIssueType, 'morning');
      expect(entity.issueList, hasLength(1));
      expect(entity.issueList.single.type, 'morning');
      expect(entity.issueList.single.date, 20171019);
      expect(
        entity.nextPageUrl,
        'http://baobab.kaiyanapp.com/api/v2/feed'
        '?date=1508412029000&num=1&udid=d2807c895f0348a180148c9dfa6f2feeac0781b5',
      );
      // IssueEntity.itemList is the first issue's rows.
      expect(entity.itemList, hasLength(3));
      expect(entity.itemList.first.type, 'banner2');
      expect(entity.itemList.last.type, 'textHeader');
    });

    test('feed maps a video row field for field', () async {
      final entity = await apiReturning(_map(_feedPage1Json)).feed();
      final data = entity.itemList[1].data!;
      expect(entity.itemList[1].id, 1002);
      expect(data.id, 1002);
      expect(data.title, '用 120 帧看一只蜂鸟振翅');
      expect(data.description, '蜂鸟每秒振翅 50 次，高速摄影让它们慢下来。');
      expect(data.category, '自然');
      expect(data.playUrl, 'http://baobab.kaiyanapp.com/video/hummingbird.mp4');
      expect(data.duration, 155000);
      expect(data.date, 20171019);
      expect(data.library, 'PARAMOUNT');
      expect(data.collected, isFalse);
      expect(data.ifLimitVideo, isTrue);
      expect(data.cover!.feed, 'http://img.kaiyanapp.com/hummingbird-feed.jpeg');
      expect(data.cover!.blurred, 'http://img.kaiyanapp.com/hummingbird-blurred.jpeg');
      expect(data.author!.name, 'Deep Look');
      expect(data.author!.icon, 'http://img.kaiyanapp.com/deeplook.jpeg');
      expect(data.author!.videoNum, 88);
      expect(data.author!.latestReleaseTime, 1508412029000);
      expect(data.consumption!.shareCount, 34);
      expect(data.consumption!.replyCount, 5);
      expect(data.consumption!.collectionCount, 12);
      expect(data.playInfo, hasLength(1));
      expect(data.playInfo.single.name, '标清');
      expect(data.playInfo.single.width, 854);
      expect(data.playInfo.single.urlList, hasLength(2));
      expect(data.playInfo.single.urlList.last.size, 720);
      expect(
        data.webUrl!.raw,
        'http://www.kaiyanapp.com/detail.html?vid=1002',
      );
      expect(data.tags.single.name, '自然');
      // Derived fields the list rows print.
      expect(data.authorLine, 'Deep Look');
      expect(data.authorIcon, 'http://img.kaiyanapp.com/deeplook.jpeg');
      expect(data.dateLabel, '2017/10/19');
    });

    test('a textHeader row carries its section text and no cover', () async {
      final entity = await apiReturning(_map(_feedPage1Json)).feed();
      final header = entity.itemList.last;
      expect(header.isTextHeader, isTrue);
      expect(header.isPlaceholder, isFalse);
      expect(header.headerText, '今日精选');
      expect(header.data!.cover, isNull);
      // The author line falls back to description / provider icon.
      expect(header.data!.authorLine, '');
    });

    test('a row without a cover is still an item, with a null cover', () async {
      final issue = await apiReturning(_map(_searchJson)).search('蜂鸟');
      expect(issue.total, 3);
      expect(issue.itemList, hasLength(3));
      expect(issue.itemList[1].data!.cover, isNull);
      expect(issue.itemList[1].data!.title, '无封面的条目');
      expect(
        issue.nextPageUrl,
        'http://baobab.kaiyanapp.com/api/v1/search?query=%E8%9C%82%E9%B8%9F&start=10',
      );
    });

    test('related maps the header + card rows', () async {
      final issue = await apiReturning(_map(_relatedJson)).related(1002);
      expect(issue, isA<EyepetizerIssue>());
      expect(issue.total, 2);
      expect(issue.itemList.first.isTextHeader, isTrue);
      final card = issue.itemList.last;
      expect(card.type, EyepetizerItem.videoSmallCardType);
      expect(card.data!.id, 2002);
      expect(card.data!.title, '蜂鸟之外，还有蜂鸟鹰蛾');
      expect(card.data!.duration, 128000);
      expect(card.data!.cover!.detail, 'http://img.kaiyanapp.com/moth-detail.jpeg');
    });

    test('categories maps a bare JSON array, null alias to empty', () async {
      final categories = await apiReturning(_json(_categoriesJson)).categories();
      expect(categories, hasLength(2));
      expect(categories.first, isA<EyepetizerCategory>());
      expect(categories.first.id, 14);
      expect(categories.first.name, '广告');
      expect(categories.first.alias, '广告');
      expect(categories.first.bgPicture, 'http://img.kaiyanapp.com/cat-ad.jpeg');
      expect(categories.first.headerImage, 'http://img.kaiyanapp.com/cat-ad-header.jpeg');
      expect(categories.last.alias, '');
      expect(categories.last.defaultAuthorId, 5);
      expect(categories.last.tagId, 9);
    });

    test('hotKeywords maps the string array', () async {
      final keywords = await apiReturning(_json(_hotKeywordsJson)).hotKeywords();
      expect(keywords, <String>['蜂鸟', '开眼', '旅行', '纪录片', '美食']);
    });

    test('hotKeywords tolerates a non-list payload', () async {
      final keywords = await apiReturning(
        <String, dynamic>{'unexpected': true},
      ).hotKeywords();
      expect(keywords, isEmpty);
    });

    test('a category list that is not an array is reported', () async {
      final api = apiReturning(<String, dynamic>{'itemList': <Object?>[]});
      await expectLater(
        api.categories(),
        throwsA(
          isA<EyepetizerException>().having(
            (e) => e.message,
            'message',
            '分类数据格式无法解析',
          ),
        ),
      );
    });

    test('a sparse payload degrades to zero values instead of throwing', () {
      final item = EyepetizerItem.fromJson(<String, dynamic>{
        'type': 'video',
        'id': 5,
        'data': <String, dynamic>{'id': 5, 'duration': '1200'},
      });
      final data = item.data!;
      expect(data.title, '');
      expect(data.duration, 1200);
      expect(data.cover, isNull);
      expect(data.author, isNull);
      expect(data.consumption, isNull);
      expect(data.playInfo, isEmpty);
      expect(data.authorLine, '');
      expect(data.authorIcon, '');
      expect(data.dateLabel, '');
      expect(EyepetizerData.fromJson(null).id, 0);
    });
  });

  group('EyepetizerDuration', () {
    test('formats milliseconds the way the source badge did', () {
      expect(EyepetizerDuration.mmss(155000), '02:35');
      expect(EyepetizerDuration.mmss(95000), '01:35');
      expect(EyepetizerDuration.mmss(1000), '00:01');
      expect(EyepetizerDuration.mmss(0), '00:00');
      expect(EyepetizerDuration.mmss(-5), '00:00');
      // Hours fold into minutes, exactly like DateUtil.formatDateMsByMS.
      expect(EyepetizerDuration.mmss(3723000), '62:03');
    });

    test('formats the detail publish stamp as yyyy/MM/dd HH:mm', () {
      final stamp = DateTime(2017, 10, 19, 15, 20);
      expect(
        EyepetizerDuration.ymdHm(stamp.millisecondsSinceEpoch),
        '2017/10/19 15:20',
      );
      expect(EyepetizerDuration.ymdHm(0), '');
    });
  });

  group('EyepetizerImage', () {
    test('accepts http(s) and upgrades scheme-relative URLs', () {
      expect(
        EyepetizerImage.resolve('http://img.kaiyanapp.com/a.jpeg'),
        'http://img.kaiyanapp.com/a.jpeg',
      );
      expect(
        EyepetizerImage.resolve('//img.kaiyanapp.com/a.jpeg'),
        'https://img.kaiyanapp.com/a.jpeg',
      );
    });

    test('rejects blanks and the source asset placeholder', () {
      expect(EyepetizerImage.resolve(''), isNull);
      expect(EyepetizerImage.resolve(null), isNull);
      expect(EyepetizerImage.resolve('images/ic_default_img.png'), isNull);
      expect(EyepetizerImage.needsPlaceholder('data:image/png;base64,AAAA'), isTrue);
      expect(
        EyepetizerImage.needsPlaceholder('http://img.kaiyanapp.com/a.jpeg'),
        isFalse,
      );
    });
  });

  group('EyepetizerPlayback', () {
    test('exposes playUrl first, then each playInfo quality, de-duplicated', () {
      final data = EyepetizerIssueEntity.fromJson(
        _map(_feedPage1Json),
      ).itemList[1].data!;
      final playback = EyepetizerPlayback.from(data);
      expect(playback.hasStream, isTrue);
      expect(
        playback.sources.map((source) => source.label),
        <String>['默认', '标清 · 480p', '标清 · 720p'],
      );
      expect(
        playback.sources.first.url,
        Uri.parse('http://baobab.kaiyanapp.com/video/hummingbird.mp4'),
      );
      expect(
        playback.sources[1].url,
        Uri.parse('http://baobab.kaiyanapp.com/video/hummingbird-480.mp4'),
      );
      // The duplicated 480 URL from playInfo[].url was dropped, not re-added.
      expect(playback.sources, hasLength(3));
      expect(
        playback.externalUrl,
        Uri.parse('http://www.kaiyanapp.com/detail.html?vid=1002'),
      );
    });

    test('falls back to the share URL when there is no stream', () {
      final data = EyepetizerData.fromJson(<String, dynamic>{
        'id': 8,
        'title': '没有流地址',
        'webUrl': <String, dynamic>{'raw': '//www.kaiyanapp.com/detail.html?vid=8'},
      });
      final playback = EyepetizerPlayback.from(data);
      expect(playback.hasStream, isFalse);
      expect(playback.sources, isEmpty);
      expect(
        playback.externalUrl,
        Uri.parse('https://www.kaiyanapp.com/detail.html?vid=8'),
      );
    });

    test('reports nothing playable when both stream and share URL are absent', () {
      final playback = EyepetizerPlayback.from(
        EyepetizerData.fromJson(<String, dynamic>{'id': 9}),
      );
      expect(playback.hasStream, isFalse);
      expect(playback.externalUrl, isNull);
    });
  });

  group('EyepetizerHomeFeed', () {
    test('first page becomes the carousel and seeds a placeholder row', () async {
      final entity = EyepetizerIssueEntity.fromJson(_map(_feedPage1Json));
      final feed = EyepetizerHomeFeed.firstPage(entity);
      // Faithful to the source: `doRefreshDataProcess` calls
      // `doLoadMoreDataProcess` FIRST (which strips every `banner2` row) and
      // only then does `bannerList = list`, so the carousel shows issue 1's
      // ordinary rows and the server's own banner2 row is dropped entirely.
      expect(
        feed.banner.map((item) => item.type),
        <String>['video', 'textHeader'],
      );
      expect(feed.banner.first.data!.title, '用 120 帧看一只蜂鸟振翅');
      expect(feed.banner.any((item) => item.isBanner), isFalse);
      expect(feed.items, hasLength(1));
      expect(feed.items.single.isPlaceholder, isTrue);
      expect(
        feed.nextPageUrl,
        'http://baobab.kaiyanapp.com/api/v2/feed'
        '?date=1508412029000&num=1&udid=d2807c895f0348a180148c9dfa6f2feeac0781b5',
      );
    });

    test('the second page appends its rows and keeps the carousel', () async {
      final feed = EyepetizerHomeFeed.firstPage(
        EyepetizerIssueEntity.fromJson(_map(_feedPage1Json)),
      ).appendPage(EyepetizerIssueEntity.fromJson(_map(_feedPage2Json)));
      expect(feed.items, hasLength(2));
      expect(feed.items.first.isPlaceholder, isTrue);
      expect(feed.items.last.data!.title, '深夜书店里的猫');
      expect(feed.items.last.data!.duration, 62000);
      expect(feed.banner, hasLength(2));
      expect(feed.nextPageUrl, isNull);
    });

    test('visibleItems drops exactly the banner2 rows', () {
      final rows = <EyepetizerItem>[
        const EyepetizerItem(type: 'banner2'),
        const EyepetizerItem(type: 'video'),
        const EyepetizerItem(type: 'banner2'),
        const EyepetizerItem.placeholder(),
      ];
      expect(
        EyepetizerHomeFeed.visibleItems(rows).map((item) => item.type),
        <String>['video', 'placeholder'],
      );
    });
  });

  group('EyepetizerCollapse', () {
    test('keeps the light title only while the header is expanded', () {
      const threshold = 24 + EyepetizerCollapse.toolbarHeight;
      expect(
        EyepetizerCollapse.showsLightTitle(height: 200, collapseThreshold: threshold),
        isTrue,
      );
      // Exactly at the toolbar height: dark title, as in the source.
      expect(
        EyepetizerCollapse.showsLightTitle(height: threshold, collapseThreshold: threshold),
        isFalse,
      );
      // Past the source's hard-coded 250 ceiling: also dark.
      expect(
        EyepetizerCollapse.showsLightTitle(height: 250, collapseThreshold: threshold),
        isFalse,
      );
      expect(EyepetizerCollapse.collapseThresholdFor(24), 80);
    });
  });

  group('home page', () {
    testWidgets('shows the carousel, the next page and both entry actions', (
      tester,
    ) async {
      final requested = <Uri>[];
      final api = EyepetizerApi(
        dio: _routedDio((options) {
          requested.add(options.uri);
          if (options.uri.path.endsWith('/v2/feed') &&
              options.uri.queryParameters.containsKey('date')) {
            return _map(_feedPage2Json);
          }
          return _map(_feedPage1Json);
        }),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: EyepetizerHomePage(api: api, bannerAutoPlay: false),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('开眼 · Eyepetizer'), findsOneWidget);
      expect(find.byType(EyepetizerBanner), findsOneWidget);
      expect(find.byType(CarouselSlider), findsOneWidget);
      // Page 1's rows fill the carousel — the source's `removeWhere` drops the
      // banner2 row, so the carousel never shows '横幅 · 冰川之上'.
      expect(find.text('用 120 帧看一只蜂鸟振翅'), findsOneWidget);
      expect(find.text('横幅 · 冰川之上'), findsNothing);
      expect(find.text('深夜书店里的猫'), findsOneWidget);
      expect(find.byType(EyepetizerVideoCard), findsOneWidget);
      expect(find.byIcon(Icons.grid_view_outlined), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);

      // refresh() + the automatic loadMore() the source did.
      expect(requested, hasLength(2));
      expect(requested.first.path, '/api/v2/feed');
      expect(requested.last.queryParameters['date'], '1508412029000');
    });

    testWidgets('a failed load shows the message and a working retry', (
      tester,
    ) async {
      var attempts = 0;
      final dio = _fakeDio((options) {
        attempts += 1;
        if (attempts == 1) {
          return _response(500, <String, dynamic>{}, options);
        }
        if (options.uri.queryParameters.containsKey('date')) {
          return _ok(_map(_feedPage2Json), options);
        }
        return _ok(_map(_feedPage1Json), options);
      });
      await tester.pumpWidget(
        MaterialApp(
          home: EyepetizerHomePage(api: EyepetizerApi(dio: dio), bannerAutoPlay: false),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('请求失败：HTTP 500'), findsOneWidget);

      await tester.tap(find.text('重试'));
      await tester.pumpAndSettle();
      expect(attempts, greaterThan(1));
      expect(find.text('用 120 帧看一只蜂鸟振翅'), findsOneWidget);
      expect(find.text('深夜书店里的猫'), findsOneWidget);
    });

    testWidgets('an empty feed shows the empty state', (tester) async {
      final api = EyepetizerApi(
        dio: _statusDio(200, <String, dynamic>{
          'issueList': <Object?>[],
          'nextPageUrl': null,
        }),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: EyepetizerHomePage(api: api, bannerAutoPlay: false),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('首页暂时没有内容'), findsOneWidget);
    });
  });

  group('category browsing', () {
    testWidgets('grid lists categories and opens the category detail', (
      tester,
    ) async {
      final requests = <Uri>[];
      final api = EyepetizerApi(
        dio: _routedDio((options) {
          requests.add(options.uri);
          if (options.uri.path.endsWith('/v4/categories')) {
            return _json(_categoriesJson);
          }
          return _map(_categoryVideosJson);
        }),
      );

      await tester.pumpWidget(MaterialApp(home: EyepetizerCategoryPage(api: api)));
      await tester.pumpAndSettle();

      expect(find.text('分类'), findsOneWidget);
      expect(find.text('广告'), findsOneWidget);
      // A null alias falls back to the name.
      expect(find.text('创意'), findsOneWidget);

      await tester.tap(find.text('广告'));
      await tester.pumpAndSettle();

      expect(find.byType(EyepetizerCategoryDetailPage), findsOneWidget);
      expect(find.text('把 40 秒广告拍成一部短片'), findsOneWidget);
      // The category list request carried the source's hard-coded device.
      final categoryRequest = requests.last;
      expect(categoryRequest.path, '/api/v4/categories/videoList');
      expect(categoryRequest.queryParameters['id'], '14');
      expect(categoryRequest.queryParameters['deviceModel'], 'Android');
    });

    testWidgets('a failed category load offers a retry', (tester) async {
      var attempts = 0;
      final dio = _fakeDio((options) {
        attempts += 1;
        if (attempts == 1) {
          return _response(404, <String, dynamic>{}, options);
        }
        return _ok(_json(_categoriesJson), options);
      });
      await tester.pumpWidget(
        MaterialApp(home: EyepetizerCategoryPage(api: EyepetizerApi(dio: dio))),
      );
      await tester.pumpAndSettle();
      expect(find.text('请求失败：HTTP 404'), findsOneWidget);

      await tester.tap(find.text('重试'));
      await tester.pumpAndSettle();
      expect(find.text('广告'), findsOneWidget);
    });

    testWidgets('the category detail shows its collapsing header', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: EyepetizerCategoryDetailPage(
            category: const EyepetizerCategory(
              id: 14,
              name: '广告',
              alias: '广告',
              bgPicture: 'http://img.kaiyanapp.com/cat-ad.jpeg',
            ),
            api: EyepetizerApi(
              dio: _routedDio((options) => _map(_categoryVideosJson)),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SliverAppBar), findsOneWidget);
      expect(find.text('广告'), findsOneWidget);
      expect(find.text('把 40 秒广告拍成一部短片'), findsOneWidget);
      expect(find.text('没有更多了'), findsOneWidget);
    });
  });

  group('search page', () {
    testWidgets('shows hot keyword chips and searches on tap', (tester) async {
      final queries = <String>[];
      final api = EyepetizerApi(
        dio: _routedDio((options) {
          if (options.uri.path.endsWith('/v3/queries/hot')) {
            return _json(_hotKeywordsJson);
          }
          queries.add(options.uri.queryParameters['query'] ?? '');
          return _map(_searchJson);
        }),
      );

      await tester.pumpWidget(MaterialApp(home: EyepetizerSearchPage(api: api)));
      await tester.pumpAndSettle();

      expect(find.text('热门搜索'), findsOneWidget);
      expect(find.widgetWithText(ActionChip, '纪录片'), findsOneWidget);

      await tester.tap(find.widgetWithText(ActionChip, '旅行'));
      await tester.pumpAndSettle();

      expect(queries, <String>['旅行']);
      // The cover-less hit is dropped, the other two are shown.
      expect(find.text('蜂鸟的悬停'), findsOneWidget);
      expect(find.text('蜂鸟与花'), findsOneWidget);
      expect(find.text('无封面的条目'), findsNothing);
      expect(find.text('上拉加载更多'), findsOneWidget);
    });

    testWidgets('initialQuery searches immediately and pages on scroll', (
      tester,
    ) async {
      final requested = <Uri>[];
      final api = EyepetizerApi(
        dio: _routedDio((options) {
          requested.add(options.uri);
          if (options.uri.queryParameters.containsKey('start')) {
            return _map(_searchPage2Json);
          }
          return _map(_searchJson);
        }),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: EyepetizerSearchPage(api: api, initialQuery: '蜂鸟'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('蜂鸟的悬停'), findsOneWidget);
      expect(requested.single.queryParameters['query'], '蜂鸟');
      // No keyword request when a query was supplied.
      expect(
        requested.where((uri) => uri.path.endsWith('/v3/queries/hot')),
        isEmpty,
      );

      await tester.drag(find.byType(ListView), const Offset(0, -400));
      await tester.pumpAndSettle();

      expect(find.text('蜂鸟的迁徙路线'), findsOneWidget);
      expect(find.text('共 3 个结果'), findsOneWidget);
      expect(requested.last.queryParameters['start'], '10');
    });

    testWidgets('a failed search shows the message and a retry', (tester) async {
      var attempts = 0;
      final dio = _fakeDio((options) {
        attempts += 1;
        if (attempts == 1) {
          return _response(500, <String, dynamic>{}, options);
        }
        return _ok(_map(_searchJson), options);
      });
      await tester.pumpWidget(
        MaterialApp(
          home: EyepetizerSearchPage(
            api: EyepetizerApi(dio: dio),
            initialQuery: '蜂鸟',
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('请求失败：HTTP 500'), findsOneWidget);

      await tester.tap(find.text('重试'));
      await tester.pumpAndSettle();
      expect(find.text('蜂鸟的悬停'), findsOneWidget);
    });

    testWidgets('no hits shows the empty state', (tester) async {
      final api = EyepetizerApi(
        dio: _statusDio(200, <String, dynamic>{
          'total': 0,
          'itemList': <Object?>[],
          'nextPageUrl': null,
        }),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: EyepetizerSearchPage(api: api, initialQuery: '不存在的片子'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('没有找到相关视频'), findsOneWidget);
    });
  });

  group('video detail page', () {
    EyepetizerData hummingbird() {
      final entity = EyepetizerIssueEntity.fromJson(_map(_feedPage1Json));
      return entity.itemList[1].data!;
    }

    testWidgets('renders the metadata and the related strip', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: EyepetizerVideoDetailPage(
            data: hummingbird(),
            api: EyepetizerApi(
              dio: _routedDio((options) => _map(_relatedJson)),
            ),
            onPlay: (context, data, sources) async {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // App bar title + the metadata title.
      expect(find.text('用 120 帧看一只蜂鸟振翅'), findsWidgets);
      expect(find.text('自然'), findsOneWidget);
      expect(find.text('Deep Look'), findsOneWidget);
      expect(find.text('2017/10/19'), findsOneWidget);
      expect(find.textContaining('分享 34'), findsOneWidget);
      expect(find.textContaining('评论 5'), findsOneWidget);
      expect(
        find.text('蜂鸟每秒振翅 50 次，高速摄影让它们慢下来。'),
        findsOneWidget,
      );
      // Related rows: the textHeader plus the card.
      expect(find.text('相关推荐'), findsOneWidget);
      expect(find.text('蜂鸟之外，还有蜂鸟鹰蛾'), findsOneWidget);
      expect(find.text('自然 · 02:08'), findsOneWidget);
    });

    testWidgets('the play button hands the extracted streams to the host', (
      tester,
    ) async {
      List<MediaStreamSource>? played;
      EyepetizerData? playedData;
      await tester.pumpWidget(
        MaterialApp(
          home: EyepetizerVideoDetailPage(
            data: hummingbird(),
            api: EyepetizerApi(
              dio: _routedDio((options) => _map(_relatedJson)),
            ),
            onPlay: (context, data, sources) async {
              played = sources;
              playedData = data;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('播放'));
      await tester.pumpAndSettle();

      expect(playedData!.id, 1002);
      expect(
        played!.map((source) => source.label),
        <String>['默认', '标清 · 480p', '标清 · 720p'],
      );
      expect(
        played!.first.url.toString(),
        'http://baobab.kaiyanapp.com/video/hummingbird.mp4',
      );
      // The injected handler replaced the real player page entirely.
      expect(find.byType(MediaPlaybackPage), findsNothing);
    });

    testWidgets('without a stream it opens the share URL externally', (
      tester,
    ) async {
      Uri? opened;
      final data = EyepetizerData.fromJson(<String, dynamic>{
        'id': 8,
        'title': '只有分享链接',
        'cover': <String, dynamic>{'detail': 'http://img.kaiyanapp.com/only.jpeg'},
        'webUrl': <String, dynamic>{'raw': 'http://www.kaiyanapp.com/detail.html?vid=8'},
      });
      await tester.pumpWidget(
        MaterialApp(
          home: EyepetizerVideoDetailPage(
            data: data,
            api: EyepetizerApi(
              dio: _routedDio((options) => _map(_relatedJson)),
            ),
            onOpenExternal: (url) async {
              opened = url;
              return true;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('播放'));
      await tester.pumpAndSettle();

      expect(
        opened,
        Uri.parse('http://www.kaiyanapp.com/detail.html?vid=8'),
      );
      expect(find.byType(MediaPlaybackPage), findsNothing);
    });

    testWidgets('with nothing playable it explains why', (tester) async {
      final data = EyepetizerData.fromJson(<String, dynamic>{
        'id': 9,
        'title': '什么都没有',
      });
      await tester.pumpWidget(
        MaterialApp(
          home: EyepetizerVideoDetailPage(
            data: data,
            api: EyepetizerApi(
              dio: _routedDio((options) => _map(_relatedJson)),
            ),
            onOpenExternal: (url) async => true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('播放'));
      await tester.pump();

      expect(find.text('该视频没有可播放的地址'), findsOneWidget);
    });

    testWidgets('a failed related load shows a retry that re-requests', (
      tester,
    ) async {
      var attempts = 0;
      final dio = _fakeDio((options) {
        attempts += 1;
        if (attempts == 1) {
          return _response(500, <String, dynamic>{}, options);
        }
        return _ok(_map(_relatedJson), options);
      });
      await tester.pumpWidget(
        MaterialApp(
          home: EyepetizerVideoDetailPage(
            data: hummingbird(),
            api: EyepetizerApi(dio: dio),
            onPlay: (context, data, sources) async {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('请求失败：HTTP 500'), findsOneWidget);

      await tester.tap(find.text('重试'));
      await tester.pumpAndSettle();
      expect(attempts, greaterThan(1));
      expect(find.text('蜂鸟之外，还有蜂鸟鹰蛾'), findsOneWidget);
    });

    testWidgets('a related card replaces the page in place', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: EyepetizerVideoDetailPage(
            data: hummingbird(),
            api: EyepetizerApi(
              dio: _routedDio((options) => _map(_relatedJson)),
            ),
            onPlay: (context, data, sources) async {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('蜂鸟之外，还有蜂鸟鹰蛾'));
      await tester.pumpAndSettle();

      expect(find.byType(EyepetizerVideoDetailPage), findsOneWidget);
      // The replaced page is the only detail page on screen.
      expect(find.text('用 120 帧看一只蜂鸟振翅'), findsNothing);
      expect(find.text('蜂鸟之外，还有蜂鸟鹰蛾'), findsWidgets);
    });
  });
}
