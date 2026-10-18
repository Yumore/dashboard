// FlutterEbookApp（OpenLeaf）Feedbooks 目录模块的移植测试。
//
// 全部用例都是离线的：
//  * 目录接口用注入的假 `HttpClientAdapter`（手写 atom fixture）；
//  * 封面走 `FeedbooksCoverImage.debugBuilder`，不碰网络与磁盘缓存；
//  * 本地库用 `SharedPreferences.setMockInitialValues`。
//
// 断言的值都来自源工程：端点路径、GData 键名（`dcterms$language` /
// `opensearch$totalResults` / `thr:count`）、分页规则（`&page=N` 追加）、
// 下载文件名规则、以及源工程里那些“看起来是 bug 但行为如此”的边界。

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dashboard/features/reading/flutterebook/data/feedbooks_book_details_repository.dart';
import 'package:dashboard/features/reading/flutterebook/data/feedbooks_book_repository.dart';
import 'package:dashboard/features/reading/flutterebook/data/feedbooks_dio.dart';
import 'package:dashboard/features/reading/flutterebook/data/feedbooks_download_record.dart';
import 'package:dashboard/features/reading/flutterebook/data/feedbooks_download_service.dart';
import 'package:dashboard/features/reading/flutterebook/data/feedbooks_downloads_local_data_source_impl.dart';
import 'package:dashboard/features/reading/flutterebook/data/feedbooks_downloads_repository_impl.dart';
import 'package:dashboard/features/reading/flutterebook/data/feedbooks_explore_repository.dart';
import 'package:dashboard/features/reading/flutterebook/data/feedbooks_favorites_local_data_source_impl.dart';
import 'package:dashboard/features/reading/flutterebook/data/feedbooks_favorites_repository_impl.dart';
import 'package:dashboard/features/reading/flutterebook/data/feedbooks_gdata_converter.dart';
import 'package:dashboard/features/reading/flutterebook/data/feedbooks_home_repository.dart';
import 'package:dashboard/features/reading/flutterebook/data/feedbooks_http_failure.dart';
import 'package:dashboard/features/reading/flutterebook/feedbooks_api.dart';
import 'package:dashboard/features/reading/flutterebook/feedbooks_format.dart';
import 'package:dashboard/features/reading/flutterebook/models/category_feed.dart';
import 'package:dashboard/features/reading/flutterebook/models/entry.dart';
import 'package:dashboard/features/reading/flutterebook/models/feed.dart';
import 'package:dashboard/features/reading/flutterebook/models/link.dart';
import 'package:dashboard/features/reading/flutterebook/models/schema_series.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/controllers/feedbooks_book_details_controller.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/controllers/feedbooks_downloads_controller.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/controllers/feedbooks_favorites_controller.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/controllers/feedbooks_genre_feed_controller.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/controllers/feedbooks_home_feed_controller.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/pages/book_details/feedbooks_book_details_page.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/pages/downloads/feedbooks_downloads_page.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/pages/explore/feedbooks_explore_page.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/pages/favorites/feedbooks_favorites_page.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/pages/genre/feedbooks_genre_page.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/pages/home/feedbooks_home_page.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/widgets/feedbooks_book_list_item.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/widgets/feedbooks_cover_image.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/widgets/feedbooks_description_text.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/widgets/feedbooks_empty_view.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/widgets/feedbooks_error_widget.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/widgets/feedbooks_genre_row.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    // 图片一律用占位方块，测试不碰网络。
    FeedbooksCoverImage.debugBuilder =
        (BuildContext context, String url) =>
            const SizedBox(width: 8.0, height: 8.0);
  });

  tearDown(() {
    FeedbooksCoverImage.debugBuilder = null;
  });

  _apiConstantTests();
  _formatBytesTests();
  _gdataConverterTests();
  _xmlParserEdgeCaseTests();
  _modelMappingTests();
  _repositoryTests();
  _homeFeedControllerTests();
  _genreFeedControllerTests();
  _bookDetailsControllerTests();
  _downloadsStoreTests();
  _favoritesStoreTests();
  _downloadServiceTests();
  _sharedWidgetTests();
  _pageTests();
}

// ---------------------------------------------------------------------------
// 假传输层
// ---------------------------------------------------------------------------

class _RecordedRequest {
  _RecordedRequest(this.path, this.uri, this.uriQuery);

  final String path;
  final Uri uri;
  final Map<String, String> uriQuery;

  @override
  String toString() => '$_RecordedRequest($uri)';
}

typedef _FakeHandler = ResponseBody Function(_RecordedRequest request);

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.handler);

  final _FakeHandler handler;
  final List<_RecordedRequest> requests = <_RecordedRequest>[];

  _RecordedRequest get last => requests.last;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final _RecordedRequest recorded = _RecordedRequest(
      options.path,
      options.uri,
      Map<String, String>.from(options.uri.queryParameters),
    );
    requests.add(recorded);
    return handler(recorded);
  }

  @override
  void close({bool force = false}) {}
}

class _FakeApi {
  _FakeApi(this.handler) {
    adapter = _FakeAdapter(handler);
    dio = createFeedbooksDio()..httpClientAdapter = adapter;
  }

  final _FakeHandler handler;
  late final _FakeAdapter adapter;
  late final Dio dio;
}

ResponseBody _atomBody(String body, {int status = 200}) {
  return ResponseBody.fromString(
    body,
    status,
    headers: <String, List<String>>{
      Headers.contentTypeHeader: <String>['application/atom+xml; charset=utf-8'],
    },
  );
}

ResponseBody _epubBody(String body) {
  return ResponseBody.fromString(
    body,
    200,
    headers: <String, List<String>>{
      Headers.contentTypeHeader: <String>['application/epub+zip'],
      Headers.contentLengthHeader: <String>['${body.length}'],
    },
  );
}

// ---------------------------------------------------------------------------
// 手写 atom fixture
// ---------------------------------------------------------------------------

const String _atomHeader =
    '<feed xmlns="http://www.w3.org/2005/Atom" '
    'xmlns:dcterms="http://purl.org/dc/terms/" '
    'xmlns:opensearch="http://a9.com/-/spec/opensearch/1.1/" '
    'xmlns:opds="http://opds-spec.org/2010/catalog" '
    'xmlns:thr="http://purl.org/syndication/thread/1.0" '
    'xml:lang="en">';

String _entryXml({
  required String id,
  required String title,
  String author = 'Jane Doe',
  String authorUri =
      r'https://catalog.feedbooks.com/catalog/author/123\&amp;lang=en',
  String summary = 'A short summary of the book.',
  String cover = 'https://images.example.com/cover.jpg',
  String epub = 'https://downloads.example.com/book.epub',
  List<String> categories = const <String>['Fiction'],
}) {
  return '''
  <entry>
    <title>$title</title>
    <id>$id</id>
    <author>
      <name>$author</name>
      <uri>$authorUri</uri>
    </author>
    <published>2024-01-01T00:00:00Z</published>
    <updated>2024-01-02T00:00:00Z</updated>
    <dcterms:language>en</dcterms:language>
    <dcterms:publisher>Feedbooks</dcterms:publisher>
    <dcterms:issued>2024</dcterms:issued>
    <summary>$summary</summary>
    ${categories.map((String label) => '<category label="$label" term="TH-$label" scheme="http://thema.example"/>').join('\n    ')}
    <link rel="alternate" type="text/html" href="https://catalog.feedbooks.com/book/$id"/>
    <link rel="http://opds-spec.org/image/thumbnail" type="image/jpeg" href="$cover"/>
    <link rel="http://opds-spec.org/image" type="image/jpeg" href="$cover"/>
    <link rel="http://opds-spec.org/acquisition/open-access" type="application/epub+zip" href="$epub"/>
  </entry>''';
}

/// 热门榜：前 10 个 `<link>` 是 OPDS 导航（源工程 UI 直接跳过），
/// 第 11 个（下标 10）才是分类 facet。
String _popularFeedXml() {
  final List<String> navLinks = List<String>.generate(
    10,
    (int i) =>
        '<link rel="http://opds-spec.org/shelf" type="application/atom+xml" '
        'title="Nav Tag $i" '
        'href="https://catalog.feedbooks.com/publicdomain/browse/nav-$i.atom"/>',
  );
  return '''
<?xml version="1.0" encoding="UTF-8"?>
$_atomHeader
  <id>urn:uuid:popular</id>
  <title>Popular</title>
  <updated>2024-01-01T00:00:00Z</updated>
  ${navLinks.join('\n  ')}
  <link rel="http://opds-spec.org/facet" type="application/atom+xml" title="Science Fiction" href="https://catalog.feedbooks.com/publicdomain/browse/top.atom?cat=FBFIC028000" thr:count="12"/>
  <opensearch:totalResults>35</opensearch:totalResults>
  <opensearch:itemsPerPage>10</opensearch:itemsPerPage>
  <opensearch:startIndex>1</opensearch:startIndex>
  ${_entryXml(id: 'urn:uuid:book-1', title: 'Book One')}
  ${_entryXml(id: 'urn:uuid:book-2', title: 'Book Two', author: 'John Roe', authorUri: r'https://catalog.feedbooks.com/catalog/author/456\&amp;lang=en')}
</feed>
''';
}

