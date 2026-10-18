import 'dart:async';
import 'dart:convert';

import 'package:dashboard/features/movie/dytt/dytt_api.dart';
import 'package:dashboard/features/movie/dytt/dytt_api_exception.dart';
import 'package:dashboard/features/movie/dytt/dytt_category.dart';
import 'package:dashboard/features/movie/dytt/dytt_channel_signature.dart';
import 'package:dashboard/features/movie/dytt/dytt_detail_controller.dart';
import 'package:dashboard/features/movie/dytt/dytt_detail_page.dart';
import 'package:dashboard/features/movie/dytt/dytt_endpoint.dart';
import 'package:dashboard/features/movie/dytt/dytt_error_message.dart';
import 'package:dashboard/features/movie/dytt/dytt_headers.dart';
import 'package:dashboard/features/movie/dytt/dytt_list_controller.dart';
import 'package:dashboard/features/movie/dytt/dytt_list_page.dart';
import 'package:dashboard/features/movie/dytt/dytt_movie_detail.dart';
import 'package:dashboard/features/movie/dytt/dytt_movie_tile.dart';
import 'package:dashboard/features/movie/dytt/dytt_page.dart';
import 'package:dashboard/features/movie/dytt/dytt_play_url.dart';
import 'package:dashboard/features/movie/dytt/dytt_playback.dart';
import 'package:dashboard/features/movie/dytt/dytt_search_page.dart';
import 'package:dashboard/features/movie/dytt/dytt_signature.dart';
import 'package:dashboard/features/movie/dytt/dytt_signature_unavailable.dart';
import 'package:dashboard/features/movie/dytt/dytt_signing_notice.dart';
import 'package:dashboard/features/movie/dytt/dytt_unsupported_signature.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  _endpointAndCategoryTests();
  _headerTests();
  _modelTests();
  _apiTests();
  _controllerTests();
  _widgetTests();
}

// -----------------------------------------------------------------------------
// 无网络替身
// -----------------------------------------------------------------------------

class _Recorded {
  _Recorded(this.path, this.data, this.headers, this.uri);

  final String path;
  final Object? data;
  final Map<String, dynamic> headers;
  final Uri uri;

  Map<String, String> get form => _formFields(data);
}

typedef _Handler = FutureOr<ResponseBody> Function(_Recorded request);

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.handler);

  _Handler handler;
  final List<_Recorded> requests = <_Recorded>[];
  bool closed = false;

  _Recorded get last => requests.last;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final recorded = _Recorded(
      options.path,
      options.data,
      <String, dynamic>{...options.headers},
      options.uri,
    );
    requests.add(recorded);
    return handler(recorded);
  }

  @override
  void close({bool force = false}) {
    closed = true;
  }
}

ResponseBody _jsonBody(Object? payload, {int status = 200}) =>
    ResponseBody.fromString(
      jsonEncode(payload),
      status,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );

Map<String, String> _formFields(Object? data) {
  if (data is String) return Uri.splitQueryString(data);
  if (data is Map) {
    return data.map((key, value) => MapEntry('$key', '$value'));
  }
  return <String, String>{};
}

Map<String, String> _lowerHeaders(Map<String, dynamic> headers) =>
    headers.map((key, value) => MapEntry(key.toLowerCase(), '$value'));

/// 固定 key 的可用签名器，记录每次被要求签名的时间戳。
class _FixedSignature implements DyttSignature {
  _FixedSignature([this.key = 'signed-key-001']);

  final String key;
  final List<int> timestamps = <int>[];

  @override
  bool get isSupported => true;

  @override
  Future<String> sign(int timestampSeconds) async {
    timestamps.add(timestampSeconds);
    return key;
  }
}

DyttApi _apiWith(
  _FakeAdapter adapter, {
  DyttSignature? signature,
  DateTime Function()? now,
}) {
  return DyttApi(
    dio: Dio()..httpClientAdapter = adapter,
    signature: signature ?? _FixedSignature(),
    now: now,
  );
}

const List<Map<String, Object?>> _listRows = <Map<String, Object?>>[
  <String, Object?>{
    'id': 17094,
    'categoryId': 8,
    'name': '海贼王one PIECE 第852话',
    'publishTime': '2018-09-03',
  },
  <String, Object?>{
    'id': 17095,
    'categoryId': 9,
    'name': '名侦探柯南 第900话',
  },
];

Map<String, Object?> _listPayload({List<Map<String, Object?>>? rows}) =>
    <String, Object?>{'total': 161, 'rows': rows ?? _listRows};

const String _ftpDownloadUrl =
    'ftp://ygdy8:ygdy8@yg76.dydytt.net:5375/'
    '[阳光电影-www.ygdy8.com]致亲爱的法官大人-01+02.mp4;'
    'ftp://ygdy8:ygdy8@yg76.dydytt.net:5375/'
    '[阳光电影-www.ygdy8.com]致亲爱的法官大人-03+04.mp4;';

const String _httpDownloadUrl =
    'https://v.example.com/dytt/zhifa-01.mp4;'
    'ftp://ygdy8:ygdy8@yg76.dydytt.net:5375/zhifa-01.mp4;'
    'http://v.example.com/dytt/zhifa-02.mp4';

