import 'package:dashboard/features/anime/animetrace/animetrace_anime.dart';
import 'package:dashboard/features/anime/animetrace/scrapers/animetrace_scrape_util.dart';
import 'package:dashboard/features/anime/animetrace/scrapers/animetrace_scraper.dart';
import 'package:dashboard/features/anime/animetrace/scrapers/animetrace_stream_extractor.dart';

/// AGE动漫 (agedm.org) parser, ported from the source app's `ClimbAgemys`.
class AnimeTraceAgemysScraper extends AnimeTraceScraper {
  const AnimeTraceAgemysScraper();

  @override
  String get climbId => 'age';

  @override
  String get sourceName => 'AGE动漫';

  @override
  String get defaultBaseUrl => 'https://www.agedm.org';

  @override
  String searchUrl(String baseUrl, String keyword) =>
      '$baseUrl/search?query=$keyword';

  @override
  List<AnimeTraceAnime> parseSearchResults(String html, {String? baseUrl}) {
    final base = baseUrl ?? defaultBaseUrl;
    final document = parseAnimeTraceHtml(html);
    final elements = document.getElementsByClassName('cata_video_item');
    final animes = <AnimeTraceAnime>[];
    for (final element in elements) {
      final images = element.getElementsByTagName('img');
      if (images.isEmpty) continue;
      final cover = normalizeAnimeTraceImageUrl(
        images[0].attributes['data-original'],
      );
      if (cover.isEmpty) continue;
      final name = images[0].attributes['alt'] ?? '';
      final href = childAttribute(element, 'a', 'href') ?? '';
      final statusElements = element.getElementsByClassName(
        'video_play_status',
      );
      final statusText = statusElements.isEmpty
          ? ''
          : statusElements[0].innerHtml;
      animes.add(
        AnimeTraceAnime(
          animeName: name,
          animeCoverUrl: cover,
          animeUrl: _absoluteUrl(base, href),
          animeEpisodeCnt: parseEpisodeCountOfYhdm(statusText),
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
    final values = document.getElementsByClassName('detail_imform_value');
    String valueAt(int index) =>
        index < values.length ? values[index].innerHtml.trim() : '';

    var result = anime.copyWith(
      area: valueAt(0),
      category: valueAt(1),
      nameOri: valueAt(2),
      nameAnother: valueAt(3),
      authorOri: valueAt(4),
      productionCompany: valueAt(5),
      premiereTime: valueAt(6),
      playStatus: valueAt(7),
    );

    final descElement = firstByClass(document, 'video_detail_desc');
    if (descElement != null) {
      result = result.copyWith(animeDesc: innerHtmlWithLineBreaks(descElement));
    }

    final cover = childAttribute(
      firstByClass(document, 'video_detail_cover'),
      'img',
      'data-original',
    );
    if (cover != null && cover.trim().isNotEmpty) {
      result = result.copyWith(
        animeCoverUrl: normalizeAnimeTraceImageUrl(cover),
      );
    }

    // The episode lists include a "PV" list and possibly a single "全集" list.
    var episodeCount = 0;
    for (final list in document.getElementsByClassName(
      'video_detail_episode',
    )) {
      final items = list.getElementsByTagName('li');
      if (items.isEmpty) continue;
      final firstItem = items[0].innerHtml;
      if (firstItem.contains('PV')) continue;
      if (firstItem.contains('全集')) {
        episodeCount = 1;
        break;
      }
      if (items.length > episodeCount) episodeCount = items.length;
    }
    if (episodeCount > 0) {
      result = result.copyWith(animeEpisodeCnt: episodeCount);
    }
    return result;
  }

  /// Every episode link of the detail page, in list order, skipping the "PV"
  /// list exactly like the episode counting above does.
  @override
  List<String> parseEpisodeUrls(String html, {String? baseUrl}) {
    final base = baseUrl ?? defaultBaseUrl;
    final document = parseAnimeTraceHtml(html);
    final urls = <String>[];
    for (final list in document.getElementsByClassName(
      'video_detail_episode',
    )) {
      final items = list.getElementsByTagName('li');
      if (items.isEmpty) continue;
      if (items[0].innerHtml.contains('PV')) continue;
      for (final item in items) {
        final anchors = item.getElementsByTagName('a');
        if (anchors.isEmpty) continue;
        final href = anchors[0].attributes['href'] ?? '';
        if (href.isEmpty) continue;
        urls.add(_absoluteUrl(base, href));
      }
    }
    return urls;
  }

  @override
  String? parseVideoUrl(
    String html, {
    required int episodeNumber,
    String? baseUrl,
  }) => AnimeTraceStreamExtractor.extract(html);

  static String _absoluteUrl(String base, String href) {
    if (href.isEmpty) return '';
    if (href.startsWith('http')) return href;
    return '$base$href';
  }
}