String _recentFeedXml() {
  return '''
<?xml version="1.0" encoding="UTF-8"?>
$_atomHeader
  <id>urn:uuid:recent</id>
  <title>Recently Added</title>
  <updated>2024-02-01T00:00:00Z</updated>
  <opensearch:totalResults>1</opensearch:totalResults>
  ${_entryXml(id: 'urn:uuid:latest', title: 'Latest Arrival', summary: 'Fresh from the press.')}
</feed>
''';
}

String _genreFeedXml(int count, {required String title}) {
  final String entries = List<String>.generate(
    count,
    (int i) => _entryXml(id: 'urn:uuid:genre-$i', title: 'Genre Book $i'),
  ).join('\n  ');
  return '''
<?xml version="1.0" encoding="UTF-8"?>
$_atomHeader
  <id>urn:uuid:genre</id>
  <title>$title</title>
  <updated>2024-03-01T00:00:00Z</updated>
  <opensearch:totalResults>$count</opensearch:totalResults>
  $entries
</feed>
''';
}

String _relatedFeedXml() {
  return '''
<?xml version="1.0" encoding="UTF-8"?>
$_atomHeader
  <id>urn:uuid:related</id>
  <title>More from Author</title>
  <updated>2024-04-01T00:00:00Z</updated>
  ${_entryXml(id: 'urn:uuid:other', title: 'Other Book by Jane')}
</feed>
''';
}

// ---------------------------------------------------------------------------
// 1. 端点常量
// ---------------------------------------------------------------------------

void _apiConstantTests() {
  group('FeedbooksApi 与源工程 constants/api.dart 一致', () {
    test('baseUrl 与 publicDomainUrl', () {
      expect(FeedbooksApi.baseUrl, 'https://catalog.feedbooks.com');
      expect(FeedbooksApi.publicDomainUrl, '/publicdomain/browse');
    });

    test('热门 / 最近 / 获奖 / 精选端点', () {
      expect(FeedbooksApi.popular, '/publicdomain/browse/top.atom');
      expect(FeedbooksApi.recent, '/publicdomain/browse/recent.atom');
      expect(FeedbooksApi.awards, '/publicdomain/browse/awards.atom');
      expect(
        FeedbooksApi.noteworthy,
        '/publicdomain/browse/homepage_selection.atom',
      );
    });

    test('六个分类端点都追加 ?cat=，主题代码与源工程一致', () {
      expect(
        FeedbooksApi.shortStory,
        '/publicdomain/browse/top.atom?cat=FBFIC029000',
      );
      expect(FeedbooksApi.sciFi, '/publicdomain/browse/top.atom?cat=FBFIC028000');
      expect(
        FeedbooksApi.actionAdventure,
        '/publicdomain/browse/top.atom?cat=FBFIC002000',
      );
      expect(
        FeedbooksApi.mystery,
        '/publicdomain/browse/top.atom?cat=FBFIC022000',
      );
      expect(
        FeedbooksApi.romance,
        '/publicdomain/browse/top.atom?cat=FBFIC027000',
      );
      expect(FeedbooksApi.horror, '/publicdomain/browse/top.atom?cat=FBFIC015000');
    });

    test('appName 是 OpenLeaf（下载子目录用它）', () {
      expect(FeedbooksApi.appName, 'OpenLeaf');
      expect(FeedbooksDownloadService.appName, 'OpenLeaf');
    });
  });
}

// ---------------------------------------------------------------------------
// 2. formatBytes
// ---------------------------------------------------------------------------

void _formatBytesTests() {
  group('FeedbooksFormat.formatBytes（源 constants/utils.dart）', () {
    test('0 字节返回 0.0，而且不带单位', () {
      expect(FeedbooksFormat.formatBytes(0, 1), '0.0');
    });

    test('小于 1KB 走 Bytes', () {
      expect(FeedbooksFormat.formatBytes(512, 1), '512.0 Bytes');
    });

    test('1024 字节是 1.0 KB', () {
      expect(FeedbooksFormat.formatBytes(1024, 1), '1.0 KB');
    });

    test('1536 字节是 1.5 KB', () {
      expect(FeedbooksFormat.formatBytes(1536, 1), '1.5 KB');
    });

    test('decimals 为 0 时不保留小数', () {
      expect(FeedbooksFormat.formatBytes(1536, 0), '2 KB');
    });

    test('5MB 走 MB 单位', () {
      expect(FeedbooksFormat.formatBytes(5 * 1024 * 1024, 1), '5.0 MB');
    });
  });
}

// ---------------------------------------------------------------------------
// 3. GData 转换（xml2json 5.3.6 契约）
// ---------------------------------------------------------------------------

Map<String, dynamic> _feedMap(String xml) {
  final Map<String, dynamic> gdata = FeedbooksGdataConverter().toGData(xml);
  return gdata['feed'] as Map<String, dynamic>;
}

Map<String, dynamic> _firstEntryMap(String xml) {
  final Object? entry = _feedMap(xml)['entry'];
  if (entry is List) return entry.first as Map<String, dynamic>;
  return entry! as Map<String, dynamic>;
}

void _gdataConverterTests() {
  group('FeedbooksGdataConverter：GData 键名契约', () {
    test('顶层带 version / encoding / feed', () {
      final Map<String, dynamic> gdata = FeedbooksGdataConverter().toGData(
        _popularFeedXml(),
      );
      expect(gdata.keys, containsAll(<String>['version', 'encoding', 'feed']));
      expect(gdata['version'], '1.0');
      expect(gdata['encoding'], 'UTF-8');
      expect(gdata['feed'], isA<Map<String, dynamic>>());
    });

    test('命名空间声明与 xml:lang', () {
      final Map<String, dynamic> feed = _feedMap(_popularFeedXml());
      expect(feed['xmlns'], 'http://www.w3.org/2005/Atom');
      expect(feed[r'xmlns$dcterms'], 'http://purl.org/dc/terms/');
      expect(feed[r'xmlns$opensearch'], 'http://a9.com/-/spec/opensearch/1.1/');
      expect(feed[r'xmlns$opds'], 'http://opds-spec.org/2010/catalog');
      expect(feed['xml:lang'], 'en');
      expect(feed['title'], <String, dynamic>{r'$t': 'Popular'});
    });

    test('opensearch 三个分页字段都在 feed 上', () {
      final Map<String, dynamic> feed = _feedMap(_popularFeedXml());
      expect(
        feed[r'opensearch$totalResults'],
        <String, dynamic>{r'$t': '35'},
      );
      expect(
        feed[r'opensearch$itemsPerPage'],
        <String, dynamic>{r'$t': '10'},
      );
      expect(feed[r'opensearch$startIndex'], <String, dynamic>{r'$t': '1'});
    });

    test('两个 entry 是 List，单个 entry 是 Map', () {
      expect(_feedMap(_popularFeedXml())['entry'], isA<List<dynamic>>());
      expect((_feedMap(_popularFeedXml())['entry'] as List<dynamic>).length, 2);
      final Map<String, dynamic> single = _feedMap('''
<?xml version="1.0"?>
$_atomHeader
  <entry><title>Only</title></entry>
</feed>''');
      expect(single['entry'], isA<Map<String, dynamic>>());
    });

    test('元素名里的冒号换成 \$（dcterms:language → dcterms\$language）', () {
      final Map<String, dynamic> entry = _firstEntryMap(_popularFeedXml());
      expect(entry[r'dcterms$language'], <String, dynamic>{r'$t': 'en'});
      expect(entry[r'dcterms$publisher'], <String, dynamic>{r'$t': 'Feedbooks'});
      expect(entry.containsKey('dcterms:language'), isFalse);
    });

    test('属性保留冒号：thr:count / opds:activeFacet', () {
      final List<dynamic> links =
          _feedMap(_popularFeedXml())['link'] as List<dynamic>;
      final Map<String, dynamic> facet = links.last as Map<String, dynamic>;
      expect(facet['thr:count'], '12');
      expect(facet['title'], 'Science Fiction');
      expect(facet['rel'], 'http://opds-spec.org/facet');
      expect(
        facet['href'],
        'https://catalog.feedbooks.com/publicdomain/browse/top.atom'
        '?cat=FBFIC028000',
      );

      final Map<String, dynamic> withFacet = FeedbooksGdataConverter().toGData(
        '<r><link rel="x" opds:activeFacet="true"/></r>',
      );
      expect(
        (withFacet['r'] as Map<String, dynamic>)['link'],
        <String, dynamic>{'rel': 'x', 'opds:activeFacet': 'true'},
      );
    });

    test('CDATA 落 __cdata，且内部实体不解码', () {
      final Map<String, dynamic> gdata = FeedbooksGdataConverter().toGData(
        '<r><x><![CDATA[raw <tag> &amp;]]></x></r>',
      );
      expect(
        (gdata['r'] as Map<String, dynamic>)['x'],
        <String, dynamic>{'__cdata': 'raw <tag> &amp;'},
      );
    });

    test('实体解码：&amp; &lt; &gt; &#65; &#x42; &quot;', () {
      final Map<String, dynamic> gdata = FeedbooksGdataConverter().toGData(
        '<r><x>&amp;&lt;tag&gt;&#65;&#x42;&quot;</x></r>',
      );
      expect(
        ((gdata['r'] as Map<String, dynamic>)['x'] as Map<String, dynamic>)[
            r'$t'],
        '&<tag>AB"',
      );
    });

    test('toGDataString 是 toGData 的 jsonEncode', () {
      const String xml = '<r><x>v</x></r>';
      expect(
        FeedbooksGdataConverter().toGDataString(xml),
        jsonEncode(<String, dynamic>{
          'r': <String, dynamic>{
            'x': <String, dynamic>{r'$t': 'v'},
          },
        }),
      );
    });
  });
}