Map<String, Object?> _detailPayload({
  String downloadUrl = _httpDownloadUrl,
  String homePicUrl = '',
  String content = '致亲爱的法官大人 第24集',
}) => <String, Object?>{
  'id': 22683,
  'categoryId': 6,
  'name': '2018韩国SBS水木剧《致亲爱的法官大人》第24集[韩语中字]',
  'publishTime': '2018-09-07',
  'homePicUrl': homePicUrl,
  'pics': 'upload/',
  'downloadUrl': downloadUrl,
  'content': content,
};

// -----------------------------------------------------------------------------
// 端点与分类
// -----------------------------------------------------------------------------

void _endpointAndCategoryTests() {
  test('端点常量与源工程 networkapi.dart 逐字符一致', () {
    expect(DyttEndpoint.origin, 'http://m.dydytt.net:8080');
    expect(DyttEndpoint.movieListPath, '/adminapi/api/movieList.json');
    expect(DyttEndpoint.movieDetailPath, '/adminapi/api/movieDetail.json');
    expect(
      DyttEndpoint.movieListUrl,
      'http://m.dydytt.net:8080/adminapi/api/movieList.json',
    );
    expect(
      DyttEndpoint.movieDetailUrl,
      'http://m.dydytt.net:8080/adminapi/api/movieDetail.json',
    );
  });

  test('10 个标签的分类 ID 与 getCategoryIdByTab() 一致', () {
    expect(
      DyttCategory.values.map((category) => category.categoryId).toList(),
      <int>[9, 10, 1, 2, 3, 4, 5, 6, 7, 8],
    );
  });

  test('10 个标签的文案与源工程 Strings.tab1..tab10 一致', () {
    expect(
      DyttCategory.values.map((category) => category.label).toList(),
      <String>['最新电影', '综合电影', '华语电影', '欧美电影', '日韩电影', '华语电视', '欧美电视', '日韩电视', '综艺', '动漫'],
    );
  });

  test('枚举顺序稳定，动漫是第 10 个标签', () {
    expect(DyttCategory.values.length, 10);
    expect(DyttCategory.values.first, DyttCategory.latest);
    expect(DyttCategory.values.last, DyttCategory.anime);
    expect(DyttCategory.anime.categoryId, 8);
    expect(DyttCategory.anime.label, '动漫');
  });
}

// -----------------------------------------------------------------------------
// 请求头与签名
// -----------------------------------------------------------------------------

void _headerTests() {
  test('时间戳按毫秒除以 1000 向上取整', () {
    expect(
      DyttHeaders.timestampSeconds(DateTime.fromMillisecondsSinceEpoch(1536300000123)),
      1536300001,
    );
    expect(
      DyttHeaders.timestampSeconds(DateTime.fromMillisecondsSinceEpoch(1536300000000)),
      1536300000,
    );
  });

  test('三个请求头的键名与源工程完全一致', () {
    expect(DyttHeaders.timestampHeader, 'x-header-request-timestamp');
    expect(DyttHeaders.keyHeader, 'x-header-request-key');
    expect(DyttHeaders.imeiHeader, 'x-header-request-imei');
  });

  test('build() 只产出三个头，imei 固定为空串', () async {
    final signature = _FixedSignature('k-42');
    final headers = DyttHeaders(
      signature: signature,
      now: () => DateTime.fromMillisecondsSinceEpoch(1536300000123),
    );

    final result = await headers.build();

    expect(result, <String, String>{
      'x-header-request-timestamp': '1536300001',
      'x-header-request-key': 'k-42',
      'x-header-request-imei': '',
    });
  });

  test('签名与时间戳来自同一次取时', () async {
    final signature = _FixedSignature();
    final headers = DyttHeaders(
      signature: signature,
      now: () => DateTime.fromMillisecondsSinceEpoch(1600000000999),
    );

    final result = await headers.build();

    expect(signature.timestamps, <int>[1600000001]);
    expect(result['x-header-request-timestamp'], '1600000001');
    expect(result['x-header-request-key'], 'signed-key-001');
  });

  test('默认签名器明确报告不支持', () {
    const signature = DyttUnsupportedSignature();
    expect(signature.isSupported, isFalse);
  });

  test('默认签名器抛出的异常说明原生 .so 缺口', () async {
    const signature = DyttUnsupportedSignature();
    await expectLater(
      signature.sign(1),
      throwsA(
        isA<DyttSignatureUnavailable>().having(
          (error) => error.reason,
          'reason',
          contains('Dart 侧无法推导'),
        ),
      ),
    );
  });

  test('签名异常同时给出可展示的 message', () {
    const error = DyttSignatureUnavailable('测试原因');
    expect(error.message, '签名不可用：测试原因');
    expect(error.toString(), error.message);
  });

  test('通道名、方法名与源工程 keyutil.dart 一致', () {
    expect(DyttChannelSignature.channel.name, 'com.bzh.dytt/key_utils');
    expect(DyttChannelSignature.method, 'getHeaderKey');
  });

  test('通道签名器把秒级时间戳交给 getHeaderKey', () async {
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(DyttChannelSignature.channel, (call) async {
          calls.add(call);
          return 'native-key';
        });
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(DyttChannelSignature.channel, null);
    });

    final key = await const DyttChannelSignature().sign(1536300001);

    expect(key, 'native-key');
    expect(calls.single.method, 'getHeaderKey');
    expect(calls.single.arguments, 1536300001);
  });

  test('原生返回空值时转为签名不可用，而不是空 key', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          DyttChannelSignature.channel,
          (call) async => null,
        );
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(DyttChannelSignature.channel, null);
    });

    await expectLater(
      const DyttChannelSignature().sign(1),
      throwsA(
        isA<DyttSignatureUnavailable>().having(
          (error) => error.reason,
          'reason',
          contains('空值'),
        ),
      ),
    );
  });

  test('通道缺失时报告宿主没有注册通道', () async {
    await expectLater(
      const DyttChannelSignature().sign(1),
      throwsA(
        isA<DyttSignatureUnavailable>().having(
          (error) => error.reason,
          'reason',
          contains('没有注册'),
        ),
      ),
    );
  });

  test('原生 PlatformException 被翻译成签名不可用', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(DyttChannelSignature.channel, (call) async {
          throw PlatformException(code: 'boom', message: 'native failed');
        });
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(DyttChannelSignature.channel, null);
    });

    await expectLater(
      const DyttChannelSignature().sign(1),
      throwsA(
        isA<DyttSignatureUnavailable>().having(
          (error) => error.reason,
          'reason',
          contains('native failed'),
        ),
      ),
    );
  });
}

