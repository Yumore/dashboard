// Network-free tests for the ported `book` reading module
// (lib/features/reading/book/**).
//
// Every test runs against hand-written HTML/JSON fixtures and injected
// transports: no test touches the real network. Endpoint paths, request
// parameter names, rule-engine evaluation results, HTML/JSON field names,
// model mapping and business branches are asserted with the exact values the
// source project used.

import 'dart:convert';

import 'package:dashboard/features/reading/book/analyzer/css_analyzer.dart';
import 'package:dashboard/features/reading/book/analyzer/js_analyzer.dart';
import 'package:dashboard/features/reading/book/analyzer/json_analyzer.dart';
import 'package:dashboard/features/reading/book/analyzer/regex_analyzer.dart';
import 'package:dashboard/features/reading/book/analyzer/xpath_analyzer.dart';
import 'package:dashboard/features/reading/book/engine/book_source_engine.dart';
import 'package:dashboard/features/reading/book/engine/progress_mapper.dart';
import 'package:dashboard/features/reading/book/entity/chapter_toc_entry.dart';
import 'package:dashboard/features/reading/book/entity/read_page.dart';
import 'package:dashboard/features/reading/book/entity/text_line.dart';
import 'package:dashboard/features/reading/book/entity/text_page.dart';
import 'package:dashboard/features/reading/book/importer/source_importer.dart';
import 'package:dashboard/features/reading/book/model/book_source.dart';
import 'package:dashboard/features/reading/book/model/explore_kind.dart';
import 'package:dashboard/features/reading/book/model/search_book.dart';
import 'package:dashboard/features/reading/book/model/source_chapter.dart';
import 'package:dashboard/features/reading/book/net/analyze_request.dart';
import 'package:dashboard/features/reading/book/net/analyze_url.dart';
import 'package:dashboard/features/reading/book/net/source_response.dart';
import 'package:dashboard/features/reading/book/reader/chapter_content_loader.dart';
import 'package:dashboard/features/reading/book/reader/text_paginator.dart';
import 'package:dashboard/features/reading/book/repo/yck_item.dart';
import 'package:dashboard/features/reading/book/repo/yck_kind.dart';
import 'package:dashboard/features/reading/book/repo/yck_list_result.dart';
import 'package:dashboard/features/reading/book/repo/yckceo_repo.dart';
import 'package:dashboard/features/reading/book/repository/chapter_repository.dart';
import 'package:dashboard/features/reading/book/rule/analyze_rule.dart';
import 'package:dashboard/features/reading/book/util/book_id.dart';
import 'package:dashboard/features/reading/book/util/book_local_store.dart';
import 'package:dashboard/features/reading/book/util/text_clean.dart';
import 'package:dashboard/features/reading/book/util/url_join.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

const String kSearchHtml = '''
<div class="item">
  <h3><a href="/book/1">书名一</a></h3>
  <span class="author">作者：张三</span>
  <span class="kind">玄幻</span>
  <img src="/loading.jpg" data-src="/covers/1.jpg" />
</div>
<div class="item">
  <h3><a href="/book/2">书名二</a></h3>
  <span class="author">作者：李四</span>
  <span class="kind">都市</span>
  <img src="/covers/2.jpg" />
</div>
<div class="item">
  <h3><a href="/book/3">请输入验证码</a></h3>
</div>
''';

Map<String, dynamic> legadoSource({
  String url = 'https://fixture.local',
  String name = '测试源',
  String searchUrl = 'https://fixture.local/search?q={{key}}&page={{page}}',
  String exploreUrl = '',
  String header = '',
  Map<String, dynamic> ruleSearch = const {},
  Map<String, dynamic> ruleExplore = const {},
  Map<String, dynamic> ruleBookInfo = const {},
  Map<String, dynamic> ruleToc = const {},
  Map<String, dynamic> ruleContent = const {},
}) {
  return <String, dynamic>{
    'bookSourceUrl': url,
    'bookSourceName': name,
    'bookSourceGroup': '测试',
    'enabled': true,
    'searchUrl': searchUrl,
    'exploreUrl': exploreUrl,
    'header': header,
    'ruleSearch': ruleSearch,
    'ruleExplore': ruleExplore,
    'ruleBookInfo': ruleBookInfo,
    'ruleToc': ruleToc,
    'ruleContent': ruleContent,
  };
}

BookSource sourceFor({
  String url = 'https://fixture.local',
  String searchUrl = 'https://fixture.local/search?q={{key}}&page={{page}}',
  String exploreUrl = '',
  String header = '',
  Map<String, dynamic> ruleSearch = const {},
  Map<String, dynamic> ruleExplore = const {},
  Map<String, dynamic> ruleBookInfo = const {},
  Map<String, dynamic> ruleToc = const {},
  Map<String, dynamic> ruleContent = const {},
}) {
  return BookSource.fromLegadoJson(legadoSource(
    url: url,
    searchUrl: searchUrl,
    exploreUrl: exploreUrl,
    header: header,
    ruleSearch: ruleSearch,
    ruleExplore: ruleExplore,
    ruleBookInfo: ruleBookInfo,
    ruleToc: ruleToc,
    ruleContent: ruleContent,
  ));
}

/// Shared search rules used by the search/explore engine groups.
final Map<String, dynamic> searchRules = <String, dynamic>{
  'bookList': '.item',
  'name': 'h3 a@text',
  'author': '.author@text',
  'kind': '.kind@text',
  'coverUrl': 'img@src',
  'bookUrl': 'a@href',
  'checkKeyWord': '验证码',
};

/// Installs a deterministic transport into [AnalyzeUrl.fetchOverride] so the
/// engine never opens a socket.
class _FakeTransport {
  final List<AnalyzeRequest> requests = <AnalyzeRequest>[];
  SourceResponse Function(AnalyzeRequest request)? handler;

