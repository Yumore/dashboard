import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dashboard/features/short_video/douyin/douyin_api.dart';
import 'package:dashboard/features/short_video/douyin/douyin_api_exception.dart';
import 'package:dashboard/features/short_video/douyin/douyin_aweme.dart';
import 'package:dashboard/features/short_video/douyin/douyin_billboard_entry.dart';
import 'package:dashboard/features/short_video/douyin/douyin_count_formatter.dart';
import 'package:dashboard/features/short_video/douyin/douyin_detail_controller.dart';
import 'package:dashboard/features/short_video/douyin/douyin_detail_page.dart';
import 'package:dashboard/features/short_video/douyin/douyin_download_controller.dart';
import 'package:dashboard/features/short_video/douyin/douyin_download_store.dart';
import 'package:dashboard/features/short_video/douyin/douyin_downloaded_video.dart';
import 'package:dashboard/features/short_video/douyin/douyin_empty_signature.dart';
import 'package:dashboard/features/short_video/douyin/douyin_endpoint.dart';
import 'package:dashboard/features/short_video/douyin/douyin_entry_page.dart';
import 'package:dashboard/features/short_video/douyin/douyin_feed_controller.dart';
import 'package:dashboard/features/short_video/douyin/douyin_feed_page.dart';
import 'package:dashboard/features/short_video/douyin/douyin_play_address_kind.dart';
import 'package:dashboard/features/short_video/douyin/douyin_play_address_selector.dart';
import 'package:dashboard/features/short_video/douyin/douyin_post_list_response.dart';
import 'package:dashboard/features/short_video/douyin/douyin_signature_provider.dart';
import 'package:dashboard/features/short_video/douyin/douyin_signature_rejected.dart';
import 'package:dashboard/features/short_video/douyin/douyin_signing_notice.dart';
import 'package:dashboard/features/short_video/douyin/douyin_stale_signature.dart';
import 'package:dashboard/features/short_video/douyin/douyin_user_post_controller.dart';
import 'package:dashboard/features/short_video/douyin/douyin_user_post_page.dart';
import 'package:dashboard/features/short_video/douyin/douyin_video.dart';
import 'package:dashboard/features/short_video/douyin/douyin_video_controller.dart';
import 'package:dashboard/features/short_video/douyin/douyin_video_list_response.dart';
import 'package:dashboard/features/short_video/douyin/douyin_video_page.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  _endpointAndRequestTests();
  _modelTests();
  _apiFailureTests();
  _playAddressTests();
  _signatureTests();
  _downloadAndStoreTests();
  _controllerTests();
  _formatterTests();
  _widgetTests();
}

// ---------------------------------------------------------------------------
// 端点 / 请求构造
// ---------------------------------------------------------------------------

void _endpointAndRequestTests() {
  test('榜单请求命中 creator.douyin.com 且带 billboard_type=4', () async {
    final adapter = _FakeAdapter((_) => _jsonBody(_billboardPayload()));
    final api = _api(adapter);

    await api.fetchBillboard();

    final request = adapter.requests.single;
    expect(request.uri.host, 'creator.douyin.com');
    expect(request.path, '/aweme/v1/creator/data/billboard/');
    expect(request.queryParameters['billboard_type'], '4');
    expect(request.method, 'GET');
    api.dispose();
  });

  test('榜单可覆盖 billboard_type', () async {
    final adapter = _FakeAdapter((_) => _jsonBody(_billboardPayload()));
    final api = _api(adapter);

    await api.fetchBillboard(billboardType: 7);

    expect(adapter.requests.single.queryParameters['billboard_type'], '7');
    api.dispose();
  });

  test('作品信息保留源码的裸 dytk 查询参数', () async {
    final adapter = _FakeAdapter((_) => _jsonBody(_videoPayload()));
    final api = _api(adapter);

    await api.fetchVideoList(<String>['7001', '7002']);

    final request = adapter.requests.single;
    expect(request.uri.host, 'www.iesdouyin.com');
    expect(request.path, '/web/api/v2/aweme/iteminfo/');
    expect(request.queryParameters['item_ids'], '7001,7002');
    expect(request.uri.query, endsWith('&dytk'));
    expect(request.uri.query, isNot(contains('dytk=')));
    api.dispose();
  });

  test('播放地址请求保持源码固定参数与顺序', () async {
    final adapter = _FakeAdapter(
      (_) => _redirectBody('https://cdn.play/v1.mp4'),
    );
    final api = _api(adapter);

    await api.resolvePlayUrl('v1');

    final request = adapter.requests.single;
    expect(request.uri.host, 'aweme.snssdk.com');
    expect(request.path, '/aweme/v1/play/');
    expect(
      request.uri.query,
      'video_id=v1&ratio=720p&line=0&media_type=4&vr_type=0'
      '&improve_bitrate=0&is_play_url=1&h265=1&adapt720=1',
    );
    expect(request.followRedirects, isFalse);
    api.dispose();
  });

  test('用户作品请求带签名与游标参数', () async {
    final adapter = _FakeAdapter((_) => _jsonBody(_postsPayload()));
    final api = _api(adapter, signature: const _FixedSignature('sig-1'));

    await api.fetchUserPosts(
      secUid: 'MS4wLjAB',
      count: 20,
      minCursor: 5,
      maxCursor: 9,
      lang: 'zh',
    );

    final request = adapter.requests.single;
    expect(request.uri.host, 'www.tiktok.com');
    expect(request.path, '/share/item/list');
    expect(request.queryParameters['secUid'], 'MS4wLjAB');
    expect(request.queryParameters['type'], '5');
    expect(request.queryParameters['count'], '20');
    expect(request.queryParameters['minCursor'], '5');
    expect(request.queryParameters['maxCursor'], '9');
    expect(request.queryParameters['lang'], 'zh');
    expect(request.queryParameters['_signature'], 'sig-1');
    api.dispose();
  });

  test('creator 请求头复刻源码 referer 与 iPhone UA', () async {
    final adapter = _FakeAdapter((_) => _jsonBody(_billboardPayload()));
    final api = _api(adapter);

    await api.fetchBillboard();

    final headers = adapter.requests.single.headers;
    expect(headers['referer'], DouyinEndpoint.creatorReferer);
    expect(headers['user-agent'], DouyinEndpoint.mobileUserAgent);
    api.dispose();
  });

  test('share 请求头带签名、Origin 与 tiktok Referer', () async {
    final adapter = _FakeAdapter((_) => _jsonBody(_postsPayload()));
    final api = _api(adapter, signature: const _FixedSignature('sig-2'));

    await api.fetchUserPosts();

    final headers = adapter.requests.single.headers;
    expect(headers['_signature'], 'sig-2');
    expect(headers['Origin'], 'https://www.tiktok.com');
    expect(headers['Referer'], DouyinEndpoint.shareReferer);
    expect(headers['count'], '30');
    api.dispose();
  });
}

