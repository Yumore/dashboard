import 'package:dashboard/features/reading/alexandria/alexandria_filters.dart';
import 'package:dashboard/features/reading/alexandria/alexandria_page.dart';
import 'package:dashboard/features/reading/alexandria/alexandria_source.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Minimal z-library result page shaped like the markup the source parser walks:
/// `#searchResultBox > .resItemBox.resItemBoxBooks.exactMatch > .resItemTable`,
/// with the fixed `table > row > cover cell > info cell > ... > h3 > a` chain —
/// the info cell is the second child (`children[1]`) of the row's first cell,
/// which is the only shape the source's child-index walk accepts.
///
/// The first row uses the lazy cover (`data-src`), the second the plain
/// `cover` (`src`) and no year/language/publisher, exercising both branches and
/// the `not given` placeholders.
const String _zlibHtml = '''
<html><body>
<div id="searchResultBox">
  <div class="resItemBox resItemBoxBooks exactMatch">
    <div class="resItemTable">
      <div class="resItemRow">
        <div class="resItemCol resItemCol1">
          <a href="/book/1001/alpha"><span class="cover lazy" data-src="https://covers.z-lib.org/alpha.jpg"></span></a>
          <div class="resItemCol resItemCol2">
            <div class="resItemInfo">
              <div class="resItemInfoTop">
                <div class="resItemTitle">
                  <div class="resItemTitleBox">
                    <div class="resItemTitleHolder">
                      <h3><a href="/book/1001/alpha">Alpha Book</a></h3>
                    </div>
                  </div>
                </div>
              </div>
            </div>
            <div class="authors"><a href="/g/Author+One">Author One</a><a href="/g/Author+Two">Author Two</a></div>
            <div class="bookProperty property_year"><div class="property_label">Year:</div><div class="property_value">1999</div></div>
            <div class="bookProperty property_language"><div class="property_label">Language:</div><div class="property_value">english</div></div>
            <div class="bookProperty property__file"><div class="property_label">File:</div><div class="property_value">PDF, 1.2 MB</div></div>
            <div title="Publisher"><a href="/p/ACME">ACME Press</a></div>
          </div>
        </div>
      </div>
    </div>
  </div>
  <div class="resItemBox resItemBoxBooks exactMatch">
    <div class="resItemTable">
      <div class="resItemRow">
        <div class="resItemCol resItemCol1">
          <img class="cover" src="https://covers.z-lib.org/beta.jpg">
          <div class="resItemCol resItemCol2">
            <div class="resItemInfo">
              <div class="resItemInfoTop">
                <div class="resItemTitle">
                  <div class="resItemTitleBox">
                    <div class="resItemTitleHolder">
                      <h3><a href="/book/1002/beta">Beta Book</a></h3>
                    </div>
                  </div>
                </div>
              </div>
            </div>
            <div class="authors"><a href="/g/Solo+Author">Solo Author</a></div>
            <div class="bookProperty property__file"><div class="property_label">File:</div><div class="property_value">EPUB, 0.8 MB</div></div>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>
</body></html>
''';

/// One Library Genesis detailed-view book: an outer table wrapping an identical
/// inner table, which is what the source's "take every other match" loop assumes.
String _libGenBookTable({
  required String title,
  required String href,
  required String coverSrc,
  required List<String> authors,
  String series = '',
  String publisher = '',
  String year = '',
  String language = '',
  String pages = '',
  String isbn = '',
  String size = '',
  String extension = '',
}) =>
    '''
<table rules="cols" width="100%" border="0">
  <tr valign="top"><td>
    <table rules="cols" width="100%" border="0">
      <tr valign="top">
        <td><a href="$href"><img src="$coverSrc"></a></td>
        <td>x</td>
        <td><div><a href="$href">$title</a></div></td>
      </tr>
      <tr valign="top"><td>Authors:</td><td><div>${authors.map((author) => '<a href="..//index.php?req=$author">$author</a>').join()}</div></td></tr>
      <tr valign="top"><td>Series:</td><td>$series</td></tr>
      <tr valign="top"><td>Publisher:</td><td>$publisher</td></tr>
      <tr valign="top"><td>Year:</td><td>$year</td></tr>
      <tr valign="top"><td>Language:</td><td>$language</td><td>Pages:</td><td>$pages</td></tr>
      <tr valign="top"><td>ISBN:</td><td>$isbn</td></tr>
      <tr valign="top"><td>Comment:</td><td></td></tr>
      <tr valign="top"><td>Size:</td><td>$size</td><td>Extension:</td><td>$extension</td></tr>
    </table>
  </td></tr>
</table>
''';

