import 'package:dashboard/features/short_video/douyin/douyin_api.dart';
import 'package:dashboard/features/short_video/douyin/douyin_aweme.dart';
import 'package:dashboard/features/short_video/douyin/douyin_download_controller.dart';
import 'package:dashboard/features/short_video/douyin/douyin_downloaded_video.dart';
import 'package:dashboard/features/short_video/douyin/douyin_error_message.dart';
import 'package:dashboard/features/short_video/douyin/douyin_play_address.dart';
import 'package:dashboard/features/short_video/douyin/douyin_play_address_selector.dart';

/// 详情页控制器：作品元数据 + 播放地址 + 下载保存。
class DouyinDetailController {
  DouyinDetailController({
    required this.api,
    required this.downloadController,
    this.selector = const DouyinPlayAddressSelector(),
  });

  final DouyinApi api;
  final DouyinDownloadController downloadController;
  final DouyinPlayAddressSelector selector;

  DouyinAweme? aweme;
  DouyinPlayAddress playAddress = const DouyinPlayAddress.none();
  String playUrl = '';
  String? playError;
  String? error;
  bool isLoading = false;
  bool isDownloading = false;
  DouyinDownloadedVideo? saved;

  Future<void> load(String awemeId) async {
    isLoading = true;
    error = null;
    playError = null;
    playUrl = '';
    aweme = null;
    saved = null;
    try {
      final loaded = await api.fetchAweme(awemeId);
      aweme = loaded;
      playAddress = selector.select(loaded.video);
      if (playAddress.isDirect) {
        playUrl = playAddress.url;
      } else if (playAddress.isRedirect) {
        try {
          playUrl = await api.resolvePlayUrl(playAddress.videoId);
        } catch (failure) {
          playError = douyinErrorMessage(failure);
        }
      } else {
        playError = '没有可用的播放地址';
      }
    } catch (failure) {
      error = douyinErrorMessage(failure);
    } finally {
      isLoading = false;
    }
  }

  Future<void> download() async {
    final current = aweme;
    if (current == null) {
      error = '还没有加载到作品，无法保存';
      return;
    }
    isDownloading = true;
    error = null;
    try {
      saved = await downloadController.download(current, address: playAddress);
    } catch (failure) {
      error = douyinErrorMessage(failure);
    } finally {
      isDownloading = false;
    }
  }
}
