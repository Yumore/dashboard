import 'package:dashboard/features/anime/tsdm/tsdm_searched_thread.dart';

/// Paginated result of a forum search.
///
/// Ported from `tsdm_client/lib/features/search/models/search_result.dart`.
class TsdmSearchResult {
  /// Create a search result.
  const TsdmSearchResult({
    required this.currentPage,
    required this.totalPages,
    required this.count,
    required this.data,
  });

  /// Current page number.
  final int currentPage;

  /// Total page count.
  final int totalPages;

  /// Result count, null when the page did not show one.
  final int? count;

  /// Searched threads, null when the page had none.
  final List<TsdmSearchedThread>? data;

  /// Whether a previous page exists.
  bool get hasPreviousPage => currentPage > 1;

  /// Whether a next page exists.
  bool get hasNextPage => currentPage < totalPages;
}
