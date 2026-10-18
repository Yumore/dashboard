import 'package:dashboard/features/anime/tsdm/tsdm_user.dart';

/// A single rate record from one user.
///
/// Ported from `tsdm_client/lib/shared/models/rate.dart`.
class TsdmSingleRate {
  const TsdmSingleRate({required this.user, required this.attrValueList});

  /// User who rated.
  final TsdmUser user;

  /// Rated values, aligned with `TsdmRate.attrList`.
  final List<String> attrValueList;
}