// -----------------------------------------------------------------------------
// 模型
// -----------------------------------------------------------------------------

void _modelTests() {
  test('详情 JSON 的 8 个字段按源工程键名解析', () {
    final movie = DyttMovieDetail.fromJson(<String, dynamic>{
      ..._detailPayload(),
      'isPrefect': true,
    });

    expect(movie.id, 22683);
    expect(movie.categoryId, 6);
    expect(movie.name, '2018韩国SBS水木剧《致亲爱的法官大人》第24集[韩语中字]');
    expect(movie.publishTime, '2018-09-07');
    expect(movie.homePicUrl, '');
    expect(movie.pics, 'upload/');
    expect(movie.downloadUrl, _httpDownloadUrl);
    expect(movie.content, '致亲爱的法官大人 第24集');
    expect(movie.isPrefect, isFalse);
  });

  test('列表行缺少可选字段时落成空串而不是解析失败', () {
    final movie = DyttMovieDetail.fromJson(<String, dynamic>{
      'id': 17095,
      'categoryId': 9,
      'name': '名侦探柯南 第900话',
    });

    expect(movie.publishTime, '');
    expect(movie.homePicUrl, '');
    expect(movie.pics, '');
    expect(movie.downloadUrl, '');
    expect(movie.content, '');
  });

  test('整数字段接受字符串形态，缺失时抛 FormatException', () {
    final movie = DyttMovieDetail.fromJson(<String, dynamic>{
      'id': '17094',
      'categoryId': '8',
      'name': '海贼王',
    });
    expect(movie.id, 17094);
    expect(movie.categoryId, 8);

    expect(
      () => DyttMovieDetail.fromJson(<String, dynamic>{
        'categoryId': 8,
        'name': '缺 id',
      }),
      throwsA(
        isA<FormatException>().having(
          (error) => error.message,
          'message',
          '电影天堂 JSON 缺少整数字段 id',
        ),
      ),
    );
  });

  test('toJson() 保留源工程 8 个键与顺序，不含 isPrefect', () {
    final json = DyttMovieDetail.fromJson(<String, dynamic>{
      ..._detailPayload(),
      'isPrefect': true,
    }).toJson();

    expect(json.keys.toList(), <String>[
      'id',
      'categoryId',
      'name',
      'publishTime',
      'homePicUrl',
      'content',
      'pics',
      'downloadUrl',
    ]);
    expect(json['id'], 22683);
    expect(json['downloadUrl'], _httpDownloadUrl);
  });

  test('相等性只看 runtimeType + id + categoryId', () {
    const a = DyttMovieDetail(id: 1, categoryId: 2, name: 'A');
    const b = DyttMovieDetail(id: 1, categoryId: 2, name: 'B');
    const c = DyttMovieDetail(id: 1, categoryId: 3, name: 'A');

    expect(a, b);
    expect(a.hashCode, b.hashCode);
    expect(a, isNot(c));
    expect(a.toString(), 'DyttMovieDetail(1, 2, A)');
  });

  test('DyttPlayUrl 解析 ftp 地址并保留原始文本', () {
    final url = DyttPlayUrl.parse(_ftpDownloadUrl.split(';').first);

    expect(url.scheme, 'ftp');
    expect(url.isPlayable, isFalse);
    expect(url.raw, startsWith('ftp://ygdy8:ygdy8@yg76.dydytt.net:5375/'));
    expect(url.fileName, endsWith('-01+02.mp4'));
  });

  test('DyttPlayUrl 去空白，http/https 可播放', () {
    final url = DyttPlayUrl.parse('  https://v.example.com/a/b.mp4  ');

    expect(url.raw, 'https://v.example.com/a/b.mp4');
    expect(url.uri, Uri.parse('https://v.example.com/a/b.mp4'));
    expect(url.isPlayable, isTrue);
    expect(url.fileName, 'b.mp4');
  });

  test('DyttPlayUrl 拒绝空串与无 scheme 的文本', () {
    expect(() => DyttPlayUrl.parse('   '), throwsFormatException);
    expect(() => DyttPlayUrl.parse('not a url'), throwsFormatException);
  });

  test('DyttPlayback 拆开分号分隔的地址并丢弃空项', () {
    final playback = DyttPlayback.fromDownloadUrl(
      ';https://v.example.com/a.mp4;;ftp://x/y.mp4;',
    );

    expect(playback.urls.length, 2);
    expect(playback.urls.first.raw, 'https://v.example.com/a.mp4');
    expect(playback.hasPlayable, isTrue);
  });

  test('DyttPlayback 只把 HTTP(S) 交给播放器', () {
    final playback = DyttPlayback.fromDownloadUrl(_httpDownloadUrl);

    expect(playback.urls.length, 3);
    expect(
      playback.playable.map((url) => url.raw).toList(),
      <String>[
        'https://v.example.com/dytt/zhifa-01.mp4',
        'http://v.example.com/dytt/zhifa-02.mp4',
      ],
    );
  });

  test('纯 ftp 下载地址没有可播放线路', () {
    final playback = DyttPlayback.fromDownloadUrl(_ftpDownloadUrl);

    expect(playback.urls.length, 2);
    expect(playback.playable, isEmpty);
    expect(playback.hasPlayable, isFalse);
  });

  test('playableFrom 从第 N 条可播放线路取到末尾', () {
    final playback = DyttPlayback.fromDownloadUrl(_httpDownloadUrl);

    expect(
      playback.playableFrom(1).map((url) => url.raw).toList(),
      <String>['http://v.example.com/dytt/zhifa-02.mp4'],
    );
    expect(playback.playableFrom(1).single.raw, 'http://v.example.com/dytt/zhifa-02.mp4');
  });

  test('playableFrom 把越界索引夹到有效范围', () {
    final playback = DyttPlayback.fromDownloadUrl(_httpDownloadUrl);

    expect(playback.playableFrom(-5).length, 2);
    expect(playback.playableFrom(99).length, 1);
    expect(playback.playableFrom(99).single.raw, 'http://v.example.com/dytt/zhifa-02.mp4');
  });

  test('无地址时 playableFrom 返回空列表', () {
    expect(DyttPlayback.fromDownloadUrl('').playableFrom(0), isEmpty);
    expect(DyttPlayback.fromDownloadUrl(_ftpDownloadUrl).playableFrom(0), isEmpty);
  });
}