// ---------------------------------------------------------------------------
// 4. 解析边界（真实 xml2json 5.3.6 的实测行为）
// ---------------------------------------------------------------------------

void _xmlParserEdgeCaseTests() {
  group('FeedbooksGdataConverter：解析边界', () {
    test('纯空白文本会被丢掉', () {
      final Map<String, dynamic> gdata = FeedbooksGdataConverter().toGData(
        '<r><x>   </x><y/><z></z></r>',
      );
      final Map<String, dynamic> r = gdata['r'] as Map<String, dynamic>;
      expect(r['x'], <String, dynamic>{});
      expect(r['y'], <String, dynamic>{});
      expect(r['z'], <String, dynamic>{});
    });

    test('混合内容只保留最后一段文本（last wins）', () {
      final Map<String, dynamic> gdata = FeedbooksGdataConverter().toGData(
        '<r><x>a<b>c</b>d</x></r>',
      );
      expect(
        (gdata['r'] as Map<String, dynamic>)['x'],
        <String, dynamic>{
          r'$t': 'd',
          'b': <String, dynamic>{r'$t': 'c'},
        },
      );
    });

    test('文本不会被 trim', () {
      final Map<String, dynamic> gdata = FeedbooksGdataConverter().toGData(
        '<r><x> a </x></r>',
      );
      expect(
        ((gdata['r'] as Map<String, dynamic>)['x'] as Map<String, dynamic>)[
            r'$t'],
        ' a ',
      );
    });

    test('重复子元素聚成 List，顺序保持', () {
      final Map<String, dynamic> gdata = FeedbooksGdataConverter().toGData(
        '<r><y>1</y><y>2</y><y>3</y></r>',
      );
      expect(
        (gdata['r'] as Map<String, dynamic>)['y'],
        <dynamic>[
          <String, dynamic>{r'$t': '1'},
          <String, dynamic>{r'$t': '2'},
          <String, dynamic>{r'$t': '3'},
        ],
      );
    });

    test('注释被跳过，DOCTYPE 被跳过', () {
      final Map<String, dynamic> gdata = FeedbooksGdataConverter().toGData(
        '<!DOCTYPE opds><r><!-- c --><x>v</x></r>',
      );
      expect(
        (gdata['r'] as Map<String, dynamic>)['x'],
        <String, dynamic>{r'$t': 'v'},
      );
    });

    test('自闭合元素带属性', () {
      final Map<String, dynamic> gdata = FeedbooksGdataConverter().toGData(
        '<r><x a="1" b="两"/></r>',
      );
      expect(
        (gdata['r'] as Map<String, dynamic>)['x'],
        <String, dynamic>{'a': '1', 'b': '两'},
      );
    });

    test('文本里的换行原样保留（源工程 xml2json 会变成两个反斜杠 + n）', () {
      final Map<String, dynamic> gdata = FeedbooksGdataConverter().toGData(
        '<r><summary>Line1\nLine2</summary></r>',
      );
      final String text =
          ((gdata['r'] as Map<String, dynamic>)['summary']
              as Map<String, dynamic>)[r'$t'] as String;
      expect(text, 'Line1\nLine2');
      expect(text.contains(r'\n'), isFalse);
    });

    test('只声明前缀命名空间时不写 xmlns（源工程会得到一个 List）', () {
      final Map<String, dynamic> feed = _feedMap(
        '<feed xmlns:dc="http://purl.org/dc/elements/1.1/"><id>i</id></feed>',
      );
      expect(feed.containsKey('xmlns'), isFalse);
      expect(feed[r'xmlns$dc'], 'http://purl.org/dc/elements/1.1/');
    });
  });
}

// ---------------------------------------------------------------------------
// 5. 模型映射
// ---------------------------------------------------------------------------

Map<String, dynamic> _text(String value) => <String, dynamic>{r'$t': value};

Map<String, dynamic> _linkJson(int index) => <String, dynamic>{
  'rel': 'rel-$index',
  'type': index == 3 ? 'application/epub+zip' : 'text/html',
  'title': 'link $index',
  'href': index == 1
      ? 'https://images.example.com/cover.jpg'
      : 'https://example.com/$index',
};

Map<String, dynamic> _entryJson({
  String id = 'urn:uuid:book-1',
  String title = 'Book One',
  Object? category,
  Object? link,
  Object? author,
  Object? schemaSeries,
}) => <String, dynamic>{
  'title': _text(title),
  'id': _text(id),
  'author':
      author ??
      <String, dynamic>{
        'name': _text('Jane Doe'),
        'uri': _text(r'https://catalog.feedbooks.com/catalog/author/123\&lang=en'),
      },
  'published': _text('2024-01-01T00:00:00Z'),
  'updated': _text('2024-01-02T00:00:00Z'),
  r'dcterms$language': _text('en'),
  r'dcterms$publisher': _text('Feedbooks'),
  r'dcterms$issued': _text('2024'),
  'summary': _text('A short summary of the book.'),
  'category':
      category ??
      <Object>[
        <String, dynamic>{
          'label': 'Fiction',
          'term': 'TH-Fiction',
          'scheme': 'http://thema.example',
        },
      ],
  'link':
      link ??
      <Object>[_linkJson(0), _linkJson(1), _linkJson(2), _linkJson(3)],
  r'schema$Series': ?schemaSeries,
};

