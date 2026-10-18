import 'package:dashboard/features/movie/yyets/yyets_json.dart';
import 'package:dashboard/features/movie/yyets/yyets_movie.dart';
import 'package:dashboard/features/movie/yyets/yyets_rank_tab.dart';

/// `Api.loadRank()` 的响应体（`res.data['data']`）。
///
/// 源工程只把它当 `Map<String, dynamic>` 用，`RankPage` 按写死的 6 个 key 取
/// 列表。移植版把 6 个列表都解析出来，缺失的 key 退化成空列表。
class YyetsRankResult {
  const YyetsRankResult({required this.lists});

  /// key 是 [YyetsRankTab.key]，value 是对应榜单。
  final Map<String, List<YyetsMovie>> lists;

  factory YyetsRankResult.fromJson(Map<String, dynamic> json) =>
      YyetsRankResult(
        lists: <String, List<YyetsMovie>>{
          for (final tab in YyetsRankTab.values)
            tab.key: YyetsJson.asMapList(
              json[tab.key],
            ).map(YyetsMovie.fromJson).toList(growable: false),
        },
      );

  const YyetsRankResult.empty() : lists = const <String, List<YyetsMovie>>{};

  List<YyetsMovie> listFor(YyetsRankTab tab) =>
      lists[tab.key] ?? const <YyetsMovie>[];

  bool get isEmpty => lists.values.every((items) => items.isEmpty);

  /// 源工程 `MainPage` 的 tab 顺序。
  static List<YyetsRankTab> get tabs => YyetsRankTab.values;
}
