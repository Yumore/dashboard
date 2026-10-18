/// Base class of the forum thread filters.
///
/// Ported from `tsdm_client/lib/features/forum/models/thread_filter.dart`.
sealed class TsdmThreadFilter {
  const TsdmThreadFilter(this.filterName);

  /// Query parameter name this filter writes to.
  final String filterName;
}

/// A thread type filter (`&typeid=`).
class TsdmFilterType extends TsdmThreadFilter {
  const TsdmFilterType({required this.name, this.typeID}) : super('typeid');

  /// Display name.
  final String name;

  /// Type id value, null when the type was not recognized.
  final String? typeID;
}

/// A special thread filter (`&specialtype=`).
class TsdmFilterSpecialType extends TsdmThreadFilter {
  const TsdmFilterSpecialType({required this.name, this.specialType})
    : super('specialtype');

  /// Display name.
  final String name;

  /// Special type value.
  final String? specialType;
}

/// A dateline filter (`&dateline=`).
class TsdmFilterDateline extends TsdmThreadFilter {
  const TsdmFilterDateline({required this.name, this.dateline})
    : super('dateline');

  /// Display name.
  final String name;

  /// Dateline value in days.
  final String? dateline;
}

/// An order filter (`&orderby=`).
class TsdmFilterOrder extends TsdmThreadFilter {
  const TsdmFilterOrder({required this.name, this.orderBy}) : super('orderby');

  /// Display name.
  final String name;

  /// Order by value.
  final String? orderBy;
}

/// The digest only filter (`&digest=1`).
class TsdmFilterDigest extends TsdmThreadFilter {
  const TsdmFilterDigest({required this.digest}) : super('digest');

  /// Whether only digest threads are shown.
  final bool digest;
}

/// The recommend only filter (`&recommend=1`).
class TsdmFilterRecommend extends TsdmThreadFilter {
  const TsdmFilterRecommend({required this.recommend}) : super('recommends');

  /// Whether only recommended threads are shown.
  final bool recommend;
}
