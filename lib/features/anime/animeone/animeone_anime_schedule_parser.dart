import 'package:dashboard/features/anime/animeone/animeone_basic_parser.dart';
import 'package:dashboard/features/anime/animeone/animeone_schedule.dart';
import 'package:dashboard/features/anime/animeone/animeone_schedule_result.dart';
import 'package:dashboard/features/anime/animeone/animeone_video.dart';
import 'package:html/dom.dart';

/// 解析新番表页面：顶部预览 video[data-apireq] + 表格里的每日条目。
class AnimeOneAnimeScheduleParser
    implements AnimeOneBasicParser<AnimeOneScheduleResult> {
  const AnimeOneAnimeScheduleParser();

  @override
  AnimeOneScheduleResult parse(Document document) {
    AnimeOneVideo? video;
    final videos = document.getElementsByTagName('video');
    if (videos.isNotEmpty) {
      video = AnimeOneVideo(videos.first.attributes['data-apireq']);
    }

    final schedules = <AnimeOneSchedule>[];
    for (final body in document.querySelectorAll('table > tbody')) {
      for (final row in body.children) {
        final cells = row.children;
        for (var index = 0; index < cells.length; index++) {
          final cell = cells[index];
          if (cell.localName != 'td') continue;
          final schedule = AnimeOneSchedule.fromCell(cell, index);
          if (schedule.valid()) schedules.add(schedule);
        }
      }
    }
    return AnimeOneScheduleResult(schedules: schedules, video: video);
  }
}
