/// 书源内容类型常量与名称互转（移植 eso `lib/api/api.dart` 中的 `API` 静态常量）。
class EsoApiType {
  const EsoApiType._();

  static const int manga = 0;
  static const int novel = 1;
  static const int video = 2;
  static const int audio = 3;
  static const int rss = 4;
  static const int novelMore = 5;

  /// 0 -> 图片, 1 -> 文字, 2 -> 视频, 3 -> 音频, 4 -> RSS, 5 -> 图文, 其它 -> 图片。
  static String name(int? contentType) {
    switch (contentType) {
      case manga:
        return '图片';
      case novel:
        return '文字';
      case video:
        return '视频';
      case audio:
        return '音频';
      case rss:
        return 'RSS';
      case novelMore:
        return '图文';
      default:
        return '图片';
    }
  }

  /// 名称反查类型，未知返回 -1。
  static int fromName(String? name) {
    switch (name) {
      case '图片':
        return manga;
      case '文字':
        return novel;
      case '视频':
        return video;
      case '音频':
        return audio;
      case 'RSS':
        return rss;
      case '图文':
        return novelMore;
      default:
        return -1;
    }
  }
}