void _modelMappingTests() {
  group('模型：GData → 实体', () {
    test('CategoryFeed 映射 version / encoding / feed', () {
      final FeedbooksCategoryFeed feed = FeedbooksCategoryFeed.fromJson(
        <String, dynamic>{
          'version': '1.0',
          'encoding': 'UTF-8',
          'feed': <String, dynamic>{
            'title': _text('Popular'),
            'entry': <Object>[],
          },
        },
      );
      expect(feed.version, '1.0');
      expect(feed.encoding, 'UTF-8');
      expect(feed.feed!.title!.t, 'Popular');
    });

    test('Feed 的九个命名空间字段 + xml:lang 一一映射', () {
      final FeedbooksFeed feed = FeedbooksFeed.fromJson(<String, dynamic>{
        'xml:lang': 'en',
        'xmlns': 'http://www.w3.org/2005/Atom',
        r'xmlns$dcterms': 'dcterms-uri',
        r'xmlns$thr': 'thr-uri',
        r'xmlns$app': 'app-uri',
        r'xmlns$opensearch': 'opensearch-uri',
        r'xmlns$opds': 'opds-uri',
        r'xmlns$xsi': 'xsi-uri',
        r'xmlns$odl': 'odl-uri',
        r'xmlns$schema': 'schema-uri',
        'id': _text('urn:uuid:feed'),
        'title': _text('Popular'),
        'updated': _text('2024-01-01T00:00:00Z'),
      });
      expect(feed.xmlLang, 'en');
      expect(feed.xmlns, 'http://www.w3.org/2005/Atom');
      expect(feed.xmlnsDcterms, 'dcterms-uri');
      expect(feed.xmlnsThr, 'thr-uri');
      expect(feed.xmlnsApp, 'app-uri');
      expect(feed.xmlnsOpensearch, 'opensearch-uri');
      expect(feed.xmlnsOpds, 'opds-uri');
      expect(feed.xmlnsXsi, 'xsi-uri');
      expect(feed.xmlnsOdl, 'odl-uri');
      expect(feed.xmlnsSchema, 'schema-uri');
      expect(feed.id!.t, 'urn:uuid:feed');
      expect(feed.link, isNull);
      expect(feed.entry, isNull);
    });

    test('Feed 的 opensearch 分页字段是指向 Id 的对象', () {
      final FeedbooksFeed feed = FeedbooksFeed.fromJson(<String, dynamic>{
        r'opensearch$totalResults': _text('35'),
        r'opensearch$itemsPerPage': _text('10'),
        r'opensearch$startIndex': _text('1'),
      });
      expect(feed.opensearchTotalResults!.t, '35');
      expect(feed.opensearchItemsPerPage!.t, '10');
      expect(feed.opensearchStartIndex!.t, '1');
    });

    test('Link 映射 rel / type / href / title / thr:count / opds:activeFacet', () {
      final FeedbooksLink link = FeedbooksLink.fromJson(<String, dynamic>{
        'rel': 'http://opds-spec.org/facet',
        'type': 'application/atom+xml',
        'href': 'https://catalog.feedbooks.com/x.atom',
        'title': 'Science Fiction',
        'thr:count': '12',
        'opds:activeFacet': 'true',
        'opds:facetGroup': 'Category',
      });
      expect(link.rel, 'http://opds-spec.org/facet');
      expect(link.type, 'application/atom+xml');
      expect(link.href, 'https://catalog.feedbooks.com/x.atom');
      expect(link.title, 'Science Fiction');
      expect(link.thrCount, '12');
      expect(link.opdsActiveFacet, 'true');
      expect(link.opdsFacetGroup, 'Category');
    });

    test('单个 entry 的 Map 会被兜底成只含一项的 List', () {
      final FeedbooksFeed feed = FeedbooksFeed.fromJson(<String, dynamic>{
        'entry': _entryJson(),
      });
      expect(feed.entry!.length, 1);
      expect(feed.entry!.first.title!.t, 'Book One');
    });

    test('Entry 的完整字段映射', () {
      final FeedbooksEntry entry = FeedbooksEntry.fromJson(_entryJson());
      expect(entry.title!.t, 'Book One');
      expect(entry.id!.t, 'urn:uuid:book-1');
      expect(entry.published!.t, '2024-01-01T00:00:00Z');
      expect(entry.updated!.t, '2024-01-02T00:00:00Z');
      expect(entry.dctermsLanguage!.t, 'en');
      expect(entry.dctermsPublisher!.t, 'Feedbooks');
      expect(entry.dctermsIssued!.t, '2024');
      expect(entry.summary!.t, 'A short summary of the book.');
      expect(entry.author!.name!.t, 'Jane Doe');
      expect(
        entry.author!.uri!.t,
        r'https://catalog.feedbooks.com/catalog/author/123\&lang=en',
      );
      expect(entry.category!.single.label, 'Fiction');
      expect(entry.link!.length, 4);
      // 源工程 UI 的硬编码约定：下标 1 是封面，下标 3 是 EPUB 下载地址。
      expect(entry.link![1].href, 'https://images.example.com/cover.jpg');
      expect(entry.link![3].href, 'https://example.com/3');
      expect(entry.link![3].type, 'application/epub+zip');
    });

    test('author 同时支持 List 与 Map 两种形状', () {
      final FeedbooksEntry fromList = FeedbooksEntry.fromJson(
        _entryJson(
          author: <Object>[
            <String, dynamic>{'name': _text('First'), 'uri': _text('u1')},
            <String, dynamic>{'name': _text('Second'), 'uri': _text('u2')},
          ],
        ),
      );
      expect(fromList.author!.name!.t, 'First');

      final FeedbooksEntry fromMap = FeedbooksEntry.fromJson(
        _entryJson(
          author: <String, dynamic>{'name': _text('Only'), 'uri': _text('u')},
        ),
      );
      expect(fromMap.author!.name!.t, 'Only');
    });

    test('category 单条 Map 时走兜底分支', () {
      final FeedbooksEntry entry = FeedbooksEntry.fromJson(
        _entryJson(
          category: <String, dynamic>{
            'label': 'Mystery',
            'term': 'TH-Mystery',
            'scheme': 'http://thema.example',
          },
        ),
      );
      expect(entry.category!.length, 1);
      expect(entry.category!.single.label, 'Mystery');
    });

    test('link 单条 Map 时被源工程的空 catch 吞掉，结果是空列表', () {
      final FeedbooksEntry entry = FeedbooksEntry.fromJson(
        _entryJson(link: <String, dynamic>{'rel': 'x', 'href': 'y'}),
      );
      expect(entry.link, isEmpty);
    });

    test('schemaSeries 用冒号键读取，所以真实 GData 的 \$ 键全是 null', () {
      // 真实 GData（元素名冒号 → $）：字段读不到。
      final FeedbooksEntry real = FeedbooksEntry.fromJson(
        _entryJson(
          schemaSeries: <String, dynamic>{
            r'schema$position': _text('1'),
            r'schema$name': _text('Series A'),
            r'schema$url': _text('https://series.example.com/a'),
          },
        ),
      );
      expect(real.schemaSeries, isNotNull);
      expect(real.schemaSeries!.schemaPosition, isNull);
      expect(real.schemaSeries!.schemaName, isNull);
      expect(real.schemaSeries!.schemaUrl, isNull);

      // 冒号键 + GData 的 Map 值 → 源工程 `as String?` 直接抛类型错误。
      expect(
        () => FeedbooksEntry.fromJson(
          _entryJson(
            schemaSeries: <String, dynamic>{'schema:position': _text('2')},
          ),
        ),
        throwsA(isA<TypeError>()),
      );

      // 冒号键 + 纯字符串时能读到 —— 证明键名不匹配才是主要 bug。
      final FeedbooksSchemaSeries colon = FeedbooksSchemaSeries.fromJson(
        <String, dynamic>{
          'schema:position': '2',
          'schema:name': 'Series B',
          'schema:url': 'https://series.example.com/b',
        },
      );
      expect(colon.schemaPosition, '2');
      expect(colon.schemaName, 'Series B');
      expect(colon.schemaUrl, 'https://series.example.com/b');
    });

    test('Entry.toJson / fromJson 往返（收藏持久化的契约）', () {
      final FeedbooksEntry entry = FeedbooksEntry.fromJson(_entryJson());
      final FeedbooksEntry restored = FeedbooksEntry.fromJson(entry.toJson());
      expect(restored.title!.t, 'Book One');
      expect(restored.id!.t, 'urn:uuid:book-1');
      expect(restored.author!.name!.t, 'Jane Doe');
      expect(restored.link!.length, 4);
      expect(restored.link![3].href, entry.link![3].href);
      expect(restored.category!.single.label, 'Fiction');
    });

    test('CategoryFeed.toJson 带上 version / encoding / feed', () {
      final FeedbooksCategoryFeed feed = FeedbooksCategoryFeed.fromJson(
        <String, dynamic>{
          'version': '1.0',
          'encoding': 'UTF-8',
          'feed': <String, dynamic>{'title': _text('Popular')},
        },
      );
      final Map<String, dynamic> json = feed.toJson();
      expect(json['version'], '1.0');
      expect(json['encoding'], 'UTF-8');
      expect(json['feed'], isA<Map<String, dynamic>>());
    });
  });
}

// ---------------------------------------------------------------------------
// 6. 仓储：端点、URL 处理、失败分类
// ---------------------------------------------------------------------------

