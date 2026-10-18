import 'package:dashboard/features/reading/alexandria/alexandria_filters.dart';
import 'package:dashboard/features/reading/alexandria/libgen_book.dart';
import 'package:dashboard/features/reading/alexandria/sci_hub_result.dart';
import 'package:dashboard/features/reading/alexandria/zlib_book.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;

/// Ports the public-site scraping rules of the Alexandria project: z-library
/// (`1lib.pl`), Library Genesis (`libgen.rs`) and Sci-Hub (`sci-hub.se`).
///
/// The query builders and every parser are pure functions of their arguments —
/// parsers take the raw HTML body and return models — so the real business rules
/// can be exercised without touching the network. Only the `search*`/`load*`
/// methods perform HTTP.
class AlexandriaSource {
  AlexandriaSource({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const String zlibSiteRoot = 'https://1lib.pl';
  static const String zlibSearchRoot = 'https://1lib.pl/s/';
  static const String sciHubRoot = 'https://sci-hub.se/';
  static const String libGenRootSite = 'http://libgen.rs';
  static const String libGenSearchStart = 'http://libgen.rs/search.php?req=';
  static const String libGenSearchEnd = '&res=100&view=detailed';
  static const String libGenSearchPage = '&sortmode=ASC&page=';

  static const String searchResultBoxId = 'searchResultBox';
  static const String resultItemClass = 'resItemBox resItemBoxBooks exactMatch';
  static const String resultTableClass = 'resItemTable';

  /// The placeholder the source produced for absent metadata.
  static const String notGiven = 'not given';

  /// The marker the source swapped for [missingCoverImage] in the book card.
  static const String missingCoverMarker = '/img/cover-not-exists.png';
  static const String missingCoverImage = 'https://i.imgur.com/1mECa0I.png';

  static const Duration requestTimeout = Duration(seconds: 20);

  /// Composes the z-library book URL the way the source did: `siteRoot + href`.
  static String zlibBookUrl(String bookId) => '$zlibSiteRoot$bookId';

  // ---------------------------------------------------------------------------
  // Query building
  // ---------------------------------------------------------------------------

  /// Ported from `ApiManager.getSearchSite`.
  ///
  /// The original appends the first active filter as `/?name=value` and later
  /// ones as `&name=value`. A missing year is the literal [AlexandriaFilters
  /// .yearUnset] sentinel and the `all` placeholder means "unfiltered".
  String buildZlibSearchUrl(String query, {AlexandriaFilters? filters}) {
    var url = '$zlibSearchRoot$query';
    url = _appendZlibFilter(
      url,
      'yearFrom',
      filters?.zlibYearFrom,
      skip: AlexandriaFilters.yearUnset,
    );
    url = _appendZlibFilter(
      url,
      'yearTo',
      filters?.zlibYearTo,
      skip: AlexandriaFilters.yearUnset,
    );
    url = _appendZlibFilter(url, 'language', filters?.zlibLanguage);
    url = _appendZlibFilter(
      url,
      'extension',
      filters?.zlibExtension,
      skip: AlexandriaFilters.allOption,
    );
    return url;
  }

  /// Ported from the paging half of `ApiManager.goToSearchSite`. Paging uses a
  /// bare `?page=`/`&page=` — the original does not insert the extra `/`.
  static String buildZlibPageUrl(String baseUrl, int page) =>
      baseUrl.contains('?') ? '$baseUrl&page=$page' : '$baseUrl?page=$page';

  /// Ported from `ApiManager.getLibGenSearchSite`.
  ///
  /// The original read the page number from a static field, but every caller had
  /// just assigned that field the same value it passed as the argument, so the
  /// parameter is used directly here.
  static String buildLibGenSearchUrl(String query, int page) =>
      '$libGenSearchStart$query$libGenSearchEnd$libGenSearchPage$page';

  static String _appendZlibFilter(
    String url,
    String name,
    String? value, {
    String? skip,
  }) {
    if (value == null || value.isEmpty || value == skip) {
      return url;
    }
    return url.contains('?') ? '$url&$name=$value' : '$url/?$name=$value';
  }

  // ---------------------------------------------------------------------------
  // Network
  // ---------------------------------------------------------------------------

  Future<List<ZlibBook>> searchZlib(
    String query, {
    AlexandriaFilters? filters,
  }) async {
    final body = await _get(buildZlibSearchUrl(query, filters: filters));
    return parseZlibBooks(body);
  }

  Future<List<ZlibBook>> loadZlibPage(String baseUrl, int page) async {
    final body = await _get(buildZlibPageUrl(baseUrl, page));
    return parseZlibBooks(body);
  }

  Future<List<LibGenBook>> searchLibGen(
    String query, {
    AlexandriaFilters? filters,
    int page = 1,
  }) async {
    final body = await _get(buildLibGenSearchUrl(query, page));
    return parseLibGenBooks(body, filters: filters);
  }

  /// Looks the identifier (DOI, PMID or article link) up on Sci-Hub. Returns
  /// `null` when the page has no `#link` node, i.e. nothing was found.
  Future<SciHubResult?> searchSciHub(String identifier) async {
    final body = await _get('$sciHubRoot${identifier.trim()}');
    return parseSciHubResult(body);
  }

  Future<String> _get(String url) async {
    // Queries are pasted into the URL unencoded, exactly like the source did;
    // `Uri.encodeFull` keeps reserved characters while escaping raw spaces.
    final response = await _client
        .get(Uri.parse(Uri.encodeFull(url)))
        .timeout(requestTimeout);
    if (response.statusCode != 200) {
      throw Exception('请求失败：HTTP ${response.statusCode}');
    }
    return response.body;
  }

  void dispose() => _client.close();

  // ---------------------------------------------------------------------------
  // z-library parsing (ported from `ApiManager.getBookList`)
  // ---------------------------------------------------------------------------

  List<ZlibBook> parseZlibBooks(String html) {
    final document = parser.parse(html);
    final box = document.getElementById(searchResultBoxId);
    if (box == null) {
      return const <ZlibBook>[];
    }
    final books = <ZlibBook>[];
    for (final row in box.getElementsByClassName(resultItemClass)) {
      final table = _first(row.getElementsByClassName(resultTableClass));
      if (table == null) {
        continue;
      }
      books.add(_parseZlibRow(row, table));
    }
    return books;
  }

  ZlibBook _parseZlibRow(dom.Element row, dom.Element table) {
    // The source preferred the lazy cover's data-src and fell back to the plain
    // cover's src.
    final lazyCover = row.getElementsByClassName('cover lazy');
    final String imageUrl;
    if (lazyCover.isEmpty) {
      imageUrl =
          _first(row.getElementsByClassName('cover'))?.attributes['src'] ?? '';
    } else {
      imageUrl = lazyCover.first.attributes['data-src'] ?? '';
    }

    // Fixed chain walked by the source:
    // table > row > cover column > info column > ... > h3, whose first child is
    // the book link.
    final titleNode = _descend(table, const <int>[0, 0, 1, 0, 0, 0, 0, 0, 0]);
    final title = titleNode?.text.trim() ?? '';
    final bookId = _child(titleNode, 0)?.attributes['href'] ?? '';

    final authors = <String>[];
    final authorUrls = <String>[];
    final authorsBox = _first(table.getElementsByClassName('authors'));
    if (authorsBox != null) {
      for (final element in authorsBox.children) {
        authors.add(element.text);
        authorUrls.add((element.attributes['href'] ?? '').trim());
      }
    }

    var year = notGiven;
    final yearBox = _first(
      table.getElementsByClassName('bookProperty property_year'),
    );
    if (yearBox != null) {
      year = _childText(yearBox, 1);
    }

    var language = notGiven;
    final languageBox = _first(
      table.getElementsByClassName('bookProperty property_language'),
    );
    if (languageBox != null) {
      language = _childText(languageBox, 1);
    }

    final fileBox = _first(
      table.getElementsByClassName('bookProperty property__file'),
    );
    final file = fileBox == null ? notGiven : _childText(fileBox, 1);

    final publisherNode = row.querySelector('div[title="Publisher"]');
    var publisher = notGiven;
    var publisherUrl = notGiven;
    if (publisherNode != null) {
      publisher = publisherNode.text.trim();
      publisherUrl = _child(publisherNode, 0)?.attributes['href'] ?? notGiven;
    }

    return ZlibBook(
      title: title,
      imageUrl: imageUrl,
      authors: authors,
      authorUrls: authorUrls,
      publisher: publisher,
      publisherUrl: publisherUrl,
      year: year,
      language: language,
      file: file,
      bookId: bookId,
    );
  }

  // ---------------------------------------------------------------------------
  // Library Genesis parsing (ported from `ApiManager.getLibgenBookList`)
  // ---------------------------------------------------------------------------

  List<LibGenBook> parseLibGenBooks(String html, {AlexandriaFilters? filters}) {
    final document = parser.parse(html);
    final tables = document.querySelectorAll(
      '[rules="cols"][width="100%"][border="0"]',
    );
    final books = <LibGenBook>[];
    // The original took every other match: each book renders as a nested pair of
    // matching tables and only the even entries are parsed.
    for (var index = 0; index < tables.length; index += 2) {
      final book = _parseLibGenTable(tables[index]);
      if (book != null) {
        books.add(book);
      }
    }
    return _applyLibGenFilters(books, filters);
  }

  LibGenBook? _parseLibGenTable(dom.Element table) {
    final content = table.querySelectorAll('[valign="top"]');
    if (content.length < 9) {
      return null;
    }
    // The first match is the wrapper row around the whole book.
    content.removeAt(0);

    final coverImage = _descend(content[0], const <int>[0, 0, 0]);
    var coverUrl = coverImage?.attributes['src'] ?? '';
    if (coverUrl.contains('static')) {
      coverUrl = coverUrl.replaceAll('/covers/', '').trim();
    } else {
      coverUrl = '$libGenRootSite$coverUrl';
    }

    final titleLink = _descend(content[0], const <int>[2, 0, 0]);
    final title = titleLink?.text.trim() ?? '';
    final bookHref = (titleLink?.attributes['href'] ?? '')
        .replaceFirst('..', '')
        .trim();
    final bookUrl = '$libGenRootSite$bookHref';

    final authors = <String>[];
    final authorsBox = _descend(content[1], const <int>[1, 0]);
    if (authorsBox != null) {
      for (final element in authorsBox.children) {
        authors.add(element.text.trim());
      }
    }

    return LibGenBook(
      title: title,
      bookUrl: bookUrl,
      imageUrl: coverUrl,
      authors: authors,
      series: _value(content[2], 1),
      publisher: _value(content[3], 1),
      year: _value(content[4], 1),
      language: _value(content[5], 1),
      pages: _value(content[5], 3),
      isbn: _value(content[6], 1),
      size: _value(content[8], 1),
      extension: _value(content[8], 3),
    );
  }

  /// Client-side filtering, preserved from `ApiManager.getLibgenBookList`.
  List<LibGenBook> _applyLibGenFilters(
    List<LibGenBook> books,
    AlexandriaFilters? filters,
  ) {
    if (filters == null) {
      return books;
    }
    final language = filters.libGenLanguage;
    if (language != null && language.isNotEmpty) {
      books.removeWhere((book) => book.language != language);
    }
    final extension = filters.libGenExtension;
    if (extension != null && extension.isNotEmpty) {
      books.removeWhere((book) => book.extension != extension);
    }
    final from = filters.libGenYearFrom;
    final to = filters.libGenYearTo;
    if (_isYearBound(from) || _isYearBound(to)) {
      books.removeWhere((book) => !_yearInRange(book.year, from, to));
    }
    return books;
  }

  static bool _isYearBound(String year) =>
      year.isNotEmpty && year != AlexandriaFilters.yearUnset;

  static bool _yearInRange(String year, String from, String to) {
    final value = int.tryParse(year.trim());
    // The source dropped `not given` (and would have thrown on anything else).
    if (value == null) {
      return false;
    }
    if (_isYearBound(from)) {
      final lower = int.tryParse(from.trim());
      if (lower != null && value < lower) {
        return false;
      }
    }
    if (_isYearBound(to)) {
      final upper = int.tryParse(to.trim());
      if (upper != null && value > upper) {
        return false;
      }
    }
    return true;
  }

  // ---------------------------------------------------------------------------
  // Sci-Hub parsing (ported from `ApiManager.GetSciHubResult`)
  // ---------------------------------------------------------------------------

  SciHubResult? parseSciHubResult(String html) {
    final document = parser.parse(html);
    final link = document.getElementById('link');
    if (link == null) {
      return null;
    }
    final shareUrl = link.children.length > 1
        ? link.children[1].attributes['href'] ?? ''
        : '';

    var downloadUrl = '';
    final buttons = document.getElementById('buttons');
    final onclick = _descend(buttons, const <int>[
      0,
      0,
      0,
    ])?.attributes['onclick'];
    if (onclick != null) {
      downloadUrl = onclick
          .replaceAll('?download=true', '')
          .trim()
          .replaceAll("location.href='//", '')
          .replaceAll("'", '')
          .trim();
    }
    return SciHubResult(shareUrl: shareUrl, downloadUrl: downloadUrl);
  }

  // ---------------------------------------------------------------------------
  // DOM helpers
  // ---------------------------------------------------------------------------

  static dom.Element? _first(List<dom.Element> elements) =>
      elements.isEmpty ? null : elements.first;

  static dom.Element? _child(dom.Element? element, int index) {
    if (element == null || index >= element.children.length) {
      return null;
    }
    return element.children[index];
  }

  static String _childText(dom.Element element, int index) =>
      _child(element, index)?.text.trim() ?? '';

  static String _value(dom.Element element, int index) {
    final text = _childText(element, index);
    return text.isEmpty ? notGiven : text;
  }

  static dom.Element? _descend(dom.Element? element, List<int> indexes) {
    var current = element;
    for (final index in indexes) {
      current = _child(current, index);
    }
    return current;
  }
}
