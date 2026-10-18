import 'package:dashboard/features/anime/animetrace/animetrace_anime.dart';
import 'package:dashboard/features/anime/animetrace/animetrace_health_probe.dart';
import 'package:dashboard/features/anime/animetrace/animetrace_ping_status.dart';
import 'package:dashboard/features/anime/animetrace/animetrace_source.dart';
import 'package:dashboard/features/anime/animetrace/scrapers/animetrace_scrape_util.dart';
import 'package:dashboard/features/anime/animetrace/scrapers/animetrace_scraper.dart';
import 'package:dashboard/features/anime/animetrace/scrapers/animetrace_source_catalog.dart';
import 'package:dashboard/features/anime/animetrace/store/animetrace_source_store.dart';
import 'package:dio/dio.dart';

/// What one cross-source search produced.
class AnimeTraceSearchResult {
  const AnimeTraceSearchResult({required this.animes, required this.errors});

  /// Merged hits of every enabled source, in source order.
  final List<AnimeTraceAnime> animes;

  /// Source display name -> failure message, for the sources that failed.
  /// A partial failure never hides the hits of the working sources.
  final Map<String, String> errors;

  bool get hasErrors => errors.isNotEmpty;
}

/// Fetches pages and drives the pure scrapers.
///
/// Every parser lives in `scrapers/` and takes an HTML `String`, so this class
/// is the only place that performs I/O. It is injectable (`Dio`, health probe,
/// source store) and never called from `build`.
class AnimeTraceRepository {
  AnimeTraceRepository({
    Dio? dio,
    AnimeTraceHealthProbe? probe,
    AnimeTraceSourceStore? sourceStore,
    this.timeout = const Duration(seconds: 15),
  }) : dio = dio ?? _defaultDio(),
       probe = probe ?? AnimeTraceHealthProbe(dio: dio),
       sourceStore = sourceStore ?? AnimeTraceSourceStore();

  final Dio dio;
  final AnimeTraceHealthProbe probe;
  final AnimeTraceSourceStore sourceStore;
  final Duration timeout;