void _repositoryTests() {
  group('仓储', () {
    test('首页热门走 /publicdomain/browse/top.atom', () async {
      final _FakeApi api = _FakeApi((_) => _atomBody(_popularFeedXml()));
      final FeedbooksRepositoryData result =
          await FeedbooksHomeRepository(api.dio).getPopularHomeFeed();
      expect(
        api.adapter.last.uri.toString(),
        'https://catalog.feedbooks.com/publicdomain/browse/top.atom',
      );
      expect(result.feed!.feed!.title!.t, 'Popular');
      expect(result.failure, isNull);
    });

    test('首页最近走 /publicdomain/browse/recent.atom', () async {
      final _FakeApi api = _FakeApi((_) => _atomBody(_recentFeedXml()));
      await FeedbooksHomeRepository(api.dio).getRecentHomeFeed();
      expect(
        api.adapter.last.uri.toString(),
        'https://catalog.feedbooks.com/publicdomain/browse/recent.atom',
      );
    });

    test('分类仓储先剥掉 baseUrl 再请求（feed 里的 href 是绝对地址）', () async {
      final _FakeApi api = _FakeApi((_) => _atomBody(_genreFeedXml(2, title: 'Sci')));
      final FeedbooksRepositoryData result = await FeedbooksExploreRepository(
        api.dio,
      ).getGenreFeed('${FeedbooksApi.baseUrl}${FeedbooksApi.sciFi}');
      expect(
        api.adapter.last.uri.toString(),
        'https://catalog.feedbooks.com/publicdomain/browse/top.atom'
        '?cat=FBFIC028000',
      );
      expect(api.adapter.last.uriQuery['cat'], 'FBFIC028000');
      expect(result.feed!.feed!.entry!.length, 2);
    });

    test('详情页的相关书同样剥掉 baseUrl', () async {
      final _FakeApi api = _FakeApi((_) => _atomBody(_relatedFeedXml()));
      await FeedbooksBookDetailsRepository(api.dio).getRelatedFeed(
        'https://catalog.feedbooks.com/catalog/author/123?lang=en',
      );
      expect(
        api.adapter.last.uri.toString(),
        'https://catalog.feedbooks.com/catalog/author/123?lang=en',
      );
      expect(api.adapter.last.uriQuery['lang'], 'en');
    });

    test('404 → notFound，description 是源工程的文案', () async {
      final _FakeApi api = _FakeApi((_) => _atomBody('nope', status: 404));
      final FeedbooksRepositoryData result =
          await FeedbooksHomeRepository(api.dio).getCategory('/missing.atom');
      expect(result.feed, isNull);
      expect(result.failure, FeedbooksHttpFailure.notFound);
      expect(result.failure!.description, '404 not found');
    });

    test('500 → unknown', () async {
      final _FakeApi api = _FakeApi((_) => _atomBody('boom', status: 500));
      final FeedbooksRepositoryData result =
          await FeedbooksHomeRepository(api.dio).getCategory('/boom.atom');
      expect(result.failure, FeedbooksHttpFailure.unknown);
      expect(result.failure!.description, 'Unknown error');
    });

    test('连不上（没有 response）也归到 unknown', () async {
      final _FakeApi api = _FakeApi((_RecordedRequest request) {
        throw DioException(
          requestOptions: RequestOptions(path: request.path),
          type: DioExceptionType.connectionError,
          error: 'offline',
        );
      });
      final FeedbooksRepositoryData result =
          await FeedbooksHomeRepository(api.dio).getCategory('/offline.atom');
      expect(result.failure, FeedbooksHttpFailure.unknown);
    });

    test('单 link 的 feed 会让模型层抛错（源工程同样不在 try 内）', () async {
      final _FakeApi api = _FakeApi(
        (_) => _atomBody(
          '<?xml version="1.0"?><feed xmlns="http://www.w3.org/2005/Atom">'
          '<title>t</title><link rel="self" href="h"/></feed>',
        ),
      );
      await expectLater(
        FeedbooksHomeRepository(api.dio).getCategory('/single-link.atom'),
        throwsA(anyOf(isA<TypeError>(), isA<NoSuchMethodError>())),
      );
    });
  });
}

// ---------------------------------------------------------------------------
// 7. 首页控制器
// ---------------------------------------------------------------------------

void _homeFeedControllerTests() {
  group('FeedbooksHomeFeedController', () {
    test('fetch 一次拉热门 + 最近，顺序与源工程一致', () async {
      final _FakeApi api = _FakeApi((_RecordedRequest request) {
        if (request.uri.path.contains('recent')) {
          return _atomBody(_recentFeedXml());
        }
        return _atomBody(_popularFeedXml());
      });
      final FeedbooksHomeFeedController controller = FeedbooksHomeFeedController(
        repository: FeedbooksHomeRepository(api.dio),
      );

      await controller.fetch();

      expect(controller.error, isNull);
      expect(controller.data!.popularFeed.feed!.title!.t, 'Popular');
      expect(controller.data!.recentFeed.feed!.title!.t, 'Recently Added');
      expect(api.adapter.requests.length, 2);
      expect(api.adapter.requests[0].uri.path, contains('/top.atom'));
      expect(api.adapter.requests[1].uri.path, contains('/recent.atom'));
    });

    test('热门 404 → error 是 failure.description', () async {
      final _FakeApi api = _FakeApi((_) => _atomBody('x', status: 404));
      final FeedbooksHomeFeedController controller = FeedbooksHomeFeedController(
        repository: FeedbooksHomeRepository(api.dio),
      );

      await controller.fetch();

      expect(controller.data, isNull);
      expect(controller.error, '404 not found');
    });

    test('最近 500 → error 是 Unknown error', () async {
      final _FakeApi api = _FakeApi((_RecordedRequest request) {
        if (request.uri.path.contains('recent')) {
          return _atomBody('x', status: 500);
        }
        return _atomBody(_popularFeedXml());
      });
      final FeedbooksHomeFeedController controller = FeedbooksHomeFeedController(
        repository: FeedbooksHomeRepository(api.dio),
      );

      await controller.fetch();

      expect(controller.error, 'Unknown error');
    });
  });
}

// ---------------------------------------------------------------------------
// 8. 分类控制器（分页规则）
// ---------------------------------------------------------------------------

void _genreFeedControllerTests() {
  group('FeedbooksGenreFeedController', () {
    test('fetch 取第一页', () async {
      final _FakeApi api = _FakeApi((_) => _atomBody(_genreFeedXml(3, title: 'Sci')));
      final FeedbooksGenreFeedController controller =
          FeedbooksGenreFeedController(
            repository: FeedbooksExploreRepository(api.dio),
            url: '${FeedbooksApi.baseUrl}${FeedbooksApi.sciFi}',
          );

      await controller.fetch();

      expect(controller.error, isNull);
      expect(controller.books.length, 3);
      expect(controller.data!.loadingMore, isFalse);
    });

    test('paginate 在 url 后追加 &page=N 并把结果接到列表尾部', () async {
      final _FakeApi api = _FakeApi((_RecordedRequest request) {
        final String? page = request.uriQuery['page'];
        if (page == null) return _atomBody(_genreFeedXml(2, title: 'Sci'));
        return _atomBody(_genreFeedXml(2, title: 'Sci'));
      });
      final FeedbooksGenreFeedController controller =
          FeedbooksGenreFeedController(
            repository: FeedbooksExploreRepository(api.dio),
            url: '${FeedbooksApi.baseUrl}${FeedbooksApi.sciFi}',
          );
      await controller.fetch();

      await controller.paginate(2);

      expect(api.adapter.requests.length, 2);
      expect(
        api.adapter.last.uri.toString(),
        'https://catalog.feedbooks.com/publicdomain/browse/top.atom'
        '?cat=FBFIC028000&page=2',
      );
      expect(api.adapter.last.uriQuery['page'], '2');
      expect(controller.books.length, 4);
      expect(controller.data!.loadingMore, isFalse);
    });

    test('没有第一页数据时 paginate 不发请求', () async {
      final _FakeApi api = _FakeApi((_) => _atomBody(_genreFeedXml(2, title: 'Sci')));
      final FeedbooksGenreFeedController controller =
          FeedbooksGenreFeedController(
            repository: FeedbooksExploreRepository(api.dio),
            url: '${FeedbooksApi.baseUrl}${FeedbooksApi.sciFi}',
          );

      await controller.paginate(2);

      expect(api.adapter.requests, isEmpty);
    });

    test('第一页 404 → error 是 404 not found', () async {
      final _FakeApi api = _FakeApi((_) => _atomBody('x', status: 404));
      final FeedbooksGenreFeedController controller =
          FeedbooksGenreFeedController(
            repository: FeedbooksExploreRepository(api.dio),
            url: '${FeedbooksApi.baseUrl}${FeedbooksApi.sciFi}',
          );

      await controller.fetch();

      expect(controller.error, '404 not found');
      expect(controller.books, isEmpty);
    });

    test('翻页失败时收起 loadingMore 并记录错误（源工程会一直转圈）', () async {
      final _FakeApi api = _FakeApi((_RecordedRequest request) {
        if (request.uriQuery['page'] != null) {
          return _atomBody('x', status: 500);
        }
        return _atomBody(_genreFeedXml(2, title: 'Sci'));
      });
      final FeedbooksGenreFeedController controller =
          FeedbooksGenreFeedController(
            repository: FeedbooksExploreRepository(api.dio),
            url: '${FeedbooksApi.baseUrl}${FeedbooksApi.sciFi}',
          );
      await controller.fetch();

      await controller.paginate(2);

      expect(controller.data!.loadingMore, isFalse);
      expect(controller.books.length, 2);
      expect(controller.error, 'Unknown error');
    });
  });
}

