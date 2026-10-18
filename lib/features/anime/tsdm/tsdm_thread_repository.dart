import 'package:dashboard/features/anime/tsdm/tsdm_api_urls.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_exception.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_http_client.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_operation_log_item.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import 'package:dashboard/features/anime/tsdm/tsdm_selector_compat.dart';

/// Fetch thread pages and their operation logs.
///
/// Ported from `tsdm_client/lib/features/thread/v1/repository/thread_repository.dart`.
/// The source returned `fpdart`'s `Either`; the port throws a [TsdmException]
/// instead, and the controllers catch it, which keeps the same failure set
/// (`HttpRequestFailedException`) without the extra dependency.
class TsdmThreadRepository {
  /// Create the repository.
  const TsdmThreadRepository({required this.client});

  /// Transport used by this repository.
  final TsdmHttpClient client;

  /// Build the thread page url for [tid].
  ///
  /// [visibleUid] restricts the page to the posts of one author, [reverseOrder]
  /// and [exactOrder] control the post order exactly as the source did:
  /// an explicit [exactOrder] wins, then a `true` [reverseOrder] maps to
  /// `ordertype=1` and a `false` one to `ordertype=2`.
  static String buildThreadUrl({
    String? tid,
    String? pid,
    int pageNumber = 1,
    String? onlyVisibleUid,
    bool? reverseOrder,
    int? exactOrder,
  }) {
    assert(tid != null || pid != null, 'either tid or pid must be given');
    final visibleUid = onlyVisibleUid == null
        ? ''
        : '&authorid=$onlyVisibleUid';
    final orderType = switch ((exactOrder, reverseOrder)) {
      (final int i, _) => '&ordertype=$i',
      (null, true) => '&ordertype=1',
      (null, false) => '&ordertype=2',
      (null, null) => '',
    };
    if (tid != null) {
      return TsdmApiUrls.threadUrl(
        tid: tid,
        pageNumber: pageNumber,
        orderType: orderType,
        visibleUid: visibleUid,
      );
    }
    return TsdmApiUrls.redirectToPostUrl(pid!);
  }

  /// Fetch a thread page.
  Future<dom.Document> fetchThread({
    String? tid,
    String? pid,
    int pageNumber = 1,
    String? onlyVisibleUid,
    bool? reverseOrder,
    int? exactOrder,
  }) async {
    final url = buildThreadUrl(
      tid: tid,
      pid: pid,
      pageNumber: pageNumber,
      onlyVisibleUid: onlyVisibleUid,
      reverseOrder: reverseOrder,
      exactOrder: exactOrder,
    );
    final response = await client.get(url);
    if (response.statusCode != 200) {
      throw HttpRequestFailedException(response.statusCode);
    }
    return html_parser.parse(response.data);
  }

  /// Fetch the operation log of thread [tid].
  Future<List<TsdmOperationLogItem>> fetchOperationLog(String tid) async {
    final response = await client.get(TsdmApiUrls.operationLogUrl(tid));
    if (response.statusCode != 200) {
      throw HttpRequestFailedException(response.statusCode);
    }
    final logText = html_parser
        .parse(response.data)
        .documentElement
        ?.nodes
        .firstOrNull
        ?.text;
    if (logText == null) {
      throw const HtmlNodeNotFoundException('operation log body');
    }
    final document = html_parser.parse(logText);
    final items = <TsdmOperationLogItem>[];
    for (final element in document.qAll('table tr')) {
      final item = TsdmOperationLogItem.fromTr(element);
      if (item != null) {
        items.add(item);
      }
    }
    return items;
  }
}
