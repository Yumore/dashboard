import 'package:dashboard/features/anime/animetrace/animetrace_source.dart';
import 'package:dashboard/features/anime/animetrace/scrapers/animetrace_agemys_scraper.dart';
import 'package:dashboard/features/anime/animetrace/scrapers/animetrace_bangumi_scraper.dart';
import 'package:dashboard/features/anime/animetrace/scrapers/animetrace_omofun_scraper.dart';
import 'package:dashboard/features/anime/animetrace/scrapers/animetrace_scraper.dart';
import 'package:dashboard/features/anime/animetrace/scrapers/animetrace_yhdm_scraper.dart';

/// The four public sites this port implements, plus the URL-matching registry
/// that maps a scraped anime URL back to its source.
///
/// Only sites verified reachable from the host are registered: bangumi.tv,
/// agedm.org / agemys.*, iyhdmm.com / yhdmp.* and omofun.tv. The remaining
/// scrapers of the source app (douban, cycdm, qdm, quqi, aimii) were not
/// ported.
class AnimeTraceSourceCatalog {
  const AnimeTraceSourceCatalog._();

  /// Regexp each source matches against a scraped anime URL, mirroring the
  /// source app's `ClimbWebsite.regexp` field.
  static const List<AnimeTraceSource> defaults = <AnimeTraceSource>[
    AnimeTraceSource(
      name: 'AGE动漫',
      climbId: 'age',
      regexp: r'agedm\.org|agedm\.cc|agemys\.com|agemys\.cc',
      spkey: 'animetrace.source.age.enable',
      enable: true,
      baseUrl: 'https://www.agedm.org',
      supportImport: true,
      supportPlayVideo: true,
    ),
    AnimeTraceSource(
      name: '樱花动漫',
      climbId: 'yhdm',
      regexp: r'iyhdmm\.com|yhdmp\.(com|cc|net)',
      spkey: 'animetrace.source.yhdm.enable',
      enable: true,
      baseUrl: 'https://www.iyhdmm.com',
      supportImport: true,
      supportPlayVideo: true,
    ),
    AnimeTraceSource(
      name: 'OmoFun',
      climbId: 'omofun',
      regexp: r'omofun\.tv',
      spkey: 'animetrace.source.omofun.enable',
      enable: true,
      baseUrl: 'https://omofun.tv',
      supportImport: true,
      supportPlayVideo: true,
    ),
    AnimeTraceSource(
      name: 'Bangumi',
      climbId: 'bangumi',
      regexp: r'bangumi\.tv|bgm\.tv',
      spkey: 'animetrace.source.bangumi.enable',
      enable: true,
      baseUrl: 'https://bangumi.tv',
      comment: '仅用于搜索与导入公开收藏，无播放地址',
      supportImport: true,
      supportPlayVideo: false,
    ),
  ];

  static final Map<String, AnimeTraceScraper> _scrapers =
      <String, AnimeTraceScraper>{
        for (final scraper in <AnimeTraceScraper>[
          const AnimeTraceAgemysScraper(),
          const AnimeTraceYhdmScraper(),
          const AnimeTraceOmofunScraper(),
          const AnimeTraceBangumiScraper(),
        ])
          scraper.climbId: scraper,
      };

  static List<AnimeTraceScraper> get scrapers =>
      List<AnimeTraceScraper>.unmodifiable(_scrapers.values);

  /// The scraper for [climbId], or `null` for an unknown id.
  static AnimeTraceScraper? scraperOf(String climbId) => _scrapers[climbId];

  /// The source whose [AnimeTraceSource.regexp] matches [animeUrl].
  static AnimeTraceSource? sourceOfAnimeUrl(
    String animeUrl, {
    List<AnimeTraceSource> sources = defaults,
  }) {
    if (animeUrl.isEmpty) return null;
    for (final source in sources) {
      if (source.regexp.isEmpty) continue;
      if (source.matchesUrl(animeUrl)) return source;
    }
    return null;
  }

  /// The scraper that should handle [animeUrl], or `null`.
  static AnimeTraceScraper? scraperOfAnimeUrl(
    String animeUrl, {
    List<AnimeTraceSource> sources = defaults,
  }) {
    final source = sourceOfAnimeUrl(animeUrl, sources: sources);
    if (source == null) return null;
    return scraperOf(source.climbId);
  }
}