/// Four Library Genesis hits: English/pdf/1999, Polish/epub/2015 with the
/// `static` cover branch, English/pdf/1800 and an all-empty one that must be
/// dropped by any year filter.
final String _libGenHtml =
    '''
<html><body>
${_libGenBookTable(title: 'Alpha Book', href: '../book/index.php?md5=AAA', coverSrc: '/covers/aaa.jpg', authors: ['Author One', 'Author Two'], series: 'Alpha Series', publisher: 'ACME Press', year: '1999', language: 'English', pages: '321', isbn: '978-0-00-000000-0', size: '4 MB', extension: 'pdf')}
${_libGenBookTable(title: 'Beta Book', href: '../book/index.php?md5=BBB', coverSrc: '/covers/static/nocover.png', authors: ['Author Three'], year: '2015', language: 'Polish', size: '2 MB', extension: 'epub')}
${_libGenBookTable(title: 'Gamma Book', href: '../book/index.php?md5=CCC', coverSrc: '/covers/ccc.jpg', authors: ['Author Four'], year: '1800', language: 'English', size: '9 MB', extension: 'pdf')}
${_libGenBookTable(title: 'Delta Book', href: '../book/index.php?md5=DDD', coverSrc: '/covers/ddd.jpg', authors: <String>[])}
</body></html>
''';

/// Sci-Hub result page: `#link > a[href]` plus the `#buttons...onclick` chain the
/// source scraped the scheme-less download location from.
const String _sciHubHtml = '''
<html><body>
<div id="link"><span>Save</span><a href="https://sci-hub.se/download/10.1000/xyz">download</a></div>
<div id="buttons"><div><div><button onclick="location.href='//sci-hub.se/downloads/2020/xyz.pdf?download=true'">pdf</button></div></div></div>
</body></html>
''';

