import 'package:dashboard/features/anime/tsdm/tsdm_latest_thread.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_latest_thread_repository.dart';
import 'package:flutter/foundation.dart';

/// Loading status of the latest thread page.
enum TsdmLatestThreadStatus {
  /// Nothing requested yet.
  initial,

  /// A request is in flight.
  loading,

  /// The last request succeeded.
  success,

  /// The last request failed.
  failed,
}

/// Controller of the latest thread page.
///
/// Replaces the bloc of `tsdm_client/lib/features/latest_thread/bloc/latest_thread_bloc.dart`
/// with a [ChangeNotifier].
class TsdmLatestThreadController extends ChangeNotifier {
  /// Create a controller.
  TsdmLatestThreadController({required this.repository});

  /// Repository used to fetch pages.
  final TsdmLatestThreadRepository repository;

  /// Current status.
  TsdmLatestThreadStatus status = TsdmLatestThreadStatus.initial;

  /// Loaded threads.
  List<TsdmLatestThread> threadList = const [];

  /// Page number of the last request.
  int pageNumber = 1;

  /// Url of the next page, null when the last page was reached.
  String? nextPageUrl;

  /// Error of the last failed request.
  Object? error;

  /// Load the first page at [url].
  Future<void> refresh(String url) {
    pageNumber = 1;
    threadList = const [];
    return _load(url);
  }

  /// Load a page at [url], appending to the loaded threads when [url] is a
  /// pagination url.
  Future<void> loadUrl(String url) => _load(url);

  /// Load the next page, doing nothing when there is none.
  Future<void> loadMore() async {
    final url = nextPageUrl;
    if (url == null) {
      return;
    }
    pageNumber += 1;
    await _load(url);
  }

  Future<void> _load(String url) async {
    status = TsdmLatestThreadStatus.loading;
    notifyListeners();
    try {
      final document = await repository.fetchDocument(url);
      final threads = TsdmLatestThreadRepository.parseThreadList(document);
      threadList = [...threadList, ...threads];
      nextPageUrl = TsdmLatestThreadRepository.parseNextPageUrl(document);
      status = TsdmLatestThreadStatus.success;
    } on Object catch (e) {
      error = e;
      status = TsdmLatestThreadStatus.failed;
    }
    notifyListeners();
  }
}
