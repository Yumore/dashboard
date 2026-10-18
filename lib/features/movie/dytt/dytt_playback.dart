import 'package:dashboard/features/movie/dytt/dytt_play_url.dart';

/// 把详情里的 `downloadUrl` 拆成有序地址列表，并挑出宿主能播的 HTTP(S)。
///
/// 源工程把整串地址只当作一个字符串展示，下载按钮是空实现；宿主把它
/// 解析成线路，点第 N 条就从第 N 条开始连续播放。
class DyttPlayback {
  DyttPlayback._(this.urls);

  factory DyttPlayback.fromDownloadUrl(String downloadUrl) {
    final urls = <DyttPlayUrl>[];
    for (final part in downloadUrl.split(';')) {
      if (part.trim().isEmpty) continue;
      try {
        urls.add(DyttPlayUrl.parse(part));
      } on FormatException {
        // 源站偶尔混入无法解析的条目；丢掉这一条，不拖垮整个详情页。
      }
    }
    return DyttPlayback._(List<DyttPlayUrl>.unmodifiable(urls));
  }

  /// 全部可解析地址，保持源站顺序。
  final List<DyttPlayUrl> urls;

  /// 只有 HTTP(S) 能交给 `MediaPlaybackPage`。
  List<DyttPlayUrl> get playable =>
      List<DyttPlayUrl>.unmodifiable(urls.where((url) => url.isPlayable));

  bool get hasPlayable => playable.isNotEmpty;

  /// 从第 [index] 条可播放线路取到末尾，供「点某一集继续连播」使用。
  ///
  /// 索引越界时夹到有效范围；没有可播放地址时返回空列表。
  List<DyttPlayUrl> playableFrom(int index) {
    final all = playable;
    if (all.isEmpty) return const <DyttPlayUrl>[];
    final start = index < 0
        ? 0
        : index >= all.length
        ? all.length - 1
        : index;
    return List<DyttPlayUrl>.unmodifiable(all.sublist(start));
  }
}
