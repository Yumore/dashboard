import 'package:dashboard/features/anime/tsdm/tsdm_filter_state.dart';

/// Query parameters of a forum display request.
///
/// Ported from the private `_formatForumUrl` of
/// `tsdm_client/lib/features/forum/repository/forum_repository.dart`. The
/// insertion order is significant: the recommend filter writes both
/// `recommend` and `orderby` first, and every later filter may override
/// `orderby`.
class TsdmForumQuery {
  const TsdmForumQuery._(this.parameters);

  /// Built query parameters, in insertion order.
  final Map<String, String> parameters;

  /// Build the query of forum [fid] page [pageNumber] with [filterState].
  static TsdmForumQuery build({
    required String fid,
    required TsdmFilterState filterState,
    int pageNumber = 1,
  }) {
    final queryMap = <String, String>{
      'mod': 'forumdisplay',
      'fid': fid,
      'page': '$pageNumber',
    };

    // The recommend filter must be applied before the order filter: it is a
    // compound of `recommend=1` plus `orderby=recommends`, and a user selected
    // order must win over it.
    if (filterState.filterRecommend.recommend) {
      queryMap['recommend'] = '1';
      queryMap['orderby'] = 'recommends';
    }

    final typeID = filterState.filterType?.typeID;
    if (typeID != null) {
      queryMap['typeid'] = typeID;
    }

    final specialType = filterState.filterSpecialType?.specialType;
    if (specialType != null) {
      queryMap['specialtype'] = specialType;
    }

    final orderBy = filterState.filterOrder?.orderBy;
    if (orderBy != null) {
      queryMap['orderby'] = orderBy;
    }

    final dateline = filterState.filterDateline?.dateline;
    if (dateline != null) {
      queryMap['dateline'] = dateline;
    }

    if (filterState.filterDigest.digest) {
      queryMap['digest'] = '1';
    }

    final extraFilter = filterState.filter;
    if (extraFilter != null && queryMap.containsKey(extraFilter)) {
      queryMap['filter'] = extraFilter;
    }

    return TsdmForumQuery._(queryMap);
  }
}
