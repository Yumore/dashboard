import 'package:dashboard/features/movie/youtubedl/youtubedl_player_result.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_search_page.dart';

/// Abstraction over YouTube's data endpoints.
///
/// `youtube_explode_dart` is intentionally not a host dependency, so this
/// provider is the single seam where stream URLs are extracted. The production
/// implementation uses the host's `dio`; tests inject fakes.
abstract class YouTubeStreamProvider {
  /// Loads metadata and directly playable streams for [videoId].
  Future<YoutubeDlPlayerResult> loadPlayer(String videoId);

  /// Searches YouTube videos. Pass [continuation] to fetch the next page.
  Future<YoutubeDlSearchPage> searchVideos(
    String query, {
    String? continuation,
  });

  /// Search-box suggestions for [query].
  Future<List<String>> suggestions(String query);
}
