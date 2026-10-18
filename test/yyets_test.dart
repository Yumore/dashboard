import 'dart:convert';
import 'dart:typed_data';

import 'package:dashboard/features/movie/yyets/yyets_api.dart';
import 'package:dashboard/features/movie/yyets/yyets_detail.dart';
import 'package:dashboard/features/movie/yyets/yyets_edition.dart';
import 'package:dashboard/features/movie/yyets/yyets_endpoint.dart';
import 'package:dashboard/features/movie/yyets/yyets_episode.dart';
import 'package:dashboard/features/movie/yyets/yyets_exception.dart';
import 'package:dashboard/features/movie/yyets/yyets_favorites_page.dart';
import 'package:dashboard/features/movie/yyets/yyets_file_entry.dart';
import 'package:dashboard/features/movie/yyets/yyets_file_link.dart';
import 'package:dashboard/features/movie/yyets/yyets_home_page.dart';
import 'package:dashboard/features/movie/yyets/yyets_json.dart';
import 'package:dashboard/features/movie/yyets/yyets_latest_resource_page.dart';
import 'package:dashboard/features/movie/yyets/yyets_link_launcher.dart';
import 'package:dashboard/features/movie/yyets/yyets_movie.dart';
import 'package:dashboard/features/movie/yyets/yyets_news_item.dart';
import 'package:dashboard/features/movie/yyets/yyets_news_page.dart';
import 'package:dashboard/features/movie/yyets/yyets_paging.dart';
import 'package:dashboard/features/movie/yyets/yyets_rank_result.dart';
import 'package:dashboard/features/movie/yyets/yyets_rank_tab.dart';
import 'package:dashboard/features/movie/yyets/yyets_resource_detail.dart';
import 'package:dashboard/features/movie/yyets/yyets_resource_item.dart';
import 'package:dashboard/features/movie/yyets/yyets_resource_page.dart';
import 'package:dashboard/features/movie/yyets/yyets_search_page.dart';
import 'package:dashboard/features/movie/yyets/yyets_season.dart';
import 'package:dashboard/features/movie/yyets/yyets_session.dart';
import 'package:dashboard/features/movie/yyets/yyets_status_view.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  _urlBuildingTests();
  _rankApiTests();
  _searchApiTests();
  _detailApiTests();
  _resourceApiTests();
  _newsAndFavoritesTests();
  _errorMessageTests();
  _jsonHelperTests();
  _modelTests();
  _pagingTests();
  _widgetTests();
}

// -----------------------------------------------------------------------------
// 无网络替身
// -----------------------------------------------------------------------------

/// 一次被拦下来的请求。
///
/// Dio 把查询串同时写进 `options.path` 和 `options.uri`，而
/// `options.queryParameters` 在绝对 URL 调用路径上会被清空，所以断言以
/// [uriQuery]（真正发出去的那串参数）为准。
class RecordedRequest {
  RecordedRequest(this.path, this.query, this.uriQuery);

  /// `options.path`；绝对 URL 时含查询串。
  final String path;

  /// `options.queryParameters` 快照。
  final Map<String, dynamic> query;

  /// `options.uri.queryParameters` —— 权威查询参数。
  final Map<String, dynamic> uriQuery;

  @override
  String toString() => path;
}

typedef FakeHandler = ResponseBody Function(RecordedRequest request);

/// 记录每一次请求并返回预置响应的 [HttpClientAdapter]。
class FakeAdapter implements HttpClientAdapter {
  FakeAdapter(this.handler);

  final FakeHandler handler;
  final List<RecordedRequest> requests = <RecordedRequest>[];

  RecordedRequest get last => requests.last;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final recorded = RecordedRequest(
      options.path,
      <String, dynamic>{...options.queryParameters},
      <String, dynamic>{...options.uri.queryParameters},
    );
    requests.add(recorded);
    return handler(recorded);
  }

  @override
  void close({bool force = false}) {}
}

/// 把任意 JSON 编成 Dio 能解析的响应体。
ResponseBody jsonBody(Object? payload, {int status = 200}) =>
    ResponseBody.fromString(
      jsonEncode(payload),
      status,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );

/// `a.zmzapi.com` 统一的 `{status, info, data}` 信封。
///
/// `file.apicvn.com` 的响应**没有**信封，那种情况直接用 [jsonBody]。
ResponseBody envelopeBody({
  required Object? data,
  int status = 1,
  String? info,
}) => jsonBody(<String, Object?>{
  'status': status,
  'info': ?info,
  'data': data,
});

/// 造一个走假适配器的 [YyetsApi]，保证测试不触网。
YyetsApi apiWith(
  FakeHandler handler, {
  YyetsSession session = YyetsSession.anonymous,
}) => YyetsApi(dio: Dio()..httpClientAdapter = FakeAdapter(handler), session: session);

/// 所有请求都返回 `{status: 1, data: <payload>}`。
YyetsApi apiReturning(Object? payload) =>
    apiWith((request) => envelopeBody(data: payload));

/// 所有请求都返回 `{status: 0, info: <info>}`。
YyetsApi apiFailing(String info) =>
    apiWith((request) => envelopeBody(data: <String, Object?>{}, status: 0, info: info));

/// 在请求发出前直接失败的 Dio（用于网络层错误文案）。
Dio rejectingDio(DioException error) {
  final dio = Dio();
  dio.interceptors.add(
    InterceptorsWrapper(onRequest: (options, handler) => handler.reject(error)),
  );
  return dio;
}

/// 记录打开过的链接的假 launcher。
class RecordingLauncher extends YyetsLinkLauncher {
  RecordingLauncher({this.result = true});

  final bool result;
  final List<String> opened = <String>[];

  @override
  Future<bool> open(String address, {String? passwd}) async {
    opened.add(address);
    return result;
  }
}

Widget host(Widget child) => MaterialApp(home: child);

// -----------------------------------------------------------------------------
// fixtures —— 字段名照抄源工程消费点
// -----------------------------------------------------------------------------

Map<String, Object?> movieJson({
  String id = '31812',
  String? itemid,
  String cnname = '三体',
  String enname = 'Three-Body',
  String? poster = 'https://img.zmzapi.com/poster/31812.jpg',
  String? posterB,
  String channel = 'tv',
  String channelCn = '国产剧',
  String area = '大陆',
  String category = '科幻',
  String score = '9.1',
  String playStatus = '已完结',
  String typeName = '电视剧',
}) => <String, Object?>{
  'id': id,
  'itemid': ?itemid,
  'cnname': cnname,
  'enname': enname,
  'poster': poster,
  'poster_b': ?posterB,
  'channel': channel,
  'channel_cn': channelCn,
  'area': area,
  'category': category,
  'score': score,
  'play_status': playStatus,
  'type_name': typeName,
};

