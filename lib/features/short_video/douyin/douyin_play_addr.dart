import 'package:dashboard/features/short_video/douyin/douyin_json.dart';

/// `video.play_addr`：`uri` 用于向播放接口换无水印地址，`url_list` 是带水印直链。
class DouyinPlayAddr {
  const DouyinPlayAddr({this.uri = '', this.urls = const <String>[]});

  factory DouyinPlayAddr.fromJson(Object? json) {
    final map = DouyinJson.asMap(json);
    return DouyinPlayAddr(
      uri: DouyinJson.asString(map['uri']),
      urls: DouyinJson.stringList(map['url_list']),
    );
  }

  final String uri;
  final List<String> urls;

  String get firstUrl => urls.isEmpty ? '' : urls.first;

  bool get isEmpty => uri.isEmpty && firstUrl.isEmpty;
}
