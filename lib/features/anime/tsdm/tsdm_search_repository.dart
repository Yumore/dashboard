import 'package:dashboard/features/anime/tsdm/tsdm_api_urls.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_exception.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_html_ext.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_http_client.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_search_result.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_searched_thread.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_string_ext.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import 'package:dashboard/features/anime/tsdm/tsdm_selector_compat.dart';

/// Search threads through the site search plugin.
///
/// Ported from `tsdm_client/lib/features/search/repository/search_repository.dart`.
class TsdmSearchRepository {
  /// Create the repository.
  const TsdmSearchRepository({required this.client});

  /// Transport used by this repository.
  final TsdmHttpClient client;

  /// Search with [keyword] in forum [fid], published by user [uid], page [pageNumber].
  ///
  /// The query parameter names of the source are preserved exactly:
  /// `id`, `query`, `authorid`, `fid` and `page`.
  Future<dom.Document> searchWithParameters({
    required String keyword,
    required String fid,
    required String uid,
    required int pageNumber,
  }) async {
    final uri = Uri.parse(TsdmApiUrls.searchUrl).replace(
      queryParameters: {
        'id': TsdmApiUrls.searchPluginId,
        'query': keyword,
        'authorid': uid,
        'fid': fid,
        'page': '$pageNumber',
      },
    );
    final response = await client.getUri(uri);
    if (response.statusCode != 200) {
      throw HttpRequestFailedException(response.statusCode);
    }
    return html_parser.parse(response.data);
  }

  /// Parse a search result document.
  ///
  /// The result list lives in `div#ct > div#ct_shell > div#left_s >
  /// div.ts_se_rs`; the result count is the first word of the `h3` heading.
  static TsdmSearchResult parseSearchResultDocument(dom.Document document) {
    final threads = <TsdmSearchedThread>[];
    for (final element in document.qAll(
      'div#ct > div#ct_shell > div#left_s > div.ts_se_rs',
    )) {
      final thread = TsdmSearchedThread.fromDivNode(element);
      if (thread != null) {
        threads.add(thread);
      }
    }
    final countText = document.q('h3')?.firstEndDeepText();
    final count = countText?.split(' ').first.parseToInt();
    final currentPage = document.currentPage() ?? 1;
    final totalPages = document.totalPages() ?? currentPage;
    return TsdmSearchResult(
      currentPage: currentPage,
      totalPages: totalPages,
      count: count,
      data: threads.isEmpty ? null : threads,
    );
  }
}
