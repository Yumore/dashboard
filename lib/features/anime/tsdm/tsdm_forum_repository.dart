import 'package:dashboard/features/anime/tsdm/tsdm_api_urls.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_exception.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_filter_state.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_forum_group.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_forum_group_parser.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_forum_query.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_http_client.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;

/// Fetch forum display pages and forum groups.
///
/// Ported from `tsdm_client/lib/features/forum/repository/forum_repository.dart`.
class TsdmForumRepository {
  /// Create the repository.
  const TsdmForumRepository({required this.client});

  /// Transport used by this repository.
  final TsdmHttpClient client;

  /// Fetch forum [fid] page [pageNumber] with [filterState].
  Future<dom.Document> fetchForum({
    required String fid,
    required TsdmFilterState filterState,
    int pageNumber = 1,
  }) async {
    final query = TsdmForumQuery.build(
      fid: fid,
      filterState: filterState,
      pageNumber: pageNumber,
    );
    final uri = Uri.https(
      TsdmApiUrls.baseHostAlt,
      '/forum.php',
      query.parameters,
    );
    final response = await client.getUri(uri);
    if (response.statusCode != 200) {
      throw HttpRequestFailedException(response.statusCode);
    }
    return html_parser.parse(response.data);
  }

  /// Fetch the forum group with [gid].
  Future<TsdmForumGroup?> fetchForumGroup(String gid) async {
    final response = await client.get(
      '${TsdmApiUrls.baseUrl}/forum.php?gid=$gid',
    );
    if (response.statusCode != 200) {
      throw HttpRequestFailedException(response.statusCode);
    }
    final document = html_parser.parse(response.data);
    return TsdmForumGroupParser.buildGroupListFromDocument(
      document,
    ).firstOrNull;
  }
}
