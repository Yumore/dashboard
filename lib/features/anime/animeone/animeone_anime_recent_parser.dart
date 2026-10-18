import 'package:dashboard/features/anime/animeone/animeone_basic_parser.dart';
import 'package:dashboard/features/anime/animeone/animeone_recent.dart';
import 'package:html/dom.dart';

/// 解析首页侧栏“最近更新”：div.widget-area 下第一个 ul 的 li 列表。
class AnimeOneAnimeRecentParser
    implements AnimeOneBasicParser<List<AnimeOneRecent>> {
  const AnimeOneAnimeRecentParser();

  @override
  List<AnimeOneRecent> parse(Document document) {
    final areas = document.getElementsByClassName('widget-area');
    if (areas.isEmpty) return [];
    final lists = areas.first.getElementsByTagName('ul');
    if (lists.isEmpty) return [];
    return lists.first.children
        .map(AnimeOneRecent.fromElement)
        .where((recent) => recent.valid())
        .toList();
  }
}
