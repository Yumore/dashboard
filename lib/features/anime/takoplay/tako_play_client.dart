import 'package:dashboard/features/anime/takoplay/tako_anime.dart';
import 'package:dashboard/features/anime/takoplay/tako_anime_details.dart';
import 'package:dashboard/features/anime/takoplay/tako_anime_parser.dart';
import 'package:dashboard/features/anime/takoplay/tako_embed_parser.dart';
import 'package:dashboard/features/anime/takoplay/tako_episode.dart';
import 'package:dashboard/features/anime/takoplay/tako_episode_parser.dart';
import 'package:dashboard/features/anime/takoplay/tako_mirror_parser.dart';
import 'package:dashboard/features/anime/takoplay/tako_play_endpoints.dart';
import 'package:dashboard/features/anime/takoplay/tako_search_results.dart';
import 'package:http/http.dart' as http;

/// Read-only client for gogoanime.wiki, ported from the source's
/// `AnimeService` + chopper `RequestService`.
///
/// Every request goes through the injected [http.Client], so the whole client
/// (search, catalogue, detail, episode list, embed and mirror lookups) runs
/// against fixtures in tests without touching the network.
class TakoPlayClient {
  TakoPlayClient({http.Client? client, Uri? base})
    : _client = client ?? http.Client(),
      _base = base ?? TakoPlayEndpoints.base;

  final http.Client _client;
  final Uri _base;

  /// The underlying transport, so a resolver can run its extractor over the
  /// same (possibly injected) client.
  http.Client get httpClient => _client;

  /// `search.html?keyword=` results (source `search_screen` + `getAnimes`).
  Future<TakoSearchResults> search(String query) async {
    final body = await _get(TakoPlayEndpoints.search(query));
    return TakoSearchResults.fromHtml(query, body, base: _base);
  }

  /// `popular.html`, `anime-movies.html` or a genre path.
  Future<List<TakoAnime>> catalogue(String path) async {
    return TakoAnimeParser.cards(await _get(_base.resolve(path)), base: _base);
  }

  /// Recently updated episodes from `page-recent-release.html`.
  Future<List<TakoAnime>> recent() async {
    return TakoAnimeParser.recentlyAdded(
      await _get(TakoPlayEndpoints.recentEndpoint),
      base: _base,
    );
  }

  /// Detail page + its episode list (source `fetchAnimeDetails`).
  Future<TakoAnimeDetails> details(Uri url) async {
    final detailSource = await _get(url);
    final episodeId = TakoAnimeParser.episodeId(detailSource);
    final episodeSource = episodeId.isEmpty
        ? ''
        : await _get(TakoPlayEndpoints.episodes(episodeId));
    return TakoAnimeParser.details(
      detailSource,
      episodeSource,
      url: url,
      base: _base,
    );
  }

  /// Raw episode list of an `anime_id`.
  Future<List<TakoEpisode>> episodes(String episodeId) async {
    return TakoEpisodeParser.parse(
      await _get(TakoPlayEndpoints.episodes(episodeId)),
      base: _base,
    );
  }

  /// gogoplay embed player URL of an episode page (source `fetchIframeEmbedded`).
  Future<Uri?> embedUrl(Uri episodeUrl) async {
    return TakoEmbedParser.iframe(await _get(episodeUrl), base: _base);
  }

  /// `.dowload` mirror table of an embed URL (source `fetchCdnStreamLink`).
  Future<Map<String, Uri>> mirrors(Uri embedUrl) async {
    return TakoMirrorParser.parse(
      await _get(TakoPlayEndpoints.mirrors(embedUrl)),
      base: _base,
    );
  }

  Future<String> _get(Uri uri) async {
    final response = await _client
        .get(uri, headers: TakoPlayEndpoints.browserHeaders)
        .timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) {
      throw http.ClientException('HTTP ${response.statusCode}', uri);
    }
    return response.body;
  }

  void dispose() => _client.close();
}
