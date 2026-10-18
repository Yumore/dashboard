import 'package:dashboard/features/anime/animetrace/animetrace_anime.dart';
import 'package:dashboard/features/anime/animetrace/scrapers/animetrace_scrape_util.dart';
import 'package:dashboard/features/anime/animetrace/scrapers/animetrace_scraper.dart';

/// Bangumi (bangumi.tv) parser, ported from the source app's `ClimbBangumi`.
///
/// Bangumi is a database site: it has no playable stream, but it is the only
/// ported source that exposes a user's public collection, which the import flow
/// uses.
class AnimeTraceBangumiScraper extends AnimeTraceScraper {
  const AnimeTraceBangumiScraper();

  /// Collection tabs of a bangumi user, in site order.
  static const Map<String, String> collectionTabs = <String, String>{
    'wish': '想看',
    'collect': '看过',
    'do': '在看',
    'on_hold': '搁置',
    'dropped': '放弃',
  };

  /// Bangumi paginates a user's collection 24 entries per page.
  static const int userCollectionPageSize = 24;

  @override
  String get climbId => 'bangumi';

  @override
  String get sourceName => 'Bangumi';

  @override
  String get defaultBaseUrl => 'https://bangumi.tv';

  @override
  String searchUrl(String baseUrl, String keyword) =>
      '$baseUrl/subject_search/$keyword?cat=all';

  /// `https://bangumi.tv/anime/list/<user>/<word>?page=N`
  String userCollectionUrl(
    String baseUrl,
    String userId,
    String word, {
    int page = 1,
  }) => '$baseUrl/anime/list/$userId/$word?page=$page';

  @override
  List<AnimeTraceAnime> parseSearchResults(String html, {String? baseUrl}) =>
      parseAnimeListByBrowserItemList(html, baseUrl: baseUrl);

  /// Parses the `#browserItemList` used by both search results and the user
  /// collection pages.
  List<AnimeTraceAnime> parseAnimeListByBrowserItemList(
    String html, {
    String? baseUrl,
  }) {
    final base = baseUrl ?? defaultBaseUrl;
    final document = parseAnimeTraceHtml(html);
    final container = document.getElementById('browserItemList');
    if (container == null) return <AnimeTraceAnime>[];
    final items = container.getElementsByTagName('li');

    final animes = <AnimeTraceAnime>[];
    for (final li in items) {
      final anchors = li.getElementsByTagName('a');
      if (anchors.isEmpty) continue;
      final detailUrl = anchors[0].attributes['href'] ?? '';
      if (detailUrl.isEmpty) continue;

      final images = li.getElementsByTagName('img');
      // Some entries have no cover at all (for example 魔法科高校的劣等生 续篇).
      var cover = images.isEmpty ? '' : images[0].attributes['src'] ?? '';
      if (!cover.startsWith('https:')) cover = 'https:$cover';

      final inner = li.getElementsByClassName('inner');
      if (inner.isEmpty) continue;
      final innerElement = inner[0];
      final name = childInnerHtml(innerElement, 'a');
      final small = innerElement.getElementsByTagName('small');
      final nameAnother = small.isEmpty ? '' : small.first.innerHtml;

      final tipElements = innerElement.getElementsByClassName('info tip');
      if (tipElements.isEmpty) continue;
      final tempInfo = tipElements[0].innerHtml.trim();

      final parts = tipElements[0].innerHtml.split('/');
      var episodeCount = 0;
      var rawDate = '';
      if (parts.isNotEmpty) {
        var first = parts[0].trim();
        if (parts[0].contains('话')) {
          first = first.substring(0, first.length - 1);
          episodeCount = int.tryParse(first) ?? 0;
          // When the first field is the episode count the second one is the
          // premiere date.
          if (parts.length >= 2) rawDate = parts[1].trim();
        } else {
          rawDate = parts[0].trim();
        }
      }

      animes.add(
        AnimeTraceAnime(
          animeName: name,
          nameAnother: nameAnother,
          animeCoverUrl: cover,
          animeUrl: '$base$detailUrl',
          animeEpisodeCnt: episodeCount,
          premiereTime: normalizeBangumiDate(rawDate),
          tempInfo: tempInfo,
        ),
      );
    }
    return animes;
  }

  @override
  AnimeTraceAnime applyAnimeInfo(
    String html,
    AnimeTraceAnime anime, {
    String? baseUrl,
  }) {
    final document = parseAnimeTraceHtml(html);
    var result = anime;

    final cover = childAttribute(
      document.getElementById('bangumiInfo'),
      'a',
      'href',
    );
    if (cover != null && cover.isNotEmpty) {
      result = result.copyWith(
        animeCoverUrl: cover.startsWith('https:')
            ? cover
            : normalizeAnimeTraceImageUrl(cover),
      );
    }

    final summary = document.getElementById('subject_summary');
    if (summary != null) {
      result = result.copyWith(
        animeDesc: summary.innerHtml.replaceAll('<br>', ''),
      );
    }

    final infobox = document.getElementById('infobox');
    if (infobox != null) {
      final items = infobox.getElementsByTagName('li');
      if (items.length > 1 && items[1].innerHtml.contains('话数')) {
        final text = items[1].innerHtml
            .replaceAll('<span class="tip">话数: </span>', '')
            .trim();
        final count = int.tryParse(text);
        if (count != null) {
          result = result.copyWith(animeEpisodeCnt: count);
        }
      }
    }
    return result;
  }

  /// `false` when bangumi renders the "no such user" message page.
  bool existUser(String html) {
    final document = parseAnimeTraceHtml(html);
    return document.getElementsByClassName('message').isEmpty;
  }

  /// Total entries of one collection tab, parsed from the "想看 (44)" counters.
  int parseUserCollectionTotal(String html, String word) {
    final document = parseAnimeTraceHtml(html);
    final tabs = document.getElementsByClassName('navSubTabs');
    if (tabs.isEmpty) return 0;
    final match = RegExp(
      '$word.*?\\([0-9]*\\)',
    ).firstMatch(tabs[0].innerHtml)?.group(0);
    if (match == null) return 0;
    final open = match.indexOf('(');
    final close = match.indexOf(')');
    if (open < 0 || close <= open) return 0;
    return int.tryParse(match.substring(open + 1, close)) ?? 0;
  }
}