// ---------------------------------------------------------------------------
// 9. 详情控制器
// ---------------------------------------------------------------------------

void _bookDetailsControllerTests() {
  group('FeedbooksBookDetailsController', () {
    test('fetch 拿到同作者的其他书', () async {
      final _FakeApi api = _FakeApi((_) => _atomBody(_relatedFeedXml()));
      final FeedbooksBookDetailsController controller =
          FeedbooksBookDetailsController(
            repository: FeedbooksBookDetailsRepository(api.dio),
            url: 'https://catalog.feedbooks.com/catalog/author/123',
          );

      await controller.fetch();

      expect(controller.error, isNull);
      expect(controller.feed!.feed!.entry!.single.title!.t, 'Other Book by Jane');
    });

    test('404 → error 是 404 not found', () async {
      final _FakeApi api = _FakeApi((_) => _atomBody('x', status: 404));
      final FeedbooksBookDetailsController controller =
          FeedbooksBookDetailsController(
            repository: FeedbooksBookDetailsRepository(api.dio),
            url: 'https://catalog.feedbooks.com/catalog/author/123',
          );

      await controller.fetch();

      expect(controller.feed, isNull);
      expect(controller.error, '404 not found');
    });
  });
}

// ---------------------------------------------------------------------------
// 10. 下载本地库（源工程 sembast → shared_preferences）
// ---------------------------------------------------------------------------

void _downloadsStoreTests() {
  group('FeedbooksDownloadsLocalDataSourceImpl', () {
    test('addBook 落成源工程那张 5 字段 map', () async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final FeedbooksDownloadsLocalDataSourceImpl store =
          FeedbooksDownloadsLocalDataSourceImpl(preferences: prefs);

      await store.addBook(<String, dynamic>{
        'id': 'urn:1',
        'path': '/tmp/Book_One.epub',
        'image': 'https://images.example.com/1.jpg',
        'size': '1.2 MB',
        'name': 'Book One',
      }, 'urn:1');

      final Map<String, dynamic> raw =
          jsonDecode(prefs.getString(FeedbooksDownloadsLocalDataSourceImpl.storageKey)!)
              as Map<String, dynamic>;
      expect(raw.keys, <String>['urn:1']);
      expect(
        (raw['urn:1'] as Map<String, dynamic>).keys,
        containsAll(<String>['id', 'path', 'image', 'size', 'name']),
      );
      expect((raw['urn:1'] as Map<String, dynamic>)['size'], '1.2 MB');
    });

    test('同 id 再次 addBook 是浅合并（源工程 merge: true）', () async {
      final FeedbooksDownloadsLocalDataSourceImpl store =
          FeedbooksDownloadsLocalDataSourceImpl(
            preferences: await SharedPreferences.getInstance(),
          );
      await store.addBook(<String, dynamic>{
        'id': 'urn:1',
        'path': '/tmp/a.epub',
        'name': 'Book One',
      }, 'urn:1');

      await store.addBook(<String, dynamic>{'size': '2.0 MB'}, 'urn:1');

      final Map<String, dynamic>? book = await store.fetchBook('urn:1');
      expect(book!['path'], '/tmp/a.epub');
      expect(book['name'], 'Book One');
      expect(book['size'], '2.0 MB');
    });

    test('deleteBook 与 deleteAllBooksWithId 等价', () async {
      final FeedbooksDownloadsLocalDataSourceImpl store =
          FeedbooksDownloadsLocalDataSourceImpl(
            preferences: await SharedPreferences.getInstance(),
          );
      await store.addBook(<String, dynamic>{'id': 'a'}, 'a');
      await store.addBook(<String, dynamic>{'id': 'b'}, 'b');

      await store.deleteAllBooksWithId('a');

      expect(await store.downloadList(), hasLength(1));
      expect((await store.downloadList()).single['id'], 'b');
    });

    test('clearBooks 清空存储', () async {
      final FeedbooksDownloadsLocalDataSourceImpl store =
          FeedbooksDownloadsLocalDataSourceImpl(
            preferences: await SharedPreferences.getInstance(),
          );
      await store.addBook(<String, dynamic>{'id': 'a'}, 'a');

      await store.clearBooks();

      expect(await store.downloadList(), isEmpty);
    });

    test('downloadList 保持插入顺序', () async {
      final FeedbooksDownloadsLocalDataSourceImpl store =
          FeedbooksDownloadsLocalDataSourceImpl(
            preferences: await SharedPreferences.getInstance(),
          );
      await store.addBook(<String, dynamic>{'id': 'first'}, 'first');
      await store.addBook(<String, dynamic>{'id': 'second'}, 'second');

      final List<Map<String, dynamic>> list = await store.downloadList();

      expect(list.map((Map<String, dynamic> e) => e['id']).toList(), <String>[
        'first',
        'second',
      ]);
    });

    test('订阅时会补发当前快照（对应 sembast onSnapshots）', () async {
      final FeedbooksDownloadsLocalDataSourceImpl store =
          FeedbooksDownloadsLocalDataSourceImpl(
            preferences: await SharedPreferences.getInstance(),
          );
      await store.addBook(<String, dynamic>{'id': 'a'}, 'a');

      final List<int> lengths = <int>[];
      final StreamSubscription<List<Map<String, dynamic>>> subscription =
          (await store.downloadListStream()).listen(
            (List<Map<String, dynamic>> records) => lengths.add(records.length),
          );
      await pumpEventQueue();
      await subscription.cancel();

      expect(lengths, <int>[1]);
    });

    test('写入后流会推送新列表', () async {
      final FeedbooksDownloadsLocalDataSourceImpl store =
          FeedbooksDownloadsLocalDataSourceImpl(
            preferences: await SharedPreferences.getInstance(),
          );

      final List<int> lengths = <int>[];
      final StreamSubscription<List<Map<String, dynamic>>> subscription =
          (await store.downloadListStream()).listen(
            (List<Map<String, dynamic>> records) => lengths.add(records.length),
          );
      await pumpEventQueue();
      await store.addBook(<String, dynamic>{'id': 'a'}, 'a');
      await pumpEventQueue();
      await subscription.cancel();

      expect(lengths, <int>[0, 1]);
    });

    test('FeedbooksDownloadRecord 与源工程的 map 键一一对应', () {
      const FeedbooksDownloadRecord record = FeedbooksDownloadRecord(
        id: 'urn:1',
        path: '/tmp/a.epub',
        image: 'https://x/1.jpg',
        size: '1.2 MB',
        name: 'Book One',
      );
      expect(record.toMap(), <String, dynamic>{
        'id': 'urn:1',
        'path': '/tmp/a.epub',
        'image': 'https://x/1.jpg',
        'size': '1.2 MB',
        'name': 'Book One',
      });
      final FeedbooksDownloadRecord restored = FeedbooksDownloadRecord.fromMap(
        record.toMap(),
      );
      expect(restored.name, 'Book One');
      expect(restored.size, '1.2 MB');
    });
  });
}

// ---------------------------------------------------------------------------
// 11. 收藏本地库
// ---------------------------------------------------------------------------

