/// v.anime1.me/api 解析出的播放地址与响应 Cookie。
class AnimeOneVideoSource {
  const AnimeOneVideoSource({this.url, this.cookie});

  final String? url;
  final String? cookie;

  bool get available => (url ?? '').isNotEmpty;
}