// -----------------------------------------------------------------------------
// API
// -----------------------------------------------------------------------------

void _apiTests() {
  test('列表请求是 POST 表单到 movieList.json，字段顺序固定', () async {
    final adapter = _FakeAdapter((request) => _jsonBody(_listPayload()));
    final api = _apiWith(adapter);

    final movies = await api.movieList(categoryId: 8, page: 1);

    expect(adapter.requests.length, 1);
    final request = adapter.last;
    expect(request.path, DyttEndpoint.movieListUrl);
    expect(request.uri, Uri.parse(DyttEndpoint.movieListUrl));
    expect(request.form.keys.toList(), <String>['categoryId', 'page', 'searchContent']);
    expect(request.form, <String, String>{
      'categoryId': '8',
      'page': '1',
      'searchContent': '',
    });
    final contentType = _lowerHeaders(request.headers)['content-type'];
    expect(contentType, startsWith('application/x-www-form-urlencoded'));
    expect(movies.length, 2);
    expect(movies.first.id, 17094);
    expect(movies.first.name, '海贼王one PIECE 第852话');
    expect(movies.last.publishTime, '');
  });

  test('每个请求都带上源站要求的三个签名头', () async {
    final signature = _FixedSignature('abc123');
    final adapter = _FakeAdapter((request) => _jsonBody(_listPayload()));
    final api = _apiWith(
      adapter,
      signature: signature,
      now: () => DateTime.fromMillisecondsSinceEpoch(1536300000123),
    );

    await api.movieList(categoryId: 9);

    final headers = _lowerHeaders(adapter.last.headers);
    expect(headers['x-header-request-timestamp'], '1536300001');
    expect(headers['x-header-request-key'], 'abc123');
    expect(headers['x-header-request-imei'], '');
    expect(signature.timestamps, <int>[1536300001]);
  });

  test('搜索把关键词放进 searchContent 并保留分页参数', () async {
    final adapter = _FakeAdapter((request) => _jsonBody(_listPayload()));
    final api = _apiWith(adapter);

    await api.movieList(categoryId: 9, page: 2, searchContent: '法官');

    expect(adapter.last.path, DyttEndpoint.movieListUrl);
    expect(adapter.last.form, <String, String>{
      'categoryId': '9',
      'page': '2',
      'searchContent': '法官',
    });
  });

  test('详情请求表单字段是 categoryId + movieDetailId', () async {
    final adapter = _FakeAdapter((request) => _jsonBody(_detailPayload()));
    final api = _apiWith(adapter);

    final movie = await api.movieDetail(categoryId: 6, movieDetailId: 22683);

    expect(adapter.last.path, DyttEndpoint.movieDetailUrl);
    expect(adapter.last.form, <String, String>{
      'categoryId': '6',
      'movieDetailId': '22683',
    });
    expect(movie.name, '2018韩国SBS水木剧《致亲爱的法官大人》第24集[韩语中字]');
    expect(movie.downloadUrl, _httpDownloadUrl);
  });

  test('详情响应缺少 rows 也不影响，因为详情是根对象', () async {
    final adapter = _FakeAdapter(
      (request) => _jsonBody(<String, Object?>{'id': 7, 'categoryId': 1, 'name': 'X'}),
    );
    final api = _apiWith(adapter);

    final movie = await api.movieDetail(categoryId: 1, movieDetailId: 7);

    expect(movie.id, 7);
    expect(movie.content, '');
  });

  test('列表响应没有 rows 数组时抛出模块异常', () async {
    final adapter = _FakeAdapter(
      (request) => _jsonBody(<String, Object?>{'total': 0}),
    );

    await expectLater(
      _apiWith(adapter).movieList(categoryId: 9),
      throwsA(
        isA<DyttApiException>().having(
          (error) => error.message,
          'message',
          '电影天堂列表响应缺少 rows 数组',
        ),
      ),
    );
  });

  test('rows 中的坏行被包装成列表解析失败', () async {
    final adapter = _FakeAdapter(
      (request) => _jsonBody(<String, Object?>{
        'rows': <Object?>[
          <String, Object?>{'id': 1, 'categoryId': 9, 'name': 'ok'},
          <String, Object?>{'categoryId': 9, 'name': '缺 id'},
        ],
      }),
    );

    await expectLater(
      _apiWith(adapter).movieList(categoryId: 9),
      throwsA(
        isA<DyttApiException>().having(
          (error) => error.message,
          'message',
          contains('电影天堂列表 JSON 解析失败：电影天堂 JSON 缺少整数字段 id'),
        ),
      ),
    );
  });

  test('rows 里混入非对象元素时明确报错', () async {
    final adapter = _FakeAdapter(
      (request) => _jsonBody(<String, Object?>{
        'rows': <Object?>['oops'],
      }),
    );

    await expectLater(
      _apiWith(adapter).movieList(categoryId: 9),
      throwsA(
        isA<DyttApiException>().having(
          (error) => error.message,
          'message',
          contains('rows 中存在非对象元素'),
        ),
      ),
    );
  });

  test('响应不是 JSON 对象时抛出模块异常', () async {
    final adapter = _FakeAdapter(
      (request) => _jsonBody(<Object?>[1, 2, 3]),
    );

    await expectLater(
      _apiWith(adapter).movieList(categoryId: 9),
      throwsA(
        isA<DyttApiException>().having(
          (error) => error.message,
          'message',
          '电影天堂响应不是 JSON 对象',
        ),
      ),
    );
  });

  test('2xx 中非 200 的响应也按 HTTP 错误处理', () async {
    final adapter = _FakeAdapter((request) => _jsonBody(<String, Object?>{}, status: 204));

    await expectLater(
      _apiWith(adapter).movieList(categoryId: 9),
      throwsA(
        isA<DyttApiException>()
            .having((error) => error.message, 'message', '电影天堂返回 HTTP 204')
            .having((error) => error.statusCode, 'statusCode', 204),
      ),
    );
  });

  test('500 响应被 Dio 转成带状态码的请求失败', () async {
    final adapter = _FakeAdapter((request) => _jsonBody(<String, Object?>{}, status: 500));

    await expectLater(
      _apiWith(adapter).movieList(categoryId: 9),
      throwsA(
        isA<DyttApiException>()
            .having((error) => error.message, 'message', startsWith('请求电影天堂失败：'))
            .having((error) => error.statusCode, 'statusCode', 500),
      ),
    );
  });

  test('默认签名器下列表请求一个字节都不会发出', () async {
    final adapter = _FakeAdapter((request) => _jsonBody(_listPayload()));
    final api = DyttApi(dio: Dio()..httpClientAdapter = adapter);

    expect(api.signingSupported, isFalse);
    await expectLater(
      api.movieList(categoryId: 9),
      throwsA(isA<DyttSignatureUnavailable>()),
    );
    expect(adapter.requests, isEmpty);
  });

  test('默认签名器下详情请求也不会发出', () async {
    final adapter = _FakeAdapter((request) => _jsonBody(_detailPayload()));
    final api = DyttApi(dio: Dio()..httpClientAdapter = adapter);

    await expectLater(
      api.movieDetail(categoryId: 6, movieDetailId: 22683),
      throwsA(isA<DyttSignatureUnavailable>()),
    );
    expect(adapter.requests, isEmpty);
  });

  test('注入可用签名器后 signingSupported 为 true', () {
    final adapter = _FakeAdapter((request) => _jsonBody(_listPayload()));
    expect(_apiWith(adapter).signingSupported, isTrue);
  });

  test('dispose 关闭底层 Dio 连接', () {
    final adapter = _FakeAdapter((request) => _jsonBody(_listPayload()));
    final api = _apiWith(adapter);

    api.dispose();

    expect(adapter.closed, isTrue);
  });

  test('错误文案统一从 dyttErrorMessage 取出', () {
    expect(
      dyttErrorMessage(const DyttApiException('列表失败')),
      '列表失败',
    );
    expect(
      dyttErrorMessage(const DyttSignatureUnavailable('不可用')),
      '签名不可用：不可用',
    );
    expect(dyttErrorMessage(StateError('boom')), contains('boom'));
  });
}

