import 'package:dashboard/features/anime/tsdm/tsdm_filter_state.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_forum.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_forum_page_parser.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_forum_repository.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_normal_thread.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_stick_thread.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_thread_filter.dart';
import 'package:flutter/foundation.dart';
import 'package:html/dom.dart' as dom;

/// Loading status of a forum page.
///
/// Ported from `ForumStatus` of `tsdm_client/lib/features/forum/bloc/forum_state.dart`.
enum TsdmForumStatus {
  /// Nothing requested yet.
  initial,

  /// A request is in flight.
  loading,

  /// The last request succeeded.
  success,

  /// The last request failed.
  failure,
}

/// Controller of a forum display page.
///
/// Replaces the bloc of `tsdm_client/lib/features/forum/bloc/forum_bloc.dart`
/// with a [ChangeNotifier] so the host does not need `flutter_bloc`. The parse
/// rules live in [TsdmForumPageParser] and are unchanged.
class TsdmForumController extends ChangeNotifier {
  /// Create a controller of forum [fid].
  TsdmForumController({required this.repository, required this.fid});

  /// Repository used to fetch the forum.
  final TsdmForumRepository repository;

  /// Forum id of this controller.
  final String fid;

  /// Current status.
  TsdmForumStatus status = TsdmForumStatus.initial;

  /// Forum title, null when not loaded yet.
  String? title;

  /// Forum rules node.
  dom.Element? rulesElement;

  /// Pinned threads, always replaced by the newest page.
  List<TsdmStickThread> stickThreadList = const [];

  /// Normal threads of all loaded pages.
  List<TsdmNormalThread> normalThreadList = const [];

  /// Sub forums of the forum.
  List<TsdmForum> subredditList = const [];

  /// Whether another page can be loaded.
  bool canLoadMore = true;

  /// Current page number.
  int currentPage = 1;

  /// Total page count.
  int totalPages = 1;

  /// Whether the current user may read this forum.
  bool havePermission = true;

  /// Message shown when the user may not read this forum.
  dom.Element? permissionDeniedMessage;

  /// Whether the user has to log in first.
  bool needLogin = false;

  /// Error of the last failed request.
  Object? error;

  /// Selected filters.
  TsdmFilterState filterState = const TsdmFilterState();

  /// Available thread type filters.
  List<TsdmFilterType> filterTypeList = const [];

  /// Available special thread filters.
  List<TsdmFilterSpecialType> filterSpecialTypeList = const [];

  /// Available order filters.
  List<TsdmFilterOrder> filterOrderList = const [];

  /// Available dateline filters.
  List<TsdmFilterDateline> filterDatelineList = const [];

  /// Whether any filter is active or available.
  bool get hasFilter {
    return filterState.isFiltering() ||
        filterTypeList.isNotEmpty ||
        filterSpecialTypeList.isNotEmpty ||
        filterOrderList.isNotEmpty ||
        filterDatelineList.isNotEmpty;
  }

  /// Whether a request is currently in flight.
  bool isLoading() => status == TsdmForumStatus.loading;

  /// Refresh page [pageNumber] of this forum.
  Future<void> loadPage(int pageNumber) async {
    status = TsdmForumStatus.loading;
    notifyListeners();
    try {
      final document = await repository.fetchForum(
        fid: fid,
        filterState: filterState,
        pageNumber: pageNumber,
      );
      _parse(document, pageNumber);
      status = TsdmForumStatus.success;
    } on Object catch (e) {
      error = e;
      status = TsdmForumStatus.failure;
    }
    notifyListeners();
  }

  /// Refresh the first page.
  Future<void> refresh() => loadPage(1);

  /// Append page [pageNumber] to the loaded threads.
  Future<void> loadMore(int pageNumber) async {
    if (!canLoadMore) {
      return;
    }
    await loadPage(pageNumber);
  }

  /// Jump to page [pageNumber], replacing the loaded threads.
  Future<void> jumpToPage(int pageNumber) async {
    normalThreadList = const [];
    await loadPage(pageNumber);
  }

  /// Apply [state] and reload the first page.
  Future<void> changeFilterState(TsdmFilterState state) async {
    filterState = state;
    normalThreadList = const [];
    await loadPage(1);
  }

  void _parse(dom.Document document, int pageNumber) {
    final data = TsdmForumPageParser.parse(document, fid, pageNumber);

    if (data.title != null) {
      title = data.title;
    }
    if (data.rulesElement != null) {
      rulesElement = data.rulesElement;
    }
    // Pinned threads are always re-parsed: a thread page opened directly has no
    // cached pinned content, so the source refreshes them on every page.
    if (data.stickThreadList.isNotEmpty) {
      stickThreadList = data.stickThreadList;
    }
    if (data.subredditList.isNotEmpty) {
      subredditList = data.subredditList;
    }

    normalThreadList = [...normalThreadList, ...data.normalThreadList];
    canLoadMore = data.canLoadMore;
    currentPage = data.currentPage;
    totalPages = data.totalPages;
    havePermission = data.havePermission;
    permissionDeniedMessage = data.permissionDeniedMessage;
    needLogin = data.needLogin;

    if (data.filterTypeList.isNotEmpty) {
      filterTypeList = data.filterTypeList;
    }
    if (data.filterSpecialTypeList.isNotEmpty) {
      filterSpecialTypeList = data.filterSpecialTypeList;
    }
    if (data.filterOrderList.isNotEmpty) {
      filterOrderList = data.filterOrderList;
    }
    if (data.filterDatelineList.isNotEmpty) {
      filterDatelineList = data.filterDatelineList;
    }
  }
}