/// `Api.getResInfo` 的 `data`：`item_list` + `item_app`。
Map<String, Object?> resourceDetailJson() => <String, Object?>{
  'item_app': <String, Object?>{'name': 'thunder://QUFodHRwOi8vZXhhbXBsZS5jb20='},
  'item_list': <Object?>[
    <String, Object?>{
      'format_tip': 'HR-HDTV',
      'foramt': 'MKV',
      'size': '1.4G',
      'dateline': 1697000000,
      'files': <Object?>[
        <String, Object?>{
          'address': 'magnet:?xt=urn:btih:ABCDEF123456',
          'passwd': '',
          'way': 3,
          'way_name': '磁力链接',
        },
        <String, Object?>{
          'address': 'https://pan.baidu.com/s/1abcDEF',
          'passwd': 'rr99',
          'way': 1,
          'way_name': '百度网盘',
        },
      ],
    },
    <String, Object?>{
      'format_tip': 'MP4',
      'foramt': 'MP4',
      'size': '2.1G',
      'dateline': '1698000000',
      'files': <Object?>[
        <String, Object?>{'address': 'ed2k://|file|demo.mkv|123|HASH|/'},
        <String, Object?>{'address': '', 'way_name': '空链接'},
      ],
    },
  ],
};

/// `Api.getDetail` 的 `data`。
Map<String, Object?> detailJson() => <String, Object?>{
  'resource': <String, Object?>{
    'id': '90001',
    'channel': 'tv',
    'channel_cn': '国产剧',
    'content': '地球往事。',
    'level': 'a',
    'score': '9.1',
    'play_status': '已完结',
    'poster_b': 'https://img.zmzapi.com/poster_b/31812.jpg',
    'zimuzu': '人人影视字幕组',
    'category': <Object?>['科幻', '悬疑'],
  },
  'movie_items': <Object?>[
    <String, Object?>{'number': 'HDTV-MP4', 'name': 'item-1', 'play': 1},
    <String, Object?>{'number': 'WEB-DL', 'name': 'item-2', 'play': 0},
  ],
  'season_list': <Object?>[
    <String, Object?>{
      'season': 1,
      'season_cn': '第一季',
      'episode_list': <Object?>[
        <String, Object?>{
          'episode': 1,
          'name': '科学边界',
          'play_status': 1,
          'play_status_cn': '已播',
          'play_time': '2023-01-15',
          'itemid': 'it-1',
        },
        <String, Object?>{'episode': 2, 'play_status_cn': '未播'},
      ],
    },
    <String, Object?>{
      'season': 2,
      'season_cn': '第二季',
      'episode_list': <Object?>[
        <String, Object?>{'episode': 1, 'name': '面壁者', 'play_status_cn': '已播'},
      ],
    },
  ],
  'similar': <Object?>[
    movieJson(id: '40001', cnname: '流浪地球', enname: 'The Wandering Earth'),
  ],
  'comments_hot': <Object?>[
    <String, Object?>{
      'id': 'c1',
      'content': '神作',
      'username': '剧迷',
      'dateline': 1697000000,
      'userpic': 'https://img.zmzapi.com/u/1.jpg',
    },
  ],
  'comments_count': 128,
  'share_url': 'http://www.rrys2019.com/resource/31812',
};

Map<String, Object?> fileEntryJson({
  String fileid = '5599182',
  String fileName = 'Three.Body.S01E01.1080p.mkv',
  String fileSize = '1.4GB',
  String createTime = '2023-01-16 09:12:00',
  String? magnet = 'magnet:?xt=urn:btih:DEADBEEF',
}) => <String, Object?>{
  'fileid': fileid,
  'file_name': fileName,
  'file_size': fileSize,
  'create_time': createTime,
  'magnet_url': magnet,
};

/// 文章型资讯：`intro` / `username` / `good_status` / `dateline`。
Map<String, Object?> newsJson() => <String, Object?>{
  'id': '771',
  'type': 'article',
  'title': '《三体》第二季开机',
  'intro': '官方公布主创阵容。',
  'poster': 'https://img.zmzapi.com/news/771.jpg',
  'username': '人人影视',
  'good_status': '36',
  'dateline': '1697000000',
  'url': 'https://weibo.com/1/abc',
};

/// 微博型资讯：`content` / `author_name` / `views` / `time`。
Map<String, Object?> weiboNewsJson() => <String, Object?>{
  'id': '772',
  'type': 'weibo',
  'title': '字幕组招新',
  'content': '招新公告',
  'cover': 'https://img.zmzapi.com/news/772.jpg',
  'author_name': 'YYeTs',
  'user_logo': 'https://img.zmzapi.com/u/2.jpg',
  'views': 77,
  'time': 1697100000,
  'url': 'https://weibo.com/1/def',
};

// -----------------------------------------------------------------------------
// URL 拼装（含签名参数）
// -----------------------------------------------------------------------------

void _urlBuildingTests() {
  group('URL 拼装与签名', () {
    test('linkUrl 与源工程逐字节一致', () {
      expect(
        YyetsApi.linkUrl('m=index&a=HOT&limit=100&g=api/v3'),
        'http://a.zmzapi.com/index.php/'
        '?accesskey=519f9cab85c8059d17544947k361a827&client=2'
        '&m=index&a=HOT&limit=100&g=api/v3',
      );
    });

    test('三个公开主机与签名常量照抄源工程', () {
      expect(YyetsEndpoint.baseUrl, 'http://a.zmzapi.com');
      expect(YyetsEndpoint.fileBaseUrl, 'http://file.apicvn.com');
      expect(YyetsEndpoint.resourceBaseUrl, 'http://m1.rrys2019.com');
      expect(YyetsEndpoint.accessKey, '519f9cab85c8059d17544947k361a827');
      expect(YyetsEndpoint.client, '2');
      expect(YyetsEndpoint.indexPath, '/index.php/');
    });

    test('rankUrl / detailUrl / commentUrl', () {
      expect(YyetsApi.rankUrl, contains('&m=index&a=HOT&limit=100&g=api/v3'));
      expect(
        YyetsApi.detailUrl('31812'),
        contains('&m=index&a=resource&rid=31812&g=api/v2'),
      );
      expect(
        YyetsApi.commentUrl('31812', 'tv', 2),
        contains('&a=fetch&itemid=31812&channel=tv&pagesize=20&page=2&m=comment'),
      );
    });

    test('searchUrl：g 被编码，k / page 原样', () {
      expect(
        YyetsApi.searchUrl('三体', 2),
        contains('&st=resource&a=search&g=api%2Fv2&limit=10&k=三体&page=2&m=index'),
      );
    });

    test('resUrl 保留源工程的 channel 死参数', () {
      final url = YyetsApi.resUrl(
        id: '90001',
        itemid: 'it-1',
        channel: 'tv',
        season: '1',
        episode: '2',
      );
      expect(
        url,
        contains(
          '&g=api/v2&m=index&a=resource_item&id=90001&season=1&episode=2&itemid=it-1',
        ),
      );
      expect(url, isNot(contains('channel=')));
    });

    test('资源库 / 收藏 / 资讯 / 网页地址', () {
      expect(YyetsApi.fileListUrl(3), 'http://file.apicvn.com/file/list?page=3');
      expect(
        YyetsApi.fileSearchUrl('三体', 1),
        'http://file.apicvn.com/file/search?keyword=三体&page=1',
      );
      expect(
        YyetsApi.favoritesUrl(2),
        contains('&g=api/v2&m=index&a=fav_list&ft=resource&page=2&limit=20'),
      );
      expect(
        YyetsApi.newsUrl(4),
        contains('&g=api/v2&m=index&a=new_article_list&page=4'),
      );
      expect(
        YyetsEndpoint.resourceItemUrl(rid: '31812', season: 1, episode: 2),
        'http://m1.rrys2019.com/resource/item?rid=31812&season=1&episode=2',
      );
      expect(
        YyetsEndpoint.articleUrl('771'),
        'http://m1.rryslink.com/article/771',
      );
    });
  });
}

