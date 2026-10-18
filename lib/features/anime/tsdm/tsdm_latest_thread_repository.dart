import 'package:dashboard/features/anime/tsdm/tsdm_exception.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_http_client.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_html_ext.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_latest_thread.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_string_ext.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import 'package:dashboard/features/anime/tsdm/tsdm_selector_compat.dart';

/// Fetch and parse the `latest thread` page.
///
/// Ported from `tsdm_client/lib/features/latest_thread/repository/latest_thread_repository.dart`
/// and `tsdm_client/lib/features/latest_thread/bloc/latest_thread_bloc.dart`.
class TsdmLatestThreadRepository {
  /// Create the repository.
  const TsdmLatestThreadRepository({required this.client});

  /// Transport used by this repository.
  final TsdmHttpClient client;

  /// Fetch the document at [url].
  Future<dom.Document> fetchDocument(String url) async {
    final response = await client.get(url);
    if (response.statusCode != 200) {
      throw HttpRequestFailedException(response.statusCode);
    }
    return html_parser.parse(response.data);
  }

  /// Parse the thread list of a latest-thread document.
  static List<TsdmLatestThread> parseThreadList(dom.Document document) {
    final listNode = document.q('div#threadlist > ul');
    if (listNode == null) {
      return const [];
    }
    final threads = <TsdmLatestThread>[];
    for (final element in listNode.qAll('li')) {
      final thread = TsdmLatestThread.fromLi(element);
      if (thread != null) {
        threads.add(thread);
      }
    }
    return threads;
  }

  /// Parse the url of the next page, null when this is the last page.
  static String? parseNextPageUrl(dom.Document document) {
    return document
        .q('div#ct_shell div.pg > a.nxt')
        ?.firstHref()
        ?.prependHost();
  }
}
