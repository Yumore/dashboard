import 'package:dashboard/features/anime/takoplay/tako_anime.dart';
import 'package:dashboard/features/anime/takoplay/tako_anime_details.dart';
import 'package:dashboard/features/anime/takoplay/tako_genre.dart';
import 'package:dashboard/features/anime/takoplay/tako_episode_parser.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html;

/// Hand-written parsers for the gogoanime.wiki HTML the source app scraped.
///
/// The source read attribute *positions* (`attributes.values.first` /
/// `.last`); that behaviour is kept, with a text fallback when a card carries
/// no `title` attribute so a card can never be created with a URL as its name.
class TakoAnimeParser {
  const TakoAnimeParser._();

  /// Search results and catalogue rows: `div.items > div` cards.
  static List<TakoAnime> cards(String source, {required Uri base}) {
    final document = html.parse(source);
    final list = _first(document.getElementsByClassName('items'))?.children;
    if (list == null) return const [];

    final animes = <TakoAnime>[];
    for (final element in list) {
      final image = _attributesOf(element, 'img', 'a img');
      final anchor = _first(
        element.getElementsByClassName('name'),
      )?.querySelector('a');
      if (anchor == null) continue;
      final attributes = anchor.attributes.values.toList();
      final href = attributes.isEmpty ? '' : attributes.first;
      final title = _titleOf(anchor, attributes);
      final released = _first(element.getElementsByClassName('released'));
      animes.add(
        TakoAnime(
          id: title,
          title: title,
          url: base.resolve(href),
          image: image.isEmpty ? null : base.resolve(image),
          releasedDate: released?.text.trim() ?? '',
        ),
      );
    }
    return animes;
  }

  /// Recently updated rows from `page-recent-release.html`.
  static List<TakoAnime> recentlyAdded(String source, {required Uri base}) {
    final document = html.parse(source);
    final list = _first(document.getElementsByClassName('items'))?.children;
    if (list == null) return const [];

    final animes = <TakoAnime>[];
    for (final element in list) {
      final anchor = _first(
        element.getElementsByClassName('name'),
      )?.querySelector('a');
      if (anchor == null) continue;
      final attributes = anchor.attributes.values.toList();
      final href = attributes.isEmpty ? '' : attributes.first;
      final title = _titleOf(anchor, attributes);
      final image = _attributesOf(element, 'img', 'a img');
      final episode = _first(element.getElementsByClassName('episode'));
      animes.add(
        TakoAnime(
          id: title,
          title: title,
          url: base.resolve(href),
          image: image.isEmpty ? null : base.resolve(image),
          currentEpisode: episode?.text.trim() ?? '',
        ),
      );
    }
    return animes;
  }

  /// Anime detail page combined with its `load-list-episode` response.
  static TakoAnimeDetails details(
    String detailSource,
    String episodeSource, {
    required Uri url,
    required Uri base,
  }) {
    final document = html.parse(detailSource);
    final info = _first(document.getElementsByClassName('anime_info_body_bg'));
    final blocks = info?.getElementsByClassName('type').toList() ?? const [];
    final image = info?.querySelector('img')?.attributes['src'] ?? '';
    final title = info?.querySelector('h1')?.text.trim() ?? '';

    final genres = <TakoGenre>[];
    if (blocks.length > 2) {
      for (final anchor in blocks[2].getElementsByTagName('a')) {
        final href = _firstValue(anchor.attributes.values);
        genres.add(
          TakoGenre(
            name: anchor.text.split(',').last.trim(),
            link: base.resolve(href),
          ),
        );
      }
    }

    return TakoAnimeDetails(
      title: title,
      url: url,
      image: image.isEmpty ? null : base.resolve(image),
      summary: blocks.length > 1
          ? blocks[1].text.trim().split('Plot Summary:').last.trim()
          : '',
      releasedDate: blocks.length > 3
          ? blocks[3].text.trim().split('Released:').last.trim()
          : '',
      status: blocks.length > 4
          ? (blocks[4].querySelector('a')?.text.trim() ?? '')
          : '',
      genres: genres,
      episodeId: _episodeId(document),
      episodes: TakoEpisodeParser.parse(
        episodeSource,
        base: base,
      ).reversed.toList(),
    );
  }

  /// `anime_id` of a detail page, used by the episode list endpoint.
  static String episodeId(String source) => _episodeId(html.parse(source));

  static String _episodeId(dom.Document document) {
    final input = _first(
      document.getElementsByClassName('anime_info_episodes_next'),
    )?.querySelector('input');
    if (input == null) return '';
    final attributes = input.attributes.values.toList();
    // Source read `attributes.values.elementAt(1)` (`type` then `value`);
    // the named attribute wins when the markup orders them differently.
    return input.attributes['value'] ??
        (attributes.length > 1 ? attributes[1] : '');
  }

  static String _firstValue(Iterable<String> values) =>
      values.isEmpty ? '' : values.first;

  static String _titleOf(dom.Element anchor, List<String> attributes) {
    final last = attributes.isEmpty ? '' : attributes.last;
    if (last.isNotEmpty && !last.startsWith('/') && !last.startsWith('http')) {
      return last;
    }
    return anchor.text.trim();
  }

  /// Attribute value of `className`'s [selector] descendant, `''` when absent.
  static String _attributesOf(
    dom.Element element,
    String className,
    String selector,
  ) {
    final node = element.querySelector('.$className $selector');
    return _firstValue(node?.attributes.values ?? const []);
  }

  static dom.Element? _first(Iterable<dom.Element>? elements) =>
      elements == null || elements.isEmpty ? null : elements.first;
}
