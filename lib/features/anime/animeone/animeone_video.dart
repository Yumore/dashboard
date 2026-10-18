/// 剧集页面里解析出的视频源信息。
class AnimeOneVideo {
  const AnimeOneVideo(this.video);

  final String? video;

  /// anime1.me 把受保护的播放地址编码成 %7B%22...（{"c":...} 的 URL 编码）。
  bool get hasToken => video?.startsWith('%7B%22') ?? false;

  /// YouTube 预告片无法交给播放器播放。
  bool get isYoutube => video?.contains('youtube') ?? false;

  /// 是否需要输入密码才能观看（解析不到视频源）。
  bool get isEmpty => (video ?? '').trim().isEmpty;
}