// -----------------------------------------------------------------------------
// 榜单 / 搜索接口
// -----------------------------------------------------------------------------

void _rankApiTests() {
  group('YyetsApi.loadRank', () {
    test('解析 6 个榜单，缺失的 key 退化为空列表', () async {
      final api = apiReturning(<String, Object?>{
        'today_list': <Object?>[movieJson(id: '1', cnname: '今日片')],
        'movie_list': <Object?>[movieJson(id: '2', cnname: '电影片')],
      });
      final YyetsRankResult rank = await api.loadRank();

      expect(YyetsRankResult.tabs.length, 6);
      expect(rank.listFor(YyetsRankTab.today).single.cnName, '今日片');
      expect(rank.listFor(YyetsRankTab.movie).single.cnName, '电影片');
      expect(rank.listFor(YyetsRankTab.japan), isEmpty);
      expect(rank.listFor(YyetsRankTab.total), isEmpty);
      expect(rank.lists.length, 6);
      expect(rank.isEmpty, isFalse);
      expect(YyetsRankTab.values.map((tab) => tab.label).toList(), <String>[
        '今日',
        '本月',
        '电影',
        '新剧',
        '日剧',
        '全部',
      ]);
      expect(YyetsRankTab.today.key, 'today_list');
      expect(YyetsRankTab.total.icon, Icons.list_alt_outlined);
    });

    test('全空榜单 isEmpty 为 true', () {
      const rank = YyetsRankResult.empty();
      expect(rank.isEmpty, isTrue);
      expect(rank.listFor(YyetsRankTab.today), isEmpty);
    });

    test('status != 1 时抛出 info 文案', () {
      final api = apiFailing('接口维护中');
      expect(
        api.loadRank,
        throwsA(
          isA<YyetsException>().having(
            (error) => error.message,
            'message',
            '接口维护中',
          ),
        ),
      );
    });
  });
}

void _searchApiTests() {
  group('YyetsApi.search', () {
    test('拼出真实搜索 URL，并把 itemid 归一成 id', () async {
      final adapter = FakeAdapter(
        (request) => envelopeBody(
          data: <String, Object?>{
            'list': <Object?>[
              movieJson(id: '', itemid: '88123', cnname: '漫长的季节'),
              movieJson(id: '31812', cnname: '三体'),
            ],
          },
        ),
      );
      final api = YyetsApi(dio: Dio()..httpClientAdapter = adapter);
      final List<YyetsMovie> results = await api.search('三体', 2);

      expect(adapter.last.path, startsWith('http://a.zmzapi.com/index.php/'));
      expect(adapter.last.uriQuery['accesskey'], YyetsEndpoint.accessKey);
      expect(adapter.last.uriQuery['client'], '2');
      expect(adapter.last.uriQuery['st'], 'resource');
      expect(adapter.last.uriQuery['a'], 'search');
      expect(adapter.last.uriQuery['g'], 'api/v2');
      expect(adapter.last.uriQuery['limit'], '10');
      expect(adapter.last.uriQuery['k'], '三体');
      expect(adapter.last.uriQuery['page'], '2');
      expect(adapter.last.uriQuery['m'], 'index');

      expect(results.length, 2);
      expect(results.first.id, '88123');
      expect(results.first.itemId, '88123');
      expect(results.first.cnName, '漫长的季节');
      expect(results.last.id, '31812');
    });

    test('关键字两侧空白被裁剪', () async {
      final adapter = FakeAdapter(
        (request) => envelopeBody(data: <String, Object?>{'list': <Object?>[]}),
      );
      final api = YyetsApi(dio: Dio()..httpClientAdapter = adapter);
      expect(await api.search('  三体  ', 1), isEmpty);
      expect(adapter.last.uriQuery['k'], '三体');
    });

    test('空关键字不发请求', () {
      final api = apiReturning(<String, Object?>{'list': <Object?>[]});
      expect(
        () => api.search('   ', 1),
        throwsA(
          isA<YyetsException>().having(
            (error) => error.message,
            'message',
            '搜索关键字不能为空',
          ),
        ),
      );
    });

    test('data.list 缺失时返回空列表', () async {
      final api = apiReturning(<String, Object?>{});
      expect(await api.search('三体', 1), isEmpty);
    });

    test('命中里没有 id 也没有 itemid 的条目被丢弃', () async {
      final api = apiReturning(<String, Object?>{
        'list': <Object?>[<String, Object?>{'cnname': '无 id 条目'}],
      });
      expect(await api.search('三体', 1), isEmpty);
    });

    test('分页：第 2 页返回空列表即没有下一页', () async {
      final api = apiWith((request) {
        final page = YyetsJson.asInt(request.uriQuery['page']);
        return envelopeBody(
          data: <String, Object?>{
            'list': page == 1 ? <Object?>[movieJson(id: '1')] : <Object?>[],
          },
        );
      });
      expect((await api.search('三体', 1)).length, 1);
      expect(await api.search('三体', 2), isEmpty);
    });
  });
}

