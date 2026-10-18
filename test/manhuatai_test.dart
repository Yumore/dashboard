import 'dart:convert';

import 'package:dashboard/features/comic/manhuatai/manhuatai_book_list.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_chapter.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_client.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_detail.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_endpoints.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_exception.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_favorite.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_image_url.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_influence.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_json.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_library_store.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_rank_detail.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_rank_list.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_rank_types.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_read_record.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_search_comic.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_sort_list.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_source.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_update_list.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A [ManhuataiSource] wired to an in-memory transport, plus the requests it
/// received. Nothing here touches the network.
class _Harness {
  _Harness(Future<http.Response> Function(http.Request request) handler) {
    client = MockClient((http.Request request) async {
      requests.add(request);
      return handler(request);
    });
    source = ManhuataiSource(client: ManhuataiClient(client: client));
  }

  final List<http.Request> requests = <http.Request>[];
  late final MockClient client;
  late final ManhuataiSource source;

  http.Request get last => requests.last;

  /// Answers every request with the same JSON payload.
  static _Harness json(Object body, {int status = 200}) {
    return _Harness((_) async => http.Response(
          jsonEncode(body),
          status,
          headers: <String, String>{
            'content-type': 'application/json; charset=utf-8',
          },
        ));
  }

  static _Harness raw(String body, {int status = 200}) {
    return _Harness((_) async => http.Response(body, status));
  }
}

/// Minimal chapter fixture matching the backend's `comic_chapter` shape.
Map<String, dynamic> _chapterJson({
  String name = '第1话',
  String id = '1001',
  int topicId = 101,
  int start = 1,
  int end = 6,
  int islock = 0,
  String middle = r'/comic/1/$$.jpg',
}) {
  return <String, dynamic>{
    'chapter_name': name,
    'chapter_id': id,
    'chapter_topic_id': topicId,
    'create_date': 1600000000,
    'islock': islock,
    'chapter_share_url': 'http://share/$topicId',
    'download_price': 0,
    'price': 5,
    'isbuy': 0,
    'start_num': start,
    'end_num': end,
    'chapter_domain': 'mhpic.jumanhua.com',
    'source_url': '',
    'rule': '',
    'webview': '',
    'show_spiltline': 0,
    'chapter_image': <String, dynamic>{
      'low': r'/comic/1/low/$$.jpg',
      'middle': middle,
      'high': r'/comic/1/high/$$.jpg',
    },
  };
}