void _favoritesStoreTests() {
  group('FeedbooksFavoritesLocalDataSourceImpl', () {
    test('addBook 存的是 Entry.toJson()', () async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final FeedbooksFavoritesLocalDataSourceImpl store =
          FeedbooksFavoritesLocalDataSourceImpl(preferences: prefs);
      final FeedbooksEntry entry = FeedbooksEntry.fromJson(_entryJson());

      await store.addBook(entry, 'urn:uuid:book-1');

      final Map<String, dynamic> raw =
          jsonDecode(prefs.getString(FeedbooksFavoritesLocalDataSourceImpl.storageKey)!)
              as Map<String, dynamic>;
      final Map<String, dynamic> stored =
          raw['urn:uuid:book-1'] as Map<String, dynamic>;
      expect(stored['title'], <String, dynamic>{r'$t': 'Book One'});
      expect(
        (stored['link'] as List<dynamic>).length,
        4,
      );
    });

    test('订阅时补发当前收藏，写入后再推一次', () async {
      final FeedbooksFavoritesLocalDataSourceImpl store =
          FeedbooksFavoritesLocalDataSourceImpl(
            preferences: await SharedPreferences.getInstance(),
          );
      final FeedbooksEntry entry = FeedbooksEntry.fromJson(_entryJson());
      await store.addBook(entry, 'urn:uuid:book-1');

      final List<int> lengths = <int>[];
      final StreamSubscription<List<FeedbooksEntry>> subscription =
          (await store.favoritesListStream()).listen(
            (List<FeedbooksEntry> favorites) => lengths.add(favorites.length),
          );
      await pumpEventQueue();
      await store.addBook(
        FeedbooksEntry.fromJson(_entryJson(id: 'urn:uuid:book-2', title: 'Book Two')),
        'urn:uuid:book-2',
      );
      await pumpEventQueue();
      await subscription.cancel();

      expect(lengths, <int>[1, 2]);
    });

    test('deleteBook 删除单条，clearBooks 清空', () async {
      final FeedbooksFavoritesLocalDataSourceImpl store =
          FeedbooksFavoritesLocalDataSourceImpl(
            preferences: await SharedPreferences.getInstance(),
          );
      await store.addBook(FeedbooksEntry.fromJson(_entryJson()), 'a');
      await store.addBook(
        FeedbooksEntry.fromJson(_entryJson(id: 'b', title: 'Book Two')),
        'b',
      );

      await store.deleteBook('a');

      final List<FeedbooksEntry> afterDelete = <FeedbooksEntry>[];
      await for (final List<FeedbooksEntry> favorites
          in (await store.favoritesListStream()).take(1)) {
        afterDelete.addAll(favorites);
      }
      expect(afterDelete.single.id!.t, 'b');

      await store.clearBooks();
      final List<FeedbooksEntry> afterClear = <FeedbooksEntry>[];
      await for (final List<FeedbooksEntry> favorites
          in (await store.favoritesListStream()).take(1)) {
        afterClear.addAll(favorites);
      }
      expect(afterClear, isEmpty);
    });

    test('控制器 load() 之后能读到已有收藏', () async {
      final FeedbooksFavoritesLocalDataSourceImpl store =
          FeedbooksFavoritesLocalDataSourceImpl(
            preferences: await SharedPreferences.getInstance(),
          );
      final FeedbooksEntry entry = FeedbooksEntry.fromJson(_entryJson());
      await store.addBook(entry, 'urn:uuid:book-1');
      final FeedbooksFavoritesController controller =
          FeedbooksFavoritesController(
            repository: FeedbooksFavoritesRepositoryImpl(store),
          );

      await controller.load();
      await pumpEventQueue();

      expect(controller.favorites.single.title!.t, 'Book One');
      controller.dispose();
    });
  });
}

// ---------------------------------------------------------------------------
// 12. 下载服务
// ---------------------------------------------------------------------------

void _downloadServiceTests() {
  group('FeedbooksDownloadService', () {
    test('文件名把空格换成下划线，并还原 \\\' 转义', () {
      final FeedbooksDownloadService service = FeedbooksDownloadService(
        dio: createFeedbooksDio(),
      );
      expect(service.fileNameFor('My Book'), 'My_Book');
      expect(service.fileNameFor("Author\\'s Book"), "Author's_Book");
      expect(service.fileNameFor('A  B'), 'A__B');
    });

    test('落盘在 <documents>/OpenLeaf/<fileName>.epub', () async {
      final Directory temp = await Directory.systemTemp.createTemp('fb_path');
      addTearDown(() async => temp.delete(recursive: true));
      final FeedbooksDownloadService service = FeedbooksDownloadService(
        dio: createFeedbooksDio(),
        directoryProvider: () async => temp,
      );

      final String path = await service.filePathFor('Book One');

      expect(path, startsWith(temp.path));
      expect(
        path,
        endsWith(
          '${Platform.pathSeparator}OpenLeaf${Platform.pathSeparator}Book_One.epub',
        ),
      );
    });

    test('下载完成后记录体积 / 路径 / 封面 / 名称', () async {
      final Directory temp = await Directory.systemTemp.createTemp('fb_dl');
      addTearDown(() async => temp.delete(recursive: true));
      final _FakeApi api = _FakeApi((_) => _epubBody('abc'));
      final FeedbooksDownloadService service = FeedbooksDownloadService(
        dio: api.dio,
        directoryProvider: () async => temp,
      );

      final FeedbooksDownloadRecord record = await service.download(
        url: 'https://downloads.example.com/book.epub',
        id: 'urn:uuid:book-1',
        name: 'Book One',
        image: 'https://images.example.com/cover.jpg',
      );

      expect(record.id, 'urn:uuid:book-1');
      expect(record.name, 'Book One');
      expect(record.image, 'https://images.example.com/cover.jpg');
      expect(record.size, '3.0 Bytes');
      expect(await File(record.path).readAsString(), 'abc');
      expect(record.path, await service.filePathFor('Book One'));
    });

    test('目标文件已存在时先删掉再写（不追加）', () async {
      final Directory temp = await Directory.systemTemp.createTemp('fb_rep');
      addTearDown(() async => temp.delete(recursive: true));
      final FeedbooksDownloadService service = FeedbooksDownloadService(
        dio: _FakeApi((_) => _epubBody('new')).dio,
        directoryProvider: () async => temp,
      );
      final String path = await service.filePathFor('Book One');
      await Directory(File(path).parent.path).create(recursive: true);
      await File(path).writeAsString('old-content');

      final FeedbooksDownloadRecord record = await service.download(
        url: 'https://downloads.example.com/book.epub',
        id: 'id',
        name: 'Book One',
        image: '',
      );

      expect(await File(record.path).readAsString(), 'new');
    });
  });
}

// ---------------------------------------------------------------------------
// 13. 共享 widget
// ---------------------------------------------------------------------------

FeedbooksEntry _entryFrom({
  String id = 'urn:uuid:book-1',
  String title = 'Book One',
  String summary = 'A short summary of the book.',
}) => FeedbooksEntry.fromJson(_entryJson(id: id, title: title)
  ..['summary'] = _text(summary));

void _sharedWidgetTests() {
  group('共享 widget', () {
    testWidgets('封面在测试里走 debugBuilder，不建网络图', (WidgetTester tester) async {
      FeedbooksCoverImage.debugBuilder =
          (BuildContext context, String url) => Text('cover:$url');
      await tester.pumpWidget(
        const MaterialApp(
          home: FeedbooksCoverImage(url: 'https://x/cover.jpg'),
        ),
      );
      expect(find.text('cover:https://x/cover.jpg'), findsOneWidget);
    });

    testWidgets('BookListItem 显示标题、作者、截断到 100 字的简介', (
      WidgetTester tester,
    ) async {
      final String longSummary = 'a' * 150;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeedbooksBookListItem(
              entry: _entryFrom(summary: longSummary),
            ),
          ),
        ),
      );

      expect(find.text('Book One'), findsOneWidget);
      // 头部作者 + 同作者书列的作者会出现两次。
      expect(find.text('Jane Doe'), findsWidgets);
      expect(find.text('${'a' * 100}...'), findsOneWidget);
    });

    testWidgets('DescriptionText 超过 300 字才出现 show more / show less', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: FeedbooksDescriptionText(text: 'x' * 100))),
      );
      expect(find.text('show more'), findsNothing);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: FeedbooksDescriptionText(text: 'y' * 400)),
        ),
      );
      expect(find.text('show more'), findsOneWidget);
      expect(find.text('${'y' * 300}...'), findsOneWidget);

      await tester.tap(find.text('show more'));
      await tester.pump();
      expect(find.text('show less'), findsOneWidget);
      expect(find.text('y' * 400), findsOneWidget);
    });

    testWidgets('GenreRow 跳过前 10 个 OPDS 导航 link', (WidgetTester tester) async {
      final List<FeedbooksLink> links = List<FeedbooksLink>.generate(
        11,
        (int i) => FeedbooksLink(title: 'Tag $i', href: 'https://x/$i'),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeedbooksGenreRow(
              popular: FeedbooksCategoryFeed(feed: FeedbooksFeed(link: links)),
            ),
          ),
        ),
      );

      expect(find.text('Tag 9'), findsNothing);
      expect(find.text('Tag 10'), findsOneWidget);
    });

    testWidgets('ErrorWidget 的两套文案', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: FeedbooksErrorWidget(refreshCallBack: () {})),
        ),
      );
      expect(
        find.text('Could not load this page. \nPlease try again.'),
        findsOneWidget,
      );
      expect(find.text('TRY AGAIN'), findsOneWidget);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeedbooksErrorWidget(refreshCallBack: () {}, isConnection: true),
          ),
        ),
      );
      expect(
        find.text(
          'There is a problem with your internet connection. \nPlease try again.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('EmptyView 文案', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: FeedbooksEmptyView())),
      );
      expect(find.text('Nothing is here'), findsOneWidget);
    });
  });
}

