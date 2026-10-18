// 今日看片（appapi.php CMS）模块测试。全部离线：Dio 用拦截器直接 resolve，
// 不会发出任何真实请求。
//
// 夹具来源：字段名逐个来自源站解析器
// （FlutterMovies `lib/model/movie_detail.dart`、`lib/model/movie_category_detail.dart`），
// 信封 `{code,msg,page,pagecount,limit,total,list}` 来自 MacCMS v10 / appapi.php。
// 数据值是构造的，没有联网抓过真实响应；因此只断言解析结果，不断言线上取到什么。
import 'dart:convert';

import 'package:dashboard/features/media/media_playback_page.dart';
import 'package:dashboard/features/movie/fluttermovies/fluttermovies_api.dart';
import 'package:dashboard/features/movie/fluttermovies/fluttermovies_category.dart';
import 'package:dashboard/features/movie/fluttermovies/fluttermovies_detail_page.dart';
import 'package:dashboard/features/movie/fluttermovies/fluttermovies_exception.dart';
import 'package:dashboard/features/movie/fluttermovies/fluttermovies_list_item.dart';
import 'package:dashboard/features/movie/fluttermovies/fluttermovies_list_result.dart';
import 'package:dashboard/features/movie/fluttermovies/fluttermovies_page.dart';
import 'package:dashboard/features/movie/fluttermovies/fluttermovies_paged_list.dart';
import 'package:dashboard/features/movie/fluttermovies/fluttermovies_play_episode.dart';
import 'package:dashboard/features/movie/fluttermovies/fluttermovies_play_source.dart';
import 'package:dashboard/features/movie/fluttermovies/fluttermovies_play_source_selector.dart';
import 'package:dashboard/features/movie/fluttermovies/fluttermovies_stream_sources.dart';
import 'package:dashboard/features/movie/fluttermovies/fluttermovies_video_detail.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// `ac=detail` 列表信封，page 1/5，共 48 条。
const String listResponseJson = '''
{
  "code": 1,
  "msg": "数据列表",
  "page": 1,
  "pagecount": 5,
  "limit": "10",
  "total": 48,
  "list": [
    {
      "vod_id": 1001,
      "type_id": 6,
      "type_id_1": 1,
      "group_id": 1,
      "vod_name": "流浪地球2",
      "vod_sub": "The Wandering Earth II",
      "vod_en": "liulangdiqiu2",
      "vod_status": 1,
      "vod_letter": "L",
      "vod_color": "",
      "vod_tag": "科幻,灾难",
      "vod_class": "科幻片",
      "vod_pic": "/upload/vod/20230122-1/8f2a1c.jpg",
      "vod_pic_thumb": "",
      "vod_pic_slide": "/upload/vod/20230122-1/8f2a1c_slide.jpg",
      "vod_actor": "吴京,刘德华,李雪健",
      "vod_director": "郭帆",
      "vod_writer": "龚格尔",
      "vod_blurb": "太阳危机即将来袭，人类开启移山计划。",
      "vod_remarks": "正片",
      "vod_pubdate": "2023-01-22",
      "vod_total": 1,
      "vod_serial": "1",
      "vod_area": "中国大陆",
      "vod_lang": "国语",
      "vod_year": "2023",
      "vod_version": "正片",
      "vod_state": "0",
      "vod_author": "admin",
      "vod_level": 9,
      "vod_hits": 120345,
      "vod_hits_day": 302,
      "vod_hits_week": 2456,
      "vod_hits_month": 20456,
      "vod_duration": "173",
      "vod_up": 1200,
      "vod_down": 30,
      "vod_score": "8.3",
      "vod_score_all": 830,
      "vod_score_num": "100",
      "vod_douban_score": "8.3",
      "vod_time": 1729000000,
      "vod_content": "<p>太阳危机即将来袭。</p>"
    },
    {
      "vod_id": 1002,
      "type_id": 13,
      "type_id_1": 2,
      "group_id": 0,
      "vod_name": "庆余年第二季",
      "vod_remarks": "更新至第21集",
      "vod_pic": "",
      "vod_pic_slide": "/upload/vod/20240516-1/qyn2.jpg",
      "vod_year": "2024",
      "vod_area": "中国大陆",
      "vod_class": "国产剧",
      "vod_score": "0",
      "vod_total": 36,
      "vod_serial": "21",
      "vod_time": 1729500000
    }
  ]
}
''';

