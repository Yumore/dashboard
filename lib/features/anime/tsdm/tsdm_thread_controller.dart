import 'package:dashboard/features/anime/tsdm/tsdm_post.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_thread_breadcrumb.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_thread_page_parser.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_thread_repository.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_thread_type.dart';
import 'package:flutter/foundation.dart';
import 'package:html/dom.dart' as dom;

/// Loading status of a thread page.
enum TsdmThreadStatus {
  /// Nothing requested yet.
  initial,

  /// A request is in flight.
  loading,

  /// The last request succeeded.
  success,

  /// The last request failed.
  failure,
}

/// Controller of a thread page.
///
/// Replaces the bloc of `tsdm_client/lib/features/thread/v1/bloc/thread_bloc.dart`
/// with a [ChangeNotifier]. The parse rules live in [TsdmThreadPageParser].
class TsdmThreadController extends ChangeNotifier {
  /// Create a controller of the thread [tid] or of the post [pid].
  TsdmThreadController({
    required this.repository,
    this.tid,
    this.pid,
    this.onlyVisibleUid,
    this.reverseOrder,
    this.exactOrder,
  }) : assert(tid != null || pid != null);

  /// Repository used to fetch the thread.
  final TsdmThreadRepository repository;

  /// Thread id.
  final String? tid;

  /// Post id, used when the thread is opened through a post link.
  final String? pid;

  /// Uid of the only visible author, null when all authors are visible.
  String? onlyVisibleUid;

  /// Whether the posts are shown in reverse order.
  bool? reverseOrder;

  /// Exact order type requested by the user.
  int? exactOrder;

  /// Current status.
  TsdmThreadStatus status = TsdmThreadStatus.initial;

  /// Thread id of the loaded page, may differ from [tid] after a redirect.
  String? loadedTid;

  /// Thread title.
  String? title;

  /// Forum id of this thread.
  int? fid;

  /// Forum name.
  String? forumName;

  /// Whether another page can be loaded.
  bool canLoadMore = false;

  /// Current page number.
  int currentPage = 1;

  /// Total page count.
  int totalPages = 1;

  /// Whether the user may read this thread.
  bool havePermission = true;

  /// Message shown when the user may not read this thread.
  dom.Element? permissionDeniedMessage;

  /// Whether the user has to log in first.
  bool needLogin = false;

  /// Whether the thread shows the soft-closed marker.
  bool threadSoftClosed = false;

  /// Whether the thread is closed and cannot be replied to.
  bool threadClosed = false;

  /// Posts of all loaded pages.
  List<TsdmPost> postList = const [];

  /// Reply parameters of the fast reply form.
  TsdmReplyParameters? replyParameters;

  /// Thread type.
  TsdmThreadType? threadType;

  /// Whether the thread is a draft.
  bool isDraft = false;

  /// Latest moderation action text.
  String? latestModAct;

  /// Breadcrumbs of this thread.
  List<TsdmThreadBreadcrumb> breadcrumbs = const [];

  /// Thread view count.
  int? viewCount;

  /// Thread reply count.
  int? replyCount;

  /// Error of the last failed request.
  Object? error;

  /// Whether a request is currently in flight.
  bool isLoading() => status == TsdmThreadStatus.loading;

  /// Load page [pageNumber].
  Future<void> loadPage(int pageNumber) async {
    status = TsdmThreadStatus.loading;
    notifyListeners();
    try {
      final document = await repository.fetchThread(
        tid: tid,
        pid: pid,
        pageNumber: pageNumber,
        onlyVisibleUid: onlyVisibleUid,
        reverseOrder: reverseOrder,
        exactOrder: exactOrder,
      );
      _parse(document, pageNumber);
      status = TsdmThreadStatus.success;
    } on Object catch (e) {
      error = e;
      status = TsdmThreadStatus.failure;
    }
    notifyListeners();
  }

  /// Refresh the first page.
  Future<void> refresh() {
    postList = const [];
    return loadPage(1);
  }

  /// Append page [pageNumber].
  Future<void> loadMore(int pageNumber) async {
    if (!canLoadMore) {
      return;
    }
    await loadPage(pageNumber);
  }

  /// Show only the posts of user [uid].
  ///
  /// The page number of the request is kept but the response is parsed as page
  /// 1, exactly like the source, so the post floor numbers do not overflow.
  Future<void> onlyViewAuthor(String uid) async {
    onlyVisibleUid = uid;
    status = TsdmThreadStatus.loading;
    notifyListeners();
    try {
      final document = await repository.fetchThread(
        tid: tid,
        pid: pid,
        pageNumber: currentPage,
        onlyVisibleUid: uid,
        reverseOrder: reverseOrder,
        exactOrder: exactOrder,
      );
      _parse(document, 1);
      status = TsdmThreadStatus.success;
    } on Object catch (e) {
      error = e;
      status = TsdmThreadStatus.failure;
    }
    notifyListeners();
  }

  /// Show the posts of all authors again.
  Future<void> viewAllAuthors() async {
    onlyVisibleUid = null;
    status = TsdmThreadStatus.loading;
    notifyListeners();
    try {
      final document = await repository.fetchThread(
        tid: tid,
        pid: pid,
        pageNumber: currentPage,
        reverseOrder: reverseOrder,
        exactOrder: exactOrder,
      );
      _parse(document, currentPage);
      status = TsdmThreadStatus.success;
    } on Object catch (e) {
      error = e;
      status = TsdmThreadStatus.failure;
    }
    notifyListeners();
  }

  /// Toggle the view order and return to the first page.
  Future<void> changeViewOrder() {
    reverseOrder = !(reverseOrder ?? false);
    postList = const [];
    return loadPage(1);
  }

  void _parse(dom.Document document, int pageNumber) {
    final data = TsdmThreadPageParser.parse(document, pageNumber);
    loadedTid = data.tid ?? loadedTid;
    title = data.title ?? title;
    forumName = data.forumName ?? forumName;
    threadSoftClosed = data.threadSoftClosed;
    threadClosed = data.threadClosed;
    havePermission = data.havePermission;
    permissionDeniedMessage = data.permissionDeniedMessage;
    needLogin = data.needLogin;
    threadType = data.threadType ?? threadType;
    replyParameters = data.replyParameters ?? replyParameters;
    isDraft = data.isDraft;
    latestModAct = data.latestModAct ?? latestModAct;
    if (data.breadcrumbs.isNotEmpty) {
      breadcrumbs = data.breadcrumbs;
    }
    viewCount = data.viewCount ?? viewCount;
    replyCount = data.replyCount ?? replyCount;
    fid = fid ?? data.replyParameters?.fid;
    currentPage = data.currentPage;
    totalPages = data.totalPages;
    canLoadMore = data.canLoadMore;
    postList = [...postList, ...data.postList];
  }
}