// ---------------------------------------------------------------------------
// 模型映射
// ---------------------------------------------------------------------------

void _modelTests() {
  test('tiktok 分享列表映射到 DouyinPost 展示字段', () {
    final response = DouyinPostListResponse.fromJson(_postsPayload());

    expect(response.isSuccess, isTrue);
    expect(response.hasMore, isTrue);
    expect(response.maxCursor, '9');
    final post = response.posts.single;
    expect(post.id, '5001');
    expect(post.desc, '分享作品');
    expect(post.authorHandle, '@tiktok_a');
    expect(post.musicLabel, '原声带 - 歌手');
    expect(post.playUrls, <String>['https://tiktok.play/1.mp4']);
    expect(post.firstPlayUrl, 'https://tiktok.play/1.mp4');
    expect(post.diggCount, 12);
    expect(post.commentCount, 3);
    expect(post.shareCount, 2);
    expect(post.playCount, 100);
    expect(post.duration, 15);
    expect(post.isPlayable, isTrue);
  });

  test('aweme item_list 映射到 DouyinAweme 与统计字段', () {
    final response = DouyinVideoListResponse.fromJson(_videoPayload());

    expect(response.isSuccess, isTrue);
    final aweme = response.first!;
    expect(aweme.awemeId, '7001');
    expect(aweme.desc, '第一条作品');
    expect(aweme.diggCount, 12000);
    expect(aweme.commentCount, 34);
    expect(aweme.shareCount, 5);
    expect(aweme.playCount, 888);
    expect(aweme.authorHandle, '@creator_a');
    expect(aweme.authorName, '创作者甲');
    expect(aweme.musicLabel, '背景音乐 - 演唱者');
    expect(aweme.video?.playAddr.uri, 'v-play-1');
    expect(aweme.video?.coverUrl, 'https://img.cover/7001.jpg');
    expect(aweme.hashtagLabel, '#话题一 #话题二');
    expect(aweme.riskLabel, '');
    expect(aweme.video?.aspectRatio, closeTo(0.5625, 0.0001));
    expect(aweme.video?.durationSeconds, 15);
  });

  test('榜单响应映射名次并从未尾段取作品 id', () {
    final entry = DouyinBillboardEntry.fromJson(<String, Object?>{
      'author': 'creator_a',
      'img_url': 'https://img/1.jpg',
      'link': 'https://www.douyin.com/video/7001',
      'rank': 1,
      'title': '热榜第一',
      'value': '9999',
    });

    expect(entry.rank, 1);
    expect(entry.awemeId, '7001');
    expect(entry.displayTitle, '热榜第一');
    expect(entry.displayAuthor, 'creator_a');
    expect(entry.displayValue, '9999');
  });

  test('作者头像取 avatar_medium.url_list 首个地址', () {
    final aweme = DouyinAweme.fromJson(<String, Object?>{
      'author': <String, Object?>{
        'unique_id': 'creator_a',
        'nickname': '创作者甲',
        'avatar_medium': <String, Object?>{
          'uri': 'avatar',
          'url_list': <Object?>[
            'https://img.avatar/medium.jpg',
            'https://img.avatar/backup.jpg',
          ],
        },
      },
    });

    expect(aweme.author?.avatarUrl, 'https://img.avatar/medium.jpg');
  });

  test('缺失字段使用展示兜底文案', () {
    const aweme = DouyinAweme();

    expect(aweme.displayDesc, '无描述');
    expect(aweme.authorHandle, '@未知用户');
    expect(aweme.authorName, '未知作者');
    expect(aweme.musicLabel, '原声 - 未知');
    expect(aweme.diggCount, 0);
    expect(aweme.hashtagLabel, '');
    expect(aweme.riskLabel, '');
    expect(DouyinAweme.fromJson(const <String, Object?>{}).awemeId, '');
  });

  test('风险提示在 warn 为真时才展示 content', () {
    final aweme = DouyinAweme.fromJson(<String, Object?>{
      'aweme_id': '1',
      'risk_infos': <String, Object?>{'warn': true, 'content': '内容存在风险'},
    });

    expect(aweme.riskLabel, '内容存在风险');
  });

  test('榜单响应 status_code 非零抛 DouyinApiException', () async {
    final adapter = _FakeAdapter(
      (_) => _jsonBody(<String, Object?>{
        'status_code': 10001,
        'status_msg': '参数错误',
        'billboard_data': <Object?>[],
      }),
    );
    final api = _api(adapter);

    await expectLater(
      api.fetchBillboard(),
      throwsA(
        isA<DouyinApiException>().having(
          (error) => error.message,
          'message',
          contains('10001'),
        ),
      ),
    );
    api.dispose();
  });

  test('作品信息为空时 fetchAweme 报不存在', () async {
    final adapter = _FakeAdapter(
      (_) => _jsonBody(<String, Object?>{
        'status_code': 0,
        'item_list': <Object?>[],
        'extra': <String, Object?>{},
      }),
    );
    final api = _api(adapter);

    await expectLater(
      api.fetchAweme('4040'),
      throwsA(
        isA<DouyinApiException>().having(
          (error) => error.message,
          'message',
          contains('4040 不存在或已下架'),
        ),
      ),
    );
    api.dispose();
  });

  test('fetchAweme 与 fetchVideoList 使用同一 iteminfo 端点', () async {
    final adapter = _FakeAdapter((options) {
      expect(options.uri.queryParameters['item_ids'], '7001');
      return _jsonBody(_videoPayload());
    });
    final api = _api(adapter);

    final aweme = await api.fetchAweme('7001');

    expect(aweme.awemeId, '7001');
    expect(adapter.requests, hasLength(1));
    api.dispose();
  });
}