// -----------------------------------------------------------------------------
// 控制器
// -----------------------------------------------------------------------------

void _controllerTests() {
  test('列表控制器加载第 1 页并记录页码', () async {
    final adapter = _FakeAdapter((request) => _jsonBody(_listPayload()));
    final controller = DyttListController(api: _apiWith(adapter), categoryId: 9);
    addTearDown(controller.dispose);

    await controller.load();

    expect(controller.items.length, 2);
    expect(controller.items.first.id, 17094);
    expect(controller.page, 1);
    expect(controller.isLoading, isFalse);
    expect(controller.hasMore, isTrue);
    expect(controller.error, isNull);
    expect(adapter.last.form['page'], '1');
    expect(adapter.last.form['categoryId'], '9');
  });

  test('加载更多请求 page=2 并追加条目', () async {
    final adapter = _FakeAdapter((request) {
      final page = request.form['page'];
      return _jsonBody(
        _listPayload(
          rows: page == '1'
              ? _listRows
              : <Map<String, Object?>>[
                  <String, Object?>{'id': 17096, 'categoryId': 8, 'name': '第三项'},
                ],
        ),
      );
    });
    final controller = DyttListController(api: _apiWith(adapter), categoryId: 8);
    addTearDown(controller.dispose);

    await controller.load();
    await controller.loadMore();

    expect(controller.items.length, 3);
    expect(controller.items.last.id, 17096);
    expect(controller.page, 2);
    expect(adapter.requests.map((request) => request.form['page']).toList(), <String>['1', '2']);
  });

  test('空页说明没有更多，页码不再前进', () async {
    var call = 0;
    final adapter = _FakeAdapter((request) {
      call++;
      return _jsonBody(_listPayload(rows: call == 1 ? _listRows : const <Map<String, Object?>>[]));
    });
    final controller = DyttListController(api: _apiWith(adapter), categoryId: 8);
    addTearDown(controller.dispose);

    await controller.load();
    await controller.loadMore();
    await controller.loadMore();

    expect(controller.items.length, 2);
    expect(controller.page, 1);
    expect(controller.hasMore, isFalse);
    expect(adapter.requests.length, 2);
  });

  test('刷新清空旧条目并重新请求第 1 页', () async {
    final adapter = _FakeAdapter((request) => _jsonBody(_listPayload()));
    final controller = DyttListController(api: _apiWith(adapter), categoryId: 9);
    addTearDown(controller.dispose);

    await controller.load();
    await controller.loadMore();
    await controller.load(refresh: true);

    expect(controller.items.length, 2);
    expect(controller.page, 1);
    expect(adapter.requests.last.form['page'], '1');
  });

  test('首屏失败保留错误文案，重试后可恢复', () async {
    var fail = true;
    final adapter = _FakeAdapter((request) {
      if (fail) return _jsonBody(<String, Object?>{}, status: 500);
      return _jsonBody(_listPayload());
    });
    final controller = DyttListController(api: _apiWith(adapter), categoryId: 9);
    addTearDown(controller.dispose);

    await controller.load();
    expect(controller.items, isEmpty);
    expect(controller.error, startsWith('请求电影天堂失败：'));

    fail = false;
    await controller.load(refresh: true);
    expect(controller.error, isNull);
    expect(controller.items.length, 2);
  });

  test('加载更多失败只设置 moreError，已有条目保留', () async {
    var fail = false;
    final adapter = _FakeAdapter((request) {
      if (fail) return _jsonBody(<String, Object?>{}, status: 500);
      return _jsonBody(_listPayload());
    });
    final controller = DyttListController(api: _apiWith(adapter), categoryId: 9);
    addTearDown(controller.dispose);

    await controller.load();
    fail = true;
    await controller.loadMore();

    expect(controller.items.length, 2);
    expect(controller.moreError, startsWith('请求电影天堂失败：'));
    expect(controller.isLoadingMore, isFalse);
  });

  test('未加载时加载更多是空操作', () async {
    final adapter = _FakeAdapter((request) => _jsonBody(_listPayload()));
    final controller = DyttListController(api: _apiWith(adapter), categoryId: 9);
    addTearDown(controller.dispose);

    await controller.loadMore();

    expect(adapter.requests, isEmpty);
    expect(controller.page, 0);
  });

  test('签名不可用时控制器记录签名错误且没有请求', () async {
    final adapter = _FakeAdapter((request) => _jsonBody(_listPayload()));
    final controller = DyttListController(
      api: DyttApi(dio: Dio()..httpClientAdapter = adapter),
      categoryId: 9,
    );
    addTearDown(controller.dispose);

    await controller.load();

    expect(controller.error, startsWith('签名不可用：'));
    expect(controller.items, isEmpty);
    expect(adapter.requests, isEmpty);
  });

  test('释放后迟到的响应不会触发通知', () async {
    final completer = Completer<ResponseBody>();
    final adapter = _FakeAdapter((request) => completer.future);
    final controller = DyttListController(api: _apiWith(adapter), categoryId: 9);

    final loading = controller.load();
    controller.dispose();
    completer.complete(_jsonBody(_listPayload()));
    await loading;

    expect(controller.items, isEmpty);
  });

  test('详情控制器先用列表项占位，加载后换成完整详情', () async {
    final adapter = _FakeAdapter((request) => _jsonBody(_detailPayload()));
    final controller = DyttDetailController(
      api: _apiWith(adapter),
      categoryId: 8,
      movieId: 17094,
      initial: const DyttMovieDetail(id: 17094, categoryId: 8, name: '海贼王'),
    );
    addTearDown(controller.dispose);

    expect(controller.movie?.name, '海贼王');
    await controller.load();

    expect(controller.movie?.id, 22683);
    expect(controller.movie?.content, '致亲爱的法官大人 第24集');
    expect(adapter.last.form, <String, String>{
      'categoryId': '8',
      'movieDetailId': '17094',
    });
  });

  test('详情控制器失败时保留占位条目并给出错误', () async {
    final adapter = _FakeAdapter((request) => _jsonBody(<String, Object?>{}, status: 500));
    final controller = DyttDetailController(
      api: _apiWith(adapter),
      categoryId: 8,
      movieId: 17094,
      initial: const DyttMovieDetail(id: 17094, categoryId: 8, name: '海贼王'),
    );
    addTearDown(controller.dispose);

    await controller.load();

    expect(controller.movie?.name, '海贼王');
    expect(controller.error, startsWith('请求电影天堂失败：'));
    expect(controller.isLoading, isFalse);
  });

  test('详情控制器在签名不可用时报错且不发请求', () async {
    final adapter = _FakeAdapter((request) => _jsonBody(_detailPayload()));
    final controller = DyttDetailController(
      api: DyttApi(dio: Dio()..httpClientAdapter = adapter),
      categoryId: 8,
      movieId: 17094,
    );
    addTearDown(controller.dispose);

    await controller.load();

    expect(controller.error, startsWith('签名不可用：'));
    expect(adapter.requests, isEmpty);
  });
}