  static Dio _defaultDio() {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        headers: const <String, String>{
          'User-Agent':
              'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) '
              'AppleWebKit/537.36 (KHTML, like Gecko) '
              'Chrome/124.0 Safari/537.36',
        },
      ),
    );
    return dio;
  }

  Future<List<AnimeTraceSource>> loadSources() => sourceStore.loadSources();

  /// Effective base URL of [source]: its custom URL when set, otherwise the
  /// catalog URL, otherwise the scraper default.
  String baseUrlOf(AnimeTraceSource source) {
    if (source.baseUrl.isNotEmpty) return source.baseUrl;
    final scraper = AnimeTraceSourceCatalog.scraperOf(source.climbId);
    return scraper?.defaultBaseUrl ?? '';
  }

  /// GETs [url] as text and throws a Chinese message on a non-200 response
  /// (host style).
  Future<String> fetchHtml(String url) async {
    final response = await dio.get<String>(
      url,
      options: Options(
        responseType: ResponseType.plain,
        followRedirects: true,
        receiveTimeout: timeout,
        sendTimeout: timeout,
        validateStatus: (status) => status != null && status < 500,
      ),
    );
    final status = response.statusCode ?? 0;
    if (status != 200) {
      throw Exception('请求失败：HTTP $status');
    }
    return response.data ?? '';
  }

  /// Searches every enabled, importable source concurrently.
  Future<AnimeTraceSearchResult> search(
    String keyword, {
    List<AnimeTraceSource>? sources,
  }) async {
    final trimmed = keyword.trim();
    if (trimmed.isEmpty) {
      return const AnimeTraceSearchResult(
        animes: <AnimeTraceAnime>[],
        errors: <String, String>{},
      );
    }
    final targets = (sources ?? await loadSources())
        .where((source) => source.enable && !source.discard)
        .toList();

    final futures = <Future<_SourceSearchOutcome>>[];
    final names = <String>[];
    for (final source in targets) {
      final scraper = AnimeTraceSourceCatalog.scraperOf(source.climbId);
      if (scraper == null) continue;
      names.add(source.name);
      futures.add(_searchOne(scraper, source, trimmed));
    }

    final results = await Future.wait(futures);
    final animes = <AnimeTraceAnime>[];
    final errors = <String, String>{};
    for (var index = 0; index < results.length; index++) {
      final result = results[index];
      if (result.error != null) {
        errors[names[index]] = result.error!;
      } else {
        animes.addAll(result.animes);
      }
    }
    return AnimeTraceSearchResult(animes: animes, errors: errors);
  }

  Future<_SourceSearchOutcome> _searchOne(
    AnimeTraceScraper scraper,
    AnimeTraceSource source,
    String keyword,
  ) async {
    final base = baseUrlOf(source);
    try {
      final html = await fetchHtml(scraper.searchUrl(base, keyword));
      return _SourceSearchOutcome(
        animes: scraper.parseSearchResults(html, baseUrl: base),
      );
    } catch (error) {
      return _SourceSearchOutcome(error: '$error');
    }
  }

  /// Re-scrapes the detail page of [anime] and enriches it.
  ///
  /// Mirrors the source app, which also converted the scraped episode count
  /// through the series' `episodeStartNumber`.
  Future<AnimeTraceAnime> climbAnimeInfo(AnimeTraceAnime anime) async {
    final scraper = AnimeTraceSourceCatalog.scraperOfAnimeUrl(anime.animeUrl);
    if (scraper == null) {
      throw Exception('没有匹配的站点解析器：${anime.animeUrl}');
    }
    final source = AnimeTraceSourceCatalog.sourceOfAnimeUrl(anime.animeUrl);
    final base = source == null ? '' : baseUrlOf(source);
    final html = await fetchHtml(anime.animeUrl);
    final enriched = scraper.applyAnimeInfo(
      html,
      anime,
      baseUrl: base.isEmpty ? null : base,
    );
    if (enriched.animeEpisodeCnt > 0) {
      return enriched.copyWith(
        animeEpisodeCnt: adjustEpisodeCountByStartNumber(
          enriched.animeEpisodeCnt,
          enriched.episodeStartNumber,
        ),
      );
    }
    return enriched;
  }

  /// Resolves a playable stream URL for one episode, or `null` when the site
  /// does not expose one (the UI then offers to open the page in a browser).
  Future<String?> resolveVideoUrl(
    AnimeTraceAnime anime, {
    required int episodeNumber,
  }) async {
    final scraper = AnimeTraceSourceCatalog.scraperOfAnimeUrl(anime.animeUrl);
    if (scraper == null || episodeNumber <= 0) return null;
    final source = AnimeTraceSourceCatalog.sourceOfAnimeUrl(anime.animeUrl);
    final base = source == null ? null : baseUrlOf(source);

    final detailHtml = await fetchHtml(anime.animeUrl);
    final episodeUrls = scraper.parseEpisodeUrls(detailHtml, baseUrl: base);
    if (episodeUrls.isEmpty) return null;
    final index = episodeNumber - 1;
    if (index < 0 || index >= episodeUrls.length) return null;

    final episodeHtml = await fetchHtml(episodeUrls[index]);
    return scraper.parseVideoUrl(
      episodeHtml,
      episodeNumber: episodeNumber,
      baseUrl: base,
    );
  }

  /// Probes one source's reachability and latency.
  Future<AnimeTracePingStatus> ping(AnimeTraceSource source) {
    final base = baseUrlOf(source);
    if (base.isEmpty) {
      return Future<AnimeTracePingStatus>.value(
        const AnimeTracePingStatus(needPing: false),
      );
    }
    return probe.check(base);
  }

  /// Probes every source concurrently and returns them with fresh status.
  Future<List<AnimeTraceSource>> refreshHealth(
    List<AnimeTraceSource> sources,
  ) async {
    final statuses = await Future.wait(
      sources.map(
        (source) => source.discard
            ? Future<AnimeTracePingStatus>.value(
                const AnimeTracePingStatus(needPing: false),
              )
            : ping(source),
      ),
    );
    return <AnimeTraceSource>[
      for (var index = 0; index < sources.length; index++)
        sources[index].copyWith(pingStatus: statuses[index]),
    ];
  }
}

class _SourceSearchOutcome {
  const _SourceSearchOutcome({
    this.animes = const <AnimeTraceAnime>[],
    this.error,
  });

  final List<AnimeTraceAnime> animes;
  final String? error;
}