void _detailApiTests() {
  group('YyetsApi.getDetail', () {
    test('解析 resource / movie_items / season_list / similar / 热评', () async {
      final api = apiReturning(detailJson());
      final YyetsDetail detail = await api.getDetail('31812');

      expect(detail.resource.id, '90001');
      expect(detail.resource.channel, 'tv');
      expect(detail.resource.channelCn, '国产剧');
      expect(detail.resource.content, '地球往事。');
      expect(detail.resource.levelLabel, 'A');
      expect(detail.resource.categoryLabel, '科幻/悬疑');
      expect(detail.resource.zimuzu, '人人影视字幕组');
      expect(detail.isMovie, isFalse);
      expect(detail.movieItems.length, 2);
      expect(detail.movieItems.first.number, 'HDTV-MP4');
      expect(detail.movieItems.first.play, isTrue);
      expect(detail.movieItems.last.play, isFalse);
      expect(detail.seasons.length, 2);
      expect(detail.seasons.first.label, '第一季');
      expect(detail.seasons.first.episodes.first.name, '科学边界');
      expect(detail.seasons.first.episodes.first.canOpen, isTrue);
      expect(detail.seasons.first.episodes.last.isUnbroadcast, isTrue);
      expect(detail.similar.single.cnName, '流浪地球');
      expect(detail.hotComments.single.content, '神作');
      expect(detail.commentsCount, 128);
      expect(detail.shareUrl, 'http://www.rrys2019.com/resource/31812');
      expect(
        detail.shareText(detail.similar.single),
        '流浪地球(The Wandering Earth)\n'
        'http://www.rrys2019.com/resource/31812\n\n来自 人人影视_Flutter',
      );
    });

    test('没有 season_list 时按电影处理', () async {
      final api = apiReturning(<String, Object?>{'movie_items': <Object?>[]});
      expect((await api.getDetail('1')).isMovie, isTrue);
      expect(YyetsDetail.empty.isMovie, isTrue);
      expect(YyetsDetail.empty.resource.isEmpty, isTrue);
    });
  });
}

// -----------------------------------------------------------------------------
// 资源详情 / 资源库 / 资讯 / 收藏
// -----------------------------------------------------------------------------

void _resourceApiTests() {
  group('YyetsApi.getResourceDetail', () {
    test('拼出 resource_item 参数并解析 item_list / item_app', () async {
      final adapter = FakeAdapter(
        (request) => envelopeBody(data: resourceDetailJson()),
      );
      final api = YyetsApi(dio: Dio()..httpClientAdapter = adapter);

      final YyetsResourceDetail detail = await api.getResourceDetail(
        id: '31812',
        itemid: 'it-1',
        channel: 'tv',
        season: '1',
        episode: '1',
      );

      expect(adapter.last.uriQuery['a'], 'resource_item');
      expect(adapter.last.uriQuery['g'], 'api/v2');
      expect(adapter.last.uriQuery['m'], 'index');
      expect(adapter.last.uriQuery['id'], '31812');
      expect(adapter.last.uriQuery['season'], '1');
      expect(adapter.last.uriQuery['episode'], '1');
      expect(adapter.last.uriQuery['itemid'], 'it-1');

      expect(detail.editions.length, 2);
      expect(detail.editions.first.formatTip, 'HR-HDTV');
      expect(detail.editions.first.format, 'MKV');
      expect(detail.editions.first.size, '1.4G');
      expect(detail.editions.first.dateline, 1697000000);
      expect(detail.editions.first.files.length, 2);
      expect(detail.editions.last.dateline, 1698000000);
      expect(detail.editions.last.launchableFiles.single.isEd2k, isTrue);
      expect(detail.canDownloadAndPlay, isTrue);
      expect(detail.downloadAndPlayUri, 'thunder://QUFodHRwOi8vZXhhbXBsZS5jb20=');
      expect(detail.isEmpty, isFalse);
      expect(detail.editionsWithFiles.length, 2);
    });

    test('status != 1 时用 info 抛错（页面直接展示）', () {
      final api = apiFailing('该资源已下架');
      expect(
        () => api.getResourceDetail(id: '1'),
        throwsA(
          isA<YyetsException>().having(
            (error) => error.message,
            'message',
            '该资源已下架',
          ),
        ),
      );
    });
  });

  group('YyetsApi 资源库', () {
    test('latestResources 走 file.apicvn.com，响应没有信封', () async {
      final adapter = FakeAdapter(
        (request) => jsonBody(<Object?>[
          fileEntryJson(),
          fileEntryJson(fileid: '5599183', magnet: ''),
        ]),
      );
      final api = YyetsApi(dio: Dio()..httpClientAdapter = adapter);

      final List<YyetsFileEntry> entries = await api.latestResources(2);

      expect(adapter.last.path, startsWith('http://file.apicvn.com/file/list'));
      expect(adapter.last.uriQuery['page'], '2');
      expect(entries.length, 2);
      expect(entries.first.fileName, 'Three.Body.S01E01.1080p.mkv');
      expect(entries.first.hasMagnet, isTrue);
      expect(entries.last.hasMagnet, isFalse);
      expect(entries.last.magnetUrl, isNull);
    });

    test('searchResources 拼 keyword / page，空关键字不发请求', () async {
      final adapter = FakeAdapter(
        (request) => jsonBody(<Object?>[fileEntryJson()]),
      );
      final api = YyetsApi(dio: Dio()..httpClientAdapter = adapter);

      final entries = await api.searchResources(' 三体 ', 3);

      expect(adapter.last.path, startsWith('http://file.apicvn.com/file/search'));
      expect(adapter.last.uriQuery['keyword'], '三体');
      expect(adapter.last.uriQuery['page'], '3');
      expect(entries.single.fileId, '5599182');
      expect(
        () => api.searchResources(' ', 1),
        throwsA(isA<YyetsException>()),
      );
    });
  });
}

void _newsAndFavoritesTests() {
  group('YyetsApi 登录态', () {
    test('已登录会话追加 uid / token，匿名会话不追加', () async {
      final authorized = FakeAdapter(
        (request) => envelopeBody(data: <Object?>[]),
      );
      final withSession = YyetsApi(
        dio: Dio()..httpClientAdapter = authorized,
        session: const YyetsSession(uid: 'u-1', token: 't-9'),
      );
      await withSession.news(1);
      expect(authorized.last.uriQuery['uid'], 'u-1');
      expect(authorized.last.uriQuery['token'], 't-9');
      expect(authorized.last.uriQuery['page'], '1');

      final anonymous = FakeAdapter(
        (request) => envelopeBody(data: <Object?>[]),
      );
      final withoutSession = YyetsApi(
        dio: Dio()..httpClientAdapter = anonymous,
      );
      await withoutSession.news(1);
      expect(anonymous.last.uriQuery.containsKey('uid'), isFalse);
      expect(anonymous.last.uriQuery.containsKey('token'), isFalse);
    });
  });

  group('YyetsApi.news', () {
    test('两种来源的字段回退链', () async {
      final api = apiReturning(<Object?>[newsJson(), weiboNewsJson()]);
      final List<YyetsNewsItem> items = await api.news(1);

      expect(items.length, 2);
      expect(items.first.isWeibo, isFalse);
      expect(items.first.content, '官方公布主创阵容。');
      expect(items.first.imageUrl, 'https://img.zmzapi.com/news/771.jpg');
      expect(items.first.author, '人人影视');
      expect(items.first.likeCount, 36);
      expect(items.first.dateline, 1697000000);
      expect(items.first.webUrl, 'http://m1.rryslink.com/article/771');

      expect(items.last.isWeibo, isTrue);
      expect(items.last.content, '招新公告');
      expect(items.last.author, 'YYeTs');
      expect(items.last.userPic, 'https://img.zmzapi.com/u/2.jpg');
      expect(items.last.likeCount, 77);
      expect(items.last.isVideo, isTrue);
      expect(items.last.dateline, 1697100000);
      expect(items.last.webUrl, 'https://weibo.com/1/def');
    });
  });

  group('YyetsApi.myFavorites / loadComments', () {
    test('收藏取每条的 detail 子对象并跳过空 detail', () async {
      final adapter = FakeAdapter(
        (request) => envelopeBody(
          data: <Object?>[
            <String, Object?>{'detail': movieJson(id: '1', cnname: '已收藏')},
            <String, Object?>{},
          ],
        ),
      );
      final api = YyetsApi(
        dio: Dio()..httpClientAdapter = adapter,
        session: const YyetsSession(uid: 'u-1', token: 't-9'),
      );

      final favorites = await api.myFavorites(1);

      expect(adapter.last.uriQuery['a'], 'fav_list');
      expect(adapter.last.uriQuery['ft'], 'resource');
      expect(adapter.last.uriQuery['limit'], '20');
      expect(favorites.single.cnName, '已收藏');
    });

    test('loadComments 原样返回 list，每页 20 条', () async {
      final adapter = FakeAdapter(
        (request) => envelopeBody(
          data: <String, Object?>{
            'list': <Object?>[
              <String, Object?>{'id': 'c1', 'content': '好看'},
            ],
          },
        ),
      );
      final api = YyetsApi(dio: Dio()..httpClientAdapter = adapter);

      final comments = await api.loadComments('31812', 'tv', 1);

      expect(adapter.last.uriQuery['pagesize'], '20');
      expect(adapter.last.uriQuery['itemid'], '31812');
      expect(adapter.last.uriQuery['channel'], 'tv');
      expect(comments.single['content'], '好看');
    });
  });
}

