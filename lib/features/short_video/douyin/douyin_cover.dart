import 'package:dashboard/features/short_video/douyin/douyin_json.dart';

/// 抖音封面/头像的统一形状 `{uri, url_list}`。
///
/// 源工程为 `avatar_medium`、`avatar_larger`、`cover_medium`、`cover_large`
/// 等各写了一个字段完全相同的类（`Douyin.Dart`）；宿主只保留一个值对象。
class DouyinCover {
  const DouyinCover({this.uri = '', this.urls = const <String>[]});

  factory DouyinCover.fromJson(Object? json) {
    final map = DouyinJson.asMap(json);
    return DouyinCover(
      uri: DouyinJson.asString(map['uri']),
      urls: DouyinJson.stringList(map['url_list']),
    );
  }

  static const DouyinCover empty = DouyinCover();

  final String uri;
  final List<String> urls;

  String get firstUrl => urls.isEmpty ? '' : urls.first;

  bool get isEmpty => firstUrl.isEmpty;
}
