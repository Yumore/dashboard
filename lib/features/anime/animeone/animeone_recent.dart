import 'package:dashboard/features/anime/animeone/animeone_basic.dart';
import 'package:dashboard/features/anime/animeone/animeone_url.dart';
import 'package:html/dom.dart';

/// 首页侧栏“最近更新”里的一条记录，只有名称与链接。
class AnimeOneRecent extends AnimeOneBasic {
  AnimeOneRecent({super.name, super.link});

  factory AnimeOneRecent.fromElement(Element element) {
    final first = element.firstChild;
    final anchor = first is Element ? first : element.querySelector('a');
    if (anchor == null) return AnimeOneRecent();
    return AnimeOneRecent(
      name: anchor.text.trim(),
      link: AnimeOneUrl.absolute(anchor.attributes['href']),
    );
  }
}
