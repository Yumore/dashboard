import 'package:dashboard/features/anime/animetrace/animetrace_anime.dart';
import 'package:dashboard/features/anime/animetrace/scrapers/animetrace_scrape_util.dart';
import 'package:dashboard/features/anime/animetrace/scrapers/animetrace_scraper.dart';
import 'package:dashboard/features/anime/animetrace/scrapers/animetrace_stream_extractor.dart';
import 'package:html/dom.dart';

/// OmoFun (omofun.tv) parser, ported from the source app's `ClimbOmofun`.
///
/// The search page lays the same results out in four parallel node lists:
/// covers, info lines, play status and category. Index `i` of every list
/// belongs to the same anime.
class AnimeTraceOmofunScraper extends AnimeTraceScraper {
  const AnimeTraceOmofunScraper();

  /// The source app splits the info line on this markup instead of on a
  /// character.
  static const String infoSeparator = '<span class="slash">/</span>';

  @override
  String get climbId => 'omofun';

  @override
  String get sourceName => 'OmoFun';

  @override
  String get defaultBaseUrl => 'https://omofun.tv';

  @override
  String searchUrl(String baseUrl, String keyword) =>
      '$baseUrl/vod/search.html?wd=$keyword';

  @override
  List<AnimeTraceAnime> parseSearchResults(String html, {String? baseUrl}) {
    final base = baseUrl ?? defaultBaseUrl;
    final document = parseAnimeTraceHtml(html);
    final animes = <AnimeTraceAnime>[];

    for (final element in document.getElementsByClassName('lazy lazyload')) {
      final cover = element.attributes['data-original'];
      if (cover == null) continue;
      animes.add(
        AnimeTraceAnime(
          animeName: element.attributes['alt'] ?? '',
          animeCoverUrl: normalizeAnimeTraceImageUrl(cover),
        ),
      );
    }
    if (animes.isEmpty) return animes;

    final infoItems = document.getElementsByClassName('module-card-item-info');
    for (var i = 0; i < infoItems.length && i < animes.length; i++) {
      final href = childAttribute(infoItems[i], 'a', 'href') ?? '';
      animes[i] = animes[i].copyWith(animeUrl: _absoluteUrl(base, href));

      final contents = infoItems[i].getElementsByClassName(
        'module-info-item-content',
      );
      if (contents.isEmpty) continue;
      final parts = contents[0].innerHtml.split(infoSeparator);
      animes[i] = animes[i].copyWith(
        premiereTime: parts.isNotEmpty ? parts[0].trim() : '',
        area: parts.length > 1 ? parts[1].trim() : '',
      );
    }

    final notes = document.getElementsByClassName('module-item-note');
    for (var i = 0; i < notes.length && i < animes.length; i++) {
      animes[i] = animes[i].copyWith(playStatus: notes[i].innerHtml.trim());
    }

    final classes = document.getElementsByClassName('module-card-item-class');
    for (var i = 0; i < classes.length && i < animes.length; i++) {
      animes[i] = animes[i].copyWith(category: classes[i].innerHtml.trim());
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
    final smalls = document.getElementsByTagName('small');
    if (smalls.length >= 2) {
      final count = int.tryParse(smalls[1].innerHtml.trim());
      if (count != null) result = result.copyWith(animeEpisodeCnt: count);
    }

    final contents = document.getElementsByClassName(
      'module-info-item-content',
    );
    if (contents.isNotEmpty) {
      result = result.copyWith(playStatus: contents.last.innerHtml.trim());
    }

    final tagLinks = document.getElementsByClassName('module-info-tag-link');
    final premiereTime = _anchorText(tagLinks, 0);
    if (premiereTime.isNotEmpty) {
      result = result.copyWith(premiereTime: premiereTime);
    }
    final area = _anchorText(tagLinks, 1);
    if (area.isNotEmpty) result = result.copyWith(area: area);

    final cover = childAttribute(
      firstByClass(document, 'module module-info'),
      'img',
      'data-original',
    );
    if (cover != null && cover.trim().isNotEmpty) {
      result = result.copyWith(
        animeCoverUrl: normalizeAnimeTraceImageUrl(cover),
      );
    }

    final desc = firstByClass(document, 'show-desc');
    final descParagraph = childInnerHtml(desc, 'p');
    if (descParagraph.isNotEmpty) {
      result = result.copyWith(animeDesc: descParagraph);
    }

    return result;
  }

  @override
  String? parseVideoUrl(
    String html, {
    required int episodeNumber,
    String? baseUrl,
  }) => AnimeTraceStreamExtractor.extract(html);

  static String _anchorText(List<Element> containers, int index) {
    if (index < 0 || index >= containers.length) return '';
    return childInnerHtml(containers[index], 'a').trim();
  }

  static String _absoluteUrl(String base, String href) {
    if (href.isEmpty) return '';
    if (href.startsWith('http')) return href;
    return '$base$href';
  }
}