void _errorMessageTests() {
  group('错误处理', () {
    test('HTTP 500 变成 YyetsException 并带状态码', () {
      final api = apiWith(
        (request) => ResponseBody.fromString('server error', 500),
      );
      expect(
        () => api.news(1),
        throwsA(
          isA<YyetsException>()
              .having((error) => error.statusCode, 'statusCode', 500)
              .having((error) => error.message, 'message', '请求失败：HTTP 500'),
        ),
      );
    });

    test('连接失败给出网络文案', () {
      final api = YyetsApi(
        dio: rejectingDio(
          DioException.connectionError(
            requestOptions: RequestOptions(path: '/index.php/'),
            reason: 'offline',
          ),
        ),
      );
      expect(
        () => api.news(1),
        throwsA(
          isA<YyetsException>().having(
            (error) => error.message,
            'message',
            '网络连接失败，请检查网络',
          ),
        ),
      );
    });

    test('超时给出重试文案', () {
      final api = YyetsApi(
        dio: rejectingDio(
          DioException.receiveTimeout(
            timeout: const Duration(seconds: 15),
            requestOptions: RequestOptions(path: '/index.php/'),
          ),
        ),
      );
      expect(
        () => api.news(1),
        throwsA(
          isA<YyetsException>().having(
            (error) => error.message,
            'message',
            '请求超时，请重试',
          ),
        ),
      );
    });

    test('toString 直接是用户文案，不带 Exception: 前缀', () {
      expect(const YyetsException('资源加载失败').toString(), '资源加载失败');
    });
  });
}

// -----------------------------------------------------------------------------
// JSON 助手 / 模型
// -----------------------------------------------------------------------------

void _jsonHelperTests() {
  group('YyetsJson', () {
    test('数字与布尔混用都能取值', () {
      expect(YyetsJson.asInt('7'), 7);
      expect(YyetsJson.asInt(7.9), 7);
      expect(YyetsJson.asInt(null), 0);
      expect(YyetsJson.asInt('abc'), 0);
      expect(YyetsJson.asNullableInt(''), isNull);
      expect(YyetsJson.asDouble('9.1'), 9.1);
      expect(YyetsJson.asBool('1'), isTrue);
      expect(YyetsJson.asBool(1), isTrue);
      expect(YyetsJson.asBool('true'), isTrue);
      expect(YyetsJson.asBool('0'), isFalse);
      expect(YyetsJson.asBool(null), isFalse);
    });

    test('字符串与列表：空串按缺失处理', () {
      expect(YyetsJson.asString(null), '');
      expect(YyetsJson.asString(3), '3');
      expect(YyetsJson.asNullableString('  '), isNull);
      expect(YyetsJson.asStringList(<Object?>['a', '', 3]), <String>['a', '3']);
      expect(YyetsJson.asStringList('nope'), isEmpty);
      expect(YyetsJson.asList(<Object?>[1]), <Object?>[1]);
      expect(YyetsJson.asList('nope'), isEmpty);
    });

    test('map 取值：键统一成字符串，非 map 退化', () {
      expect(YyetsJson.asMap(<Object?, Object?>{1: 'a'}), <String, dynamic>{'1': 'a'});
      expect(YyetsJson.asMap('nope'), isEmpty);
      expect(YyetsJson.asMapOrNull('nope'), isNull);
      expect(
        YyetsJson.asMapList(<Object?>[
          <String, Object?>{'a': 1},
          'nope',
        ]).single,
        <String, dynamic>{'a': 1},
      );
    });
  });
}

