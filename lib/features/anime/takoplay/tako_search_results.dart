import 'package:dashboard/features/anime/takoplay/tako_anime.dart';
import 'package:dashboard/features/anime/takoplay/tako_anime_parser.dart';

/// Result of a Tako-Play (gogoanime.wiki) keyword search.
class TakoSearchResults {
  const TakoSearchResults({required this.query, required this.results});

  /// Parses the `search.html?keyword=` response body.
  factory TakoSearchResults.fromHtml(
    String query,
    String html, {
    required Uri base,
  }) => TakoSearchResults(
    query: query,
    results: TakoAnimeParser.cards(html, base: base),
  );

  final String query;
  final List<TakoAnime> results;

  bool get isEmpty => results.isEmpty;
}