Map<String, dynamic> _detailJson() {
  return <String, dynamic>{
    'servicetime': 1700000000,
    'comic_name': '斗破苍穹',
    'comic_type': <String, dynamic>{'rexue': '热血', 'shenmo': '神魔'},
    'comic_type_new': <dynamic>[
      <String, dynamic>{'id': 3, 'name': '热血', 'urlid': 'rexue'},
    ],
    'update_status_str': '已完结',
    'seo_title': 't',
    'seo_keywords': 'k',
    'seo_description': 'd',
    'comic_status': 1,
    'comic_author': '天蚕土豆',
    'comic_desc': '简介',
    'comic_notice': '',
    'comic_copyright': '',
    'last_chapter_id': '2000',
    'last_chapter_name': '第10话',
    'copyright_type': 1,
    'readtype': 0,
    'human_type': 0,
    'copyright_type_cn': '',
    'background_color': '',
    'comic_share_url': '',
    'update_time': 1700000000,
    'cover_charge_status': '',
    'comic_media': '',
    'site_status': '',
    'shoucang': 12345,
    'renqi': '987654',
    'allprice': 0,
    'charge_status': '',
    'charge_paid': 0,
    'cover_list': <dynamic>['comic/1/cover.jpg'],
    'comic_chapter': <dynamic>[
      _chapterJson(name: '第1话', topicId: 101),
      _chapterJson(name: '第2话', topicId: 102, islock: 1),
    ],
  };
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('endpoints', () {
    test('keeps the exact 321mh/yyhao host paths of the source', () {
      expect(
        ManhuataiEndpoints.comicInfoBody,
        'https://comic.321mh.com/app_api/v5/getcomicinfo_body/',
      );
      expect(
        ManhuataiEndpoints.comicInfoInfluence,
        'http://comic.321mh.com/app_api/v5/getcomicinfo_influence/',
      );
      expect(
        ManhuataiEndpoints.rankDetail,
        'https://rankdata-globalapi.321mh.com/app_api/v1/comic/getRankDataDetials/',
      );
      expect(
        ManhuataiEndpoints.comicChapterInfo,
        'http://kanmanapi-main.321mh.com/v1/comic/getchapterinfobychapterid',
      );
      expect(
        ManhuataiEndpoints.legacyRecommend,
        'https://cms-booklist.321mh.com/api/v1/bookList/getBookByType',
      );
      expect(
        ManhuataiEndpoints.bookInfoById,
        'http://cms-booklist.321mh.com/api/v1/bookList/getbookinfo_sys',
      );
    });

    test('preserves the backend misspellings serachcomic / serachKey', () {
      expect(
        ManhuataiEndpoints.searchComic,
        'https://getconfig-globalapi.yyhao.com/app_api/v5/serachcomic/',
      );
      expect(ManhuataiEndpoints.searchComic.contains('searchcomic'), isFalse);
    });

    test('shared product identity values match the source constants', () {
      expect(ManhuataiEndpoints.platformName, 'android');
      expect(ManhuataiEndpoints.productName, 'mht');
      expect(ManhuataiEndpoints.platform, 8);
      expect(ManhuataiEndpoints.bookType, 132);
      expect(ManhuataiEndpoints.recommendPageSize, 10);
      expect(ManhuataiEndpoints.legacyRecommendPageSize, 20);
      expect(ManhuataiEndpoints.bookPositionPageSize, 20);
      expect(ManhuataiEndpoints.defaultSortPageSize, 7);
      expect(ManhuataiEndpoints.defaultSortOrder, 'click');
      expect(ManhuataiEndpoints.rankProductId, 2);
      expect(ManhuataiEndpoints.defaultRankType, 'heat');
      expect(ManhuataiEndpoints.defaultTimeType, 'week');
      expect(ManhuataiEndpoints.defaultUserType, 'device');
      expect(ManhuataiEndpoints.homePositionId, 7);
    });
  });

  group('client transport', () {
    test('buildUri leaves a parameter-less URL untouched', () {
      final client = ManhuataiClient(client: MockClient((_) async => http.Response('', 200)));
      expect(
        client.buildUri(ManhuataiEndpoints.updateList).toString(),
        ManhuataiEndpoints.updateList,
      );
      expect(
        client
            .buildUri(ManhuataiEndpoints.updateList, <String, dynamic>{})
            .toString(),
        ManhuataiEndpoints.updateList,
      );
    });

    test('buildUri drops null values', () {
      final client = ManhuataiClient(client: MockClient((_) async => http.Response('', 200)));
      final uri = client.buildUri(
        'http://x/y',
        <String, dynamic>{'a': 1, 'b': null},
      );
      expect(uri.query, 'a=1');
    });

    test('buildUri expands a List to a repeated key (chapterid)', () {
      final client = ManhuataiClient(client: MockClient((_) async => http.Response('', 200)));
      final uri = client.buildUri(
        ManhuataiEndpoints.comicChapterInfo,
        <String, dynamic>{'chapterid': <int>[101, 102]},
      );
      expect(uri.query, 'chapterid=101&chapterid=102');
      expect(uri.toString().contains('chapterid[]'), isFalse);
    });

    test('buildUri appends with & when the URL already has a query', () {
      final client = ManhuataiClient(client: MockClient((_) async => http.Response('', 200)));
      final uri = client.buildUri('http://x/y?appId=2', <String, dynamic>{'b': 2});
      expect(uri.toString(), 'http://x/y?appId=2&b=2');
    });

    test('buildUri percent-encodes non-ASCII values', () {
      final client = ManhuataiClient(client: MockClient((_) async => http.Response('', 200)));
      final uri = client.buildUri('http://x/y', <String, dynamic>{'serachKey': '斗破'});
      expect(uri.queryParameters['serachKey'], '斗破');
      expect(uri.query, contains('%E6%96%97'));
    });

    test('sends the platformname/productname default headers on every GET', () async {
      final harness = _Harness.json(<String, dynamic>{'status': 0});
      await harness.source.updateList();
      expect(harness.last.method, 'GET');
      expect(harness.last.headers['platformname'], 'android');
      expect(harness.last.headers['productname'], 'mht');
    });

    test('throws ManhuataiApiException with the status code on non-2xx', () async {
      final harness = _Harness.raw('server error', status: 500);
      try {
        await harness.source.detail(comicId: 1);
        fail('expected ManhuataiApiException');
      } on ManhuataiApiException catch (error) {
        expect(error.statusCode, 500);
        expect(error.url, contains('getcomicinfo_body'));
      }
    });

    test('throws ManhuataiApiException when the body is not JSON', () async {
      final harness = _Harness.raw('<html>nope</html>');
      await expectLater(
        harness.source.updateList(),
        throwsA(isA<ManhuataiApiException>()),
      );
    });

    test('treats an empty body as an empty JSON object', () async {
      final harness = _Harness.raw('');
      final detail = await harness.source.detail(comicId: 9);
      expect(detail.comicName, '');
      expect(detail.comicChapter, isEmpty);
    });

    test('POST sends a JSON body and sets Content-Type', () async {
      final harness = _Harness.json(<String, dynamic>{'status': 0});
      final ok = await harness.source.setUserCollect(action: 'add', comicId: 123);
      expect(ok, isTrue);
      expect(harness.last.method, 'POST');
      expect(harness.last.headers['content-type'], contains('application/json'));
      final body = jsonDecode(harness.last.body) as Map<String, dynamic>;
      expect(body['comic_id'], 123);
      expect(body['autologo'], 1);
      expect(body['type'], 'device');
    });
  });

  group('source requests', () {
    test('detail hits getcomicinfo_body with comic_id/from_page', () async {
      final harness = _Harness.json(_detailJson());
      final detail = await harness.source.detail(comicId: 321);
      expect(
        harness.last.url.toString(),
        'https://comic.321mh.com/app_api/v5/getcomicinfo_body/'
        '?comic_id=321&from_page=&platformname=android&productname=mht',
      );
      expect(detail.comicName, '斗破苍穹');
    });

    test('influence sends rank_type=all', () async {
      final harness = _Harness.json(<String, dynamic>{
        'status': 0,
        'msg': '',
        'data': <String, dynamic>{'out_list': <int>[1], 'insider_list': <dynamic>[]},
      });
      await harness.source.influence(comicId: 7);
      expect(harness.last.url.path, '/app_api/v5/getcomicinfo_influence/');
      expect(harness.last.url.queryParameters['comic_id'], '7');
      expect(harness.last.url.queryParameters['rank_type'], 'all');
    });

    test('commentCount sends appId/commentType/ssid/ssidType and parses int data', () async {
      final harness = _Harness.json(<String, dynamic>{'status': 0, 'msg': '', 'data': 42});
      final count = await harness.source.commentCount(comicId: 88);
      expect(harness.last.url.host, 'community-hots.321mh.com');
      // The source's comment-count endpoint carries no product identity.
      expect(harness.last.url.queryParameters, <String, String>{
        'appId': '2',
        'commentType': '2',
        'ssid': '88',
        'ssidType': '0',
      });
      expect(count.data, 42);
    });

    test('rankDetail formats query_time and sends the rank selectors', () async {
      final harness = _Harness.json(<String, dynamic>{'status': 0, 'msg': '', 'data': <dynamic>[]});
      await harness.source.rankDetail(
        sortType: 'shaonian',
        rankType: 'heat',
        timeType: 'month',
        now: DateTime(2026, 10, 17),
      );
      expect(harness.last.url.queryParameters['sort_type'], 'shaonian');
      expect(harness.last.url.queryParameters['rank_type'], 'heat');
      expect(harness.last.url.queryParameters['time_type'], 'month');
      expect(harness.last.url.queryParameters['query_time'], '2026-10-17');
      expect(harness.last.url.queryParameters['product_id'], '2');
    });

    test('rankDetail defaults to heat/week', () async {
      final harness = _Harness.json(<String, dynamic>{'status': 0, 'msg': '', 'data': <dynamic>[]});
      await harness.source.rankDetail(sortType: 'rexue', now: DateTime(2026, 1, 2));
      expect(harness.last.url.queryParameters['rank_type'], 'heat');
      expect(harness.last.url.queryParameters['time_type'], 'week');
      expect(harness.last.url.queryParameters['query_time'], '2026-01-02');
    });

    test('searchComic sends serachKey and omits topNumber when null', () async {
      final harness = _Harness.json(<String, dynamic>{'status': 0, 'msg': '', 'data': <dynamic>[]});
      await harness.source.searchComic('斗破');
      expect(harness.last.url.queryParameters['serachKey'], '斗破');
      expect(harness.last.url.queryParameters.containsKey('topNumber'), isFalse);
    });

    test('searchComic forwards topNumber when given', () async {
      final harness = _Harness.json(<String, dynamic>{'status': 0, 'msg': '', 'data': <dynamic>[]});
      await harness.source.searchComic('斗破', topNumber: 5);
      expect(harness.last.url.queryParameters['topNumber'], '5');
    });

    test('chapterInfo builds a repeated chapterid key', () async {
      final harness = _Harness.json(<String, dynamic>{
        'status': 0,
        'data': <dynamic>[_chapterJson(topicId: 101), _chapterJson(topicId: 102)],
      });
      final chapters = await harness.source.chapterInfo(chapterIds: <int>[101, 102]);
      expect(
        harness.last.url.toString(),
        'http://kanmanapi-main.321mh.com/v1/comic/getchapterinfobychapterid'
        '?chapterid=101&chapterid=102&platformname=android&productname=mht',
      );
      expect(chapters, hasLength(2));
      expect(chapters.first.chapterTopicId, 101);
    });

    test('chapterInfo returns an empty list when status != 0', () async {
      final harness = _Harness.json(<String, dynamic>{'status': 1, 'data': <dynamic>[]});
      expect(await harness.source.chapterInfo(chapterIds: <int>[1]), isEmpty);
    });

    test('sortList sends the paging/order/search_key parameters', () async {
      final harness = _Harness.json(<String, dynamic>{
        'page': <String, dynamic>{'current_page': 2, 'total_page': 3},
        'data': <dynamic>[],
      });
      await harness.source.sortList(page: 2, size: 7, orderby: 'click', searchKey: '斗');
      expect(harness.last.url.queryParameters, <String, String>{
        'page': '2',
        'size': '7',
        'orderby': 'click',
        'search_key': '斗',
        'platformname': 'android',
        'productname': 'mht',
      });
    });

    test('legacyRecommend sends page/pagesize/pytype/booktype/platform', () async {
      final harness = _Harness.json(<String, dynamic>{'status': 0, 'data': <String, dynamic>{}});
      await harness.source.legacyRecommend();
      expect(harness.last.url.queryParameters, <String, String>{
        'page': '1',
        'pagesize': '20',
        'pytype': '',
        'booktype': '132',
        'platform': '8',
        'platformname': 'android',
        'productname': 'mht',
      });
    });

    test('recommend returns an empty list when status != 0', () async {
      final harness = _Harness.json(<String, dynamic>{'status': 7, 'data': <String, dynamic>{}});
      final list = await harness.source.recommend(userId: 'u1', page: 3);
      expect(harness.last.url.queryParameters['user_id'], 'u1');
      expect(harness.last.url.queryParameters['page'], '3');
      expect(harness.last.url.queryParameters['pagesize'], '10');
      expect(list.data.isEmpty, isTrue);
      // The source replaced the whole payload with `BookList.fromJson({})`,
      // so a non-zero backend status surfaces as status 0 / empty data.
      expect(list.status, 0);
    });

    test('bookByPosition defaults to position 7 and pagesize 20', () async {
      final harness = _Harness.json(<String, dynamic>{'status': 0, 'data': <String, dynamic>{}});
      await harness.source.bookByPosition();
      expect(harness.last.url.queryParameters['position_id'], '7');
      expect(harness.last.url.queryParameters['pagesize'], '20');
    });

    test('bookInfoById sends book_id', () async {
      final harness = _Harness.json(<String, dynamic>{'status': 0, 'data': <String, dynamic>{}});
      await harness.source.bookInfoById(bookId: 55);
      expect(harness.last.url.queryParameters['book_id'], '55');
    });

    test('hotSearch parses a bare JSON array', () async {
      final harness = _Harness.json(<dynamic>[
        <String, dynamic>{
          'comic_id': 4,
          'comic_name': '热门',
          'last_chapter_name': '第3话',
          'comic_newid': 'n1',
        },
      ]);
      final hot = await harness.source.hotSearch();
      expect(hot, hasLength(1));
      expect(hot.first.comicName, '热门');
      expect(hot.first.comicId, 4);
    });

    test('hotSearch tolerates a non-array payload', () async {
      final harness = _Harness.json(<String, dynamic>{'status': 0});
      expect(await harness.source.hotSearch(), isEmpty);
    });

    test('setUserCollect("dels") keeps the source trailing comma', () async {
      final harness = _Harness.json(<String, dynamic>{'status': 0});
      await harness.source.setUserCollect(
        action: 'dels',
        comicIdList: <int>[11, 22],
      );
      final body = jsonDecode(harness.last.body) as Map<String, dynamic>;
      expect(body['comic_id_list'], '11,22,');
    });

    test('setUserCollect("add") without comicId throws ArgumentError', () {
      final harness = _Harness.json(<String, dynamic>{'status': 0});
      expect(
        () => harness.source.setUserCollect(action: 'add'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('setUserCollect("dels") without ids throws ArgumentError', () {
      final harness = _Harness.json(<String, dynamic>{'status': 0});
      expect(
        () => harness.source.setUserCollect(action: 'dels'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('addUserRead posts the reading position and checks status == 0', () async {
      final harness = _Harness.json(<String, dynamic>{'status': 0});
      final ok = await harness.source.addUserRead(
        comicId: 9,
        chapterId: 1001,
        chapterName: '第1话',
        chapterPage: 3,
      );
      expect(ok, isTrue);
      expect(harness.last.url.host, 'adduserread.321mh.com');
      final body = jsonDecode(harness.last.body) as Map<String, dynamic>;
      expect(body['comic_id'], 9);
      expect(body['chapter_id'], 1001);
      expect(body['chapter_name'], '第1话');
      expect(body['chapter_page'], 3);
      expect(body['localtime'], isA<int>());
    });

    test('addUserRead reports failure for a non-zero status', () async {
      final harness = _Harness.json(<String, dynamic>{'status': 5});
      expect(
        await harness.source.addUserRead(
          comicId: 1,
          chapterId: 2,
          chapterName: 'x',
          chapterPage: 0,
        ),
        isFalse,
      );
    });

    test('delUserRead posts comic_id and chapter_id', () async {
      final harness = _Harness.json(<String, dynamic>{'status': 0});
      await harness.source.delUserRead(comicId: 3, chapterId: 4);
      final body = jsonDecode(harness.last.body) as Map<String, dynamic>;
      expect(body['comic_id'], 3);
      expect(body['chapter_id'], 4);
      expect(harness.last.url.path, '/app_api/v5/deluserread/');
    });
  });

  group('model mapping', () {
    test('detail maps snake_case fields, legacy type map and chapters', () {
      final detail = ManhuataiDetail.fromJson(_detailJson());
      expect(detail.comicName, '斗破苍穹');
      expect(detail.comicAuthor, '天蚕土豆');
      expect(detail.comicDesc, '简介');
      expect(detail.updateStatusStr, '已完结');
      expect(detail.shoucang, 12345);
      expect(detail.renqi, '987654');
      expect(detail.comicTypeLegacy['rexue'], '热血');
      expect(detail.comicTypeNew.single.name, '热血');
      expect(detail.coverList, <String>['comic/1/cover.jpg']);
      expect(detail.comicChapter, hasLength(2));
      expect(detail.comicChapter[1].isLocked, isTrue);
      expect(detail.lastChapterName, '第10话');
    });

    test('detail tolerates a payload without comic_chapter/cover_list', () {
      final detail = ManhuataiDetail.fromJson(<String, dynamic>{'comic_name': 'X'});
      expect(detail.comicName, 'X');
      expect(detail.comicChapter, isEmpty);
      expect(detail.coverList, isEmpty);
      expect(detail.renqi, '');
    });

    test('chapter maps chapter_topic_id/chapter_id and page count', () {
      final chapter = ManhuataiChapter.fromJson(_chapterJson(end: 6));
      expect(chapter.chapterName, '第1话');
      expect(chapter.chapterId, '1001');
      expect(chapter.chapterTopicId, 101);
      expect(chapter.startNum, 1);
      expect(chapter.endNum, 6);
      expect(chapter.pageCount, 6);
      expect(chapter.chapterImage.middle, r'/comic/1/$$.jpg');
      expect(chapter.chapterShareUrl, 'http://share/101');
    });

    test('chapter falls back to an empty chapter_image', () {
      final chapter = ManhuataiChapter.fromJson(<String, dynamic>{
        'chapter_name': 'x',
      });
      expect(chapter.chapterImage.middle, '');
      expect(chapter.isLocked, isFalse);
      expect(chapter.pageCount, 0);
    });

    test('rank list maps groups and coerces rise_rank to String', () {
      final list = ManhuataiRankList.fromJson(<String, dynamic>{
        'status': 0,
        'msg': '',
        'data': <dynamic>[
          <String, dynamic>{
            'type': 'heat',
            'name': '热度榜',
            'list': <dynamic>[
              <String, dynamic>{
                'comic_id': 5,
                'comic_name': 'A',
                'rise_rank': 3,
                'comic_score': '9.6',
                'count_num': '12345',
                'count_day': '2',
              },
            ],
          },
        ],
      });
      expect(list.groups, hasLength(1));
      expect(list.groups.first.name, '热度榜');
      expect(list.groups.first.type, 'heat');
      expect(list.groups.first.list.single.riseRank, '3');
      expect(list.groups.first.list.single.comicScore, 9.6);
      expect(list.groups.first.list.single.countNum, '12345');
      expect(list.groups.first.list.single.countDay, 2);
    });

    test('rank detail maps its data rows', () {
      final detail = ManhuataiRankDetail.fromJson(<String, dynamic>{
        'status': 0,
        'msg': '',
        'data': <dynamic>[
          <String, dynamic>{
            'comic_id': 6,
            'comic_name': 'B',
            'comic_shortdesc': '短简介',
            'rise_rank': '12',
          },
        ],
      });
      expect(detail.data, hasLength(1));
      expect(detail.data.single.comicShortdesc, '短简介');
      expect(detail.data.single.riseRank, '12');
    });

    test('update list keeps camelCase date keys and today-only view count', () {
      final list = ManhuataiUpdateList.fromJson(<String, dynamic>{
        'tab_title': '更新',
        'servicetime': 123,
        'update': <dynamic>[
          <String, dynamic>{
            'comicUpdateDate': '2026.10.17',
            'comicUpdateDate_new': '10-17',
            'info': <dynamic>[
              <String, dynamic>{
                'comic_id': 7,
                'comic_name': 'B',
                'comic_chapter_name': '第2话',
                'comic_type': <dynamic>['热血', '玄幻'],
                'renqi': 100,
                'score': '8.5',
                'comic_newid': 'x',
              },
            ],
          },
        ],
        'today': <dynamic>[
          <String, dynamic>{
            'comicUpdateDate': '2026.10.17',
            'comicUpdateDate_new': '10-17',
            'info': <dynamic>[
              <String, dynamic>{
                'comic_id': 8,
                'comic_name': 'C',
                'yesterday_view_num': 55,
              },
            ],
          },
        ],
      });
      expect(list.tabTitle, '更新');
      expect(list.servicetime, 123);
      expect(list.update.single.comicUpdateDate, '2026.10.17');
      expect(list.update.single.comicUpdateDateNew, '10-17');
      expect(list.update.single.info.single.comicChapterName, '第2话');
      expect(list.update.single.info.single.comicType, <String>['热血', '玄幻']);
      expect(list.update.single.info.single.score, 8.5);
      expect(list.update.single.info.single.yesterdayViewNum, isNull);
      expect(list.today.single.info.single.yesterdayViewNum, 55);
    });

    test('sort list maps page paging fields and rows', () {
      final list = ManhuataiSortList.fromJson(<String, dynamic>{
        'page': <String, dynamic>{
          'current_page': 2,
          'total_page': 15,
          'orderby': 'click',
          'count': 100,
          'comic_sort': '',
          'search_key': '斗',
          'time': 1,
        },
        'data': <dynamic>[
          <String, dynamic>{
            'comic_id': 3,
            'comic_name': 'D',
            'last_chapter_name': '第9话',
            'comic_type': '热血',
            'comic_newid': 'n',
          },
        ],
      });
      expect(list.page.currentPage, 2);
      expect(list.page.totalPage, 15);
      expect(list.page.orderby, 'click');
      expect(list.page.searchKey, '斗');
      expect(list.data.single.comicName, 'D');
      expect(list.data.single.comicType, '热血');
    });

    test('search comic maps hits', () {
      final result = ManhuataiSearchComic.fromJson(<String, dynamic>{
        'status': 0,
        'msg': '',
        'data': <dynamic>[
          <String, dynamic>{
            'total_view_num': 88,
            'cartoon_newid': 'c',
            'comic_id': 2,
            'comic_name': 'E',
            'comic_newid': 'n',
          },
        ],
      });
      expect(result.status, 0);
      expect(result.data.single.totalViewNum, 88);
      expect(result.data.single.cartoonNewid, 'c');
      expect(result.data.single.comicName, 'E');
    });

    test('book list maps nested config and comic_info', () {
      final list = ManhuataiBookList.fromJson(<String, dynamic>{
        'status': 0,
        'message': 'ok',
        'data': <String, dynamic>{
          'name': '推荐',
          'book': <dynamic>[
            <String, dynamic>{
              'book_id': 9,
              'title': '少年',
              'istop': 1,
              'config': <String, dynamic>{'display_type': 1, 'horizonratio': '3:4'},
              'comic_info': <dynamic>[
                <String, dynamic>{
                  'comic_id': 11,
                  'comic_name': '斗破',
                  'img_url': 'a/b.jpg',
                  'comic_type': <dynamic>['热血'],
                  'total_view_num': '123456',
                  'ordernum': 1,
                },
              ],
            },
          ],
        },
      });
      expect(list.message, 'ok');
      expect(list.data.name, '推荐');
      expect(list.data.book.single.bookId, 9);
      expect(list.data.book.single.config.horizonratio, '3:4');
      expect(list.data.book.single.comicInfo.single.comicName, '斗破');
      expect(
        list.data.book.single.comicInfo.single.totalViewNum,
        '123456',
      );
    });

    test('influence maps out_list and insider_list (uppercase Uname)', () {
      final influence = ManhuataiInfluence.fromJson(<String, dynamic>{
        'status': 0,
        'msg': '',
        'data': <String, dynamic>{
          'out_list': <dynamic>[1, 2],
          'insider_list': <dynamic>[
            <String, dynamic>{
              'uid': 1,
              'counts': 2,
              'Uname': '甲',
              'level': 3,
              'isvip': 1,
            },
          ],
        },
      });
      expect(influence.data.outList, <int>[1, 2]);
      expect(influence.data.insiderList.single.uname, '甲');
      expect(influence.data.insiderList.single.level, 3);
      expect(influence.data.insiderList.single.isvip, 1);
    });

    test('rank types maps options including the int product name', () {
      final types = ManhuataiRankTypes.fromJson(<String, dynamic>{
        'status': 0,
        'msg': '',
        'data': <String, dynamic>{
          'rank_type_list': <dynamic>[
            <String, dynamic>{'name': '热度', 'value': 'heat'},
          ],
          'sort_type_list': <dynamic>[
            <String, dynamic>{'name': '少年', 'value': 'shaonian'},
          ],
          'product_id_list': <dynamic>[
            <String, dynamic>{'name': 2, 'value': 'comic'},
          ],
          'time_type_list': <dynamic>[
            <String, dynamic>{'name': '周', 'value': 'week'},
          ],
          'yearlist': <dynamic>[2025, 2026],
          'servertime': 123,
          'weeklist': <dynamic>[],
        },
      });
      expect(types.status, 0);
      expect(types.data.rankTypeList.single.name, '热度');
      expect(types.data.rankTypeList.single.value, 'heat');
      expect(types.data.sortTypeList.single.value, 'shaonian');
      expect(types.data.productIdList.single.name, 2);
      expect(types.data.timeTypeList.single.value, 'week');
      expect(types.data.yearlist, <int>[2025, 2026]);
      expect(types.data.servertime, 123);
    });

    test('coercion helpers normalise the backend type drift', () {
      expect(ManhuataiJson.asInt('12'), 12);
      expect(ManhuataiJson.asInt(3.9), 3);
      expect(ManhuataiJson.asInt(null), 0);
      expect(ManhuataiJson.asInt(true), 1);
      expect(ManhuataiJson.asDouble('9.5'), 9.5);
      expect(ManhuataiJson.asDouble(4), 4.0);
      expect(ManhuataiJson.asString(null, fallback: 'x'), 'x');
      expect(ManhuataiJson.asString(7), '7');
      expect(ManhuataiJson.asDynamicString(3), '3');
      expect(ManhuataiJson.asStringList(<dynamic>['a', 1, null]), <String>['a', '1', '']);
      expect(ManhuataiJson.asIntList(<dynamic>['a', '2']), <int>[0, 2]);
      expect(ManhuataiJson.asBool('true'), isTrue);
      expect(ManhuataiJson.asBool(0), isFalse);
      expect(ManhuataiJson.map(null), isEmpty);
      expect(ManhuataiJson.map(<dynamic, dynamic>{1: 'a'})['1'], 'a');
      expect(
        ManhuataiJson.maps(<dynamic>[
          <String, dynamic>{'a': 1},
          'skip',
          <dynamic, dynamic>{'b': 2},
        ]).map((item) => item['b']),
        <dynamic>[null, 2],
      );
    });

    test('favorite/read-record JSON round-trip the persistence keys', () {
      final favorite = ManhuataiFavorite(
        comicId: 1,
        comicName: 'A',
        imgUrl: 'u',
        comicNewid: 'n',
        addedAt: 5,
      );
      expect(favorite.toJson(), <String, dynamic>{
        'comic_id': 1,
        'comic_name': 'A',
        'img_url': 'u',
        'comic_newid': 'n',
        'added_at': 5,
      });
      expect(ManhuataiFavorite.fromJson(favorite.toJson()).comicName, 'A');

      final record = ManhuataiReadRecord.fromJson(<String, dynamic>{
        'comic_id': 2,
        'comic_name': 'B',
        'chapter_topic_id': 202,
        'chapter_name': '第2话',
        'chapter_page': 4,
        'read_at': 7,
        'img_url': 'i',
      });
      expect(record.chapterTopicId, 202);
      expect(record.chapterPage, 4);
      expect(record.toJson()['chapter_topic_id'], 202);
    });

    test('read record factory copies chapter identity', () {
      final chapter = ManhuataiChapter.fromJson(_chapterJson(topicId: 999));
      final record = ManhuataiReadRecord.fromChapter(
        comicId: 3,
        comicName: 'C',
        chapter: chapter,
        chapterPage: 1,
      );
      expect(record.comicId, 3);
      expect(record.chapterTopicId, 999);
      expect(record.chapterName, '第1话');
      expect(record.readAt, greaterThan(0));
    });
  });

  group('image URLs', () {
    final chapter = ManhuataiChapter.fromJson(_chapterJson());

    test('chapterPageUrl prefixes mhpic.jumanhua.com and replaces \$\$', () {
      expect(
        ManhuataiImageUrl.chapterPageUrl(chapter, 3),
        'http://mhpic.jumanhua.com/comic/1/3.jpg',
      );
    });

    test('chapterPageUrls yields start_num..start_num+end_num-1', () {
      final urls = ManhuataiImageUrl.chapterPageUrls(chapter);
      expect(urls, hasLength(6));
      expect(urls.first, 'http://mhpic.jumanhua.com/comic/1/1.jpg');
      expect(urls.last, 'http://mhpic.jumanhua.com/comic/1/6.jpg');
    });

    test('cover() uses the m3x4 WebP suffix by default', () {
      expect(
        ManhuataiImageUrl.cover(comicId: 123),
        'http://image.yqmh.com/mh/123.jpg-960x1280.jpg.webp',
      );
    });

    test('cover() prefers the CMS img_url', () {
      expect(
        ManhuataiImageUrl.cover(comicId: 123, imgUrl: 'comic/1/cover.jpg'),
        'http://cms.samanlehua.com/comic/1/cover.jpg-noresize.webp',
      );
    });

    test('cover() special-cases a 2:1 aspect ratio', () {
      expect(
        ManhuataiImageUrl.cover(comicId: 123, horizonratio: '2:1'),
        'http://image.yqmh.com/mh/123_2_1.jpg-640x320.jpg.webp',
      );
    });

    test('cover() with useDefault emits the noresize thumbnail', () {
      expect(
        ManhuataiImageUrl.cover(comicId: 123, useDefault: true),
        'http://image.yqmh.com/mh/123.jpg-noresize.webp',
      );
    });

    test('cover() on iOS drops .webp', () {
      expect(
        ManhuataiImageUrl.cover(comicId: 123, isIos: true),
        'http://image.yqmh.com/mh/123.jpg-480x640.jpg',
      );
    });

    test('fromId() shards a head id into 3-digit groups', () {
      expect(
        ManhuataiImageUrl.fromId(id: 123, type: 'head'),
        'http://head.samanlehua.com/kmh_user_head/000/000/123.jpg-100x100.webp',
      );
    });

    test('fromId() uses the 2:1 path for a 2:1 aspect ratio', () {
      expect(
        ManhuataiImageUrl.fromId(id: 123, aspectRatio: '2:1'),
        'http://image.yqmh.com/mh/123_2_1.jpg-640x320.jpg.webp',
      );
    });

    test('suffix lookup exposes Android and iOS sets', () {
      expect(ManhuataiImageUrl.suffix('m3x4'), '-960x1280.jpg.webp');
      expect(ManhuataiImageUrl.suffix('m3x4', isIos: true), '-480x640.jpg');
      expect(ManhuataiImageUrl.suffix('unknown'), '');
      expect(ManhuataiImageUrl.defaultSuffix(), '-noresize.webp');
    });

    test('formatNumber follows the 万/亿 rules of the source', () {
      expect(ManhuataiImageUrl.formatNumber('99999'), '99999');
      expect(ManhuataiImageUrl.formatNumber('100000'), '100000');
      expect(ManhuataiImageUrl.formatNumber('123456'), '12.3万');
      expect(ManhuataiImageUrl.formatNumber('12345678'), '1234万');
      expect(ManhuataiImageUrl.formatNumber('200000000'), '2.0亿');
      expect(ManhuataiImageUrl.formatNumber('abc'), 'abc');
    });
  });

  group('library store', () {
    setUp(() {
      SharedPreferences.setMockInitialValues(<String, Object>{});
    });

    ManhuataiFavorite favorite(int id) => ManhuataiFavorite(
          comicId: id,
          comicName: 'C$id',
          imgUrl: 'u$id',
          comicNewid: 'n$id',
          addedAt: id,
        );

    test('toggleFavorite adds then removes and isFavorite reflects it', () async {
      final store = ManhuataiLibraryStore();
      expect(await store.isFavorite(1), isFalse);
      expect(await store.toggleFavorite(favorite(1)), isTrue);
      expect(await store.isFavorite(1), isTrue);
      expect((await store.favorites()).single.comicName, 'C1');
      expect(await store.toggleFavorite(favorite(1)), isFalse);
      expect(await store.favorites(), isEmpty);
    });

    test('favorites persist under the content.manhuatai key as JSON', () async {
      final store = ManhuataiLibraryStore();
      await store.toggleFavorite(favorite(7));
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(ManhuataiLibraryStore.favoritesKey);
      expect(raw, isNotNull);
      expect(raw, contains('"comic_id":7'));
      expect(raw, contains('"comic_name":"C7"'));
    });

    test('remember moves one comic to the front without duplicating it', () async {
      final store = ManhuataiLibraryStore();
      await store.remember(
        ManhuataiReadRecord(
          comicId: 1,
          comicName: 'A',
          chapterTopicId: 11,
          chapterName: '第1话',
          chapterPage: 0,
          readAt: 1,
        ),
      );
      await store.remember(
        ManhuataiReadRecord(
          comicId: 2,
          comicName: 'B',
          chapterTopicId: 22,
          chapterName: '第2话',
          chapterPage: 0,
          readAt: 2,
        ),
      );
      await store.remember(
        ManhuataiReadRecord(
          comicId: 1,
          comicName: 'A',
          chapterTopicId: 12,
          chapterName: '第3话',
          chapterPage: 1,
          readAt: 3,
        ),
      );
      final history = await store.history();
      expect(history, hasLength(2));
      expect(history.first.comicId, 1);
      expect(history.first.chapterName, '第3话');
      expect(history.last.comicId, 2);
    });

    test('history caps at historyLimit, keeping the newest', () async {
      final store = ManhuataiLibraryStore();
      for (var i = 1; i <= ManhuataiLibraryStore.historyLimit + 5; i++) {
        await store.remember(
          ManhuataiReadRecord(
            comicId: i,
            comicName: 'C$i',
            chapterTopicId: i,
            chapterName: 'ch$i',
            chapterPage: 0,
            readAt: i,
          ),
        );
      }
      final history = await store.history();
      expect(history, hasLength(ManhuataiLibraryStore.historyLimit));
      expect(history.first.comicId, ManhuataiLibraryStore.historyLimit + 5);
      expect(history.last.comicId, 6);
    });

    test('removeHistory and clearHistory drop entries', () async {
      final store = ManhuataiLibraryStore();
      await store.remember(
        ManhuataiReadRecord(
          comicId: 1,
          comicName: 'A',
          chapterTopicId: 1,
          chapterName: 'c',
          chapterPage: 0,
          readAt: 1,
        ),
      );
      await store.removeHistory(1);
      expect(await store.history(), isEmpty);
      await store.remember(
        ManhuataiReadRecord(
          comicId: 2,
          comicName: 'B',
          chapterTopicId: 2,
          chapterName: 'c',
          chapterPage: 0,
          readAt: 2,
        ),
      );
      await store.clearHistory();
      expect(await store.history(), isEmpty);
    });

    test('search history de-duplicates, caps and clears', () async {
      final store = ManhuataiLibraryStore();
      for (var i = 1; i <= ManhuataiLibraryStore.searchHistoryLimit + 3; i++) {
        await store.rememberSearch('k$i');
      }
      var history = await store.searchHistory();
      expect(history, hasLength(ManhuataiLibraryStore.searchHistoryLimit));
      expect(history.first, 'k23');

      await store.rememberSearch('k5');
      history = await store.searchHistory();
      expect(history.first, 'k5');
      expect(history.where((item) => item == 'k5'), hasLength(1));

      await store.clearSearchHistory();
      expect(await store.searchHistory(), isEmpty);
    });

    test('a corrupt persisted payload degrades to an empty list', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        ManhuataiLibraryStore.favoritesKey: '[{not json',
      });
      final store = ManhuataiLibraryStore();
      expect(await store.favorites(), isEmpty);
    });
  });
}