// ---------------------------------------------------------------------------
// API 失败面
// ---------------------------------------------------------------------------

void _apiFailureTests() {
  test('HTTP 非 200 转成带状态码的异常', () async {
    final adapter = _FakeAdapter(
      (_) => _jsonBody(<String, Object?>{'error': 'boom'}, statusCode: 500),
    );
    final api = _api(adapter);

    await expectLater(
      api.fetchBillboard(),
      throwsA(
        isA<DouyinApiException>()
            .having((error) => error.statusCode, 'statusCode', 500)
            .having((error) => error.message, 'message', contains('HTTP 500')),
      ),
    );
    api.dispose();
  });

  test('响应不是 JSON 对象时报解析失败', () async {
    final adapter = _FakeAdapter((_) => _jsonBody(<Object?>[1, 2, 3]));
    final api = _api(adapter);

    await expectLater(
      api.fetchBillboard(),
      throwsA(
        isA<DouyinApiException>().having(
          (error) => error.message,
          'message',
          '抖音响应不是 JSON 对象',
        ),
      ),
    );
    api.dispose();
  });

  test('网络异常包装为 DouyinApiException', () async {
    final adapter = _FakeAdapter(
      (options) => throw DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
        message: 'connection refused',
      ),
    );
    final api = _api(adapter);

    await expectLater(
      api.fetchBillboard(),
      throwsA(
        isA<DouyinApiException>().having(
          (error) => error.message,
          'message',
          contains('connection refused'),
        ),
      ),
    );
    api.dispose();
  });

  test('302 从 Location 头取无水印地址', () async {
    final adapter = _FakeAdapter(
      (_) => _redirectBody('https://cdn.play/v1.mp4'),
    );
    final api = _api(adapter);

    expect(await api.resolvePlayUrl('v1'), 'https://cdn.play/v1.mp4');
    api.dispose();
  });

  test('302 缺少 Location 时按源码从响应体取引号内容', () async {
    final adapter = _FakeAdapter(
      (_) => ResponseBody.fromString(
        '<script>location.href="https://cdn.play/body.mp4"</script>',
        302,
        headers: <String, List<String>>{
          Headers.contentTypeHeader: <String>['application/json'],
        },
      ),
    );
    final api = _api(adapter);

    expect(await api.resolvePlayUrl('v1'), 'https://cdn.play/body.mp4');
    api.dispose();
  });

  test('播放接口非 302 时报错并附状态码', () async {
    final adapter = _FakeAdapter((_) => _jsonBody(<String, Object?>{}, statusCode: 200));
    final api = _api(adapter);

    await expectLater(
      api.resolvePlayUrl('v1'),
      throwsA(
        isA<DouyinApiException>()
            .having((error) => error.message, 'message', contains('未返回 302'))
            .having((error) => error.statusCode, 'statusCode', 200),
      ),
    );
    api.dispose();
  });
}

// ---------------------------------------------------------------------------
// 播放地址选择
// ---------------------------------------------------------------------------

void _playAddressTests() {
  test('优先用 play_addr.uri 换无水印地址', () {
    const selector = DouyinPlayAddressSelector();
    final address = selector.select(
      DouyinVideo.fromJson(<String, Object?>{
        'play_addr': <String, Object?>{
          'uri': 'v-play-1',
          'url_list': <Object?>['https://watermarked/1.mp4'],
        },
        'vid': 'v-vid',
      }),
    );

    expect(address.kind, DouyinPlayAddressKind.redirect);
    expect(address.videoId, 'v-play-1');
    expect(address.isRedirect, isTrue);
  });

  test('没有 uri 时退回 play_addr 直链', () {
    const selector = DouyinPlayAddressSelector();
    final address = selector.select(
      DouyinVideo.fromJson(<String, Object?>{
        'play_addr': <String, Object?>{
          'url_list': <Object?>['https://direct/1.mp4'],
        },
      }),
    );

    expect(address.kind, DouyinPlayAddressKind.direct);
    expect(address.url, 'https://direct/1.mp4');
  });

  test('只有 vid 时仍走播放接口', () {
    const selector = DouyinPlayAddressSelector();
    final address = selector.select(
      DouyinVideo.fromJson(<String, Object?>{'vid': 'v-only'}),
    );

    expect(address.isRedirect, isTrue);
    expect(address.videoId, 'v-only');
  });

  test('完全没有地址时返回 none', () {
    const selector = DouyinPlayAddressSelector();

    expect(selector.select(null).isEmpty, isTrue);
    expect(selector.select(const DouyinVideo()).isEmpty, isTrue);
  });
}

