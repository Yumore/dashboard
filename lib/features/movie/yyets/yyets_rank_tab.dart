import 'package:flutter/material.dart';

/// 榜单分类。
///
/// 源工程 `RankPage._body` 固定按这个顺序渲染 6 个 tab：
///
/// ```dart
/// data["today_list"], data["month_list"], data["movie_list"],
/// data["new_list"], data["japan_list"], data["total_list"]
/// ```
///
/// 而 `MainPage` 的 tab 文案依次是 今日 / 本月 / 电影 / 新剧 / 日剧 / 全部。
/// 两边合起来才是 [YyetsRankTab] 的完整定义。
enum YyetsRankTab {
  today('today_list', '今日'),
  month('month_list', '本月'),
  movie('movie_list', '电影'),
  newDrama('new_list', '新剧'),
  japan('japan_list', '日剧'),
  total('total_list', '全部');

  const YyetsRankTab(this.key, this.label);

  /// `data` 里的列表字段名。
  final String key;

  /// tab 文案。
  final String label;

  /// 源工程的 tab 图标（源工程没给图标，这里按语义补齐，便于宿主模块入口复用）。
  IconData get icon => switch (this) {
    YyetsRankTab.today => Icons.today_outlined,
    YyetsRankTab.month => Icons.calendar_month_outlined,
    YyetsRankTab.movie => Icons.movie_outlined,
    YyetsRankTab.newDrama => Icons.fiber_new_outlined,
    YyetsRankTab.japan => Icons.live_tv_outlined,
    YyetsRankTab.total => Icons.list_alt_outlined,
  };
}
