import 'package:dashboard/features/movie/youtubedl/youtubedl_search_result.dart';

/// One page of YouTube search results plus the continuation token.
class YoutubeDlSearchPage {
  const YoutubeDlSearchPage({required this.items, this.continuation = ''});

  final List<YoutubeDlSearchResult> items;

  /// Empty when there are no more pages.
  final String continuation;

  bool get hasMore => continuation.isNotEmpty;
}