/// `ac=detail&ids=1001` 详情信封，第 1 条含 5 条线路。
const String detailResponseJson = '''
{
  "code": 1,
  "msg": "数据列表",
  "page": 1,
  "pagecount": 1,
  "limit": "1",
  "total": 1,
  "list": [
    {
      "vod_id": 1001,
      "type_id": 6,
      "type_id_1": 1,
      "vod_name": "流浪地球2",
      "vod_pic": "/upload/vod/20230122-1/8f2a1c.jpg",
      "vod_pic_slide": "/upload/vod/20230122-1/8f2a1c_slide.jpg",
      "vod_year": "2023",
      "vod_area": "中国大陆",
      "vod_class": "科幻片",
      "vod_remarks": "正片",
      "vod_score": "8.3",
      "vod_douban_score": "8.3",
      "vod_actor": "吴京,刘德华,李雪健",
      "vod_director": "郭帆",
      "vod_blurb": "太阳危机即将来袭，人类开启移山计划。",
      "vod_content": "<p>太阳危机即将来袭。</p>",
      "vod_play_from": "lzm3u8\$\$\$bfzym3u8\$\$\$ckm3u8\$\$\$dbm3u8\$\$\$wjm3u8",
      "vod_play_server": "lz\$\$\$bf\$\$\$ck\$\$\$db\$\$\$wj",
      "vod_play_note": "",
      "vod_play_url": "",
      "vod_play_list": [
        {
          "sid": 1,
          "from": "lzm3u8",
          "server": "lz",
          "note": "量子资源",
          "url": "",
          "url_count": 4,
          "player_info": {
            "status": "ok",
            "copyright_url": "",
            "from": "lzm3u8",
            "show": "量子资源",
            "des": "",
            "target": "",
            "ps": "1",
            "parse": "https://jx.example.com/?url=",
            "sort": "1",
            "tip": "",
            "id": "1"
          },
          "urls": [
            {"name": "第01集", "url": "https://v.jinrikanpian.net/20230122/8f2a1c/index.m3u8", "from": "lzm3u8", "nid": 1},
            {"name": "第02集", "url": "https://v.jinrikanpian.net/20230122/8f2a1c/1000.m3u8", "from": "lzm3u8", "nid": 2},
            {"name": "第03集-高清", "url": "https://v.jinrikanpian.net/20230122/8f2a1c/2000.m3u8", "from": "lzm3u8", "nid": 3},
            {"name": "第04集", "url": "javascript:void(0);", "from": "lzm3u8", "nid": 4}
          ]
        },
        {
          "sid": 2,
          "from": "bfzym3u8",
          "server": "bf",
          "note": "暴风资源",
          "url_count": 2,
          "player_info": {"status": "ok", "from": "bfzym3u8", "show": "暴风资源", "ps": "1", "sort": "2", "id": "2"},
          "urls": [
            {"name": "第01集", "url": "https://bf.example.com/8f2a1c/1.m3u8", "from": "bfzym3u8", "nid": 1},
            {"name": "第02集", "url": "https://bf.example.com/8f2a1c/2.m3u8", "from": "bfzym3u8", "nid": 2}
          ]
        },
        {
          "sid": 3,
          "from": "ckm3u8",
          "server": "ck",
          "note": "CK资源",
          "url_count": 5,
          "player_info": {"status": "ok", "from": "ckm3u8", "show": "CK资源", "ps": "1", "sort": "3", "id": "3"},
          "urls": [
            {"name": "第01集", "url": "https://ck.example.com/1.m3u8", "from": "ckm3u8", "nid": 1},
            {"name": "第02集", "url": "https://ck.example.com/2.m3u8", "from": "ckm3u8", "nid": 2},
            {"name": "第03集", "url": "https://ck.example.com/3.m3u8", "from": "ckm3u8", "nid": 3},
            {"name": "第04集", "url": "https://ck.example.com/4.m3u8", "from": "ckm3u8", "nid": 4},
            {"name": "第05集", "url": "https://ck.example.com/5.m3u8", "from": "ckm3u8", "nid": 5}
          ]
        },
        {
          "sid": 4,
          "from": "dbm3u8",
          "server": "db",
          "note": "豆瓣资源",
          "url_count": 4,
          "player_info": {"status": "ok", "from": "dbm3u8", "show": "豆瓣资源", "ps": "1", "sort": "4", "id": "4"},
          "urls": [
            {"name": "第01集", "url": "https://db.example.com/1.m3u8", "from": "dbm3u8", "nid": 1},
            {"name": "第02集", "url": "https://db.example.com/2.m3u8", "from": "dbm3u8", "nid": 2},
            {"name": "第03集", "url": "https://db.example.com/3.m3u8", "from": "dbm3u8", "nid": 3},
            {"name": "第04集", "url": "https://db.example.com/4.m3u8", "from": "dbm3u8", "nid": 4}
          ]
        },
        {
          "sid": 5,
          "from": "wjm3u8",
          "server": "wj",
          "note": "无地址",
          "url_count": 0,
          "player_info": {"status": "ok", "from": "wjm3u8", "show": "无地址线路", "ps": "1", "sort": "5", "id": "5"},
          "urls": []
        }
      ]
    }
  ]
}
''';

/// `getPcategory?pt=0` 的父类列表。
const String parentCategoryJson = '''
{
  "code": 1,
  "msg": "数据列表",
  "list": [
    {
      "type_id": 1,
      "type_name": "电影",
      "type_en": "dianying",
      "type_sort": 1,
      "type_mid": 1,
      "type_pid": 0,
      "type_status": 1,
      "type_logo": "",
      "type_pic": "",
      "type_key": "",
      "type_des": "电影分类",
      "type_title": "电影",
      "type_union": "",
      "type_jumpurl": "",
      "type_extend": {"class": "喜剧,爱情", "area": "大陆,香港", "lang": "国语,粤语", "year": "2024,2023", "star": "", "director": "", "state": "", "version": "正片"}
    },
    {"type_id": 2, "type_name": "电视剧", "type_en": "dianshiju", "type_sort": 2, "type_mid": 1, "type_pid": 0, "type_status": 1, "type_extend": {}},
    {"type_id": 3, "type_name": "综艺", "type_en": "zongyi", "type_sort": 3, "type_mid": 1, "type_pid": 0, "type_status": 1, "type_extend": {}},
    {"type_id": 4, "type_name": "动漫", "type_en": "dongman", "type_sort": 4, "type_mid": 1, "type_pid": 0, "type_status": 1, "type_extend": {}}
  ]
}
''';

/// `getSubcategoryByPcategory?pt=1` 的子类列表。
const String subCategoryJson = '''
{
  "code": 1,
  "msg": "数据列表",
  "list": [
    {"type_id": 6, "type_name": "科幻片", "type_en": "kehuanpian", "type_sort": 1, "type_mid": 1, "type_pid": 1, "type_status": 1, "type_extend": {}},
    {"type_id": 7, "type_name": "动作片", "type_en": "dongzuopian", "type_sort": 2, "type_mid": 1, "type_pid": 1, "type_status": 1, "type_extend": {}}
  ]
}
''';

Map<String, dynamic> _decode(String source) =>
    jsonDecode(source) as Map<String, dynamic>;

Response<dynamic> _ok(Object data, RequestOptions options) =>
    Response<dynamic>(requestOptions: options, statusCode: 200, data: data);