// ---------------------------------------------------------------------------
// 签名契约
// ---------------------------------------------------------------------------

void _signatureTests() {
  test('默认提供者返回源码里写死的过期签名', () async {
    const provider = DouyinStaleSignature();

    expect(provider.isSupported, isTrue);
    expect(
      await provider.signature(),
      'pKb.ogAgEB9ImoSQahoqJKSm.rAAPox',
    );
  });

  test('空签名提供者不发送请求并抛签名被拒', () async {
    final adapter = _FakeAdapter((_) => _jsonBody(_postsPayload()));
    final api = _api(adapter, signature: const DouyinEmptySignature());

    await expectLater(
      api.fetchUserPosts(),
      throwsA(
        isA<DouyinSignatureRejected>().having(
          (error) => error.message,
          'message',
          contains('未发送 /share/item/list 请求'),
        ),
      ),
    );
    expect(adapter.requests, isEmpty);
    api.dispose();
  });

  test('HTTP 403 映射为签名被拒并保留签名值', () async {
    final adapter = _FakeAdapter(
      (_) => _jsonBody(<String, Object?>{'status_code': 403}, statusCode: 403),
    );
    final api = _api(adapter, signature: const _FixedSignature('sig-403'));

    await expectLater(
      api.fetchUserPosts(),
      throwsA(
        isA<DouyinSignatureRejected>()
            .having((error) => error.statusCode, 'statusCode', 403)
            .having((error) => error.signature, 'signature', 'sig-403')
            .having((error) => error.message, 'message', contains('HTTP 403')),
      ),
    );
    expect(adapter.requests, hasLength(1));
    api.dispose();
  });

  test('签名原样透传，不额外拼接 HTTP/1.1', () async {
    final adapter = _FakeAdapter((_) => _jsonBody(_postsPayload()));
    final api = _api(
      adapter,
      signature: const _FixedSignature(DouyinStaleSignature.staleSignature),
    );

    await api.fetchUserPosts();

    final request = adapter.requests.single;
    expect(request.headers['_signature'], DouyinStaleSignature.staleSignature);
    expect(
      request.queryParameters['_signature'],
      DouyinStaleSignature.staleSignature,
    );
    api.dispose();
  });

  test('签名提供者返回空白同样视为不可用', () async {
    final adapter = _FakeAdapter((_) => _jsonBody(_postsPayload()));
    final api = _api(adapter, signature: const _FixedSignature('   '));

    await expectLater(
      api.fetchUserPosts(),
      throwsA(isA<DouyinSignatureRejected>()),
    );
    expect(adapter.requests, isEmpty);
    api.dispose();
  });

  test('签名被拒文案解释源工程与注入方式', () {
    const rejected = DouyinSignatureRejected();

    expect(rejected.message, contains('flutter_app/lib/config/api.dart'));
    expect(rejected.message, contains('HTTP 403'));
    expect(rejected.message, contains('DouyinSignatureProvider'));
  });
}

// ---------------------------------------------------------------------------
// 下载与保存
// ---------------------------------------------------------------------------

void _downloadAndStoreTests() {
  late Directory tempDir;
  late DouyinDownloadStore store;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('douyin_test_');
    final prefs = await SharedPreferences.getInstance();
    store = DouyinDownloadStore(preferences: prefs);
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('下载写入文件并记录到 shared_preferences', () async {
    final playAdapter = _FakeAdapter(
      (_) => _redirectBody('https://cdn.play/7001.mp4'),
    );
    final api = _api(playAdapter);
    final downloadAdapter = _FakeAdapter(
      (_) => _bytesBody(utf8.encode('MP4DATA')),
    );
    final controller = _downloadController(
      api: api,
      store: store,
      adapter: downloadAdapter,
      directory: tempDir,
    );

    final saved = await controller.download(_aweme());

    final file = File(saved.path);
    expect(file.existsSync(), isTrue);
    expect(file.readAsBytesSync(), utf8.encode('MP4DATA'));
    expect(saved.path, '${tempDir.path}/douyin_7001.mp4');
    expect(saved.awemeId, '7001');
    expect(saved.title, '第一条作品');
    expect(saved.savedAt, DateTime.utc(2026, 10, 13, 8));
    final records = await store.load();
    expect(records, hasLength(1));
    expect(records.single.path, saved.path);
    final raw = (await SharedPreferences.getInstance())
        .getString(DouyinDownloadStore.storageKey);
    expect(raw, isNotNull);
    expect(raw, contains('douyin_7001.mp4'));
    api.dispose();
  });

  test('下载请求带播放接口的 referer 头', () async {
    final api = _api(
      _FakeAdapter((_) => _redirectBody('https://cdn.play/7001.mp4')),
    );
    final downloadAdapter = _FakeAdapter((_) => _bytesBody(<int>[1, 2, 3]));
    final controller = _downloadController(
      api: api,
      store: store,
      adapter: downloadAdapter,
      directory: tempDir,
    );

    await controller.download(_aweme());

    expect(
      downloadAdapter.requests.single.headers['referer'],
      DouyinEndpoint.creatorReferer,
    );
    api.dispose();
  });

  test('重复保存同一作品只保留一条最新记录', () async {
    final api = _api(
      _FakeAdapter((_) => _redirectBody('https://cdn.play/7001.mp4')),
    );
    final controller = _downloadController(
      api: api,
      store: store,
      adapter: _FakeAdapter((_) => _bytesBody(<int>[9])),
      directory: tempDir,
    );

    await controller.download(_aweme());
    await controller.download(_aweme());

    expect(await store.load(), hasLength(1));
    api.dispose();
  });

  test('下载非 200 删除残文件并抛异常', () async {
    final api = _api(
      _FakeAdapter((_) => _redirectBody('https://cdn.play/7001.mp4')),
    );
    final controller = _downloadController(
      api: api,
      store: store,
      adapter: _FakeAdapter((_) => _bytesBody(<int>[0], statusCode: 404)),
      directory: tempDir,
    );

    await expectLater(
      controller.download(_aweme()),
      throwsA(
        isA<DouyinApiException>().having(
          (error) => error.message,
          'message',
          '保存抖音视频失败：HTTP 404',
        ),
      ),
    );
    expect(File('${tempDir.path}/douyin_7001.mp4').existsSync(), isFalse);
    expect(await store.load(), isEmpty);
    api.dispose();
  });

  test('没有播放地址时下载直接失败且不发请求', () async {
    final playAdapter = _FakeAdapter((_) => _redirectBody('https://x'));
    final api = _api(playAdapter);
    final downloadAdapter = _FakeAdapter((_) => _bytesBody(<int>[1]));
    final controller = _downloadController(
      api: api,
      store: store,
      adapter: downloadAdapter,
      directory: tempDir,
    );

    await expectLater(
      controller.download(
        DouyinAweme.fromJson(<String, Object?>{'aweme_id': '7009'}),
      ),
      throwsA(
        isA<DouyinApiException>().having(
          (error) => error.message,
          'message',
          '没有可用的播放地址，无法保存',
        ),
      ),
    );
    expect(playAdapter.requests, isEmpty);
    expect(downloadAdapter.requests, isEmpty);
    api.dispose();
  });

  test('保存记录可读回并解析时间', () async {
    final video = DouyinDownloadedVideo(
      awemeId: 'a1',
      title: '标题',
      path: '/tmp/a1.mp4',
      savedAt: DateTime.utc(2026, 1, 2, 3, 4, 5),
    );

    await store.save(video);
    final loaded = await store.load();

    expect(loaded.single.awemeId, 'a1');
    expect(loaded.single.savedAt, DateTime.utc(2026, 1, 2, 3, 4, 5));
    await store.remove('a1');
    expect(await store.load(), isEmpty);
  });

  test('文件名从文案清洗非法字符', () {
    final stem = DouyinDownloadController.fileStem(
      DouyinAweme.fromJson(<String, Object?>{
        'aweme_id': '',
        'desc': 'a/b:c d',
      }),
    );

    expect(stem, 'a_b_c_d');
  });
}

