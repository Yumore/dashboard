import 'package:dashboard/features/movie/fluttermovies/fluttermovies_play_source.dart';

/// 源站的选线逻辑（lib/movie/movie_detail/movie_detail_view.dart:68-79, 383）：
/// 按分集数从多到少排序，再过滤掉 `from == 'ckm3u8'`，默认取第一条。
///
/// 这里保持同样的结果顺序：分集数相同的线路按原数组顺序（稳定排序），
/// 与源站 `List.sort` 在小列表下的实际行为一致，同时不依赖 sort 的稳定性实现。
class FlutterMoviesPlaySourceSelector {
  const FlutterMoviesPlaySourceSelector._();

  static List<FlutterMoviesPlaySource> select(
    List<FlutterMoviesPlaySource> sources,
  ) {
    final usable = <FlutterMoviesPlaySource>[
      for (final source in sources)
        if (source.from != FlutterMoviesPlaySource.excludedFrom) source,
    ];
    final order = <FlutterMoviesPlaySource, int>{
      for (var index = 0; index < usable.length; index++) usable[index]: index,
    };
    usable.sort((a, b) {
      final byEpisodes = b.episodes.length.compareTo(a.episodes.length);
      if (byEpisodes != 0) return byEpisodes;
      return (order[a] ?? 0).compareTo(order[b] ?? 0);
    });
    return usable;
  }

  /// 过滤后仍然有分集地址的线路。
  static List<FlutterMoviesPlaySource> playable(
    List<FlutterMoviesPlaySource> sources,
  ) => select(
    sources,
  ).where((source) => source.episodes.isNotEmpty).toList(growable: false);

  /// 详情页默认选中的线路：源站取 `vodPlayListTmp[0]`。
  static FlutterMoviesPlaySource? defaultSource(
    List<FlutterMoviesPlaySource> sources,
  ) {
    final usable = select(sources);
    return usable.isEmpty ? null : usable.first;
  }

  /// TabView 默认下标，恒为 0。
  static int defaultIndex(List<FlutterMoviesPlaySource> sources) => 0;
}