  void install() {
    AnalyzeUrl.fetchOverride = (AnalyzeRequest request) async {
      requests.add(request);
      final h = handler;
      if (h == null) {
        throw StateError('unexpected request: ${request.url}');
      }
      return h(request);
    };
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeTransport fake;

  setUp(() async {
    fake = _FakeTransport()..install();
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await SpUtil.getInstance();
  });

  tearDown(() {
    AnalyzeUrl.fetchOverride = null;
  });

  // -------------------------------------------------------------------------
  group('SourceImporter', () {
    test('parses a single Legado source object', () {
      final result = SourceImporter.parseJson(jsonEncode(legadoSource()));
      expect(result.sources.length, 1);
      expect(result.sources.first.bookSourceName, '测试源');
      expect(result.sources.first.bookSourceUrl, 'https://fixture.local');
      // Original payload is preserved verbatim for lossless round-tripping.
      expect(result.sources.first.rawJson, contains('bookSourceUrl'));
      expect(result.duplicatesInBatch, 0);
    });

    test('parses an array of sources in order', () {
      final payload = jsonEncode(<Map<String, dynamic>>[
        legadoSource(url: 'https://a.local', name: 'A'),
        legadoSource(url: 'https://b.local', name: 'B'),
      ]);
      final result = SourceImporter.parseJson(payload);
      expect(result.sources.map((e) => e.bookSourceName).toList(), ['A', 'B']);
    });

    test('collapses duplicate bookSourceUrl keeping the last one', () {
      final payload = jsonEncode(<Map<String, dynamic>>[
        legadoSource(name: 'A1'),
        legadoSource(name: 'A2'),
      ]);
      final result = SourceImporter.parseJson(payload);
      expect(result.sources.length, 1);
      expect(result.duplicatesInBatch, 1);
      expect(result.sources.first.bookSourceName, 'A2');
    });

    test('unwraps a nested data envelope', () {
      final payload = jsonEncode(<String, dynamic>{
        'data': <Map<String, dynamic>>[
          legadoSource(name: '嵌套源'),
        ],
      });
      final result = SourceImporter.parseJson(payload);
      expect(result.sources.length, 1);
      expect(result.sources.first.bookSourceName, '嵌套源');
    });

    test('maps Legado RSS keys onto BookSource and tags the group', () {
      final payload = jsonEncode(<Map<String, dynamic>>[
        <String, dynamic>{
          'sourceName': '源仓库(官方纯净)',
          'sourceUrl': 'http://yckceo.vip',
          'sourceGroup': '',
          'enabled': true,
          'enableJs': false,
        },
      ]);
      final result = SourceImporter.parseJson(payload);
      expect(result.sources.length, 1);
      final s = result.sources.first;
      expect(s.bookSourceName, '源仓库(官方纯净)');
      expect(s.bookSourceUrl, 'http://yckceo.vip');
      expect(s.bookSourceGroup, contains('订阅源'));
      expect(s.rawJson, contains('sourceName'));
    });

    test('rejects malformed JSON with a FormatException', () {
      expect(() => SourceImporter.parseJson('not json'), throwsFormatException);
    });
  });

  // -------------------------------------------------------------------------
  group('AnalyzeUrl request building', () {
    test('fills {{key}} and {{page}} into a search template', () {
      final source = sourceFor();
      final req = AnalyzeUrl.build(source, source.searchUrl, key: '剑来', page: 3);
      expect(req.method, 'GET');
      expect(req.url, startsWith('https://fixture.local/search?q='));
      expect(req.url, contains(Uri.encodeQueryComponent('剑来')));
      expect(req.url, endsWith('&page=3'));
      expect(req.url, isNot(contains('{{')));
    });

    test('merges source headers and drops @js marker keys', () {
      final source = sourceFor(
        header: '{"User-Agent":"UA-TEST","Referer":"https://fixture.local/",'
            '"@js":"cfCheck()"}',
      );
      final req = AnalyzeUrl.build(source, source.searchUrl, key: 'x');
      expect(req.headers['User-Agent'], 'UA-TEST');
      expect(req.headers['Referer'], 'https://fixture.local/');
      expect(req.headers.containsKey('@js'), isFalse);
    });

    test('reads method/headers from the url option object', () {
      final source = sourceFor();
      final req = AnalyzeUrl.build(
        source,
        'https://ex.com/s,{"method":"GET","headers":{"@js":"1","X-Ok":"yes"}}',
        key: 'x',
      );
      expect(req.url, 'https://ex.com/s');
      expect(req.headers['X-Ok'], 'yes');
      expect(req.headers.containsKey('@js'), isFalse);
    });

    test('honours POST + charset + body from a single-quoted option object', () {
      final source = sourceFor();
      final req = AnalyzeUrl.build(
        source,
        "https://ex.com/s,{'method':'POST','charset':'gbk',"
            "'body':'searchkey={{key}}&searchtype=all'}",
        key: '剑来',
      );
      expect(req.method, 'POST');
      expect(req.charset, 'gbk');
      expect(req.body, contains(Uri.encodeQueryComponent('剑来')));
      expect(req.body, contains('searchtype=all'));
    });

    test('strips the cookie JS helper out of a Legacy searchUrl', () {
      final source = sourceFor(url: 'http://www.kkbiquge.net');
      final req = AnalyzeUrl.build(
        source,
        '{{cookie.removeCookie(source.getKey())}}'
            'http://www.kkbiquge.net/search2c.html?searchkey={{key}}',
        key: '斗破',
      );
      expect(req.url, startsWith('http://www.kkbiquge.net/search2c.html'));
      expect(req.url, contains(Uri.encodeQueryComponent('斗破')));
      expect(req.url, isNot(contains('cookie')));
      expect(req.url, isNot(contains('{{')));
    });

    test('recovers a URL template disguised as a <js> search block', () {
      final source = sourceFor(url: 'https://www.69shuba.com');
      final req = AnalyzeUrl.build(
        source,
        "<js>/modules/article/search.php,{'charset':'gbk',"
            "'body':'searchkey={{key}}&searchtype=all','method':'POST'};"
            "result='';result;</js>",
        key: '剑来',
      );
      expect(req.method, 'POST');
      expect(req.charset, 'gbk');
      expect(req.url, 'https://www.69shuba.com/modules/article/search.php');
      expect(req.body, contains(Uri.encodeQueryComponent('剑来')));
    });

    test('sanitizeUrl strips unevaluated {{…}} JS templates', () {
      expect(
        AnalyzeUrl.sanitizeUrl(
          '{{java.ajax("x")}}https://a.com/path?q=1',
          base: 'https://fallback.com',
        ),
        'https://a.com/path?q=1',
      );
    });

    test('sanitizeUrl rejects leftover JS statements', () {
      expect(
        AnalyzeUrl.sanitizeUrl(
          "let base_url = getArguments(source.getVariable(), 'server');",
          base: 'https://example.com',
        ),
        isEmpty,
      );
    });

    test('urlJoin never throws on a JS-looking relative path', () {
      final joined = urlJoin('https://example.com', 'let base_url = x;');
      expect(joined, contains('let base_url'));
    });

    test('an empty searchUrl yields an empty request url', () {
      final source = sourceFor(searchUrl: '');
      final req = AnalyzeUrl.build(source, source.searchUrl, key: 'x');
      expect(req.url, isEmpty);
    });
  });

  // -------------------------------------------------------------------------
  group('parseExploreKinds', () {
    test('reads 标题::url / 标题&&url lines including {page}', () {
      final kinds = parseExploreKinds(
        '玄幻::https://ex.com/x/{{page}}\n都市&&https://ex.com/d/{page}',
      );
      expect(kinds.length, 2);
      expect(kinds.first.title, '玄幻');
      expect(kinds.first.url, 'https://ex.com/x/{{page}}');
      expect(kinds[1].title, '都市');
    });

    test('reads a JSON array of {title,url}', () {
      final kinds = parseExploreKinds(
        '[{"title":"完本","url":"https://ex.com/f/{{page}}"}]',
      );
      expect(kinds.length, 1);
      expect(kinds.single.title, '完本');
    });

    test('falls back to a single 全部 kind for a bare URL', () {
      final kinds = parseExploreKinds('https://ex.com/all/{{page}}');
      expect(kinds.length, 1);
      expect(kinds.single.title, '全部');
      expect(kinds.single.url, 'https://ex.com/all/{{page}}');
    });

    test('returns an empty list for blank input', () {
      expect(parseExploreKinds('   '), isEmpty);
    });
  });

  // -------------------------------------------------------------------------
  group('AnalyzeRule (CSS pipeline)', () {
    test('getList splits alternatives with ||', () {
      const html = '<ul class="chapter_list"><li><a href="/1">第1章</a></li>'
          '<li><a href="/2">第2章</a></li></ul>';
      final rule = AnalyzeRule(content: html, baseUrl: 'https://x.com');
      expect(rule.getList('.chapter_list a').length, 2);
      expect(rule.getList('.missing||ul.chapter_list a').length, 2);
      expect(rule.getList(''), isEmpty);
    });

    test('getString reads text/attribute from a scoped item', () {
      final rule = AnalyzeRule(content: kSearchHtml, baseUrl: 'https://x.com');
      final items = rule.getList('.item');
      expect(items.length, 3);
      expect(rule.getString('h3 a@text', scope: items.first), '书名一');
      expect(rule.getString('a@href', scope: items.first), '/book/1');
      expect(rule.getString('.author@text', scope: items.first), '作者：张三');
      expect(rule.getString('.missing@text', scope: items.first), isEmpty);
    });

    test('cleanAuthor strips prefixes, suffixes and trailing metadata', () {
      expect(cleanAuthor('作者：王五'), '王五');
      // The source engine flattens HTML before cleanAuthor (raw markup would
      // otherwise be captured as a name).
      expect(cleanAuthor(htmlToPlainText('<span>王五</span>')), '王五');
      expect(cleanAuthor('作者：天蚕土豆著'), '天蚕土豆');
      expect(cleanAuthor('张三/玄幻'), '张三');
      expect(cleanAuthor('原著：王五'), '王五');
      expect(cleanAuthor('张三 分类：玄幻 状态：连载'), '张三');
      expect(cleanAuthor('书名一\n作者：赵六 分类：都市\n简介xxx'), '赵六');
      expect(cleanAuthor(''), isEmpty);
      expect(cleanAuthor('123'), isEmpty);
    });

    test('ownText excludes descendants while text includes them', () {
      const html = '<div class="d">外层<span>内层</span></div>';
      final rule = AnalyzeRule(content: html, baseUrl: 'https://x.com');
      expect(rule.getString('.d@ownText'), '外层');
      expect(rule.getString('.d@text'), contains('内层'));
    });

    test('supports eq/gt/lt pseudo selectors', () {
      const html = '<div id="list"><a href="/1">A</a><a href="/2">B</a>'
          '<a href="/3">C</a></div>';
      final rule = AnalyzeRule(content: html, baseUrl: 'https://x.com');
      expect(rule.getList('#list a:eq(0)').length, 1);
      expect(rule.getString('#list a:eq(1)@text'), 'B');
      expect(rule.getList('#list a:gt(0)').length, 2);
      expect(rule.getList('#list a:lt(2)').length, 2);
      expect(rule.getString('#list a:lt(2)@text', scope: null), 'A');
    });

    test('supports :contains', () {
      const html = '<a href="/next">下一章</a><a href="/prev">上一章</a>';
      final rule = AnalyzeRule(content: html, baseUrl: 'https://x.com');
      expect(rule.getString('a:contains(下一章)@href'), '/next');
    });

    test('supports the [-1:0] reverse range token', () {
      const html = '<div id="list"><a>第1章</a><a>第2章</a><a>第3章</a></div>';
      final rule = AnalyzeRule(content: html, baseUrl: 'https://x.com');
      final items = rule.getList('#list a[-1:0]');
      expect(items.length, 3);
      expect(items.first.text, '第3章');
      expect(items.last.text, '第1章');
    });

    test('maps Jsoup class./tag. selectors onto CSS', () {
      const html = '<ul class="chapter_list"><dd><a href="/1">第1章</a></dd>'
          '<dd><a href="/2">第2章</a></dd></ul>';
      final rule = AnalyzeRule(content: html, baseUrl: 'https://x.com');
      expect(
        rule.getList('class.chapter_list@tag.dd:eq(1)@tag.a').length,
        1,
      );
      expect(rule.getString('class.chapter_list@tag.dd:eq(1)@tag.a@text'),
          '第2章');
    });

    test('prefers a lazy data-src over a placeholder src', () {
      const html = '<div class="item"><img src="/loading.jpg" '
          'data-src="/covers/real.webp"/></div>';
      final rule = AnalyzeRule(content: html, baseUrl: 'https://x.com');
      expect(rule.getString('img@src'), '/covers/real.webp');
    });

    test('appends a post-regex with ##', () {
      const html = '<h3>第1234章 终局</h3>';
      final rule = AnalyzeRule(content: html, baseUrl: 'https://x.com');
      expect(rule.getString(r'h3@text##\d+'), '第章 终局');
      expect(rule.getString(r'h3@text##^第\d+章\s*'), '终局');
    });

    test('joins && sub-rules with a space', () {
      const html = '<label>玄幻</label><label>连载</label>';
      final rule = AnalyzeRule(content: html, baseUrl: 'https://x.com');
      expect(rule.getString('label.0@text&&label.1@text'), '玄幻 连载');
    });

    test('evaluates an @xpath rule', () {
      const html = '<html><head><meta property="og:novel:book_name" '
          'content="剑来"/></head><body></body></html>';
      final rule = AnalyzeRule(content: html, baseUrl: 'https://x.com');
      expect(
        rule.getString("//meta[@property='og:novel:book_name']/@content"),
        '剑来',
      );
    });

    test('evaluates an explicit @regex rule', () {
      const html = '<div id="content">正文<span>广告</span></div>';
      final rule = AnalyzeRule(content: html, baseUrl: 'https://x.com');
      expect(
        rule.getString(r'@regex:id="content"[^>]*>([\s\S]*?)</div>'),
        '正文<span>广告</span>',
      );
    });

    test('evaluates a JSON path rule with a Map scope', () {
      const body = '{"data":[{"name":"N1","url":"/1"},'
          '{"name":"N2","url":"/2"}]}';
      final rule = AnalyzeRule(content: body, baseUrl: 'https://x.com');
      expect(rule.isJson, isTrue);
      final items = rule.getList(r'$.data');
      expect(items.length, 2);
      expect(rule.getString(r'$.name', scope: items.first), 'N1');
    });

    test('getHtmlString keeps inner HTML for a container', () {
      const html = '<div class="txtnav"><p>第一段</p><p>第二段</p></div>';
      final rule = AnalyzeRule(content: html, baseUrl: 'https://x.com');
      final out = rule.getHtmlString('.txtnav');
      expect(out, contains('<p>第一段</p>'));
      expect(out, contains('第二段'));
    });

    test('handles the <js> hybrid prefix by degrading to the tail rule', () {
      const html = '<div id="article_list_content"><ul><li><h3>'
          '<a href="/1">书A</a></h3></li><li><h3><a href="/2">书B</a></h3>'
          '</li></ul></div>';
      final rule = AnalyzeRule(content: html, baseUrl: 'https://x.com');
      final items = rule.getList(
        '<js>cfCheck(result, baseUrl);</js>#article_list_content li',
      );
      expect(items.length, 2);
      expect(
        rule.getString(
          '<js>cfCheck(result, baseUrl);</js>#article_list_content li.1 h3 a@text',
        ),
        '书B',
      );
    });
  });

  // -------------------------------------------------------------------------
  group('analyzers directly', () {
    test('JsonAnalyzer walks maps and lists', () {
      final root = jsonDecode('{"data":{"list":[{"n":"a"},{"n":"b"}]}}');
      expect(JsonAnalyzer.getList(root, r'$.data.list').length, 2);
      expect(JsonAnalyzer.getString(root, r'$.data.list[1].n'), 'b');
      expect(JsonAnalyzer.getList(root, ''), isEmpty);
    });

    test('RegexAnalyzer returns captures and groups', () {
      expect(
        RegexAnalyzer.getString('<div>abc</div>', r'<div>(.*?)</div>'),
        'abc',
      );
      expect(RegexAnalyzer.getList('a1b22', r'(\d+)'), ['1', '22']);
      expect(RegexAnalyzer.getString('none', r'(\d+)'), isEmpty);
    });

    test('XpathAnalyzer resolves attribute xpaths', () {
      final doc = XpathAnalyzer.parse(
        '<html><head><meta name="author" content="张三"/></head></html>',
      );
      expect(
        XpathAnalyzer.getString(doc, "//meta[@name='author']/@content"),
        '张三',
      );
    });

    test('CssAnalyzer normalizes Jsoup selectors and applies ranges', () {
      expect(
        CssAnalyzer.normalizeSelector('class.chapter_list@tag.dd:eq(1)@tag.a'),
        '.chapter_list dd:eq(1) a',
      );
      final doc = CssAnalyzer.parse('<div><a>1</a><a>2</a><a>3</a></div>');
      final els = CssAnalyzer.getElements(doc, 'a');
      expect(els.length, 3);
      final reversed = CssAnalyzer.applyRange(els, -1, 0);
      expect(reversed.first.text, '3');
      expect(reversed.last.text, '1');
    });
  });

  // -------------------------------------------------------------------------
  group('JsEngine degradation (no flutter_js on host)', () {
    test('needsJs detects JS-bearing rules', () {
      expect(JsEngine.needsJs('@js: result'), isTrue);
      expect(JsEngine.needsJs('<js>1+1</js>'), isTrue);
      expect(JsEngine.needsJs('.item a@text'), isFalse);
    });

    test('extractCode unwraps @js: and <js> forms', () {
      expect(JsEngine.extractCode('@js: result + "!"'), 'result + "!"');
      expect(JsEngine.extractCode('<js>1+1</js>'), '1+1');
      expect(JsEngine.extractCode('.item'), isNull);
    });

    test('eval degrades to a passthrough result instead of executing', () {
      expect(
        JsEngine.instance.eval('result + "-ok"', result: 'hello'),
        'hello',
      );
      expect(
        JsEngine.instance.eval('cfCheck(result);', result: '', src: 'raw-body'),
        'raw-body',
      );
      expect(JsEngine.instance.eval('', result: 'kept'), 'kept');
      expect(JsEngine.instance.runtimeAvailable, isFalse);
    });

    test('evalList parses JSON results and falls back to line splitting', () {
      expect(JsEngine.instance.evalList('', result: '[{"a":1}]').length, 1);
      expect(
        JsEngine.instance.evalList('', result: '第一行\n第二行'),
        ['第一行', '第二行'],
      );
    });
  });

  // -------------------------------------------------------------------------
  group('text utilities', () {
    test('urlJoin resolves relative and absolute paths', () {
      expect(urlJoin('https://a.com/x/', 'y'), 'https://a.com/x/y');
      expect(urlJoin('https://a.com/x', '/y'), 'https://a.com/y');
      expect(urlJoin('https://a.com', 'https://b.com/z'), 'https://b.com/z');
    });

    test('applyReplaceRegex supports the rule##replacement form', () {
      expect(applyReplaceRegex('abc123', r'\d+##'), 'abc');
      expect(applyReplaceRegex('abc123', r'\d+##X'), 'abcX');
      expect(applyReplaceRegex('abc', ''), 'abc');
    });

    test('htmlToPlainText keeps paragraphs and drops counter lines', () {
      final text = htmlToPlainText('<p>第一段</p><p>第二段</p><div>3</div>');
      expect(text, contains('第一段'));
      expect(text, contains('第二段'));
      expect(text, isNot(contains('3')));
    });

    test('normalizeChapterTitle strips numbering and spaces', () {
      expect(normalizeChapterTitle('第二章 风暴'), normalizeChapterTitle('第2章风暴'));
      expect(normalizeChapterTitle(' 第 一 章 '), isEmpty);
      expect(normalizeChapterTitle('第1234章 终局'), '终局');
    });

    test('makeBookKey is stable, short and source-scoped', () {
      final a = makeBookKey('https://s1.local', 'https://b.local/1');
      final b = makeBookKey('https://s1.local', 'https://b.local/1');
      final c = makeBookKey('https://s2.local', 'https://b.local/1');
      expect(a, b);
      expect(a.length, 16);
      expect(a, isNot(c));
    });

    test('finalizeContent converts HTML then applies replaceRegex', () {
      final out = finalizeContent('<p>正文内容</p>', '');
      expect(out, '正文内容');
      expect(finalizeContent('<p>正文123</p>', r'\d+##'), '正文');
    });
  });

  // -------------------------------------------------------------------------
  group('ProgressMapper', () {
    final chapters = <SourceChapter>[
      SourceChapter(name: '第一章 起航', url: 'u1', index: 0),
      SourceChapter(name: '第二章 风暴', url: 'u2', index: 1),
      SourceChapter(name: '第三章 归途', url: 'u3', index: 2),
    ];

    test('maps by exact and normalized chapter name', () {
      expect(
        ProgressMapper.map(oldName: '第二章 风暴', oldIndex: 0, newChapters: chapters),
        1,
      );
      expect(
        ProgressMapper.map(oldName: '第2章风暴', oldIndex: 0, newChapters: chapters),
        1,
      );
    });

    test('falls back to the clamped index when the name is gone', () {
      expect(
        ProgressMapper.map(
          oldName: '不存在的章节',
          oldIndex: 2,
          newChapters: chapters,
        ),
        2,
      );
      expect(
        ProgressMapper.map(oldName: null, oldIndex: 0, newChapters: const []),
        0,
      );
    });
  });

  // -------------------------------------------------------------------------
  group('BookSource model', () {
    test('fromLegadoJson / toLegadoJson round-trip the rule sets', () {
      final map = legadoSource(
        ruleSearch: <String, dynamic>{
          'bookList': '.item',
          'name': 'h3 a@text',
          'author': '.author@text',
          'coverUrl': 'img@src',
          'bookUrl': 'a@href',
        },
        ruleToc: <String, dynamic>{
          'chapterList': '#list dd a',
          'chapterName': 'text',
          'chapterUrl': 'href',
        },
        ruleContent: <String, dynamic>{
          'content': '#content',
          'replaceRegex': '广告##',
        },
      );
      final source = BookSource.fromLegadoJson(map);
      expect(source.ruleSearch.bookList, '.item');
      expect(source.ruleSearch.name, 'h3 a@text');
      expect(source.ruleToc.chapterList, '#list dd a');
      expect(source.ruleContent.replaceRegex, '广告##');
      final back = source.toLegadoJson();
      expect((back['ruleSearch'] as Map)['name'], 'h3 a@text');
      expect((back['ruleToc'] as Map)['chapterUrl'], 'href');
      expect((back['ruleContent'] as Map)['content'], '#content');
    });

    test('missing rule objects become safe empty defaults', () {
      final source = BookSource.fromLegadoJson(<String, dynamic>{
        'bookSourceUrl': 'https://x.local',
      });
      expect(source.ruleSearch.bookList, isEmpty);
      expect(source.ruleToc.chapterList, isEmpty);
      expect(source.ruleContent.content, isEmpty);
      expect(source.enabled, isTrue);
    });

    test('canExplore requires an explore url', () {
      expect(sourceFor(exploreUrl: 'https://x.local/e').canExplore, isTrue);
      expect(sourceFor().canExplore, isFalse);
    });
  });

  // -------------------------------------------------------------------------
  group('BookSourceEngine.search', () {
    test('parses the result list and skips checkKeyWord hits', () async {
      fake.handler = (req) =>
          SourceResponse(url: req.url, body: kSearchHtml);
      final source = sourceFor(ruleSearch: searchRules);
      final books = await BookSourceEngine().search(source, '剑来', 1);

      expect(books.length, 2);
      final first = books.first;
      expect(first, isA<SearchBook>());
      expect(first.name, '书名一');
      expect(first.author, '张三');
      expect(first.kind, '玄幻');
      expect(first.bookUrl, 'https://fixture.local/book/1');
      expect(first.coverUrl, 'https://fixture.local/covers/1.jpg');
      expect(first.sourceUrl, 'https://fixture.local');
      expect(first.sourceName, '测试源');
      expect(books.map((e) => e.name), isNot(contains('请输入验证码')));

      expect(fake.requests.length, 1);
      final url = fake.requests.single.url;
      expect(url, startsWith('https://fixture.local/search?q='));
      expect(url, contains(Uri.encodeQueryComponent('剑来')));
      expect(url, endsWith('&page=1'));
    });

    test('returns nothing for an empty keyword without any request', () async {
      final source = sourceFor(ruleSearch: searchRules);
      final books = await BookSourceEngine().search(source, '', 1);
      expect(books, isEmpty);
      expect(fake.requests, isEmpty);
    });
  });

  // -------------------------------------------------------------------------
  group('BookSourceEngine.explore', () {
    test('prefers ruleExplore over ruleSearch', () async {
      fake.handler = (req) => SourceResponse(
            url: req.url,
            body: '<div class="item"><span class="title">探索名</span>'
                '<h3><a href="/book/9">搜索名</a></h3></div>',
          );
      final source = sourceFor(
        exploreUrl: 'https://fixture.local/explore/{{page}}',
        ruleExplore: <String, dynamic>{
          'bookList': '.item',
          'name': '.title@text',
          'bookUrl': 'a@href',
        },
        ruleSearch: searchRules,
      );
      final books = await BookSourceEngine().explore(source, source.exploreUrl);
      expect(books.single.name, '探索名');
      expect(fake.requests.single.url, 'https://fixture.local/explore/1');
    });

    test('falls back to ruleSearch when ruleExplore is empty', () async {
      fake.handler = (req) =>
          SourceResponse(url: req.url, body: kSearchHtml);
      final source = sourceFor(
        exploreUrl: 'https://fixture.local/explore/{{page}}',
        ruleSearch: searchRules,
      );
      final books = await BookSourceEngine().explore(source, source.exploreUrl);
      expect(books.length, 2);
      expect(books.first.name, '书名一');
    });
  });

  // -------------------------------------------------------------------------
  group('BookSourceEngine.bookInfo', () {
    test('maps info fields, probes the cover and keeps the toc url', () async {
      fake.handler = (req) => SourceResponse(
            url: req.url,
            body: '<h1>书名一</h1>'
                '<div class="author">作者：张三</div>'
                '<div id="intro">这是简介</div>'
                '<div class="latest">最新：第10章</div>'
                '<div class="cover"><img src="/loading.jpg" '
                'data-src="/covers/1.jpg"></div>',
          );
      final source = sourceFor(
        ruleBookInfo: <String, dynamic>{
          'name': 'h1@text',
          'author': '.author@text',
          'intro': '#intro@text',
          'lastChapter': '.latest@text',
        },
      );
      const bookUrl = 'https://fixture.local/book/1';
      final info = await BookSourceEngine().bookInfo(source, bookUrl);

      expect(info.name, '书名一');
      expect(info.author, '张三');
      expect(info.description, '这是简介');
      expect(info.latestChapter, '最新：第10章');
      expect(info.coverUrl, 'https://fixture.local/covers/1.jpg');
      expect(info.tocUrl, bookUrl);
      expect(info.sourceUrl, 'https://fixture.local');
      expect(info.originName, '测试源');
      expect(info.id, makeBookKey('https://fixture.local', bookUrl));
      expect(fake.requests.single.url, bookUrl);
    });
  });

  // -------------------------------------------------------------------------
  group('BookSourceEngine.toc', () {
    test('walks nextTocUrl pages and de-duplicates chapter urls', () async {
      fake.handler = (req) {
        if (req.url == 'https://fixture.local/toc/2') {
          return SourceResponse(
            url: req.url,
            body: '<div id="list"><dd><a href="/c/3">第三章 归途</a></dd></div>',
          );
        }
        return SourceResponse(
          url: req.url,
          body: '<div id="list">'
              '<dd><a href="/c/1">第一章 起航</a></dd>'
              '<dd><a href="/c/2">第二章 风暴</a></dd>'
              '<dd><a href="/c/1">第一章 起航</a></dd>'
              '</div><a class="next" href="/toc/2">下一页</a>',
        );
      };
      final source = sourceFor(
        ruleToc: <String, dynamic>{
          'chapterList': '#list dd a',
          'chapterName': 'text',
          'chapterUrl': 'href',
          'nextTocUrl': '.next@href',
        },
      );
      final chapters = await BookSourceEngine()
          .toc(source, 'https://fixture.local/toc/1');

      expect(chapters.length, 3);
      expect(chapters.map((e) => e.name).toList(),
          ['第一章 起航', '第二章 风暴', '第三章 归途']);
      expect(chapters.first.url, 'https://fixture.local/c/1');
      expect(chapters.map((e) => e.index).toList(), [0, 1, 2]);
      expect(fake.requests.length, 2);
    });

    test('falls back to known toc selectors when chapterList misses', () async {
      fake.handler = (req) => SourceResponse(
            url: req.url,
            body: '<ul class="chapter_list">'
                '<li><a href="/c/1">第一章</a></li>'
                '<li><a href="/c/2">第二章</a></li></ul>',
          );
      final source = sourceFor(
        ruleToc: <String, dynamic>{
          'chapterList': '.not-here',
          'chapterName': 'text',
          'chapterUrl': 'href',
        },
      );
      final chapters =
          await BookSourceEngine().toc(source, 'https://fixture.local/toc');
      expect(chapters.length, 2);
      expect(chapters.first.name, '第一章');
      expect(chapters.first.url, 'https://fixture.local/c/1');
    });

    test('flags volume rows via the isVolume rule', () async {
      fake.handler = (req) => SourceResponse(
            url: req.url,
            body: '<div id="list">'
                '<li class="row"><span class="vol">第一卷</span></li>'
                '<dd><a href="/c/1">第一章</a></dd></div>',
          );
      final source = sourceFor(
        ruleToc: <String, dynamic>{
          'chapterList': '#list > *',
          'chapterName': 'text',
          'chapterUrl': 'href',
          'isVolume': '.vol@text',
        },
      );
      final chapters =
          await BookSourceEngine().toc(source, 'https://fixture.local/toc');
      expect(chapters.first.isVolume, isTrue);
      expect(chapters[1].isVolume, isFalse);
    });
  });

  // -------------------------------------------------------------------------
  group('BookSourceEngine.content', () {
    test('extracts and finalizes the primary content rule', () async {
      fake.handler = (req) => SourceResponse(
            url: req.url,
            body: '<div id="content"><p>第一段内容</p><p>第二段内容</p></div>',
          );
      final source = sourceFor(
        ruleContent: <String, dynamic>{'content': '#content'},
      );
      final text =
          await BookSourceEngine().content(source, 'https://fixture.local/c/1');
      expect(text, contains('第一段内容'));
      expect(text, contains('第二段内容'));
    });

    test('picks a longer fallback container when the rule yields too little',
        () async {
      fake.handler = (req) => SourceResponse(
            url: req.url,
            body: '<div id="content">短</div>'
                '<div class="chapter_content_box"><p>'
                '这是一段很长很长的正文内容，用来验证回退选择器确实会挑选更长的候选容器。'
                '</p></div>',
          );
      final source = sourceFor(
        ruleContent: <String, dynamic>{'content': '#content'},
      );
      final text =
          await BookSourceEngine().content(source, 'https://fixture.local/c/1');
      expect(text, contains('很长很长'));
    });

    test('uses sourceRegex when the content rule is empty', () async {
      fake.handler = (req) => SourceResponse(
            url: req.url,
            body: '<div id="content"><p>正文内容甲</p></div>',
          );
      final source = sourceFor(
        ruleContent: <String, dynamic>{
          'content': '',
          'sourceRegex': r'id="content"[^>]*>([\s\S]*?)</div>',
        },
      );
      final text =
          await BookSourceEngine().content(source, 'https://fixture.local/c/1');
      expect(text, '正文内容甲');
    });

    test('appends nextContentUrl pages', () async {
      fake.handler = (req) {
        if (req.url == 'https://fixture.local/c2') {
          return SourceResponse(
            url: req.url,
            body: '<div id="content"><p>第二章内容</p></div>',
          );
        }
        return SourceResponse(
          url: req.url,
          body: '<div id="content"><p>第一章内容</p></div>'
              '<a class="next" href="/c2">下一章</a>',
        );
      };
      final source = sourceFor(
        ruleContent: <String, dynamic>{
          'content': '#content',
          'nextContentUrl': '.next@href',
        },
      );
      final text =
          await BookSourceEngine().content(source, 'https://fixture.local/c1');
      expect(text, contains('第一章内容'));
      expect(text, contains('第二章内容'));
      expect(text.indexOf('第一章内容'), lessThan(text.indexOf('第二章内容')));
      expect(fake.requests.length, 2);
    });

    test('applies replaceRegex to the finalized chapter text', () async {
      fake.handler = (req) => SourceResponse(
            url: req.url,
            body: '<div id="content"><p>正文123</p></div>',
          );
      final source = sourceFor(
        ruleContent: <String, dynamic>{
          'content': '#content',
          'replaceRegex': r'\d+##',
        },
      );
      final text =
          await BookSourceEngine().content(source, 'https://fixture.local/c/1');
      expect(text, isNot(contains('123')));
      expect(text, contains('正文'));
    });
  });

  // -------------------------------------------------------------------------
  group('TextPaginator', () {
    final paginator = TextPaginator();

    test('layoutFingerprint normalizes numeric params', () {
      final fp = paginator.layoutFingerprint(
        layoutParams: <String, dynamic>{
          'abi': 3,
          'fontSize': 20.0,
          'lineHeight': 1.5,
          'paragraph': 8.0,
          'padH': 16.0,
          'boxW': 360.0,
          'boxH': 640.0,
          'fontFamily': 'F',
          'fontPath': '/f.ttf',
          'shouldJustifyHeight': false,
          'textAlign': 'justify',
        },
        contentLen: 120,
        contentSig: 'abc',
      );
      expect(
        fp,
        'abi3|20|1.5|8|16|360|640|F|/f.ttf|0|justify|120|abc',
      );
    });

    test('layoutFingerprint changes with content length and justify flag', () {
      final base = <String, dynamic>{'fontSize': 20.0, 'lineHeight': 1.5};
      final a = paginator.layoutFingerprint(
        layoutParams: base,
        contentLen: 10,
      );
      final b = paginator.layoutFingerprint(
        layoutParams: base,
        contentLen: 11,
      );
      expect(a, isNot(b));
    });

    test('contentSignature is stable and content-sensitive', () {
      expect(paginator.contentSignature(''), '0');
      final a = paginator.contentSignature('第一章内容');
      final b = paginator.contentSignature('第一章内容');
      final c = paginator.contentSignature('第二章内容');
      expect(a, b);
      expect(a, isNot(c));
    });

    test('paginateProgressive reports the dart engine and no native pager',
        () async {
      final outcome = await paginator.paginateProgressive(
        ReadPage('第一段内容。第二段内容。', '第一章', 0, const []),
      );
      expect(outcome.complete, isTrue);
      expect(outcome.engine, 'dart');
      expect(outcome.fallbackReason, 'native_unavailable');
      expect(outcome.nextChar, '第一段内容。第二段内容。'.length);
      expect(outcome.jobId, greaterThan(0));
      expect(outcome.pages, isNotEmpty);
    });

    test('cancelActive clears the active job id', () {
      paginator.cancelActive();
      expect(paginator.activeJobId, 0);
    });

    test('paginateSync returns at least one page for empty content', () {
      final pages = paginator.paginateSync(ReadPage('', '', 0, const []));
      expect(pages, isNotEmpty);
    });
  });

  // -------------------------------------------------------------------------
  group('ChapterContentLoader boundary branches', () {
    ChapterContentLoader loader() => ChapterContentLoader(
          chaptersRepo: ChapterRepository(),
          paginator: TextPaginator(),
          fetchContent: (chapterId, {int? idx}) async => '正文',
        );

    test('an empty toc delegates to the caller message page', () async {
      String? title;
      String? message;
      final page = await loader().load(
        chapters: const <ChapterTocEntry>[],
        idx: 0,
        warm: <String, ChapterDiskCache>{},
        messagePage: (t, m) async {
          title = t;
          message = m;
          return ReadPage.kong();
        },
      );
      expect(page, isNotNull);
      expect(title, '目录为空');
      expect(message, '暂无章节，请检查书源或网络后重试。');
    });

    test('an index below zero reports 已经是第一章', () async {
      final page = await loader().load(
        chapters: <ChapterTocEntry>[
          ChapterTocEntry(id: 'c1', title: '第一章', url: 'https://x/c1'),
        ],
        idx: -1,
        warm: <String, ChapterDiskCache>{},
      );
      expect(page, isNotNull);
      expect(page!.chapterName, '1');
      expect(page.chapterContent, '已经是第一章');
    });

    test('an index past the end returns null (no more content)', () async {
      final page = await loader().load(
        chapters: <ChapterTocEntry>[
          ChapterTocEntry(id: 'c1', title: '第一章', url: 'https://x/c1'),
        ],
        idx: 1,
        warm: <String, ChapterDiskCache>{},
      );
      expect(page, isNull);
    });
  });

  // -------------------------------------------------------------------------
  group('ChapterRepository page codec', () {
    test('encodePagesJson / decodePagesJson round-trip text pages', () async {
      final pages = <TextPage>[
        TextPage(
          <TextLine>[TextLine('第一行', top: 0, height: 24)],
          24,
          pageIndex: 0,
          charStart: 0,
          charEnd: 3,
        ),
      ];
      final json = await ChapterRepository.encodePagesJson(pages);
      expect(json, contains('"pageIndex"'));
      expect(json, contains('"charEnd"'));
      final back = await ChapterRepository.decodePagesJson(json);
      expect(back, isNotNull);
      expect(back!.length, 1);
      expect(back.first.lines.first.text, '第一行');
      expect(back.first.charEnd, 3);
    });

    test('decodePagesJson returns null for empty or invalid input', () async {
      expect(await ChapterRepository.decodePagesJson(null), isNull);
      expect(await ChapterRepository.decodePagesJson(''), isNull);
      expect(await ChapterRepository.decodePagesJson('not-json'), isNull);
    });
  });

  // -------------------------------------------------------------------------
  group('Yckceo repository models', () {
    test('YckItem exposes repository download metadata', () {
      const item = YckItem(
        id: '7592',
        title: '恩木书库',
        host: 'https://m.enmuku.com',
        downloads: 2369,
        kind: YckKind.source,
      );
      expect(item.id, '7592');
      expect(item.kind, YckKind.source);
      expect(item.downloads, 2369);
      expect(item.isCollection, isFalse);
      expect(
        item.jsonUrl,
        'https://www.yckceo.com/yuedu/shuyuan/json/id/7592.json',
      );
    });

    test('parseSourcesHtml reads ids, title, update time and downloads', () {
      const html = '<div class="ylist">'
          '<div class="m-left">'
          '<input type="checkbox" name="ids[]" value="7592" />'
          '<a href="/yuedu/shuyuan/content/id/7592.html">恩木书库</a>'
          '</div>'
          '<div class="m-right">'
          '<p class="m-right">2024-01-01</p><p>下载：2369</p>'
          '</div></div>';
      final items = YckceoRepo.parseSourcesHtml(html);
      expect(items.length, 1);
      expect(items.single.id, '7592');
      expect(items.single.title, '恩木书库');
      expect(items.single.downloads, 2369);
      expect(items.single.updated, '2024-01-01');
      expect(items.single.kind, YckKind.source);
      expect(
        items.single.jsonUrl,
        'https://www.yckceo.com/yuedu/shuyuan/json/id/7592.json',
      );
    });

    test('parseRssHtml keeps the rss kind and json path', () {
      const html = '<div class="ylist">'
          '<input type="checkbox" name="ids[]" value="193" />'
          '<a href="/yuedu/rss/content/id/193.html">源仓库</a>'
          '</div></div>';
      final items = YckceoRepo.parseRssHtml(html);
      expect(items.single.kind, YckKind.rss);
      expect(
        items.single.jsonUrl,
        'https://www.yckceo.com/yuedu/rss/json/id/193.json',
      );
    });

    test('parseCollectionsHtml reads collection cards', () {
      const html = '<h2><a href="/yuedu/shuyuans/content/id/1193.html">'
          '精选合集</a></h2><p class="m-right">2024-02-02</p>';
      final items = YckceoRepo.parseCollectionsHtml(html);
      expect(items.single.id, '1193');
      expect(items.single.isCollection, isTrue);
      expect(
        items.single.jsonUrl,
        'https://www.yckceo.com/yuedu/shuyuans/json/id/1193.json',
      );
    });

    test('multiSourceJsonUrl uses the first non-empty id', () {
      expect(
        YckceoRepo.multiSourceJsonUrl(<String>['1', '2', '3']),
        'https://www.yckceo.com/yuedu/shuyuan/json/id/1.json',
      );
      expect(
        YckceoRepo.multiSourceJsonUrl(const <String>[]),
        endsWith('/yuedu/shuyuan/json/id/0.json'),
      );
    });

    test('YckListResult carries the parsed page payload', () {
      const result = YckListResult(
        items: <YckItem>[
          YckItem(
            id: '193',
            title: '源仓库(官方纯净)',
            host: 'http://yckceo.vip',
            kind: YckKind.rss,
          ),
        ],
        total: 1,
        page: 1,
      );
      expect(result.items.single.title, '源仓库(官方纯净)');
      expect(result.items.single.isRss, isTrue);
      expect(
        result.items.single.jsonUrl,
        'https://www.yckceo.com/yuedu/rss/json/id/193.json',
      );
      expect(result.total, 1);
      expect(result.hasMore, isFalse);
    });
  });
}
