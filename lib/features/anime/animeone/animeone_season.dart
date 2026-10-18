import 'package:dashboard/features/anime/animeone/animeone_url.dart';

/// 根据日期计算新番季度、季度链接与快捷筛选。
class AnimeOneSeason {
  AnimeOneSeason(this.date);

  final DateTime date;

  static const List<String> _seasonChars = ['冬', '春', '夏', '秋'];
  static const List<String> _seasonWords = ['冬季', '春季', '夏季', '秋季'];
  static const List<String> _typeValues = ['連載中', '劇場版', 'OVA', 'OAD'];

  List<int> _yearAndSeason(DateTime value) {
    final int season;
    if (value.month < 4) {
      season = 0;
    } else if (value.month < 7) {
      season = 1;
    } else if (value.month < 10) {
      season = 2;
    } else {
      season = 3;
    }
    return [value.year, season];
  }

  /// 新番名称，例如 2019年春季新番。
  String get name {
    final parts = _yearAndSeason(date);
    return '${parts[0]}年${_seasonWords[parts[1]]}新番';
  }

  /// 新番表链接。
  String get scheduleLink => '${AnimeOneUrl.domain}$name';

  /// 分类页链接，去掉名称里的“新番”。
  String get categoryLink =>
      '${AnimeOneUrl.domain}category/${name.replaceFirst('新番', '')}';

  /// 预设筛选：类型 + 当季及往前三个季度，value 与站点上的中文一致。
  List<({String label, String value})> quickFilters() {
    final filters = <({String label, String value})>[
      for (final value in _typeValues) (label: value, value: value),
    ];
    for (var i = 0, offset = 0; i < 4; i++, offset -= 3) {
      final parts = _yearAndSeason(date.add(Duration(days: offset * 30)));
      filters.add((
        label: '${parts[0]} ${_seasonWords[parts[1]]}',
        value: '${parts[0]}${_seasonChars[parts[1]]}',
      ));
    }
    return filters;
  }

  @override
  String toString() => name;
}
