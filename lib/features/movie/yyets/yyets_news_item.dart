import 'package:dashboard/features/movie/yyets/yyets_endpoint.dart';
import 'package:dashboard/features/movie/yyets/yyets_json.dart';

/// `Api.news(page)` 返回的资讯条目。
///
/// 源工程 `NewsPage.buildItem` 的字段回退链比较多（同一份数据来自微博/文章两种
/// 来源），这里逐一保留：
///
/// * 图片：`poster ?? cover`
/// * 正文：`content ?? intro`
/// * 作者：`username ?? author_name`
/// * 头像：`userpic ?? user_logo`
/// * 时间：`dateline ?? time`
/// * 点赞：`good_status ?? views`
class YyetsNewsItem {
  const YyetsNewsItem({
    this.id = '',
    this.type = '',
    this.title = '',
    this.content = '',
    this.poster,
    this.cover,
    this.username = '',
    this.authorName = '',
    this.userPic,
    this.dateline,
    this.views = 0,
    this.goodStatus,
    this.commentCount = 0,
    this.url,
    this.video720,
    this.video480,
  });

  final String id;

  /// `weibo` 走 `item['url']`，其余走 `m1.rryslink.com/article/<id>`。
  final String type;

  final String title;
  final String content;
  final String? poster;
  final String? cover;
  final String username;
  final String authorName;
  final String? userPic;
  final int? dateline;
  final int views;
  final int? goodStatus;
  final int commentCount;

  /// `url` —— 仅微博类资讯有。
  final String? url;

  /// 视频资讯的两个清晰度。
  final String? video720;
  final String? video480;

  bool get isWeibo => type == 'weibo';

  /// 源工程 `var isVideo = item["cover"] != null && item["cover"] != "";`
  bool get isVideo => cover != null && cover!.isNotEmpty;

  /// 源工程 `var imgUrl = item['poster'] ?? item["cover"]; if (imgUrl == "") imgUrl = null;`
  String? get imageUrl {
    final candidate = _nonEmpty(poster) ?? _nonEmpty(cover);
    return candidate;
  }

  String get author {
    final name = _nonEmpty(username) ?? _nonEmpty(authorName);
    return name ?? '';
  }

  /// 源工程 `NewsPage` 的点击跳转地址。
  String get webUrl =>
      isWeibo && _nonEmpty(url) != null ? url! : YyetsEndpoint.articleUrl(id);

  /// 源工程 `var videoUrl = item['video_720']; if (空) videoUrl = item['video_480'];`
  String? get videoUrl => _nonEmpty(video720) ?? _nonEmpty(video480);

  /// 源工程 `_footer`：点赞数 `good_status ?? views`。
  int get likeCount => goodStatus ?? views;

  factory YyetsNewsItem.fromJson(Map<String, dynamic> json) => YyetsNewsItem(
    id: YyetsJson.asString(json['id']),
    type: YyetsJson.asString(json['type']),
    title: YyetsJson.asString(json['title']),
    content: YyetsJson.asString(json['content']).isEmpty
        ? YyetsJson.asString(json['intro'])
        : YyetsJson.asString(json['content']),
    poster: YyetsJson.asNullableString(json['poster']),
    cover: YyetsJson.asNullableString(json['cover']),
    username: YyetsJson.asString(json['username']),
    authorName: YyetsJson.asString(json['author_name']),
    userPic:
        YyetsJson.asNullableString(json['userpic']) ??
        YyetsJson.asNullableString(json['user_logo']),
    dateline:
        YyetsJson.asNullableInt(json['dateline']) ??
        YyetsJson.asNullableInt(json['time']),
    views: YyetsJson.asInt(json['views']),
    goodStatus: YyetsJson.asNullableInt(json['good_status']),
    commentCount: YyetsJson.asInt(json['count_comments']),
    url: YyetsJson.asNullableString(json['url']),
    video720: YyetsJson.asNullableString(json['video_720']),
    video480: YyetsJson.asNullableString(json['video_480']),
  );

  static String? _nonEmpty(String? value) {
    final text = value?.trim() ?? '';
    return text.isEmpty ? null : text;
  }
}
