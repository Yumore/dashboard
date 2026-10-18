import 'package:dashboard/features/anime/animeone/animeone_basic.dart';
import 'package:dashboard/features/anime/animeone/animeone_url.dart';

/// animelist.json 中的一条动画目录信息。
class AnimeOneInfo extends AnimeOneBasic {
  AnimeOneInfo({
    super.name,
    super.link,
    this.episode,
    this.year,
    this.season,
    this.subtitle,
  });

  /// animelist.json 的每一行是 [分类 ID, 名称, 集数, 年份, 季度, 字幕组]。
  factory AnimeOneInfo.fromList(List<dynamic> item) {
    String? text(int index) =>
        index < item.length && item[index] != null ? '${item[index]}' : null;
    final id = item.isNotEmpty && item.first is int ? item.first as int : 0;
    return AnimeOneInfo(
      link: AnimeOneUrl.category(id),
      name: text(1),
      episode: text(2),
      year: text(3),
      season: text(4),
      subtitle: text(5),
    );
  }

  factory AnimeOneInfo.fromJson(Map<String, dynamic> json) => AnimeOneInfo(
    name: json['name'] as String?,
    link: json['link'] as String?,
    episode: json['episode'] as String?,
    year: json['year'] as String?,
    season: json['season'] as String?,
    subtitle: json['subtitle'] as String?,
  );

  String? episode;
  String? year;
  String? season;
  String? subtitle;

  Map<String, dynamic> toJson() => {
    'subtitle': subtitle,
    'season': season,
    'year': year,
    'episode': episode,
    'name': name,
    'link': link,
  };

  @override
  bool contains(String text) {
    if (super.contains(text)) return true;
    if ('${year ?? ''}${season ?? ''}'.contains(text)) return true;
    if ((episode ?? '').contains(text)) return true;
    if ((subtitle ?? '').contains(text)) return true;
    return false;
  }

  /// 列表副标题：集数 · 年份季度 · 字幕组。
  String get meta {
    final parts = <String>[
      if ((episode ?? '').isNotEmpty) episode!,
      if ('${year ?? ''}${season ?? ''}'.isNotEmpty) '$year$season',
      if ((subtitle ?? '').isNotEmpty) subtitle!,
    ];
    return parts.join(' · ');
  }

  @override
  String toString() =>
      'AnimeOneInfo($name, $link, $episode, $year$season, $subtitle)';
}
