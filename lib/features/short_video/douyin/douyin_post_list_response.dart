import 'package:dashboard/features/short_video/douyin/douyin_json.dart';
import 'package:dashboard/features/short_video/douyin/douyin_post.dart';

/// `tiktok.com/share/item/list` 的响应（`Tiktok` + `Body`）。
class DouyinPostListResponse {
  const DouyinPostListResponse({
    this.statusCode = 0,
    this.errMsg = '',
    this.posts = const <DouyinPost>[],
    this.hasMore = false,
    this.maxCursor = '',
    this.minCursor = '',
  });

  factory DouyinPostListResponse.fromJson(Object? json) {
    final map = DouyinJson.asMap(json);
    final body = DouyinJson.asMap(map['body']);
    return DouyinPostListResponse(
      statusCode: DouyinJson.asInt(map['statusCode']),
      errMsg: DouyinJson.asString(map['errMsg']),
      posts: DouyinJson.asList(body['itemListData'])
          .map(DouyinPost.fromJson)
          .toList(growable: false),
      hasMore: DouyinJson.asBool(body['hasMore']),
      maxCursor: DouyinJson.asString(body['maxCursor']),
      minCursor: DouyinJson.asString(body['minCursor']),
    );
  }

  final int statusCode;
  final String errMsg;
  final List<DouyinPost> posts;

  /// 源工程 `Body.hasMore` 是 `json['hasMore'].toString()`（字符串 `"true"`）。
  final bool hasMore;
  final String maxCursor;
  final String minCursor;

  bool get isSuccess => statusCode == 0;

  bool get isEmpty => posts.isEmpty;
}
