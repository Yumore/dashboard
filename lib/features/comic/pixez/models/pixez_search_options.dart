/// Sort/target values accepted by `/v1/search/illust` and `/v1/search/novel`.
class PixezSearchOptions {
  const PixezSearchOptions._();

  static const String defaultSort = 'date_desc';
  static const String defaultTarget = 'partial_match_for_tags';

  static const List<String> sorts = <String>[
    'date_desc',
    'date_asc',
    'popular_desc',
  ];

  static const List<String> targets = <String>[
    'partial_match_for_tags',
    'exact_match_for_tags',
    'title_and_caption',
  ];

  static const Map<String, String> sortLabels = <String, String>{
    'date_desc': '最新',
    'date_asc': '最早',
    'popular_desc': '热门',
  };

  static const Map<String, String> targetLabels = <String, String>{
    'partial_match_for_tags': '标签部分匹配',
    'exact_match_for_tags': '标签完全匹配',
    'title_and_caption': '标题与说明',
  };
}