/// 拦截器直接 resolve，请求不会真的发出去。
Dio _fakeDio(Response<dynamic> Function(RequestOptions options) respond) {
  final dio = Dio(BaseOptions(baseUrl: FlutterMoviesApi.defaultWebUrl));
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) => handler.resolve(respond(options)),
    ),
  );
  return dio;
}

Dio _rejectingDio(DioExceptionType type) {
  final dio = Dio(BaseOptions(baseUrl: FlutterMoviesApi.defaultWebUrl));
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) => handler.reject(
        DioException(
          requestOptions: options,
          type: type,
          message: 'simulated $type',
        ),
      ),
    ),
  );
  return dio;
}

/// 记录请求并返回固定响应。
({FlutterMoviesApi api, List<RequestOptions> seen}) _recordingApi(Object data) {
  final seen = <RequestOptions>[];
  final api = FlutterMoviesApi(
    dio: _fakeDio((options) {
      seen.add(options);
      return _ok(data, options);
    }),
  );
  return (api: api, seen: seen);
}

void main() {
  group('模型映射（真实形状的 CMS JSON）', () {
    test('列表信封与列表项字段', () {
      final result = FlutterMoviesListResult.fromJson(_decode(listResponseJson));

      expect(result.items, hasLength(2));
      expect(result.page, 1);
      expect(result.pageCount, 5);
      expect(result.total, 48);
      // limit 在 CMS 里是字符串 "10"
      expect(result.limit, 10);
      expect(result.message, '数据列表');
      expect(result.isEmpty, isFalse);
      expect(result.hasMore, isTrue);
    });

    test('幻灯片 / 列表项：图片、评分、时间取值', () {
      final FlutterMoviesListItem banner = FlutterMoviesListResult.fromJson(
        _decode(listResponseJson),
      ).items.first;
      expect(banner.vodId, 1001);
      expect(banner.typeId, 6);
      expect(banner.typeId1, 1);
      expect(banner.groupId, 1);
      expect(banner.title, '流浪地球2');
      expect(banner.vodSub, 'The Wandering Earth II');
      expect(banner.vodEn, 'liulangdiqiu2');
      expect(banner.vodClass, '科幻片');
      expect(banner.vodTag, '科幻,灾难');
      expect(banner.vodActor, '吴京,刘德华,李雪健');
      expect(banner.vodDirector, '郭帆');
      expect(banner.vodRemarks, '正片');
      expect(banner.vodArea, '中国大陆');
      expect(banner.vodLang, '国语');
      expect(banner.vodYear, '2023');
      expect(banner.vodDuration, '173');
      expect(banner.vodHits, 120345);
      expect(banner.vodHitsMonth, 20456);
      expect(banner.vodScore, '8.3');
      expect(banner.vodDoubanScore, '8.3');
      expect(banner.vodLevel, 9);
      expect(banner.vodTime, 1729000000);
      // 幻灯片用横版图，列表用竖版图
      expect(banner.primaryImage, '/upload/vod/20230122-1/8f2a1c_slide.jpg');
      expect(banner.listImage, '/upload/vod/20230122-1/8f2a1c.jpg');
      expect(banner.scoreLabel, '8.3');
      expect(banner.yearLabel, '2023');
      expect(
        banner.updatedAt,
        DateTime.fromMillisecondsSinceEpoch(1729000000 * 1000),
      );

      final second = FlutterMoviesListResult.fromJson(
        _decode(listResponseJson),
      ).items[1];
      // vod_pic 为空时退回 vod_pic_slide
      expect(second.listImage, '/upload/vod/20240516-1/qyn2.jpg');
      expect(second.vodPic, '');
      expect(second.scoreLabel, '');
      expect(second.updatedAt, isNotNull);
    });

    test('分类：父类与子类', () {
      final parents = FlutterMoviesListResult.fromJson(
        _decode(parentCategoryJson),
      );
      // 分类列表没有分页信封
      expect(parents.pageCount, 0);
      expect(parents.hasMore, isFalse);

      final list = (_decode(parentCategoryJson)['list'] as List)
          .map((row) => FlutterMoviesCategory.fromJson(row as Map<String, dynamic>))
          .toList();
      expect(list, hasLength(4));
      expect(list.map((c) => c.typeName).toList(), ['电影', '电视剧', '综艺', '动漫']);
      expect(list.first.typeId, 1);
      expect(list.first.typeEn, 'dianying');
      expect(list.first.typePid, 0);
      expect(list.first.isParent, isTrue);
      expect(list.first.typeDes, '电影分类');
      expect(list.first.extend.extendClass, '喜剧,爱情');
      expect(list.first.extend.extendYear, '2024,2023');
      expect(list.first.extend.extendVersion, '正片');

      final children = (_decode(subCategoryJson)['list'] as List)
          .map((row) => FlutterMoviesCategory.fromJson(row as Map<String, dynamic>))
          .toList();
      expect(children.map((c) => c.typeId).toList(), [6, 7]);
      expect(children.first.typePid, 1);
      expect(children.first.isParent, isFalse);
    });

    test(r'详情：简介、$$$ 线路名与播放线路映射', () {
      final detail = FlutterMoviesVideoDetail.fromJson(
        _decode(detailResponseJson)['list'][0] as Map<String, dynamic>,
      );

      expect(detail.id, 1001);
      expect(detail.title, '流浪地球2');
      expect(detail.introduction, '<p>太阳危机即将来袭。</p>');
      expect(detail.playFromNames, [
        'lzm3u8',
        'bfzym3u8',
        'ckm3u8',
        'dbm3u8',
        'wjm3u8',
      ]);
      expect(detail.playServerNames, ['lz', 'bf', 'ck', 'db', 'wj']);
      expect(detail.playSources, hasLength(5));
      expect(detail.downSources, isEmpty);

      final quantum = detail.playSources.first;
      expect(quantum.sid, 1);
      expect(quantum.from, 'lzm3u8');
      expect(quantum.server, 'lz');
      expect(quantum.note, '量子资源');
      expect(quantum.urlCount, 4);
      expect(quantum.player.show, '量子资源');
      expect(quantum.player.parse, 'https://jx.example.com/?url=');
      expect(quantum.player.id, '1');
      // Tab 文案取 player_info.show
      expect(quantum.label, '量子资源');
      expect(quantum.episodeCount, 4);
      expect(quantum.isPlayable, isTrue);
      expect(quantum.episodes.map((e) => e.name).toList(), [
        '第01集',
        '第02集',
        '第03集-高清',
        '第04集',
      ]);
      expect(quantum.episodes.first.from, 'lzm3u8');
      expect(quantum.episodes.first.nid, 1);
      expect(
        quantum.episodes.first.uri,
        Uri.parse('https://v.jinrikanpian.net/20230122/8f2a1c/index.m3u8'),
      );
    });

    test('分集：文案清理、地址校验（源站 replaceAll - 与 期）', () {
      final detail = FlutterMoviesVideoDetail.fromJson(
        _decode(detailResponseJson)['list'][0] as Map<String, dynamic>,
      );
      final episodes = detail.playSources.first.episodes;

      expect(episodes[2].name, '第03集-高清');
      expect(episodes[2].label, '第03集高清');
      expect(episodes[0].label, '第01集');
      expect(episodes[2].isPlayable, isTrue);

      // javascript: 地址不可播，避免真的把伪协议塞给 media_kit
      expect(episodes[3].url, 'javascript:void(0);');
      expect(episodes[3].uri, isNull);
      expect(episodes[3].isPlayable, isFalse);

      const http = FlutterMoviesPlayEpisode(
        name: '第05期',
        url: 'http://cdn.example.com/5.m3u8',
      );
      expect(http.label, '第05');
      expect(http.isPlayable, isTrue);

      const noScheme = FlutterMoviesPlayEpisode(
        name: '第06集',
        url: 'v.example.com/6.m3u8',
      );
      expect(noScheme.uri, isNull);
    });

    test('线路 label / episodeCount 的兜底', () {
      const noShow = FlutterMoviesPlaySource(from: 'lzm3u8', server: 'lz');
      expect(noShow.label, 'lzm3u8');
      const onlyServer = FlutterMoviesPlaySource(server: 'lz');
      expect(onlyServer.label, 'lz');
      const neither = FlutterMoviesPlaySource();
      expect(neither.label, '线路');
      // 没有 urls[] 时退回 url_count
      const counted = FlutterMoviesPlaySource(urlCount: 24);
      expect(counted.episodeCount, 24);
      expect(counted.isPlayable, isFalse);
    });
  });

  group('请求构建（路径 + 真实参数名）', () {
    test('分类分页：t / pg / pagesize=10 / order=vod_level', () async {
      final recording = _recordingApi(_decode(listResponseJson));
      addTearDown(recording.api.dispose);

      await recording.api.categoryMovies(t: 6, pg: 2);

      final options = recording.seen.single;
      expect(options.method, 'GET');
      expect(options.uri.path, '/appapi.php/api/vod/');
      // 源站把 8 个键全发出去，null 由 dio 编码成「裸键」
      expect(options.uri.query, 'ac=detail&pt&t=6&pg=2&wd&h&pagesize=10&leve&order=vod_level');
      expect(options.queryParameters, {
        'ac': 'detail',
        'pt': null,
        't': 6,
        'pg': 2,
        'wd': null,
        'h': null,
        'pagesize': 10,
        'leve': null,
        'order': 'vod_level',
      });
    });

    test('分类第一页默认参数', () async {
      final recording = _recordingApi(_decode(listResponseJson));
      addTearDown(recording.api.dispose);

      await recording.api.categoryMovies(t: 1);

      expect(
        recording.seen.single.uri.query,
        'ac=detail&pt&t=1&pg=1&wd&h&pagesize=10&leve&order=vod_level',
      );
    });

    test('搜索：wd + order=vod_time，关键词两端空白被去掉', () async {
      final recording = _recordingApi(_decode(listResponseJson));
      addTearDown(recording.api.dispose);

      await recording.api.search('  流浪地球  ', pg: 3);

      final options = recording.seen.single;
      expect(options.uri.path, '/appapi.php/api/vod/');
      expect(
        options.uri.query,
        'ac=detail&pt&t&pg=3&wd=%E6%B5%81%E6%B5%AA%E5%9C%B0%E7%90%83&h&pagesize=10&leve&order=vod_time',
      );
      expect(options.queryParameters['wd'], '流浪地球');
      expect(options.queryParameters['pg'], 3);
      expect(options.queryParameters['order'], 'vod_time');
    });

    test('搜索结果直接映射为列表项', () async {
      final recording = _recordingApi(_decode(listResponseJson));
      addTearDown(recording.api.dispose);

      final result = await recording.api.search('流浪地球');

      expect(result.items, hasLength(2));
      expect(result.items.first.vodName, '流浪地球2');
      expect(result.items.first.vodId, 1001);
      expect(result.items.last.vodId, 1002);
    });

    test('排行榜：pt + pagesize=20 + order=vod_hits_month', () async {
      final recording = _recordingApi(_decode(listResponseJson));
      addTearDown(recording.api.dispose);

      await recording.api.ranking(pt: 2, pg: 4);

      expect(
        recording.seen.single.uri.query,
        'ac=detail&pt=2&t&pg=4&wd&h&pagesize=20&leve&order=vod_hits_month',
      );
    });

    test('首页幻灯片 leve=9 / 5 条，网格 leve=8 / 6 条', () async {
      final recording = _recordingApi(_decode(listResponseJson));
      addTearDown(recording.api.dispose);

      await recording.api.homeSliders();
      await recording.api.homeGridByParent(3);

      expect(
        recording.seen[0].uri.query,
        'ac=detail&pt&t&pg&wd&h&pagesize=5&leve=9&order',
      );
      expect(
        recording.seen[1].uri.query,
        'ac=detail&pt=3&t&pg&wd&h&pagesize=6&leve=8&order',
      );
    });

    test('最近更新使用 h 参数', () async {
      final recording = _recordingApi(_decode(listResponseJson));
      addTearDown(recording.api.dispose);

      await recording.api.updates(hours: 12, pg: 2);

      expect(
        recording.seen.single.uri.query,
        'ac=detail&pt&t&pg=2&wd&h=12&pagesize=10&leve&order=vod_time',
      );
    });

    test('详情：ac=detail&ids=<id>，取 list[0]', () async {
      final recording = _recordingApi(_decode(detailResponseJson));
      addTearDown(recording.api.dispose);

      final detail = await recording.api.videoDetail(1001);

      expect(recording.seen.single.uri.path, '/appapi.php/api/vod/');
      expect(recording.seen.single.uri.query, 'ac=detail&ids=1001');
      expect(detail.title, '流浪地球2');
      expect(detail.playSources, hasLength(5));
    });

    test('分类接口：getPcategory?pt=0 / getSubcategoryByPcategory / vodCategoryAll', () async {
      final parents = _recordingApi(_decode(parentCategoryJson));
      final children = _recordingApi(_decode(subCategoryJson));
      addTearDown(parents.api.dispose);
      addTearDown(children.api.dispose);

      final parentList = await parents.api.parentCategories();
      final childList = await children.api.subcategories(1);
      final all = await children.api.allCategories();

      expect(parents.seen.single.uri.path, '/appapi.php/api/getPcategory');
      expect(parents.seen.single.uri.query, 'pt=0');
      expect(childList.map((c) => c.typeName).toList(), ['科幻片', '动作片']);
      expect(children.seen[0].uri.path, '/appapi.php/api/getSubcategoryByPcategory');
      expect(children.seen[0].uri.query, 'pt=1');
      expect(children.seen[1].uri.path, '/appapi.php/api/vodCategoryAll');
      expect(children.seen[1].uri.query, isEmpty);
      // vodCategoryAll 的夹具是子类形状，仍应解析为分类
      expect(all.map((c) => c.typeId).toList(), [6, 7]);
      expect(parentList.first.isParent, isTrue);
    });

    test('vodQuery 静态构造：键顺序与源站一致', () {
      expect(FlutterMoviesApi.vodQuery(t: 1, pg: 1).keys.toList(), [
        'ac',
        'pt',
        't',
        'pg',
        'wd',
        'h',
        'pagesize',
        'leve',
        'order',
      ]);
    });
  });

  group('选线：默认线路与切换', () {
    FlutterMoviesVideoDetail detail() => FlutterMoviesVideoDetail.fromJson(
      _decode(detailResponseJson)['list'][0] as Map<String, dynamic>,
    );

    test('默认线路 = 分集最多的非 ckm3u8 线路', () {
      final sources = detail().playSources;
      expect(sources, hasLength(5));

      final ordered = FlutterMoviesPlaySourceSelector.select(sources);
      expect(ordered.map((s) => s.from).toList(), [
        'lzm3u8', // 4 集
        'dbm3u8', // 4 集（同集数时保持原顺序）
        'bfzym3u8', // 2 集
        'wjm3u8', // 0 集
      ]);
      expect(
        ordered.map((s) => s.from).contains('ckm3u8'),
        isFalse,
        reason: '源站明确过滤 from == ckm3u8',
      );

      expect(FlutterMoviesPlaySourceSelector.defaultSource(sources)?.from, 'lzm3u8');
      expect(FlutterMoviesPlaySourceSelector.defaultIndex(sources), 0);
    });

    test('可播线路列表会再剔除没有地址的线路', () {
      final playable = FlutterMoviesPlaySourceSelector.playable(
        detail().playSources,
      );
      expect(playable.map((s) => s.from).toList(), ['lzm3u8', 'dbm3u8', 'bfzym3u8']);
      expect(playable.first.episodes.first.url, contains('v.jinrikanpian.net'));
    });

    test('用户切换线路：下一条线路播放它自己的地址', () async {
      final sources = FlutterMoviesPlaySourceSelector.select(
        detail().playSources,
      );

      // 首页默认线路
      var current = 0;
      expect(FlutterMoviesPlaySourceSelector.defaultIndex(sources), current);
      expect(sources[current].player.show, '量子资源');
      expect(
        FlutterMoviesStreamSources.of(sources[current]).first.url.toString(),
        'https://v.jinrikanpian.net/20230122/8f2a1c/index.m3u8',
      );

      // 用户点第二条线路
      current = 1;
      expect(sources[current].from, 'dbm3u8');
      expect(sources[current].label, '豆瓣资源');
      expect(sources[current].episodes, hasLength(4));
      expect(
        FlutterMoviesStreamSources.of(sources[current]).first.url.toString(),
        'https://db.example.com/1.m3u8',
      );

      // 第三条
      current = 2;
      expect(sources[current].from, 'bfzym3u8');
      expect(sources[current].player.show, '暴风资源');
      expect(
        FlutterMoviesStreamSources.of(sources[current]).last.url.toString(),
        'https://bf.example.com/8f2a1c/2.m3u8',
      );
    });

    test('转为 media_kit 播放源：过滤伪协议、保留清理后的分集名', () {
      final quantum = FlutterMoviesPlaySourceSelector.defaultSource(
        detail().playSources,
      )!;
      final streams = FlutterMoviesStreamSources.of(quantum);

      // 4 条分集里有 1 条 javascript:，被过滤
      expect(streams, hasLength(3));
      expect(streams.map((s) => s.label).toList(), [
        '第01集',
        '第02集',
        '第03集高清',
      ]);
      expect(
        streams[2].url,
        Uri.parse('https://v.jinrikanpian.net/20230122/8f2a1c/2000.m3u8'),
      );
      expect(streams.first.headers, isEmpty);

      const noAddress = FlutterMoviesPlaySource(from: 'wjm3u8');
      expect(FlutterMoviesStreamSources.of(noAddress), isEmpty);

      final single = FlutterMoviesStreamSources.single(
        quantum.episodes.first,
      );
      expect(single, hasLength(1));
      expect(
        FlutterMoviesStreamSources.single(quantum.episodes[3]),
        isEmpty,
      );
    });

    test('空线路列表：默认线路为 null，不抛异常', () {
      expect(FlutterMoviesPlaySourceSelector.select(const []), isEmpty);
      expect(FlutterMoviesPlaySourceSelector.defaultSource(const []), isNull);
      expect(FlutterMoviesPlaySourceSelector.playable(const []), isEmpty);
    });

    test('全部是 ckm3u8 时结果为空', () {
      const only = <FlutterMoviesPlaySource>[
        FlutterMoviesPlaySource(from: 'ckm3u8', urlCount: 5),
      ];
      expect(FlutterMoviesPlaySourceSelector.select(only), isEmpty);
      expect(FlutterMoviesPlaySourceSelector.defaultSource(only), isNull);
    });
  });

  group('无签名 / 无加解密：请求与源站逐键一致', () {
    test('查询参数只有源站声明的键，没有 sign / token / apikey', () async {
      final recording = _recordingApi(_decode(listResponseJson));
      addTearDown(recording.api.dispose);

      await recording.api.categoryMovies(t: 6, pg: 2);
      await recording.api.ranking(pt: 1);
      await recording.api.homeSliders();
      await recording.api.videoDetail(1001);

      // 详情接口的 ids 也是源站参数
      const sourceKeys = {
        'ac',
        'ids',
        'pt',
        't',
        'pg',
        'wd',
        'h',
        'pagesize',
        'leve',
        'order',
      };
      for (final options in recording.seen) {
        expect(
          options.queryParameters.keys.toSet().difference(sourceKeys),
          isEmpty,
          reason: '${options.uri} 出现了源站没有的参数',
        );
      }
      // 详情接口只有 ac / ids
      expect(recording.seen.last.queryParameters.keys.toSet(), {'ac', 'ids'});
      // 没有任何签名头
      expect(recording.seen.every((o) => o.headers.isEmpty), isTrue);
    });

    test('参数值不被改动、也不额外加密', () {
      final query = FlutterMoviesApi.vodQuery(
        pt: 1,
        t: 6,
        pg: 2,
        wd: '流浪地球',
        h: 24,
        pagesize: 20,
        leve: 8,
        order: 'vod_time',
      );
      expect(query, {
        'ac': 'detail',
        'pt': 1,
        't': 6,
        'pg': 2,
        'wd': '流浪地球',
        'h': 24,
        'pagesize': 20,
        'leve': 8,
        'order': 'vod_time',
      });
    });
  });

  group('错误与空态', () {
    test('code != 1：抛出 CMS 的 msg', () async {
      final api = FlutterMoviesApi(
        dio: _fakeDio(
          (options) => _ok({'code': 0, 'msg': '影片不存在'}, options),
        ),
      );
      addTearDown(api.dispose);

      await expectLater(
        api.videoDetail(999),
        throwsA(
          isA<FlutterMoviesException>().having(
            (e) => e.message,
            'message',
            '影片不存在',
          ),
        ),
      );
    });

    test('code != 1 且没有 msg：给出带 code 的兜底消息', () async {
      final api = FlutterMoviesApi(
        dio: _fakeDio((options) => _ok({'code': 2, 'msg': ''}, options)),
      );
      addTearDown(api.dispose);

      await expectLater(
        api.categoryMovies(t: 1),
        throwsA(
          isA<FlutterMoviesException>().having(
            (e) => e.message,
            'message',
            '影视频道返回错误（code=2）',
          ),
        ),
      );
    });

    test('列表信封缺少 list：格式错误', () async {
      final api = FlutterMoviesApi(
        dio: _fakeDio((options) => _ok({'code': 1, 'msg': ''}, options)),
      );
      addTearDown(api.dispose);

      await expectLater(
        api.categoryMovies(t: 1),
        throwsA(
          isA<FlutterMoviesException>().having(
            (e) => e.message,
            'message',
            '影视频道列表数据格式无法解析',
          ),
        ),
      );
    });

    test('详情 list 为空：影片详情不存在', () async {
      final api = FlutterMoviesApi(
        dio: _fakeDio(
          (options) => _ok({'code': 1, 'msg': '数据列表', 'list': []}, options),
        ),
      );
      addTearDown(api.dispose);

      await expectLater(
        api.videoDetail(1001),
        throwsA(
          isA<FlutterMoviesException>().having(
            (e) => e.message,
            'message',
            '影片详情不存在',
          ),
        ),
      );
    });

    test('返回非 JSON 对象：格式无法解析', () async {
      final api = FlutterMoviesApi(
        dio: _fakeDio((options) => _ok('<html>502</html>', options)),
      );
      addTearDown(api.dispose);

      await expectLater(
        api.parentCategories(),
        throwsA(
          isA<FlutterMoviesException>().having(
            (e) => e.message,
            'message',
            '影视频道返回的数据格式无法解析',
          ),
        ),
      );
    });

    test('HTTP 500 且不是 JSON：带状态码的失败消息', () async {
      final api = FlutterMoviesApi(
        dio: _fakeDio(
          (options) => Response<dynamic>(
            requestOptions: options,
            statusCode: 500,
            data: '<html>502</html>',
          ),
        ),
      );
      addTearDown(api.dispose);

      await expectLater(
        api.parentCategories(),
        throwsA(
          isA<FlutterMoviesException>()
              .having((e) => e.message, 'message', '请求失败：HTTP 500')
              .having((e) => e.statusCode, 'statusCode', 500),
        ),
      );
    });

    test('网络错误映射为中文提示', () async {
      final offline = FlutterMoviesApi(dio: _rejectingDio(DioExceptionType.connectionError));
      final timeout = FlutterMoviesApi(dio: _rejectingDio(DioExceptionType.receiveTimeout));
      final badResponse = FlutterMoviesApi(dio: _rejectingDio(DioExceptionType.badResponse));
      addTearDown(offline.dispose);
      addTearDown(timeout.dispose);
      addTearDown(badResponse.dispose);

      await expectLater(
        offline.categoryMovies(t: 1),
        throwsA(
          isA<FlutterMoviesException>().having(
            (e) => e.message,
            'message',
            '无法连接影视频道，请检查网络',
          ),
        ),
      );
      await expectLater(
        timeout.categoryMovies(t: 1),
        throwsA(
          isA<FlutterMoviesException>().having(
            (e) => e.message,
            'message',
            '影视频道连接超时',
          ),
        ),
      );
      await expectLater(
        badResponse.categoryMovies(t: 1),
        throwsA(
          isA<FlutterMoviesException>().having(
            (e) => e.message,
            'message',
            '影视频道请求失败',
          ),
        ),
      );
    });

    test('空关键词：直接参数错误，不发请求', () async {
      final recording = _recordingApi(_decode(listResponseJson));
      addTearDown(recording.api.dispose);

      expect(() => recording.api.search('   '), throwsArgumentError);
      expect(recording.seen, isEmpty);
    });

    test('空列表：items 为空且没有下一页', () {
      final result = FlutterMoviesListResult.fromJson(_decode('''
        {"code": 1, "msg": "数据列表", "page": 3, "pagecount": 3, "limit": "10", "total": 20, "list": []}
      '''));

      expect(result.isEmpty, isTrue);
      expect(result.hasMore, isFalse);
      expect(result.page, 3);
      expect(result.total, 20);
    });

    test('列表里混入非对象行：跳过而不是崩', () {
      final result = FlutterMoviesListResult.fromJson(_decode('''
        {"code": 1, "list": [{"vod_id": 1, "vod_name": "A"}, "oops", 42]}
      '''));

      expect(result.items, hasLength(1));
      expect(result.items.single.vodName, 'A');
    });
  });

  group('分页状态（FlutterMoviesPagedList）', () {
    test('第一页 → 第二页：追加而不是替换，末页后不再请求', () async {
      final requested = <int>[];
      final list = FlutterMoviesPagedList((page) async {
        requested.add(page);
        final json = _decode(listResponseJson);
        json['page'] = page;
        return FlutterMoviesListResult.fromJson(json);
      });

      await list.refresh();
      expect(list.page, 1);
      expect(list.items, hasLength(2));
      expect(list.pageCount, 5);
      expect(list.total, 48);
      expect(list.hasMore, isTrue);
      expect(list.isEmpty, isFalse);
      expect(list.loadedOnce, isTrue);
      expect(list.loading, isFalse);

      await list.loadMore();
      expect(requested, [1, 2]);
      expect(list.page, 2);
      // 追加（夹具每页 2 条）
      expect(list.items.map((item) => item.vodId).toList(), [
        1001,
        1002,
        1001,
        1002,
      ]);
    });

    test('最后一页之后 loadMore 不再发请求', () async {
      var calls = 0;
      final list = FlutterMoviesPagedList((page) async {
        calls++;
        return FlutterMoviesListResult.fromJson(_decode('''
          {"code": 1, "page": 1, "pagecount": 1, "total": 1, "list": [{"vod_id": 7, "vod_name": "X"}]}
        '''));
      });

      await list.refresh();
      expect(list.page, 1);
      expect(list.pageCount, 1);
      expect(list.hasMore, isFalse);

      await list.loadMore();
      expect(calls, 1);
      expect(list.items, hasLength(1));
    });

    test('空结果：isEmpty 为真，hasMore 为假', () async {
      final list = FlutterMoviesPagedList(
        (page) async => FlutterMoviesListResult.fromJson(
          _decode('{"code": 1, "page": 1, "pagecount": 0, "total": 0, "list": []}'),
        ),
      );

      await list.refresh();

      expect(list.isEmpty, isTrue);
      expect(list.items, isEmpty);
      expect(list.hasMore, isFalse);
      expect(list.error, isNull);
      expect(list.loadedOnce, isTrue);
    });

    test('刷新失败：记录错误并清空，重试后恢复', () async {
      var fail = true;
      final list = FlutterMoviesPagedList((page) async {
        if (fail) {
          throw const FlutterMoviesException('无法连接影视频道，请检查网络');
        }
        return FlutterMoviesListResult.fromJson(_decode(listResponseJson));
      });

      await list.refresh();
      expect(list.error, '无法连接影视频道，请检查网络');
      expect(list.items, isEmpty);
      expect(list.isEmpty, isFalse, reason: '有错误时展示错误态而不是空态');
      expect(list.page, 0);
      expect(list.pageCount, 0);
      expect(list.hasMore, isFalse);
      expect(list.loading, isFalse);

      fail = false;
      await list.refresh();
      expect(list.error, isNull);
      expect(list.items, hasLength(2));
      expect(list.page, 1);
      expect(list.isEmpty, isFalse);
    });

    test('非 FlutterMoviesException 的错误也转成消息', () async {
      final list = FlutterMoviesPagedList(
        (page) async => throw StateError('boom'),
      );

      await list.refresh();

      expect(list.error, contains('boom'));
      expect(list.items, isEmpty);
    });
  });

  group('图片地址补全', () {
    test('相对路径按站点补全，绝对地址原样保留', () {
      expect(
        FlutterMoviesApi.resolveImageUrl('/upload/vod/a.jpg'),
        'https://www.jinrikanpian.net/upload/vod/a.jpg',
      );
      expect(
        FlutterMoviesApi.resolveImageUrl('upload/vod/a.jpg'),
        'https://www.jinrikanpian.net/upload/vod/a.jpg',
      );
      expect(
        FlutterMoviesApi.resolveImageUrl('//cdn.example.com/a.jpg'),
        'https://cdn.example.com/a.jpg',
      );
      expect(
        FlutterMoviesApi.resolveImageUrl('https://img.example.com/a.jpg'),
        'https://img.example.com/a.jpg',
      );
      expect(
        FlutterMoviesApi.resolveImageUrl('http://img.example.com/a.jpg'),
        'http://img.example.com/a.jpg',
      );
      expect(FlutterMoviesApi.resolveImageUrl(''), isNull);
      expect(FlutterMoviesApi.resolveImageUrl(null), isNull);
      expect(FlutterMoviesApi.resolveImageUrl('   '), isNull);
    });

    test('实例方法使用注入的站点前缀', () {
      final api = FlutterMoviesApi(dio: _fakeDio((o) => _ok({}, o)));
      addTearDown(api.dispose);
      // 仅测试 URL 解析，不触发请求
      expect(
        FlutterMoviesApi.resolveImageUrl(
          '/upload/vod/a.jpg',
          webUrl: 'https://mirror.example.com',
        ),
        'https://mirror.example.com/upload/vod/a.jpg',
      );
      expect(api.imageUrl('/x.jpg'), 'https://www.jinrikanpian.net/x.jpg');
    });
  });

  // 页面级 widget 测试：仍然离线（Dio 拦截器直接 resolve / reject），
  // 覆盖加载态、空态、错误重试、Tab 懒加载，以及详情页的选线交互。
  group('页面流（widget）', () {
    testWidgets('首页空数据：空态可见，且 build 期间不会重复发请求', (tester) async {
      final seen = <RequestOptions>[];
      final dio = _fakeDio((options) {
        seen.add(options);
        return _ok(const <String, Object?>{
          'code': 1,
          'msg': '数据列表',
          'page': 1,
          'pagecount': 0,
          'total': 0,
          'list': <Object?>[],
        }, options);
      });

      await tester.pumpWidget(MaterialApp(home: FlutterMoviesPage(dio: dio)));
      await tester.pumpAndSettle();

      // 首页三个真实请求：幻灯片 / 最近更新 / 父类，且顺序与源站调用一致
      expect(seen, hasLength(3));
      expect(seen[0].uri.path, '/appapi.php/api/vod/');
      expect(seen[0].uri.query, contains('ac=detail'));
      expect(seen[0].uri.query, contains('leve=9'));
      expect(seen[0].uri.query, contains('pagesize=5'));
      expect(seen[1].uri.query, contains('h=24'));
      expect(seen[2].uri.path, '/appapi.php/api/getPcategory');
      expect(seen[2].uri.query, 'pt=0');

      expect(find.text('暂无推荐内容'), findsOneWidget);

      // 切到分类：只新增分类页自己的父类请求
      final before = seen.length;
      await tester.tap(find.byIcon(Icons.category_outlined));
      await tester.pumpAndSettle();
      expect(find.text('暂无分类数据'), findsOneWidget);
      expect(seen, hasLength(before + 1));
      expect(seen.last.uri.path, '/appapi.php/api/getPcategory');

      // 回到首页：IndexedStack 保留状态，不重新请求
      await tester.tap(find.byIcon(Icons.home_outlined));
      await tester.pumpAndSettle();
      expect(find.text('暂无推荐内容'), findsOneWidget);
      expect(seen, hasLength(before + 1));
    });

    testWidgets('首页请求失败：错误态可重试，重试仍是同一组请求', (tester) async {
      var calls = 0;
      final dio = Dio(BaseOptions(baseUrl: FlutterMoviesApi.defaultWebUrl));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            calls++;
            handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.connectionError,
                message: 'down',
              ),
            );
          },
        ),
      );

      await tester.pumpWidget(MaterialApp(home: FlutterMoviesPage(dio: dio)));
      await tester.pumpAndSettle();

      expect(find.text('无法连接影视频道，请检查网络'), findsOneWidget);
      expect(find.text('重试'), findsOneWidget);
      expect(calls, 3);

      await tester.tap(find.text('重试'));
      await tester.pumpAndSettle();
      expect(calls, 6);
      expect(find.text('无法连接影视频道，请检查网络'), findsOneWidget);
    });

    testWidgets('详情页：剔除 ckm3u8，默认最长线路，切线路换分集，伪协议分集不跳转', (tester) async {
      final api = FlutterMoviesApi(
        dio: _fakeDio((options) => _ok(_decode(detailResponseJson), options)),
      );
      addTearDown(api.dispose);

      await tester.pumpWidget(
        MaterialApp(home: FlutterMoviesDetailPage(api: api, vodId: 1001)),
      );
      await tester.pumpAndSettle();

      // 线路名用 player_info.show，且 ckm3u8 被源站规则剔除
      expect(find.text('量子资源'), findsOneWidget);
      expect(find.text('豆瓣资源'), findsOneWidget);
      expect(find.text('暴风资源'), findsOneWidget);
      expect(find.text('CK资源'), findsNothing);

      // 默认选中分集最多的线路（量子资源 4 集）
      expect(find.text('选集（4）'), findsOneWidget);
      expect(find.text('第01集'), findsOneWidget);
      expect(find.text('第03集高清'), findsOneWidget);

      // 伪协议分集：给提示，不打开播放页
      await tester.tap(find.text('第04集'));
      await tester.pump();
      expect(find.text('该集暂无可播放地址'), findsOneWidget);
      expect(find.byType(MediaPlaybackPage), findsNothing);
      await tester.pumpAndSettle();

      // 切到暴风资源：分集列表随之变化
      await tester.tap(find.text('暴风资源'));
      await tester.pumpAndSettle();
      expect(find.text('选集（2）'), findsOneWidget);
      expect(find.text('第03集高清'), findsNothing);
      expect(find.byType(MediaPlaybackPage), findsNothing);
    });
  });
}
