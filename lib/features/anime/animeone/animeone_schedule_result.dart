import 'package:dashboard/features/anime/animeone/animeone_schedule.dart';
import 'package:dashboard/features/anime/animeone/animeone_video.dart';

/// 新番表页面的解析结果。
class AnimeOneScheduleResult {
  const AnimeOneScheduleResult({this.schedules = const [], this.video});

  final List<AnimeOneSchedule> schedules;

  /// 页面顶部的新番介绍视频（可能是 YouTube 预告）。
  final AnimeOneVideo? video;
}
