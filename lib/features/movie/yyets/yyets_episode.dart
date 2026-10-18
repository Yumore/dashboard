import 'package:dashboard/features/movie/yyets/yyets_json.dart';

/// 剧集里的一集。
///
/// 对应源工程 `EpisodeWidget` 里的 `epiItem`：
///
/// ```dart
/// epiItem['episode']        // 集号
/// epiItem['play_status_cn'] // "未播" 时不可点
/// epiItem['play_time']      // nullEmptyElse(.., "无时间")
/// ```
class YyetsEpisode {
  const YyetsEpisode({
    this.episode = '',
    this.name = '',
    this.playStatus = '',
    this.playStatusCn = '',
    this.playTime,
    this.itemId,
  });

  /// `episode` —— 集号，可能是数字，统一转字符串。
  final String episode;

  /// `name` —— 可选标题。
  final String name;

  /// `play_status` —— 数字/布尔状态。
  final String playStatus;

  /// `play_status_cn` —— 中文状态；源工程用 `== "未播"` 判断能否进入资源页。
  final String playStatusCn;

  /// `play_time` —— 源工程 `nullEmptyElse(epiItem['play_time'], "无时间")`。
  final String? playTime;

  /// `itemid` —— 部分接口用它定位资源。
  final String? itemId;

  /// 源工程 `bool unPlay = epiItem['play_status_cn'] == "未播";`
  bool get isUnbroadcast => playStatusCn == '未播';

  bool get canOpen => !isUnbroadcast && episode.isNotEmpty;

  /// 源工程 `nullEmptyElse(epiItem['play_time'], "无时间")`。
  String get playTimeLabel {
    final time = playTime?.trim() ?? '';
    return time.isEmpty ? '无时间' : time;
  }

  /// 源 `EpisodeWidget._toResPage` 传给资源页的参数：
  /// `epiItem + resInfo + {season_cn, season, episode}`。
  ///
  /// [itemId] 不传时用这一集自己的 [itemId]；两者都没有就不带该参数。
  Map<String, String> resourceArguments({
    required String id,
    required String season,
    String? seasonCn,
    String itemId = '',
  }) {
    final effectiveItemId = itemId.isNotEmpty ? itemId : (this.itemId ?? '');
    return <String, String>{
      'id': id,
      'episode': episode,
      'season': season,
      'season_cn': ?seasonCn,
      if (effectiveItemId.isNotEmpty) 'itemid': effectiveItemId,
    };
  }

  factory YyetsEpisode.fromJson(Map<String, dynamic> json) => YyetsEpisode(
    episode: YyetsJson.asString(json['episode']),
    name: YyetsJson.asString(json['name']),
    playStatus: YyetsJson.asString(json['play_status']),
    playStatusCn: YyetsJson.asString(json['play_status_cn']),
    playTime: YyetsJson.asNullableString(json['play_time']),
    itemId: YyetsJson.asNullableString(json['itemid']),
  );
}