// ---------------------------------------------------------------------------
// 控制器
// ---------------------------------------------------------------------------

void _controllerTests() {
  test('榜单控制器加载条目并清空错误', () async {
    final api = _api(_FakeAdapter((_) => _jsonBody(_billboardPayload())));
    final controller = DouyinFeedController(api: api);

    await controller.load();

    expect(controller.isLoading, isFalse);
    expect(controller.error, isNull);
    expect(controller.entries, hasLength(2));
    expect(controller.entries.first.title, '热榜第一');
    api.dispose();
  });

  test('榜单控制器失败时暴露文案', () async {
    final api = _api(
      _FakeAdapter((options) => throw DioException(
            requestOptions: options,
            type: DioExceptionType.connectionTimeout,
            message: 'timeout',
          )),
    );
    final controller = DouyinFeedController(api: api);

    await controller.load();

    expect(controller.entries, isEmpty);
    expect(controller.error, contains('timeout'));
    api.dispose();
  });

  test('播放控制器为每条榜单解析作品与播放地址', () async {
    final api = _api(_FakeAdapter(_standardHandler));
    final controller = DouyinVideoController(api: api);

    await controller.load(_entries());

    expect(controller.items, hasLength(2));
    expect(controller.items.first.aweme.awemeId, '7001');
    expect(controller.items.first.playUrl, 'https://cdn.play/v-play-1.mp4');
    expect(controller.items.first.hasError, isFalse);
    expect(controller.items[1].playUrl, 'https://cdn.play/v-play-2.mp4');
    api.dispose();
  });

  test('单条作品失败只标记该条，不中断整榜', () async {
    final api = _api(
      _FakeAdapter((options) {
        if (options.uri.path == '/web/api/v2/aweme/iteminfo/') {
          final id = options.uri.queryParameters['item_ids'];
          if (id == '7002') {
            return _jsonBody(<String, Object?>{
              'status_code': 0,
              'item_list': <Object?>[],
              'extra': <String, Object?>{},
            });
          }
          return _jsonBody(_videoPayload());
        }
        return _redirectBody('https://cdn.play/${options.uri.queryParameters['video_id']}.mp4');
      }),
    );
    final controller = DouyinVideoController(api: api);

    await controller.load(_entries());

    expect(controller.items, hasLength(2));
    expect(controller.items.first.hasPlayback, isTrue);
    expect(controller.items[1].hasPlayback, isFalse);
    expect(controller.items[1].error, contains('7002 不存在或已下架'));
    api.dispose();
  });

  test('播放控制器跳过缺少作品 id 的榜单链接', () async {
    final api = _api(_FakeAdapter((_) => _jsonBody(_videoPayload())));
    final controller = DouyinVideoController(api: api);

    await controller.load(<DouyinBillboardEntry>[
      const DouyinBillboardEntry(rank: 1, link: 'https://www.douyin.com/'),
    ]);

    expect(controller.items.single.error, '榜单链接缺少作品 id');
    api.dispose();
  });

  test('选择页码只接受合法下标', () async {
    final api = _api(_FakeAdapter(_standardHandler));
    final controller = DouyinVideoController(api: api);
    await controller.load(_entries());

    controller.select(1);
    expect(controller.currentIndex, 1);
    controller.select(9);
    expect(controller.currentIndex, 1);
    controller.select(-1);
    expect(controller.currentIndex, 1);
    api.dispose();
  });

  test('详情控制器解析元数据与无水印地址', () async {
    final api = _api(_FakeAdapter(_standardHandler));
    final controller = DouyinDetailController(
      api: api,
      downloadController: _downloadController(
        api: api,
        store: DouyinDownloadStore(),
        adapter: _FakeAdapter((_) => _bytesBody(<int>[1])),
        directory: Directory.systemTemp,
      ),
    );

    await controller.load('7001');

    expect(controller.aweme?.desc, '第一条作品');
    expect(controller.playAddress.videoId, 'v-play-1');
    expect(controller.playUrl, 'https://cdn.play/v-play-1.mp4');
    expect(controller.playError, isNull);
    expect(controller.error, isNull);
    api.dispose();
  });

  test('详情控制器加载失败时暴露错误', () async {
    final api = _api(
      _FakeAdapter((_) => _jsonBody(<String, Object?>{}, statusCode: 500)),
    );
    final controller = DouyinDetailController(
      api: api,
      downloadController: _downloadController(
        api: api,
        store: DouyinDownloadStore(),
        adapter: _FakeAdapter((_) => _bytesBody(<int>[1])),
        directory: Directory.systemTemp,
      ),
    );

    await controller.load('7001');

    expect(controller.aweme, isNull);
    expect(controller.error, contains('HTTP 500'));
    api.dispose();
  });

  test('详情控制器下载后暴露保存结果', () async {
    final api = _api(_FakeAdapter(_standardHandler));
    final tempDir = await Directory.systemTemp.createTemp('douyin_detail_');
    addTearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });
    final downloadController = _downloadController(
      api: api,
      store: DouyinDownloadStore(
        preferences: await SharedPreferences.getInstance(),
      ),
      adapter: _FakeAdapter((_) => _bytesBody(utf8.encode('DATA'))),
      directory: tempDir,
    );
    final controller = DouyinDetailController(
      api: api,
      downloadController: downloadController,
    );
    await controller.load('7001');

    await controller.download();

    expect(controller.error, isNull);
    expect(controller.saved, isNotNull);
    expect(controller.saved!.path, '${tempDir.path}/douyin_7001.mp4');
    expect(controller.isDownloading, isFalse);
    api.dispose();
  });

  test('用户作品控制器在 403 时标记签名被拒', () async {
    final api = _api(
      _FakeAdapter((_) => _jsonBody(<String, Object?>{}, statusCode: 403)),
    );
    final controller = DouyinUserPostController(api: api);

    await controller.load();

    expect(controller.signatureRejected, isTrue);
    expect(controller.posts, isEmpty);
    expect(controller.error, contains('HTTP 403'));
    api.dispose();
  });

  test('用户作品控制器正常映射 posts', () async {
    final api = _api(_FakeAdapter((_) => _jsonBody(_postsPayload())));
    final controller = DouyinUserPostController(api: api);

    await controller.load(secUid: 'MS4w');

    expect(controller.signatureRejected, isFalse);
    expect(controller.posts, hasLength(1));
    expect(controller.posts.single.diggCount, 12);
    expect(controller.hasMore, isTrue);
    api.dispose();
  });
}

