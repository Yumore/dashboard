import 'package:dashboard/features/anime/tsdm/tsdm_api_urls.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_exception.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_http_client.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;

/// Cached access to the forum home page and its topic page.
///
/// Ported from `tsdm_client/lib/shared/repositories/forum_home_repository/forum_home_repository.dart`.
class TsdmForumHomeRepository {
  /// Create the repository.
  const TsdmForumHomeRepository({required this.client});

  /// Transport used by this repository.
  final TsdmHttpClient client;

  /// Fetch a document by url.
  Future<dom.Document> fetchDocument(String url) async {
    final response = await client.get(url);
    if (response.statusCode != 200) {
      throw HttpRequestFailedException(response.statusCode);
    }
    return html_parser.parse(response.data);
  }

  /// Fetch the forum home page.
  Future<dom.Document> fetchHomePage() => fetchDocument(TsdmApiUrls.homePage);

  /// Fetch the forum home page of the topics tab.
  Future<dom.Document> fetchTopicPage() => fetchDocument(TsdmApiUrls.homePage);
}

/// Documents fetched by [TsdmForumHomeRepository], with a simple cache.
///
/// The source kept the document in a singleton provider and reused it unless a
/// forced refresh was requested; the port keeps the same behavior behind an
/// instance owned by the caller.
class TsdmDocumentCache {
  /// Create an empty cache.
  TsdmDocumentCache();

  dom.Document? _document;

  /// Whether a document is cached.
  bool hasCache() => _document != null;

  /// The cached document, null when empty.
  dom.Document? getCache() => _document;

  /// Store [document].
  void setCache(dom.Document document) => _document = document;

  /// Clear the cache.
  void clear() => _document = null;
}