// -----------------------------------------------------------------------------
// 页面
// -----------------------------------------------------------------------------

void _widgetTests() {
  testWidgets('默认签名器下首页明示缺口且不发请求', (tester) async {
    final adapter = _FakeAdapter((request) => _jsonBody(_listPayload()));
    final api = DyttApi(dio: Dio()..httpClientAdapter = adapter);

    await tester.pumpWidget(MaterialApp(home: DyttPage(api: api)));
    await tester.pumpAndSettle();

    expect(find.text('电影天堂'), findsOneWidget);
    expect(find.byType(DyttSigningNotice), findsOneWidget);
    expect(find.text('签名不可用'), findsOneWidget);
    expect(find.text('签名不可用，未请求电影天堂接口'), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline), findsWidgets);
    expect(adapter.requests, isEmpty);
  });

  testWidgets('首页锁定图标弹出签名说明并可关闭', (tester) async {
    final api = DyttApi(dio: Dio()..httpClientAdapter = _FakeAdapter((request) => _jsonBody(_listPayload())));

    await tester.pumpWidget(MaterialApp(home: DyttPage(api: api)));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('签名不可用'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('知道了'), findsOneWidget);
    expect(find.textContaining('libkey-lib.so'), findsWidgets);

    await tester.tap(find.text('知道了'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('首页展示源工程 10 个标签', (tester) async {
    final api = DyttApi(dio: Dio()..httpClientAdapter = _FakeAdapter((request) => _jsonBody(_listPayload())));

    await tester.pumpWidget(MaterialApp(home: DyttPage(api: api)));
    await tester.pumpAndSettle();

    for (final label in <String>['最新电影', '综合电影', '华语电影', '欧美电影', '日韩电影', '华语电视', '欧美电视', '日韩电视', '综艺', '动漫']) {
      expect(find.text(label), findsOneWidget);
    }
  });

  testWidgets('签名可用时首页加载最新电影（categoryId=9）', (tester) async {
    final adapter = _FakeAdapter((request) => _jsonBody(_listPayload()));
    final api = _apiWith(adapter);

    await tester.pumpWidget(MaterialApp(home: DyttPage(api: api)));
    await tester.pumpAndSettle();

    expect(find.text('海贼王one PIECE 第852话'), findsOneWidget);
    expect(find.text('2018-09-03'), findsOneWidget);
    expect(adapter.requests.single.form['categoryId'], '9');
    expect(adapter.requests.single.form['page'], '1');
    expect(adapter.requests.single.form['searchContent'], '');
  });

  testWidgets('独立列表页用分类自己的 categoryId 请求', (tester) async {
    final adapter = _FakeAdapter((request) => _jsonBody(_listPayload()));
    final api = _apiWith(adapter);

    await tester.pumpWidget(
      MaterialApp(home: DyttListPage(category: DyttCategory.anime, api: api, showAppBar: true)),
    );
    await tester.pumpAndSettle();

    expect(find.text('动漫'), findsOneWidget);
    expect(adapter.requests.single.form['categoryId'], '8');
  });

  testWidgets('列表项缺字段时显示兜底文案', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DyttMovieTile(
            movie: const DyttMovieDetail(id: 1, categoryId: 9, name: ''),
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.text('未命名影片'), findsOneWidget);
    expect(find.text('发布时间未知'), findsOneWidget);
  });

  testWidgets('点列表项进入详情并用列表的 id/categoryId 请求详情', (tester) async {
    final adapter = _FakeAdapter((request) {
      if (request.path == DyttEndpoint.movieDetailUrl) {
        return _jsonBody(_detailPayload());
      }
      return _jsonBody(_listPayload());
    });
    final api = _apiWith(adapter);

    await tester.pumpWidget(
      MaterialApp(home: DyttListPage(category: DyttCategory.anime, api: api)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('海贼王one PIECE 第852话'));
    await tester.pumpAndSettle();

    expect(find.text('2018韩国SBS水木剧《致亲爱的法官大人》第24集[韩语中字]'), findsNWidgets(2));
    expect(find.text('致亲爱的法官大人 第24集'), findsOneWidget);
    expect(adapter.requests.length, 2);
    expect(adapter.last.path, DyttEndpoint.movieDetailUrl);
    expect(adapter.last.form, <String, String>{
      'categoryId': '8',
      'movieDetailId': '17094',
    });
  });

  testWidgets('详情页展示发布时间与可播放线路数量', (tester) async {
    final adapter = _FakeAdapter((request) => _jsonBody(_detailPayload()));
    final api = _apiWith(adapter);

    await tester.pumpWidget(
      MaterialApp(
        home: DyttDetailPage(
          api: api,
          movie: const DyttMovieDetail(id: 17094, categoryId: 8, name: '占位名'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('发布时间：2018-09-07'), findsOneWidget);
    expect(find.text('播放线路'), findsOneWidget);
    expect(find.text('播放（2 条线路）'), findsOneWidget);
    expect(find.text('线路 1'), findsOneWidget);
    expect(find.text('线路 2'), findsOneWidget);
    expect(find.text('zhifa-01.mp4'), findsOneWidget);
    expect(find.text('zhifa-02.mp4'), findsOneWidget);
  });

  testWidgets('纯 ftp 详情显示无法直接播放的说明', (tester) async {
    final adapter = _FakeAdapter(
      (request) => _jsonBody(_detailPayload(downloadUrl: _ftpDownloadUrl)),
    );
    final api = _apiWith(adapter);

    await tester.pumpWidget(
      MaterialApp(
        home: DyttDetailPage(
          api: api,
          movie: const DyttMovieDetail(id: 22683, categoryId: 6, name: '占位名'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('暂无可播放的 HTTP(S) 地址'), findsOneWidget);
    expect(find.textContaining('ftp/ed2k'), findsOneWidget);
    expect(find.textContaining('播放（'), findsNothing);
  });

  testWidgets('详情内容为空时显示源工程兜底文案', (tester) async {
    final adapter = _FakeAdapter(
      (request) => _jsonBody(_detailPayload(content: '')),
    );
    final api = _apiWith(adapter);

    await tester.pumpWidget(
      MaterialApp(
        home: DyttDetailPage(
          api: api,
          movie: const DyttMovieDetail(id: 22683, categoryId: 6, name: '占位名'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('还没有内容！请检查网络。'), findsOneWidget);
  });

  testWidgets('默认签名器下详情页不发请求', (tester) async {
    final adapter = _FakeAdapter((request) => _jsonBody(_detailPayload()));
    final api = DyttApi(dio: Dio()..httpClientAdapter = adapter);

    await tester.pumpWidget(
      MaterialApp(
        home: DyttDetailPage(
          api: api,
          movie: const DyttMovieDetail(id: 22683, categoryId: 6, name: '占位名'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('签名不可用，未请求电影天堂详情接口'), findsOneWidget);
    expect(adapter.requests, isEmpty);
  });

  testWidgets('搜索页提交前不发请求，提交后带关键词', (tester) async {
    final adapter = _FakeAdapter((request) => _jsonBody(_listPayload()));
    final api = _apiWith(adapter);

    await tester.pumpWidget(MaterialApp(home: DyttSearchPage(api: api)));
    await tester.pumpAndSettle();

    expect(find.text('搜索电影天堂'), findsOneWidget);
    expect(find.text('输入关键词后搜索'), findsOneWidget);
    expect(adapter.requests, isEmpty);

    await tester.enterText(find.byType(TextField), '  法官  ');
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();

    expect(adapter.requests.single.form, <String, String>{
      'categoryId': '9',
      'page': '1',
      'searchContent': '法官',
    });
    expect(find.text('海贼王one PIECE 第852话'), findsOneWidget);
  });

  testWidgets('空关键词提交不会发请求', (tester) async {
    final adapter = _FakeAdapter((request) => _jsonBody(_listPayload()));
    final api = _apiWith(adapter);

    await tester.pumpWidget(MaterialApp(home: DyttSearchPage(api: api)));
    await tester.enterText(find.byType(TextField), '   ');
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();

    expect(adapter.requests, isEmpty);
  });

  testWidgets('搜索页切换分类后用新 categoryId 搜索', (tester) async {
    final adapter = _FakeAdapter((request) => _jsonBody(_listPayload()));
    final api = _apiWith(adapter);

    await tester.pumpWidget(MaterialApp(home: DyttSearchPage(api: api)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('最新电影'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('动漫').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '柯南');
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();

    expect(adapter.requests.single.form['categoryId'], '8');
    expect(adapter.requests.single.form['searchContent'], '柯南');
  });

  testWidgets('默认签名器下搜索页禁发请求并明示缺口', (tester) async {
    final adapter = _FakeAdapter((request) => _jsonBody(_listPayload()));
    final api = DyttApi(dio: Dio()..httpClientAdapter = adapter);

    await tester.pumpWidget(MaterialApp(home: DyttSearchPage(api: api)));
    await tester.pumpAndSettle();

    expect(find.text('签名不可用，未发起搜索'), findsOneWidget);
    final button = tester.widget<IconButton>(
      find.ancestor(of: find.byIcon(Icons.search), matching: find.byType(IconButton)),
    );
    expect(button.onPressed, isNull);

    await tester.enterText(find.byType(TextField), '法官');
    await tester.pumpAndSettle();
    expect(adapter.requests, isEmpty);
  });

  testWidgets('签名提示写明原生通道与未发请求', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: DyttSigningNotice())),
    );

    expect(find.textContaining('com.bzh.dytt/key_utils.getHeaderKey()'), findsOneWidget);
    expect(find.textContaining('没有发出任何请求'), findsOneWidget);
    expect(find.textContaining('DyttSignature'), findsOneWidget);
  });
}