void _modelTests() {
  group('YyetsMovie', () {
    test('搜索命中用 itemid 补 id，标题回退链', () {
      final movie = YyetsMovie.fromJson(
        movieJson(id: '', itemid: '88123', cnname: '三体', enname: 'Three-Body'),
      );
      expect(movie.id, '88123');
      expect(movie.itemId, '88123');
      expect(movie.hasId, isTrue);
      expect(movie.title, '三体(Three-Body)');
      expect(movie.gridTitle, '三体');

      final englishOnly = YyetsMovie.fromJson(
        movieJson(cnname: '', enname: 'Three-Body'),
      );
      expect(englishOnly.title, '(Three-Body)');
      expect(englishOnly.gridTitle, 'Three-Body');

      final unknown = YyetsMovie.fromJson(
        movieJson(id: '', cnname: '', enname: ''),
      );
      expect(unknown.gridTitle, '(未知影视)');
      expect(unknown.hasId, isFalse);
    });

    test('海报回退：poster → poster_b → 占位图', () {
      expect(
        YyetsMovie.fromJson(movieJson()).displayPoster,
        'https://img.zmzapi.com/poster/31812.jpg',
      );
      final bigOnly = YyetsMovie.fromJson(
        movieJson(poster: '', posterB: 'https://img.zmzapi.com/poster_b/1.jpg'),
      );
      expect(bigOnly.displayPoster, 'https://img.zmzapi.com/poster_b/1.jpg');
      expect(bigOnly.displayPosterBig, 'https://img.zmzapi.com/poster_b/1.jpg');
      final none = YyetsMovie.fromJson(movieJson(poster: '', posterB: ''));
      expect(none.displayPoster, 'https://flutter.cn/favicon.ico');
      expect(
        none.posterForDetail(<String, dynamic>{'poster_b': 'https://x/2.jpg'}),
        'https://x/2.jpg',
      );
    });

    test('标签顺序与资源页参数', () {
      final movie = YyetsMovie.fromJson(movieJson());
      expect(movie.searchTags, <String>['大陆', '9.1', '已完结', '科幻']);
      expect(movie.favoriteTags, <String>['9.1', '电视剧', '科幻', '已完结']);
      expect(movie.resourceArguments, <String, String>{
        'id': '31812',
        'channel': 'tv',
      });
      expect(movie.rid, '31812');
      expect(movie.sourceArticleUrl, 'http://m1.rryslink.com/article/31812');
      expect(movie.toString(), '三体(Three-Body)');

      final withItemId = YyetsMovie.fromJson(movieJson(itemid: 'it-9'));
      expect(withItemId.resourceArguments['itemid'], 'it-9');
    });
  });

  group('YyetsFileLink', () {
    test('密码拼接、渠道标签与可打开判断', () {
      final magnet = YyetsFileLink.fromJson(<String, Object?>{
        'address': 'magnet:?xt=urn:btih:ABC',
        'passwd': '',
        'way': 3,
        'way_name': '磁力链接',
      });
      expect(magnet.hasPasswd, isFalse);
      expect(magnet.displayText, 'magnet:?xt=urn:btih:ABC');
      expect(magnet.wayLabel, 'way: 3');
      expect(magnet.isMagnet, isTrue);
      expect(magnet.isEd2k, isFalse);
      expect(magnet.isLaunchable, isTrue);

      final pan = YyetsFileLink.fromJson(<String, Object?>{
        'address': 'https://pan.baidu.com/s/1abcDEF',
        'passwd': 'rr99',
        'way': 1,
        'way_name': '百度网盘',
      });
      expect(pan.hasPasswd, isTrue);
      expect(pan.displayText, 'https://pan.baidu.com/s/1abcDEF\n密码：rr99');
      expect(pan.wayLabel, 'way: 1');

      final empty = YyetsFileLink.fromJson(<String, Object?>{});
      expect(empty.hasAddress, isFalse);
      expect(empty.wayLabel, 'way: ');
      expect(empty.isLaunchable, isFalse);
    });
  });

  group('YyetsFileEntry', () {
    test('yyets:// 拼串与下载任务 id', () {
      final entry = YyetsFileEntry.fromJson(fileEntryJson());
      expect(
        entry.rrUri,
        'yyets://N=Three.Body.S01E01.1080p.mkv|S=1.4GB|H=5599182|',
      );
      expect(int.parse(entry.taskId), lessThanOrEqualTo(0));
      final other = YyetsFileEntry.fromJson(fileEntryJson(fileid: '777'));
      expect(other.taskId, isNot(entry.taskId));
      expect(entry.createTime, '2023-01-16 09:12:00');
    });
  });

  group('YyetsEdition / YyetsResourceDetail', () {
    test('foramt 拼写保留，首个版本默认展开', () {
      final edition = YyetsEdition.fromJson(
        <String, Object?>{
          'format_tip': 'HR-HDTV',
          'foramt': 'MKV',
          'size': '1.4G',
          'dateline': '1697000000',
          'files': <Object?>[
            <String, Object?>{'address': 'magnet:?xt=urn:btih:A'},
            <String, Object?>{'address': '   '},
          ],
        },
      );
      expect(edition.format, 'MKV');
      expect(edition.formatLabel, 'HR-HDTV\t\t\tMKV');
      expect(edition.hasSize, isTrue);
      expect(edition.dateline, 1697000000);
      expect(edition.isDefaultExpanded(0), isTrue);
      expect(edition.isDefaultExpanded(1), isFalse);
      expect(edition.launchableFiles.length, 1);
    });

    test('item_app 缺失时不能边下边播', () {
      final detail = YyetsResourceDetail.fromJson(<String, Object?>{
        'item_list': <Object?>[
          <String, Object?>{'foramt': 'MP4'},
        ],
      });
      expect(detail.editions.single.format, 'MP4');
      expect(detail.canDownloadAndPlay, isFalse);
      expect(detail.downloadAndPlayUri, isNull);
      expect(detail.isEmpty, isFalse);
      expect(detail.editionsWithFiles, isEmpty);
      expect(detail.raw['item_list'], isNotNull);

      expect(YyetsResourceDetail.empty.isEmpty, isTrue);
      expect(
        YyetsResourceDetail.fromJson(<String, Object?>{}).isEmpty,
        isTrue,
      );
    });
  });

  group('YyetsEpisode / YyetsSeason / YyetsResourceItem', () {
    test('未播集不可点，播放时间回退', () {
      final episode = YyetsEpisode.fromJson(<String, Object?>{
        'episode': 2,
        'play_status_cn': '未播',
      });
      expect(episode.episode, '2');
      expect(episode.isUnbroadcast, isTrue);
      expect(episode.canOpen, isFalse);
      expect(episode.playTimeLabel, '无时间');

      final played = YyetsEpisode.fromJson(<String, Object?>{
        'episode': '1',
        'play_status': 1,
        'play_status_cn': '已播',
        'play_time': '2023-01-15',
        'itemid': 'it-1',
      });
      expect(played.canOpen, isTrue);
      expect(played.playTimeLabel, '2023-01-15');
      expect(
        played.resourceArguments(id: '90001', season: '1', seasonCn: '第一季'),
        <String, String>{
          'id': '90001',
          'episode': '1',
          'season': '1',
          'season_cn': '第一季',
          'itemid': 'it-1',
        },
      );
      expect(
        episode.resourceArguments(id: '90001', season: '1'),
        <String, String>{'id': '90001', 'episode': '2', 'season': '1'},
      );
    });

    test('季名回退与电影条目参数', () {
      expect(
        YyetsSeason.fromJson(<String, Object?>{'season': 3}).label,
        '第3季',
      );
      final item = YyetsResourceItem.fromJson(<String, Object?>{
        'number': 'HDTV-MP4',
        'name': 'item-1',
        'play': 1,
      });
      expect(item.number, 'HDTV-MP4');
      expect(item.play, isTrue);
      expect(
        item.resourceArguments(id: '90001', itemId: 'it-1', channel: 'tv'),
        <String, String>{'id': '90001', 'itemid': 'it-1', 'channel': 'tv'},
      );
      expect(
        YyetsResourceItem.fromJson(<String, Object?>{}).play,
        isFalse,
      );
    });
  });

  group('YyetsNewsItem / YyetsSession', () {
    test('微博与文章两种来源的回退链', () {
      final article = YyetsNewsItem.fromJson(newsJson());
      expect(article.isWeibo, isFalse);
      expect(article.isVideo, isFalse);
      expect(article.content, '官方公布主创阵容。');
      expect(article.author, '人人影视');
      expect(article.likeCount, 36);
      expect(article.webUrl, 'http://m1.rryslink.com/article/771');

      final weibo = YyetsNewsItem.fromJson(weiboNewsJson());
      expect(weibo.isWeibo, isTrue);
      expect(weibo.isVideo, isTrue);
      expect(weibo.imageUrl, 'https://img.zmzapi.com/news/772.jpg');
      expect(weibo.author, 'YYeTs');
      expect(weibo.userPic, 'https://img.zmzapi.com/u/2.jpg');
      expect(weibo.likeCount, 77);
      expect(weibo.dateline, 1697100000);
      expect(weibo.webUrl, 'https://weibo.com/1/def');
      expect(
        YyetsNewsItem.fromJson(<String, Object?>{'url': 'https://weibo.com/x'}).webUrl,
        'http://m1.rryslink.com/article/',
      );
    });

    test('登录态与拦截器参数', () {
      expect(YyetsSession.anonymous.isLoggedIn, isFalse);
      expect(YyetsSession.anonymous.authQuery, isEmpty);
      expect(
        const YyetsSession(uid: 'u-1', token: '').isLoggedIn,
        isFalse,
      );
      const session = YyetsSession(uid: 'u-1', token: 't-9');
      expect(session.isLoggedIn, isTrue);
      expect(session.authQuery, <String, String>{'uid': 'u-1', 'token': 't-9'});
      expect(
        YyetsSession.fromUserJson(<String, dynamic>{'uid': 12, 'token': 'tt'})
            .authQuery,
        <String, String>{'uid': '12', 'token': 'tt'},
      );
    });
  });
}

