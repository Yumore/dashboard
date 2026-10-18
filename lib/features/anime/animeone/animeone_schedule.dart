import 'package:dashboard/features/anime/animeone/animeone_basic.dart';
import 'package:dashboard/features/anime/animeone/animeone_url.dart';
import 'package:html/dom.dart';

/// 新番表里的一行，weekday 采用 DateTime.weekday（周一 = 1，周日 = 7）。
class AnimeOneSchedule extends AnimeOneBasic {
  AnimeOneSchedule({super.name, super.link, this.weekday});

  /// anime1.me 的表格以周日开头（周日..周六），这里换成 Dart 的 weekday
  /// （周一 = 1 ... 周日 = 7）。
  factory AnimeOneSchedule.fromCell(Node cell, int index) {
    final weekday = index == 0 ? 7 : index;
    final first = cell.firstChild;
    if (first == null) return AnimeOneSchedule(weekday: weekday);
    final href = first is Element ? first.attributes['href'] : null;
    return AnimeOneSchedule(
      weekday: weekday,
      name: (first.text ?? '').trim(),
      link: AnimeOneUrl.absolute(href),
    );
  }

  factory AnimeOneSchedule.fromJson(Map<String, dynamic> json) =>
      AnimeOneSchedule(
        name: json['name'] as String?,
        link: json['link'] as String?,
        weekday: json['weekday'] as int?,
      );

  int? weekday;

  Map<String, dynamic> toJson() => {
    'weekday': weekday,
    'name': name,
    'link': link,
  };
}
