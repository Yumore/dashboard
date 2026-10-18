import 'package:dashboard/features/short_video/douyin/douyin_json.dart';

/// `billboard_data` 的一行（`creator.douyin.com` 热门视频榜）。
class DouyinBillboardEntry {
  const DouyinBillboardEntry({
    this.author = '',
    this.imgUrl = '',
    this.link = '',
    this.rank = 0,
    this.title = '',
    this.value = '',
  });

  factory DouyinBillboardEntry.fromJson(Object? json) {
    final map = DouyinJson.asMap(json);
    return DouyinBillboardEntry(
      author: DouyinJson.asString(map['author']),
      imgUrl: DouyinJson.asString(map['img_url']),
      link: DouyinJson.asString(map['link']),
      rank: DouyinJson.asInt(map['rank']),
      title: DouyinJson.asString(map['title']),
      value: DouyinJson.asString(map['value']),
    );
  }

  final String author;
  final String imgUrl;
  final String link;
  final int rank;
  final String title;
  final String value;

  /// 源工程 `trendingScreen.dart` 用 `link.split('/')[5]` 取作品 id；
  /// 榜单链接通常以 `/` 结尾（`https://www.douyin.com/video/7001/`），
  /// 直接按下标取会依赖末尾空段。这里先去掉空段，再取 `video` 后的那一段，
  /// 同时兼容没有末尾斜杠的链接。
  String get awemeId {
    final segments =
        link.split('/').where((segment) => segment.isNotEmpty).toList();
    final videoIndex = segments.indexOf('video');
    if (videoIndex != -1 && videoIndex + 1 < segments.length) {
      return segments[videoIndex + 1];
    }
    return '';
  }

  String get displayTitle => title.trim().isEmpty ? '未命名视频' : title.trim();

  String get displayAuthor => author.trim().isEmpty ? '未知作者' : author.trim();

  String get displayValue => value.trim().isEmpty ? '0' : value.trim();
}
