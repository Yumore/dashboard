import 'package:dashboard/features/anime/tsdm/tsdm_thread_filter.dart';

/// Selected filters of a forum page.
///
/// Ported from `tsdm_client/lib/features/forum/models/thread_filter.dart`.
class TsdmFilterState {
  const TsdmFilterState({
    this.filter,
    this.filterType,
    this.filterSpecialType,
    this.filterDateline,
    this.filterOrder,
    this.filterDigest = const TsdmFilterDigest(digest: false),
    this.filterRecommend = const TsdmFilterRecommend(recommend: false),
  });

  /// Extra filter key the forum page offers, applied only when the generated
  /// query already contains this key.
  final String? filter;

  /// Thread type filter.
  final TsdmFilterType? filterType;

  /// Special thread filter.
  final TsdmFilterSpecialType? filterSpecialType;

  /// Dateline filter.
  final TsdmFilterDateline? filterDateline;

  /// Order filter.
  final TsdmFilterOrder? filterOrder;

  /// Digest only filter.
  final TsdmFilterDigest filterDigest;

  /// Recommend only filter.
  final TsdmFilterRecommend filterRecommend;

  /// Whether any filter is currently active.
  bool isFiltering() {
    return filterType?.typeID != null ||
        filterSpecialType?.specialType != null ||
        filterDateline?.dateline != null ||
        filterOrder?.orderBy != null ||
        filterDigest.digest ||
        filterRecommend.recommend;
  }
}
