import 'package:dashboard/features/anime/animetrace/animetrace_anime.dart';
import 'package:dashboard/features/anime/animetrace/scrapers/animetrace_scrape_util.dart';
import 'package:dashboard/features/anime/animetrace/scrapers/animetrace_scraper.dart';
import 'package:dashboard/features/anime/animetrace/scrapers/animetrace_stream_extractor.dart';

/// 樱花动漫 (iyhdmm.com) parser, ported from the source app's `ClimbYhdm`.
///
/// The upstream implementation is shared by yhdm and by every yhdm-clone, so
/// its list and detail parsers are the reference for the AGE parser too.
class AnimeTraceYhdmScraper extends AnimeTraceScraper {
  const AnimeTraceYhdmScraper();

  @override
  String get climbId => 'yhdm';

  @override
  String get sourceName => '樱花动漫';

  @override
  String get defaultBaseUrl => 'https://www.iyhdmm.com';

  @override
  String searchUrl(String baseUrl, String keyword) =>
      '$baseUrl/s_all?ex=1&kw=$keyword';

  @override
  List<AnimeTraceAnime> parseSearchResults(String html, {String? baseUrl}) {
    final base = baseUrl ?? defaultBaseUrl;
    final document = parseAnimeTraceHtml(html);
    final containers = document.getElementsByClassName('lpic');
    if (containers.isEmpty) return <AnimeTraceAnime>[];

    final animes = <AnimeTraceAnime>[];
    for (final li in containers[0].getElementsByTagName('li')) {
      final images = li.getElementsByTagName('img');
      final anchors = li.getElementsByTagName('a');
      if (images.isEmpty || anchors.isEmpty) continue;
      final cover = normalizeAnimeTraceImageUrl(images[0].attributes['src']);
      final name = images[0].attributes['alt'] ?? '';
      final href = anchors[0].attributes['href'] ?? '';
      final episodeCountText = childInnerHtml(li, 'font');
      animes.add(
        AnimeTraceAnime(
          animeName: name,
          animeCoverUrl: cover,
          animeUrl: _absoluteUrl(base, href),
          animeEpisodeCnt: parseEpisodeCountOfYhdm(episodeCountText),
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
    final info = firstByClass(document, 'sinfo');
    var result = anime;

    if (info != null) {
      final paragraph = childInnerHtml(info, 'p');
      final marker = paragraph.lastIndexOf('>');
      final nameAnother = marker >= 0
          ? paragraph.substring(marker + 1).trim()
          : paragraph.trim();
      if (nameAnother.isNotEmpty) {
        result = result.copyWith(nameAnother: nameAnother);
      }

      final spans = info.getElementsByTagName('span');
      String spanAt(int index) =>
          index < spans.length ? spans[index].innerHtml : '';
      String anchorAt(int spanIndex, int anchorIndex) {
        if (spanIndex >= spans.length) return '';
        return childInnerHtml(spans[spanIndex], 'a', index: anchorIndex);
      }

      final premiereTime = _premiereTime(spanAt(0));
      result = result.copyWith(
        premiereTime: premiereTime,
        area: _clean(anchorAt(1, 0)),
        category: _clean(anchorAt(4, 0)),
        playStatus: _clean(anchorAt(4, 2)),
      );
    }

    final cover = childAttribute(firstByClass(document, 'thumb'), 'img', 'src');
    if (cover != null && cover.trim().isNotEmpty) {
      result = result.copyWith(
        animeCoverUrl: normalizeAnimeTraceImageUrl(cover),
      );
    }

    final desc = firstByClass(document, 'info');
    if (desc != null) {
      result = result.copyWith(animeDesc: innerHtmlWithLineBreaks(desc));
    }

    final paragraphs = document.getElementsByTagName('p');
    for (final paragraph in paragraphs) {
      final text = paragraph.innerHtml;
      if (!text.contains('更新至') && !text.contains('全集')) continue;
      final count = parseEpisodeCountOfYhdm(text);
      if (count > 0) {
        result = result.copyWith(animeEpisodeCnt: count);
        break;
      }
    }
    return result;
  }

  @override
  String? parseVideoUrl(
    String html, {
    required int episodeNumber,
    String? baseUrl,
  }) => AnimeTraceStreamExtractor.extract(html);

  static String _premiereTime(String spanHtml) {
    const marker = 'target="_blank">';
    final index = spanHtml.lastIndexOf(marker);
    final value = index >= 0
        ? spanHtml.substring(index + marker.length)
        : spanHtml;
    return _clean(value);
  }

  static String _clean(String value) =>
      value.replaceAll('</a>', '').replaceAll(RegExp('<[^>]*>'), '').trim();

  static String _absoluteUrl(String base, String href) {
    if (href.isEmpty) return '';
    if (href.startsWith('http')) return href;
    return '$base$href';
  }
}
