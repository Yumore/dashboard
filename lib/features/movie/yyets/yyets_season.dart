import 'package:dashboard/features/movie/yyets/yyets_episode.dart';
import 'package:dashboard/features/movie/yyets/yyets_json.dart';

/// 一季。
///
/// 对应源工程 `EpisodeWidget` 的 `item`：
///
/// ```dart
/// String season = item['season'].toString();
/// List epiList = item['episode_list'];
/// Text("${item['season_cn']}");
/// ```
class YyetsSeason {
  const YyetsSeason({
    this.season = '',
    this.seasonCn = '',
    this.episodes = const <YyetsEpisode>[],
  });

  /// `season` —— 季号。
  final String season;

  /// `season_cn` —— 中文季名，如 `第一季`。
  final String seasonCn;

  /// `episode_list`
  final List<YyetsEpisode> episodes;

  String get label => seasonCn.isNotEmpty ? seasonCn : '第$season季';

  factory YyetsSeason.fromJson(Map<String, dynamic> json) => YyetsSeason(
    season: YyetsJson.asString(json['season']),
    seasonCn: YyetsJson.asString(json['season_cn']),
    episodes: YyetsJson.asMapList(
      json['episode_list'],
    ).map(YyetsEpisode.fromJson).toList(growable: false),
  );
}
