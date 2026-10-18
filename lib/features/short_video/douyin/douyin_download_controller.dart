import 'dart:io';

import 'package:dashboard/features/short_video/douyin/douyin_api.dart';
import 'package:dashboard/features/short_video/douyin/douyin_api_exception.dart';
import 'package:dashboard/features/short_video/douyin/douyin_aweme.dart';
import 'package:dashboard/features/short_video/douyin/douyin_download_store.dart';
import 'package:dashboard/features/short_video/douyin/douyin_downloaded_video.dart';
import 'package:dashboard/features/short_video/douyin/douyin_headers.dart';
import 'package:dashboard/features/short_video/douyin/douyin_play_address.dart';
import 'package:dashboard/features/short_video/douyin/douyin_play_address_selector.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

/// 下载并保存一条作品。
///
/// 源码没有下载逻辑，宿主用 `dio.download` + `path_provider` 落在
/// `<文档目录>/douyin/douyin_<aweme_id>.mp4`，并把记录交给
/// [DouyinDownloadStore]。
class DouyinDownloadController {
  DouyinDownloadController({
    required this.api,
    required this.store,
    Dio? dio,
    Future<Directory> Function()? directory,
    this.selector = const DouyinPlayAddressSelector(),
    DateTime Function()? now,
  })  : _dio = dio ?? Dio(),
        _directory = directory ?? _documentsDirectory,
        _now = now ?? DateTime.now;

  final DouyinApi api;
  final DouyinDownloadStore store;
  final DouyinPlayAddressSelector selector;

  final Dio _dio;
  final Future<Directory> Function() _directory;
  final DateTime Function() _now;

  /// 保存目录：`<应用文档目录>/douyin`。
  static Future<Directory> _documentsDirectory() async {
    final root = await getApplicationDocumentsDirectory();
    return Directory('${root.path}/douyin');
  }

  /// 下载地址：direct 直接用；redirect 走播放接口换无水印地址；
  /// 都没有则报错（不允许把不可播放地址写进文件）。
  Future<String> resolveUrl(DouyinPlayAddress address) async {
    if (address.isDirect) {
      return address.url;
    }
    if (address.isRedirect) {
      return api.resolvePlayUrl(address.videoId);
    }
    throw const DouyinApiException('没有可用的播放地址，无法保存');
  }

  Future<DouyinDownloadedVideo> download(
    DouyinAweme aweme, {
    DouyinPlayAddress? address,
  }) async {
    final playAddress = address ?? selector.select(aweme.video);
    final url = await resolveUrl(playAddress);
    final directory = await _directory();
    await directory.create(recursive: true);
    final file = File('${directory.path}/${fileStem(aweme)}.mp4');
    final Response<dynamic> response;
    try {
      response = await _dio.download(
        url,
        file.path,
        options: Options(
          headers: DouyinHeaders.play(),
          validateStatus: (_) => true,
        ),
      );
    } on DioException catch (error) {
      throw DouyinApiException(
        '保存抖音视频失败：${error.message ?? error.type.name}',
        statusCode: error.response?.statusCode,
      );
    }
    if (response.statusCode != 200) {
      if (await file.exists()) {
        await file.delete();
      }
      throw DouyinApiException(
        '保存抖音视频失败：HTTP ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
    final saved = DouyinDownloadedVideo(
      awemeId: aweme.awemeId,
      title: aweme.displayDesc,
      path: file.path,
      savedAt: _now(),
    );
    await store.save(saved);
    return saved;
  }

  /// 文件名：优先 `douyin_<aweme_id>`，没有 id 时用文案；非法字符替换为 `_`。
  static String fileStem(DouyinAweme aweme) {
    final id = aweme.awemeId.trim();
    final source = id.isNotEmpty ? 'douyin_$id' : aweme.displayDesc;
    final sanitized = source
        .replaceAll(RegExp(r'[^\w\u4e00-\u9fa5-]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    final stem = sanitized.isEmpty ? 'douyin_video' : sanitized;
    return stem.length <= 60 ? stem : stem.substring(0, 60);
  }
}