void main() {
  test(
    'parses z-library rows with both cover branches and the author list',
    () {
      final source = AlexandriaSource();
      addTearDown(source.dispose);

      final books = source.parseZlibBooks(_zlibHtml);

      expect(books, hasLength(2));

      final alpha = books.first;
      expect(alpha.title, 'Alpha Book');
      expect(alpha.bookId, '/book/1001/alpha');
      expect(alpha.imageUrl, 'https://covers.z-lib.org/alpha.jpg');
      expect(alpha.authors, <String>['Author One', 'Author Two']);
      expect(alpha.authorUrls, <String>['/g/Author+One', '/g/Author+Two']);
      expect(alpha.year, '1999');
      expect(alpha.language, 'english');
      expect(alpha.file, 'PDF, 1.2 MB');
      expect(alpha.publisher, 'ACME Press');
      expect(alpha.publisherUrl, '/p/ACME');
      expect(alpha.hasPublisher, isTrue);

      final beta = books.last;
      expect(beta.title, 'Beta Book');
      expect(beta.bookId, '/book/1002/beta');
      expect(beta.imageUrl, 'https://covers.z-lib.org/beta.jpg');
      expect(beta.authors, <String>['Solo Author']);
      expect(beta.file, 'EPUB, 0.8 MB');
      // Absent properties fall back to the source placeholder.
      expect(beta.year, 'not given');
      expect(beta.language, 'not given');
      expect(beta.publisher, 'not given');
      expect(beta.hasPublisher, isFalse);
    },
  );

  test('parses all thirteen Library Genesis fields', () {
    final source = AlexandriaSource();
    addTearDown(source.dispose);

    final books = source.parseLibGenBooks(_libGenHtml);

    expect(books, hasLength(4));

    final alpha = books.first;
    expect(alpha.title, 'Alpha Book');
    expect(alpha.bookUrl, 'http://libgen.rs/book/index.php?md5=AAA');
    expect(alpha.imageUrl, 'http://libgen.rs/covers/aaa.jpg');
    expect(alpha.authors, <String>['Author One', 'Author Two']);
    expect(alpha.series, 'Alpha Series');
    expect(alpha.publisher, 'ACME Press');
    expect(alpha.year, '1999');
    expect(alpha.language, 'English');
    expect(alpha.isbn, '978-0-00-000000-0');
    expect(alpha.size, '4 MB');
    expect(alpha.pages, '321');
    expect(alpha.extension, 'pdf');
    // The source declared `id` but never populated it.
    expect(alpha.id, '');

    // The "static" cover branch keeps the raw path instead of prefixing the site.
    final beta = books[1];
    expect(beta.imageUrl, 'static/nocover.png');
    expect(beta.imageUrl.startsWith('http'), isFalse);

    // Empty cells become the source placeholder.
    final delta = books.last;
    expect(delta.series, 'not given');
    expect(delta.publisher, 'not given');
    expect(delta.year, 'not given');
    expect(delta.language, 'not given');
    expect(delta.pages, 'not given');
    expect(delta.isbn, 'not given');
    expect(delta.size, 'not given');
    expect(delta.extension, 'not given');
  });

  test('applies the Library Genesis language, extension and year filters', () {
    final source = AlexandriaSource();
    addTearDown(source.dispose);

    List<String> titles(AlexandriaFilters filters) => source
        .parseLibGenBooks(_libGenHtml, filters: filters)
        .map((book) => book.title)
        .toList();

    expect(titles(AlexandriaFilters()..libGenLanguage = 'English'), <String>[
      'Alpha Book',
      'Gamma Book',
    ]);
    expect(titles(AlexandriaFilters()..libGenExtension = 'epub'), <String>[
      'Beta Book',
    ]);
    // A year filter drops both out-of-range and `not given` years.
    expect(titles(AlexandriaFilters()..libGenYearFrom = '1900'), <String>[
      'Alpha Book',
      'Beta Book',
    ]);
    expect(titles(AlexandriaFilters()..libGenYearTo = '2000'), <String>[
      'Alpha Book',
      'Gamma Book',
    ]);
    expect(
      titles(
        AlexandriaFilters()
          ..libGenLanguage = 'English'
          ..libGenExtension = 'pdf'
          ..libGenYearFrom = '1850'
          ..libGenYearTo = '2000',
      ),
      <String>['Alpha Book'],
    );
  });

  test('extracts the Sci-Hub share link and download location', () {
    final source = AlexandriaSource();
    addTearDown(source.dispose);

    final result = source.parseSciHubResult(_sciHubHtml);

    expect(result, isNotNull);
    expect(result!.shareUrl, 'https://sci-hub.se/download/10.1000/xyz');
    expect(result.downloadUrl, 'sci-hub.se/downloads/2020/xyz.pdf');
    expect(
      result.absoluteDownloadUrl,
      'https://sci-hub.se/downloads/2020/xyz.pdf',
    );

    // No `#link` node means the source reported "couldn't find your DOI".
    expect(
      source.parseSciHubResult(
        '<html><body><div id="buttons"></div></body></html>',
      ),
      isNull,
    );
  });

  test('builds z-library query strings for paging and filters', () {
    final source = AlexandriaSource();
    addTearDown(source.dispose);

    final filters = AlexandriaFilters();
    expect(source.buildZlibSearchUrl('dune'), 'https://1lib.pl/s/dune');
    expect(
      source.buildZlibSearchUrl('dune', filters: filters),
      'https://1lib.pl/s/dune',
    );

    filters.zlibYearFrom = '1990';
    expect(
      source.buildZlibSearchUrl('dune', filters: filters),
      'https://1lib.pl/s/dune/?yearFrom=1990',
    );

    filters.zlibYearTo = '2005';
    filters.zlibLanguage = 'english';
    filters.zlibExtension = 'pdf';
    expect(
      source.buildZlibSearchUrl('dune', filters: filters),
      'https://1lib.pl/s/dune/?yearFrom=1990&yearTo=2005&language=english&extension=pdf',
    );

    // Paging never inserts the extra `/`.
    expect(
      AlexandriaSource.buildZlibPageUrl('https://1lib.pl/s/dune', 2),
      'https://1lib.pl/s/dune?page=2',
    );
    expect(
      AlexandriaSource.buildZlibPageUrl(
        'https://1lib.pl/s/dune/?yearFrom=1990',
        3,
      ),
      'https://1lib.pl/s/dune/?yearFrom=1990&page=3',
    );

    // The `year` sentinel and the `all` placeholder are skipped.
    filters.zlibYearFrom = AlexandriaFilters.yearUnset;
    filters.zlibExtension = AlexandriaFilters.allOption;
    expect(
      source.buildZlibSearchUrl('dune', filters: filters),
      'https://1lib.pl/s/dune/?yearTo=2005&language=english',
    );
  });

  test('builds the Library Genesis query string with the page number', () {
    expect(
      AlexandriaSource.buildLibGenSearchUrl('dune', 1),
      'http://libgen.rs/search.php?req=dune&res=100&view=detailed&sortmode=ASC&page=1',
    );
    expect(
      AlexandriaSource.buildLibGenSearchUrl('dune', 7),
      'http://libgen.rs/search.php?req=dune&res=100&view=detailed&sortmode=ASC&page=7',
    );
  });

  test('filters round-trip through shared preferences', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final filters = AlexandriaFilters()
      ..zlibLanguage = 'polish'
      ..zlibExtension = 'epub'
      ..zlibYearFrom = '1950'
      ..libGenLanguage = 'Polish'
      ..libGenExtension = 'pdf'
      ..libGenYearTo = '2010';
    await filters.save();

    final loaded = AlexandriaFilters();
    await loaded.load();

    expect(loaded.zlibLanguage, 'polish');
    expect(loaded.zlibExtension, 'epub');
    expect(loaded.zlibYearFrom, '1950');
    expect(loaded.zlibYearTo, AlexandriaFilters.yearUnset);
    expect(loaded.libGenLanguage, 'Polish');
    expect(loaded.libGenExtension, 'pdf');
    expect(loaded.libGenYearFrom, AlexandriaFilters.yearUnset);
    expect(loaded.libGenYearTo, '2010');
  });

  testWidgets('renders the three sources without starting a search', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await tester.pumpWidget(const MaterialApp(home: AlexandriaPage()));
    await tester.pump();

    expect(find.text('Z-Library'), findsOneWidget);
    expect(find.text('Library Genesis'), findsOneWidget);
    expect(find.text('Sci-Hub'), findsOneWidget);
    expect(find.text('输入关键词搜索 Z-Library 图书'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
