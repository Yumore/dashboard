import 'package:dashboard/features/anime/animeone/animeone_basic_parser.dart';
import 'package:dashboard/features/anime/animeone/animeone_entry.dart';
import 'package:dashboard/features/anime/animeone/animeone_page_result.dart';
import 'package:dashboard/features/anime/animeone/animeone_url.dart';
import 'package:html/dom.dart';

/// 解析分类页 / 单集页：div.hentry 列表 + 页标题 + 分类链接。
class AnimeOneAnimePageParser
    implements AnimeOneBasicParser<AnimeOnePageResult> {
  const AnimeOneAnimePageParser();

  @override
  AnimeOnePageResult parse(Document document) {
    final entries = document
        .getElementsByClassName('hentry')
        .map(AnimeOneEntry.fromElement)
        .where((entry) => entry.valid())
        .toList();

    final titleElements = document.getElementsByClassName('page-title');
    final title = titleElements.isEmpty ? '' : titleElements.first.text.trim();

    String? categoryLink;
    final catLinks = document.getElementsByClassName('cat-links');
    if (catLinks.isNotEmpty) {
      final anchors = catLinks.first.getElementsByTagName('a');
      if (anchors.isNotEmpty) {
        categoryLink = AnimeOneUrl.absolute(anchors.first.attributes['href']);
      }
    }

    return AnimeOnePageResult(
      entries: entries,
      title: title,
      categoryLink: categoryLink,
    );
  }
}