// ---------------------------------------------------------------------------
// 14. 页面
// ---------------------------------------------------------------------------

void _pageTests() {
  group('页面', () {
    testWidgets('首页：AppBar 用 OpenLeaf，三段标题都在，分类 chip 只渲染第 11 个 link', (
      WidgetTester tester,
    ) async {
      final _FakeApi api = _FakeApi((_RecordedRequest request) {
        if (request.uri.path.contains('recent')) {
          return _atomBody(_recentFeedXml());
        }
        return _atomBody(_popularFeedXml());
      });

      await tester.pumpWidget(
        MaterialApp(home: FeedbooksHomePage(dio: api.dio)),
      );
      await tester.pumpAndSettle();

      expect(find.text('OpenLeaf'), findsOneWidget);
      expect(find.text('Categories'), findsOneWidget);
      expect(find.text('Recently Added'), findsOneWidget);
      expect(find.text('Science Fiction'), findsOneWidget);
      expect(find.text('Nav Tag 9'), findsNothing);
      expect(find.text('Latest Arrival'), findsOneWidget);
      expect(api.adapter.requests.length, 2);
    });

    testWidgets('首页失败态显示 TRY AGAIN', (WidgetTester tester) async {
      final _FakeApi api = _FakeApi((_) => _atomBody('x', status: 404));

      await tester.pumpWidget(
        MaterialApp(home: FeedbooksHomePage(dio: api.dio)),
      );
      await tester.pumpAndSettle();

      expect(find.text('TRY AGAIN'), findsOneWidget);
      expect(find.text('Could not load this page. \nPlease try again.'), findsOneWidget);
    });

    testWidgets('分类页：标题进 AppBar，列表渲染书目', (WidgetTester tester) async {
      final _FakeApi api = _FakeApi(
        (_) => _atomBody(_genreFeedXml(3, title: 'Science Fiction')),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: FeedbooksGenrePage(
            title: 'Science Fiction',
            url: '${FeedbooksApi.baseUrl}${FeedbooksApi.sciFi}',
            dio: api.dio,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Science Fiction'), findsOneWidget);
      expect(find.text('Genre Book 0'), findsOneWidget);
      expect(find.text('Genre Book 2'), findsOneWidget);
    });

    testWidgets('Explore：只有第 11 个 link 成段，书目不足 10 本时隐藏 See All', (
      WidgetTester tester,
    ) async {
      final _FakeApi api = _FakeApi((_RecordedRequest request) {
        if (request.uriQuery['cat'] != null) {
          return _atomBody(_genreFeedXml(3, title: 'Science Fiction'));
        }
        return _atomBody(_popularFeedXml());
      });

      await tester.pumpWidget(
        MaterialApp(home: FeedbooksExplorePage(dio: api.dio)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Science Fiction'), findsOneWidget);
      expect(find.text('Nav Tag 0'), findsNothing);
      expect(find.text('See All'), findsNothing);
    });

    testWidgets('Explore：书目达到 10 本时显示一次 See All', (
      WidgetTester tester,
    ) async {
      final _FakeApi api = _FakeApi((_RecordedRequest request) {
        if (request.uriQuery['cat'] != null) {
          return _atomBody(_genreFeedXml(12, title: 'Science Fiction'));
        }
        return _atomBody(_popularFeedXml());
      });

      await tester.pumpWidget(
        MaterialApp(home: FeedbooksExplorePage(dio: api.dio)),
      );
      await tester.pumpAndSettle();

      expect(find.text('See All'), findsOneWidget);
    });

    testWidgets('详情页：字段、两个分区、同作者的其他书、作者链接去掉 \\&lang=en', (
      WidgetTester tester,
    ) async {
      final _FakeApi api = _FakeApi((_) => _atomBody(_relatedFeedXml()));
      String? shared;
      final FeedbooksEntry entry = FeedbooksEntry.fromJson(_entryJson());

      await tester.pumpWidget(
        MaterialApp(
          home: FeedbooksBookDetailsPage(
            entry: entry,
            dio: api.dio,
            shareText: (String text) async => shared = text,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Book One'), findsWidgets);
      // 作者名在详情页出现两次：顶部作者栏 + “More from Author” 分区标题下方的作者名。
      expect(find.text('Jane Doe'), findsWidgets);
      expect(find.text('Fiction'), findsOneWidget);
      expect(find.text('Book Description'), findsOneWidget);
      expect(find.text('More from Author'), findsOneWidget);
      expect(find.text('Other Book by Jane'), findsOneWidget);
      expect(find.text('DOWNLOAD'), findsOneWidget);
      // 作者链接：源工程 `replaceAll(r'\&lang=en', '')`。
      expect(
        api.adapter.last.uri.toString(),
        'https://catalog.feedbooks.com/catalog/author/123',
      );

      await tester.tap(find.byIcon(Icons.share));
      await tester.pump();
      expect(
        shared,
        'Book One by Jane Doe'
        'Read/Download Book One from'
        ' https://example.com/3.',
      );
    });

    testWidgets('详情页：收藏按钮写入本地库，已下载时按钮变 READ BOOK', (
      WidgetTester tester,
    ) async {
      final _FakeApi api = _FakeApi((_) => _atomBody(_relatedFeedXml()));
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final FeedbooksDownloadsLocalDataSourceImpl downloadsStore =
          FeedbooksDownloadsLocalDataSourceImpl(preferences: prefs);
      await downloadsStore.addBook(<String, dynamic>{
        'id': 'urn:uuid:book-1',
        'path': '/tmp/Book_One.epub',
        'image': 'https://images.example.com/cover.jpg',
        'size': '1.2 MB',
        'name': 'Book One',
      }, 'urn:uuid:book-1');
      final FeedbooksDownloadsController downloads =
          FeedbooksDownloadsController(
            repository: FeedbooksDownloadsRepositoryImpl(downloadsStore),
          );
      await downloads.load();

      await tester.pumpWidget(
        MaterialApp(
          home: FeedbooksBookDetailsPage(
            entry: FeedbooksEntry.fromJson(_entryJson()),
            dio: api.dio,
            downloads: downloads,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('READ BOOK'), findsOneWidget);
      expect(find.text('DOWNLOAD'), findsNothing);

      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pumpAndSettle();

      final Map<String, dynamic> raw =
          jsonDecode(prefs.getString(FeedbooksFavoritesLocalDataSourceImpl.storageKey)!)
              as Map<String, dynamic>;
      expect(raw.keys, contains('urn:uuid:book-1'));
    });

    testWidgets('下载页：显示记录，左滑删除', (WidgetTester tester) async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final FeedbooksDownloadsLocalDataSourceImpl store =
          FeedbooksDownloadsLocalDataSourceImpl(preferences: prefs);
      await store.addBook(<String, dynamic>{
        'id': 'urn:1',
        'path': '/tmp/Book_One.epub',
        'image': 'https://images.example.com/cover.jpg',
        'size': '1.2 MB',
        'name': 'Book One',
      }, 'urn:1');
      final FeedbooksDownloadsController downloads =
          FeedbooksDownloadsController(
            repository: FeedbooksDownloadsRepositoryImpl(store),
          );
      await downloads.load();

      await tester.pumpWidget(
        MaterialApp(home: FeedbooksDownloadsPage(downloads: downloads)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Downloads'), findsOneWidget);
      expect(find.text('Book One'), findsOneWidget);
      expect(find.text('COMPLETED'), findsOneWidget);
      expect(find.text('1.2 MB'), findsOneWidget);

      await tester.drag(find.text('Book One'), const Offset(-600.0, 0.0));
      await tester.pumpAndSettle();

      expect(find.text('Book One'), findsNothing);
      expect(await store.downloadList(), isEmpty);
    });

    testWidgets('收藏页：空态与列表态', (WidgetTester tester) async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final FeedbooksFavoritesLocalDataSourceImpl store =
          FeedbooksFavoritesLocalDataSourceImpl(preferences: prefs);
      final FeedbooksFavoritesController favorites =
          FeedbooksFavoritesController(
            repository: FeedbooksFavoritesRepositoryImpl(store),
          );
      await favorites.load();

      await tester.pumpWidget(
        MaterialApp(home: FeedbooksFavoritesPage(favorites: favorites)),
      );
      await tester.pumpAndSettle();
      expect(find.text('Favorites'), findsOneWidget);
      expect(find.text('Nothing is here'), findsOneWidget);

      await tester.runAsync(
        () => store.addBook(
          FeedbooksEntry.fromJson(_entryJson()),
          'urn:uuid:book-1',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Book One'), findsOneWidget);
      expect(find.text('Nothing is here'), findsNothing);
    });
  });
}