void _pagingTests() {
  group('YyetsPaging', () {
    test('空页 → 没有更多；有数据 → 页码前进', () {
      final paging = YyetsPaging<String>();
      expect(paging.page, 1);
      expect(paging.canLoadMore, isTrue);
      expect(paging.append(<String>['a', 'b']), 2);
      expect(paging.items, <String>['a', 'b']);
      expect(paging.page, 2);
      expect(paging.append(<String>[]), 0);
      expect(paging.noMore, isTrue);
      expect(paging.canLoadMore, isFalse);
    });

    test('加载中 / 失败时不能继续翻页，reset 回到初始态', () {
      final paging = YyetsPaging<String>(items: <String>['a']);
      paging.loading = true;
      expect(paging.canLoadMore, isFalse);
      paging.fail();
      expect(paging.hasError, isTrue);
      expect(paging.loading, isFalse);
      expect(paging.canLoadMore, isFalse);

      paging.page = 4;
      paging.noMore = true;
      paging.reset();
      expect(paging.items, isEmpty);
      expect(paging.page, 1);
      expect(paging.noMore, isFalse);
      expect(paging.hasError, isFalse);
      expect(paging.canLoadMore, isTrue);
      expect(paging.isEmpty, isTrue);
    });
  });
}

// -----------------------------------------------------------------------------
// Widget 测试
// -----------------------------------------------------------------------------

