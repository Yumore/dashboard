import 'package:dashboard/features/anime/tsdm/tsdm_search_repository.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_search_result.dart';
import 'package:flutter/foundation.dart';

/// Loading status of the search page.
///
/// Ported from `SearchStatus` of `tsdm_client/lib/features/search/bloc/search_state.dart`.
enum TsdmSearchStatus {
  /// Nothing requested yet.
  initial,

  /// A request is in flight.
  loading,

  /// The last request succeeded.
  success,

  /// The last request failed.
  failed,
}

/// Controller of the search page.
///
/// Replaces the bloc of `tsdm_client/lib/features/search/bloc/search_bloc.dart`
/// with a [ChangeNotifier].
class TsdmSearchController extends ChangeNotifier {
  /// Create a search controller.
  TsdmSearchController({required this.repository});

  /// Repository used to search.
  final TsdmSearchRepository repository;

  /// Current status.
  TsdmSearchStatus status = TsdmSearchStatus.initial;

  /// Keyword of the last request.
  String? keyword;

  /// Forum id filter, `0` means all forums.
  String fid = '0';

  /// Author uid filter, `0` means all authors.
  String uid = '0';

  /// Page number of the last request.
  int pageNumber = 1;

  /// Whether a previous page exists.
  bool hasPreviousPage = false;

  /// Whether a next page exists.
  bool hasNextPage = false;

  /// Result of the last successful request.
  TsdmSearchResult? searchResult;

  /// Error of the last failed request.
  Object? error;

  /// Search [searchKeyword] in forum [searchFid] published by user [searchUid].
  Future<void> search({
    required String searchKeyword,
    required String searchFid,
    required String searchUid,
  }) async {
    keyword = searchKeyword;
    fid = searchFid;
    uid = searchUid;
    pageNumber = 1;
    await _request();
  }

  /// Jump to page [page], only valid after a successful search.
  Future<void> jumpPage(int page) async {
    if (keyword == null) {
      status = TsdmSearchStatus.failed;
      notifyListeners();
      return;
    }
    pageNumber = page;
    await _request();
  }

  /// Jump to the next page.
  Future<void> gotoNextPage() {
    if (!hasNextPage) {
      return Future.value();
    }
    return jumpPage(pageNumber + 1);
  }

  /// Jump to the previous page.
  Future<void> gotoPreviousPage() {
    if (pageNumber <= 1) {
      status = TsdmSearchStatus.failed;
      notifyListeners();
      return Future.value();
    }
    return jumpPage(pageNumber - 1);
  }

  Future<void> _request() async {
    final searchKeyword = keyword;
    if (searchKeyword == null) {
      status = TsdmSearchStatus.failed;
      notifyListeners();
      return;
    }
    status = TsdmSearchStatus.loading;
    notifyListeners();
    try {
      final document = await repository.searchWithParameters(
        keyword: searchKeyword,
        fid: fid,
        uid: uid,
        pageNumber: pageNumber,
      );
      final result = TsdmSearchRepository.parseSearchResultDocument(document);
      searchResult = result;
      hasPreviousPage = result.hasPreviousPage;
      hasNextPage = result.hasNextPage;
      status = TsdmSearchStatus.success;
    } on Object catch (e) {
      error = e;
      status = TsdmSearchStatus.failed;
    }
    notifyListeners();
  }
}