// ---------------------------------------------------------------------------
// 计数格式化
// ---------------------------------------------------------------------------

void _formatterTests() {
  test('计数格式化为 w 与 亿', () {
    expect(DouyinCountFormatter.compact(0), '0');
    expect(DouyinCountFormatter.compact(-5), '0');
    expect(DouyinCountFormatter.compact(999), '999');
    expect(DouyinCountFormatter.compact(9999), '9999');
    expect(DouyinCountFormatter.compact(12000), '1.2w');
    expect(DouyinCountFormatter.compact(1000000), '100w');
    expect(DouyinCountFormatter.compact(123456789), '1.2亿');
  });
}

// ---------------------------------------------------------------------------
// 页面
// ---------------------------------------------------------------------------

void _widgetTests() {
  testWidgets('入口页展示签名过期说明与两个入口', (tester) async {
    final api = _api(_FakeAdapter((_) => _jsonBody(_billboardPayload())));

    await tester.pumpWidget(MaterialApp(home: DouyinEntryPage(api: api)));
    await tester.pumpAndSettle();

    expect(find.text('抖音短视频'), findsWidgets);
    expect(find.text('热门视频榜'), findsOneWidget);
    expect(find.text('用户作品'), findsWidgets);
    expect(find.text(DouyinSigningNotice.title), findsOneWidget);
    expect(find.textContaining('HTTP 403'), findsOneWidget);
    api.dispose();
  });

  testWidgets('榜单页渲染名次标题并可进入播放页', (tester) async {
    final api = _api(_FakeAdapter(_standardHandler));

    await tester.pumpWidget(
      MaterialApp(
        home: DouyinFeedPage(
          api: api,
          playbackBuilder: (context, title, url) => Text('播放器 $url'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('热榜第一'), findsOneWidget);
    expect(find.text('热榜第二'), findsOneWidget);

    await tester.tap(find.text('热榜第一'));
    await tester.pumpAndSettle();

    expect(find.text('抖音视频'), findsOneWidget);
    expect(find.text('第一条作品'), findsOneWidget);
    expect(find.text('播放器 https://cdn.play/v-play-1.mp4'), findsOneWidget);
    api.dispose();
  });

  testWidgets('播放页注入播放器并展示作者与音乐', (tester) async {
    final api = _api(_FakeAdapter(_standardHandler));

    await tester.pumpWidget(
      MaterialApp(
        home: DouyinVideoPage(
          entries: _entries(),
          api: api,
          playbackBuilder: (context, title, url) => Text('播放器 $url'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('@creator_a'), findsOneWidget);
    expect(find.text('第一条作品'), findsOneWidget);
    expect(find.text('背景音乐 - 演唱者'), findsOneWidget);
    expect(find.text('播放器 https://cdn.play/v-play-1.mp4'), findsOneWidget);
    api.dispose();
  });

  testWidgets('用户作品页在 403 时展示签名说明', (tester) async {
    final api = _api(
      _FakeAdapter((_) => _jsonBody(<String, Object?>{}, statusCode: 403)),
    );

    await tester.pumpWidget(MaterialApp(home: DouyinUserPostPage(api: api)));
    await tester.pumpAndSettle();

    expect(find.textContaining('HTTP 403'), findsWidgets);
    expect(find.text(DouyinSigningNotice.title), findsOneWidget);
    api.dispose();
  });

  testWidgets('空签名提供者时用户作品页展示签名不可用入口', (tester) async {
    final api = _api(
      _FakeAdapter((_) => _jsonBody(_postsPayload())),
      signature: const DouyinEmptySignature(),
    );

    await tester.pumpWidget(MaterialApp(home: DouyinUserPostPage(api: api)));
    await tester.pumpAndSettle();

    expect(find.byTooltip('签名不可用'), findsOneWidget);
    await tester.tap(find.byTooltip('签名不可用'));
    await tester.pumpAndSettle();

    expect(find.text('签名不可用'), findsWidgets);
    expect(find.text('知道了'), findsOneWidget);
    api.dispose();
  });

  testWidgets('详情页展示计数、音乐与下载按钮', (tester) async {
    final api = _api(_FakeAdapter(_standardHandler));
    final controller = DouyinDetailController(
      api: api,
      downloadController: _downloadController(
        api: api,
        store: DouyinDownloadStore(
          preferences: await SharedPreferences.getInstance(),
        ),
        adapter: _FakeAdapter((_) => _bytesBody(<int>[1])),
        directory: Directory.systemTemp,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: DouyinDetailPage(
          awemeId: '7001',
          api: api,
          controller: controller,
          playbackBuilder: (context, title, url) => Text('播放器 $url'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('第一条作品'), findsOneWidget);
    expect(find.text('点赞 1.2w'), findsOneWidget);
    expect(find.text('音乐：背景音乐 - 演唱者'), findsOneWidget);
    expect(find.text('下载并保存'), findsOneWidget);
    expect(find.text('播放视频'), findsOneWidget);
    api.dispose();
  });

  testWidgets('详情页点击下载后展示保存路径', (tester) async {
    // widget 测试的 fake-async 区域不会推进 dart:io 的异步创建，用同步 API。
    final tempDir = Directory(
      '${Directory.systemTemp.path}/douyin_widget_'
      '${DateTime.now().microsecondsSinceEpoch}',
    )..createSync(recursive: true);
    addTearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });
    final api = _api(_FakeAdapter(_standardHandler));
    final controller = DouyinDetailController(
      api: api,
      downloadController: _downloadController(
        api: api,
        store: DouyinDownloadStore(
          preferences: await SharedPreferences.getInstance(),
        ),
        adapter: _FakeAdapter((_) => _bytesBody(utf8.encode('DATA'))),
        directory: tempDir,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: DouyinDetailPage(
          awemeId: '7001',
          api: api,
          controller: controller,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 下载会做真实文件 I/O；widget 测试的默认 fake-async 区域不会推进它，
    // 必须放进 runAsync 才能跑完。
    await tester.runAsync(() async {
      await tester.tap(find.text('下载并保存'));
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();

    expect(
      find.textContaining('已保存：${tempDir.path}/douyin_7001.mp4'),
      findsOneWidget,
    );
    api.dispose();
  });
}

// ---------------------------------------------------------------------------
// 测试夹具
// ---------------------------------------------------------------------------

class _Recorded {
  _Recorded(this.uri, this.headers, this.followRedirects, this.responseType);

  final Uri uri;
  final Map<String, String> headers;
  final bool followRedirects;
  final ResponseType responseType;

  String get path => uri.path;

  Map<String, String> get queryParameters => uri.queryParameters;

  String get method => 'GET';
}

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.handler);

  final ResponseBody Function(RequestOptions options) handler;
  final List<_Recorded> requests = <_Recorded>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(
      _Recorded(
        options.uri,
        <String, String>{
          for (final entry in options.headers.entries)
            entry.key: '${entry.value}',
        },
        options.followRedirects,
        options.responseType,
      ),
    );
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

class _FixedSignature implements DouyinSignatureProvider {
  const _FixedSignature(this.value);

  final String value;

  @override
  bool get isSupported => true;

  @override
  Future<String> signature() async => value;
}

ResponseBody _jsonBody(Object? payload, {int statusCode = 200}) {
  return ResponseBody.fromString(
    jsonEncode(payload),
    statusCode,
    headers: <String, List<String>>{
      Headers.contentTypeHeader: <String>[Headers.jsonContentType],
    },
  );
}

ResponseBody _bytesBody(List<int> bytes, {int statusCode = 200}) {
  return ResponseBody.fromBytes(
    bytes,
    statusCode,
    headers: <String, List<String>>{
      Headers.contentTypeHeader: <String>['video/mp4'],
    },
  );
}

ResponseBody _redirectBody(String location) {
  return ResponseBody.fromString(
    '',
    302,
    headers: <String, List<String>>{
      'location': <String>[location],
    },
  );
}

DouyinApi _api(
  _FakeAdapter adapter, {
  DouyinSignatureProvider signature = const DouyinStaleSignature(),
}) {
  return DouyinApi(dio: Dio()..httpClientAdapter = adapter, signature: signature);
}

DouyinDownloadController _downloadController({
  required DouyinApi api,
  required DouyinDownloadStore store,
  required _FakeAdapter adapter,
  required Directory directory,
}) {
  return DouyinDownloadController(
    api: api,
    store: store,
    dio: Dio()..httpClientAdapter = adapter,
    directory: () async => directory,
    now: () => DateTime.utc(2026, 10, 13, 8),
  );
}

Map<String, Object?> _billboardPayload() {
  return <String, Object?>{
    'status_code': 0,
    'status_msg': '',
    'billboard_data': <Object?>[
      <String, Object?>{
        'author': 'creator_a',
        'img_url': 'https://img.cover/1.jpg',
        'link': 'https://www.douyin.com/video/7001',
        'rank': 1,
        'title': '热榜第一',
        'value': '9999',
      },
      <String, Object?>{
        'author': 'creator_b',
        'img_url': 'https://img.cover/2.jpg',
        'link': 'https://www.douyin.com/video/7002',
        'rank': 2,
        'title': '热榜第二',
        'value': '8888',
      },
    ],
    'extra': <String, Object?>{'now': 1700000000},
  };
}

Map<String, Object?> _videoPayload({String id = '7001'}) {
  return <String, Object?>{
    'status_code': 0,
    'item_list': <Object?>[_awemeJson(id: id)],
    'extra': <String, Object?>{'now': 1700000000, 'logid': 'log-1'},
  };
}

Map<String, Object?> _awemeJson({String id = '7001'}) {
  final suffix = id == '7001' ? '1' : '2';
  return <String, Object?>{
    'aweme_id': id,
    'desc': id == '7001' ? '第一条作品' : '第二条作品',
    'create_time': 1700000000,
    'duration': 15000,
    'aweme_type': 0,
    'is_preview': 0,
    'share_url': 'https://www.douyin.com/video/$id',
    'author': <String, Object?>{
      'uid': 'u-$id',
      'unique_id': 'creator_a',
      'nickname': '创作者甲',
      'avatar_medium': <String, Object?>{
        'uri': 'avatar-$id',
        'url_list': <Object?>[],
      },
    },
    'music': <String, Object?>{
      'id': 'm-$id',
      'title': '背景音乐',
      'author': '演唱者',
      'duration': 15,
      'play_url': <String, Object?>{
        'url_list': <Object?>['https://music/$id.mp3'],
      },
      'cover_medium': <String, Object?>{
        'url_list': <Object?>['https://img.music/$id.jpg'],
      },
    },
    'statistics': <String, Object?>{
      'aweme_id': id,
      'digg_count': 12000,
      'comment_count': 34,
      'share_count': 5,
      'play_count': 888,
    },
    'video': <String, Object?>{
      'width': 720,
      'height': 1280,
      'ratio': '720p',
      'duration': 15000,
      'vid': 'v-vid-$suffix',
      'has_watermark': 0,
      'cover': <String, Object?>{
        'url_list': <Object?>['https://img.cover/$id.jpg'],
      },
      'play_addr': <String, Object?>{
        'uri': 'v-play-$suffix',
        'url_list': <Object?>['https://watermarked/$id.mp4'],
      },
    },
    'text_extra': <Object?>[
      <String, Object?>{'hashtag_name': '话题一', 'hashtag_id': 1},
      <String, Object?>{'hashtag_name': '话题二', 'hashtag_id': 2},
    ],
    'risk_infos': <String, Object?>{'warn': false, 'content': ''},
  };
}

Map<String, Object?> _postsPayload() {
  return <String, Object?>{
    'statusCode': 0,
    'errMsg': '',
    'body': <String, Object?>{
      'hasMore': 'true',
      'maxCursor': '9',
      'minCursor': '0',
      'itemListData': <Object?>[
        <String, Object?>{
          'itemInfos': <String, Object?>{
            'id': '5001',
            'text': '分享作品',
            'createTime': '1600000000',
            'diggCount': 12,
            'commentCount': 3,
            'shareCount': 2,
            'playCount': 100,
            'video': <String, Object?>{
              'urls': <Object?>['https://tiktok.play/1.mp4'],
              'videoMeta': <String, Object?>{'duration': 15},
            },
          },
          'authorInfos': <String, Object?>{
            'uniqueId': 'tiktok_a',
            'nickName': 'TikTok A',
            'covers': <Object?>[],
          },
          'musicInfos': <String, Object?>{
            'musicName': '原声带',
            'authorName': '歌手',
          },
        },
      ],
    },
  };
}

List<DouyinBillboardEntry> _entries() {
  return <DouyinBillboardEntry>[
    const DouyinBillboardEntry(
      rank: 1,
      link: 'https://www.douyin.com/video/7001',
    ),
    const DouyinBillboardEntry(
      rank: 2,
      link: 'https://www.douyin.com/video/7002',
    ),
  ];
}

DouyinAweme _aweme({String id = '7001'}) {
  return DouyinAweme.fromJson(_awemeJson(id: id));
}

ResponseBody _standardHandler(RequestOptions options) {
  switch (options.uri.path) {
    case '/aweme/v1/creator/data/billboard/':
      return _jsonBody(_billboardPayload());
    case '/web/api/v2/aweme/iteminfo/':
      final id = options.uri.queryParameters['item_ids'] ?? '7001';
      return _jsonBody(_videoPayload(id: id));
    case '/aweme/v1/play/':
      final videoId = options.uri.queryParameters['video_id'] ?? 'v-play-1';
      return _redirectBody('https://cdn.play/$videoId.mp4');
    default:
      throw StateError('unexpected request ${options.uri}');
  }
}