void _widgetTests() {
  testWidgets('榜单首页渲染 6 个 tab，点击卡片进入详情', (tester) async {
    final adapter = FakeAdapter((request) {
      if (request.path.contains('a=HOT')) {
        return envelopeBody(
          data: <String, Object?>{
            'today_list': <Object?>[movieJson(id: '90001', cnname: '三体')],
          },
        );
      }
      if (request.path.contains('a=resource&rid=')) {
        return envelopeBody(data: detailJson());
      }
      return envelopeBody(data: <String, Object?>{});
    });
    final api = YyetsApi(dio: Dio()..httpClientAdapter = adapter);

    tester.view.physicalSize = const Size(1000, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(host(YyetsHomePage(api: api)));
    await tester.pumpAndSettle();

    expect(find.text('人人影视'), findsOneWidget);
    expect(find.text('今日'), findsOneWidget);
    expect(find.text('本月'), findsOneWidget);
    expect(find.text('三体'), findsOneWidget);
    expect(find.text('大陆 · 9.1 · 已完结'), findsOneWidget);

    // 切到空榜单：源工程同样展示空态
    await tester.ensureVisible(find.text('全部'));
    await tester.tap(find.text('全部'));
    await tester.pumpAndSettle();
    expect(find.text('榜单暂无数据'), findsOneWidget);

    await tester.ensureVisible(find.text('今日'));
    await tester.tap(find.text('今日'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('三体'));
    await tester.pumpAndSettle();

    expect(find.text('相似推荐'), findsOneWidget);
    expect(find.text('流浪地球'), findsOneWidget);
    expect(find.text('地球往事。'), findsOneWidget);
    expect(find.text('神作'), findsOneWidget);
  });

  testWidgets('榜单加载失败展示错误与重试', (tester) async {
    var calls = 0;
    final api = apiWith((request) {
      calls += 1;
      if (calls == 1) {
        return envelopeBody(
          data: <String, Object?>{},
          status: 0,
          info: '榜单维护中',
        );
      }
      return envelopeBody(
        data: <String, Object?>{
          'today_list': <Object?>[movieJson(cnname: '恢复后的剧')],
        },
      );
    });

    await tester.pumpWidget(host(YyetsHomePage(api: api)));
    await tester.pumpAndSettle();

    expect(find.text('榜单维护中'), findsOneWidget);
    expect(find.text('重试'), findsOneWidget);

    await tester.tap(find.text('重试'));
    await tester.pumpAndSettle();
    expect(find.text('恢复后的剧'), findsOneWidget);
  });

  testWidgets('搜索页提交关键字后展示结果', (tester) async {
    final adapter = FakeAdapter((request) {
      final page = YyetsJson.asInt(request.uriQuery['page']);
      if (request.path.contains('a=search')) {
        return envelopeBody(
          data: <String, Object?>{
            'list': page == 1
                ? <Object?>[
                    movieJson(id: '', itemid: '88123', cnname: '漫长的季节'),
                  ]
                : <Object?>[],
          },
        );
      }
      return envelopeBody(data: <String, Object?>{});
    });
    final api = YyetsApi(dio: Dio()..httpClientAdapter = adapter);

    await tester.pumpWidget(host(YyetsSearchPage(api: api)));
    await tester.pumpAndSettle();
    expect(find.text('输入关键字搜索影视'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '三体');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(find.text('漫长的季节(Three-Body)'), findsOneWidget);
    expect(adapter.last.uriQuery['k'], '三体');
    expect(adapter.last.uriQuery['page'], '1');
  });

  testWidgets('搜索无结果时展示空态文案', (tester) async {
    final api = apiReturning(<String, Object?>{'list': <Object?>[]});
    await tester.pumpWidget(
      host(YyetsSearchPage(api: api, initialQuery: '不存在的片')),
    );
    await tester.pumpAndSettle();
    expect(find.text('没有找到「不存在的片」相关的影视'), findsOneWidget);
  });

  testWidgets('资源页展示版本与链接，点击交给 launcher', (tester) async {
    final adapter = FakeAdapter(
      (request) => envelopeBody(data: resourceDetailJson()),
    );
    final api = YyetsApi(dio: Dio()..httpClientAdapter = adapter);
    final launcher = RecordingLauncher();

    await tester.pumpWidget(
      host(
        YyetsResourcePage(
          id: '90001',
          itemid: 'it-1',
          channel: 'tv',
          season: '1',
          episode: '1',
          title: '三体 第一季 第1集',
          api: api,
          launcher: launcher,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('三体 第一季 第1集'), findsOneWidget);
    expect(find.text('边下边播'), findsOneWidget);
    expect(find.text('HR-HDTV   MKV'), findsOneWidget);
    expect(find.text('1.4G'), findsOneWidget);
    expect(adapter.last.uriQuery['a'], 'resource_item');
    expect(adapter.last.uriQuery['episode'], '1');

    await tester.tap(find.text('magnet:?xt=urn:btih:ABCDEF123456'));
    await tester.pumpAndSettle();
    expect(launcher.opened, <String>['magnet:?xt=urn:btih:ABCDEF123456']);
    expect(find.text('已打开：磁力链接'), findsOneWidget);
    // 让 SnackBar 自己消失，避免残留定时器
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    // 第二个版本默认折叠，展开后才渲染 ed2k 链接
    expect(find.text('ed2k://|file|demo.mkv|123|HASH|/'), findsNothing);
    await tester.ensureVisible(find.text('MP4   MP4'));
    await tester.tap(find.text('MP4   MP4'));
    await tester.pumpAndSettle();
    expect(find.text('ed2k://|file|demo.mkv|123|HASH|/'), findsOneWidget);
  });

  testWidgets('资源页空数据展示空态', (tester) async {
    final api = apiReturning(<String, Object?>{'item_list': <Object?>[]});
    await tester.pumpWidget(
      host(YyetsResourcePage(id: '90001', api: api)),
    );
    await tester.pumpAndSettle();
    expect(find.text('资源详情'), findsOneWidget);
    expect(find.text('暂无可用资源'), findsOneWidget);
  });

  testWidgets('资源库页加载列表、打开磁力、搜索', (tester) async {
    final adapter = FakeAdapter((request) {
      if (request.path.contains('/file/search')) {
        return jsonBody(<Object?>[
          fileEntryJson(
            fileid: '1',
            fileName: '搜索结果.mkv',
            magnet: 'magnet:?xt=urn:btih:SEARCH',
          ),
        ]);
      }
      return jsonBody(<Object?>[
        fileEntryJson(),
        fileEntryJson(
          fileid: '5599183',
          fileName: 'No.Magnet.mkv',
          magnet: '',
          fileSize: '2.2GB',
          createTime: '2024-02-02 10:00:00',
        ),
      ]);
    });
    final api = YyetsApi(dio: Dio()..httpClientAdapter = adapter);
    final launcher = RecordingLauncher();

    await tester.pumpWidget(
      host(YyetsLatestResourcePage(api: api, launcher: launcher)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Three.Body.S01E01.1080p.mkv'), findsOneWidget);
    expect(find.text('1.4GB · 2023-01-16 09:12:00'), findsOneWidget);
    expect(adapter.requests.first.uriQuery['page'], '1');

    await tester.tap(find.text('Three.Body.S01E01.1080p.mkv'));
    await tester.pumpAndSettle();
    expect(launcher.opened, <String>['magnet:?xt=urn:btih:DEADBEEF']);

    // 没有磁力链接的条目不可点
    await tester.tap(find.text('No.Magnet.mkv'));
    await tester.pumpAndSettle();
    expect(launcher.opened.length, 1);

    await tester.enterText(find.byType(TextField), '三体');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(adapter.last.path, contains('http://file.apicvn.com/file/search'));
    expect(adapter.last.uriQuery['keyword'], '三体');
    expect(find.text('搜索结果.mkv'), findsOneWidget);
  });

  testWidgets('收藏页与资讯页渲染接口数据', (tester) async {
    final adapter = FakeAdapter((request) {
      if (request.path.contains('a=fav_list')) {
        return envelopeBody(
          data: <Object?>[
            <String, Object?>{
              'detail': movieJson(id: '1', cnname: '已收藏的剧'),
            },
          ],
        );
      }
      if (request.path.contains('a=new_article_list')) {
        return envelopeBody(data: <Object?>[newsJson()]);
      }
      return envelopeBody(data: <Object?>{});
    });
    final api = YyetsApi(dio: Dio()..httpClientAdapter = adapter);
    final launcher = RecordingLauncher();

    await tester.pumpWidget(host(YyetsFavoritesPage(api: api)));
    await tester.pumpAndSettle();
    expect(find.text('我的收藏'), findsOneWidget);
    expect(find.text('已收藏的剧(Three-Body)'), findsOneWidget);

    await tester.pumpWidget(host(YyetsNewsPage(api: api, launcher: launcher)));
    await tester.pumpAndSettle();
    expect(find.text('人人影视资讯'), findsOneWidget);
    expect(find.text('《三体》第二季开机'), findsOneWidget);
    // 源工程资讯列表只展示作者 / 视频标记 / 点赞数
    expect(find.text('人人影视 · 赞 36'), findsOneWidget);

    await tester.tap(find.text('《三体》第二季开机'));
    await tester.pumpAndSettle();
    expect(launcher.opened, <String>['http://m1.rryslink.com/article/771']);
  });

  testWidgets('YyetsStatusView 三态与重试回调', (tester) async {
    var retried = 0;
    await tester.pumpWidget(
      host(YyetsStatusView(error: '接口维护中', onRetry: () => retried += 1)),
    );
    expect(find.text('接口维护中'), findsOneWidget);
    await tester.tap(find.text('重试'));
    expect(retried, 1);

    await tester.pumpWidget(host(const YyetsStatusView(emptyText: '暂无可用资源')));
    expect(find.text('暂无可用资源'), findsOneWidget);

    await tester.pumpWidget(host(const YyetsStatusView(loading: true)));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpWidget(host(const YyetsStatusView()));
    expect(find.byType(SizedBox), findsWidgets);
  });

  testWidgets('YyetsLinkLauncher 丢掉非法地址，合法地址走注入回调', (tester) async {
    final opened = <Uri>[];
    final launcher = YyetsLinkLauncher(
      launch: (uri) async {
        opened.add(uri);
        return true;
      },
    );
    expect(await launcher.open('   '), isFalse);
    expect(await launcher.open('不是链接'), isFalse);
    expect(await launcher.open('magnet:?xt=urn:btih:ABC'), isTrue);
    expect(opened.single.scheme, 'magnet');

    final failing = YyetsLinkLauncher(launch: (uri) async => false);
    expect(await failing.open('https://example.com/a'), isFalse);
  });
}
