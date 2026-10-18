import 'package:dashboard/features/short_video/douyin/douyin_api.dart';
import 'package:dashboard/features/short_video/douyin/douyin_error_message.dart';
import 'package:dashboard/features/short_video/douyin/douyin_post.dart';
import 'package:dashboard/features/short_video/douyin/douyin_signature_rejected.dart';

/// 用户作品页控制器：`tiktok.com/share/item/list`。
///
/// 该接口依赖 `_signature`；签名过期时 [signatureRejected] 为真，
/// 页面据此展示迁移文档记录的失败说明。
class DouyinUserPostController {
  DouyinUserPostController({required this.api});

  final DouyinApi api;

  List<DouyinPost> posts = const <DouyinPost>[];
  bool isLoading = false;
  bool signatureRejected = false;
  String? error;
  String secUid = '';
  bool hasMore = false;
  String maxCursor = '';

  Future<void> load({String secUid = '', int count = 30}) async {
    isLoading = true;
    error = null;
    signatureRejected = false;
    this.secUid = secUid.trim();
    try {
      final response = await api.fetchUserPosts(
        secUid: this.secUid,
        count: count,
      );
      posts = response.posts;
      hasMore = response.hasMore;
      maxCursor = response.maxCursor;
    } catch (failure) {
      error = douyinErrorMessage(failure);
      signatureRejected = failure is DouyinSignatureRejected;
      posts = const <DouyinPost>[];
      hasMore = false;
      maxCursor = '';
    } finally {
      isLoading = false;
    }
  }
}
