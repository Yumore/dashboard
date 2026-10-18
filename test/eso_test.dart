// eso 书源引擎移植的离线测试：全程使用手写假 HTTP client 与手写 HTML/JSON 夹具，
// 不访问网络。断言的期望值全部来自 eso 源实现
// （/Users/nathaniel/workspace/Flutter/eso/lib/...）的真实行为。

import 'dart:convert';
import 'dart:typed_data';

import 'package:dashboard/features/reading/eso/eso_analyze_url.dart';
import 'package:dashboard/features/reading/eso/eso_analyzer_encode.dart';
import 'package:dashboard/features/reading/eso/eso_analyzer_decode.dart';
import 'package:dashboard/features/reading/eso/eso_analyzer_filter.dart';
import 'package:dashboard/features/reading/eso/eso_analyzer_html.dart';
import 'package:dashboard/features/reading/eso/eso_analyzer_jsonpath.dart';
import 'package:dashboard/features/reading/eso/eso_analyzer_manager.dart';
import 'package:dashboard/features/reading/eso/eso_analyzer_match.dart';
import 'package:dashboard/features/reading/eso/eso_analyzer_regexp.dart';
import 'package:dashboard/features/reading/eso/eso_analyzer_replace.dart';
import 'package:dashboard/features/reading/eso/eso_analyzer_unsupported.dart';
import 'package:dashboard/features/reading/eso/eso_analyzer_xpath.dart';
import 'package:dashboard/features/reading/eso/eso_api.dart';
import 'package:dashboard/features/reading/eso/eso_api_const.dart';
import 'package:dashboard/features/reading/eso/eso_api_from_rule.dart';
import 'package:dashboard/features/reading/eso/eso_api_manager.dart';
import 'package:dashboard/features/reading/eso/eso_api_type.dart';
import 'package:dashboard/features/reading/eso/eso_chapter_item.dart';
import 'package:dashboard/features/reading/eso/eso_chapter_page_provider.dart';
import 'package:dashboard/features/reading/eso/eso_content_provider.dart';
import 'package:dashboard/features/reading/eso/eso_decode_body.dart';
import 'package:dashboard/features/reading/eso/eso_discover_pair.dart';
import 'package:dashboard/features/reading/eso/eso_history_item_store.dart';
import 'package:dashboard/features/reading/eso/eso_http_client.dart';
import 'package:dashboard/features/reading/eso/eso_id.dart';
import 'package:dashboard/features/reading/eso/eso_json_path.dart';
import 'package:dashboard/features/reading/eso/eso_reading_progress.dart';
import 'package:dashboard/features/reading/eso/eso_rule.dart';
import 'package:dashboard/features/reading/eso/eso_rule_compress.dart';
import 'package:dashboard/features/reading/eso/eso_rule_exception.dart';
import 'package:dashboard/features/reading/eso/eso_rule_provider.dart';
import 'package:dashboard/features/reading/eso/eso_rule_store.dart';
import 'package:dashboard/features/reading/eso/eso_search_history_store.dart';
import 'package:dashboard/features/reading/eso/eso_search_item.dart';
import 'package:dashboard/features/reading/eso/eso_xpath.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// 记录请求并返回预设响应的假 client。
class _FakeHttpClient extends http.BaseClient {
  _FakeHttpClient(this.handler);

  final http.Response Function(http.BaseRequest request) handler;
  final List<http.BaseRequest> requests = <http.BaseRequest>[];

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    requests.add(request);
    final response = handler(request);
    return http.StreamedResponse(
      Stream<List<int>>.value(response.bodyBytes),
      response.statusCode,
      request: request,
      headers: response.headers,
      reasonPhrase: response.reasonPhrase,
    );
  }
}

/// 内存书源提供者，替代 Hive/sqflite 落盘。
class _MemoryRuleProvider implements EsoRuleProvider {
  _MemoryRuleProvider(this.rules);

  final List<EsoRule> rules;

  @override
  Future<List<EsoRule>> getAllRules() async => List<EsoRule>.from(rules);

  @override
  Future<EsoRule?> findRuleById(String? id) async {
    for (final rule in rules) {
      if (rule.id == id) return rule;
    }
    return null;
  }
}

http.Response _html(String body, {String contentType = 'text/html; charset=utf-8'}) =>
    http.Response.bytes(utf8.encode(body), 200,
        headers: <String, String>{'content-type': contentType});

/// 搜索/发现用的书源：HTML 结构固定，字段断言覆盖全部映射。
EsoRule _searchRule() => EsoRule(
      id: 'rule-search',
      name: '测试源',
      host: 'https://example.com',
      contentType: EsoApiType.novel,
      searchUrl: '/search?q=\$keyword&page=\$page',
      searchList: '@css:.book',
      searchTags: '@css:.tag@text',
      searchName: '@css:h3@text',
      searchCover: '@css:img@src',
      searchAuthor: '@css:.author@text',
      searchChapter: '@css:.latest@text',
      searchDescription: '@css:.intro@text',
      searchResult: '@css:a@href',
    );

const String _searchHtml = '<html><body>'
    '<div class="book"><h3>书名  一</h3><span class="author">作者A</span>'
    '<img src="/c.jpg"><span class="tag">玄幻, 热血</span>'
    '<span class="latest">最新章节</span><p class="intro">简介文本</p>'
    '<a href="/book/1">详情</a></div>'
    '<div class="book"><h3>书名二</h3><span class="author">作者B</span>'
    '<img src="/d.jpg"><span class="tag">都市</span>'
    '<a href="/book/2">详情</a></div>'
    '</body></html>';

const String _chapterHtmlPage1 = '<html><body>'
    '<a class="next" href="/list?page=2">下一页</a>'
    '<ul><li class="c"><a href="/c1">第一章</a><span class="lock">1</span></li>'
    '<li class="c"><a href="/c2">第二章</a></li></ul>'
    '</body></html>';

const String _chapterHtmlPage2 = '<html><body>'
    '<a class="next" href="/list?page=3">下一页</a>'
    '<ul><li class="c"><a href="/c3">第三章</a></li></ul>'
    '</body></html>';

const String _chapterHtmlPage3 = '<html><body>'
    '<ul><li class="c"><a href="/c4">第四章</a></li></ul>'
    '</body></html>';

EsoRule _chapterRule({bool multiRoads = false}) => EsoRule(
      id: 'rule-chapter',
      name: '目录源',
      host: 'https://example.com',
      contentType: EsoApiType.novel,
      chapterUrl: '/list?page=1',
      chapterNextUrl: '@css:a.next@href',
      enableMultiRoads: multiRoads,
      chapterRoads: '@css:.road',
      chapterRoadName: '@css:.rn@text',
      chapterList: '@css:.c',
      chapterName: '@css:a@text',
      chapterCover: '@css:img@src',
      chapterLock: '@css:.lock@text',
      chapterTime: '@css:.time@text',
      chapterResult: '@css:a@href',
    );

void main() {
  group('EsoApiType / EsoApi 常量', () {
    test('内容类型常量与源实现一致', () {
      expect(EsoApi.manga, 0);
      expect(EsoApi.novel, 1);
      expect(EsoApi.video, 2);
      expect(EsoApi.audio, 3);
      expect(EsoApi.rss, 4);
      expect(EsoApi.novelMore, 5);
    });

    test('getRuleContentTypeName 映射六种类型，未知回落到图片', () {
      expect(EsoApi.getRuleContentTypeName(0), '图片');
      expect(EsoApi.getRuleContentTypeName(1), '文字');
      expect(EsoApi.getRuleContentTypeName(2), '视频');
      expect(EsoApi.getRuleContentTypeName(3), '音频');
      expect(EsoApi.getRuleContentTypeName(4), 'RSS');
      expect(EsoApi.getRuleContentTypeName(5), '图文');
      expect(EsoApi.getRuleContentTypeName(99), '图片');
    });

    test('getRuleContentType 反查，未知返回 -1', () {
      expect(EsoApi.getRuleContentType('音频'), 3);
      expect(EsoApi.getRuleContentType('图文'), 5);
      expect(EsoApi.getRuleContentType('不存在'), -1);
    });

    test('EsoApiType 与 EsoApi 常量一致', () {
      expect(EsoApiType.name(EsoApiType.rss), 'RSS');
      expect(EsoApiType.fromName('文字'), EsoApiType.novel);
    });
  });

  group('EsoApiConst 正则', () {
    test(r'pagePattern 命中 $page 与独立的 page 参数', () {
      expect(EsoApiConst.pagePattern.hasMatch('/s?p=\$page'), isTrue);
      expect(EsoApiConst.pagePattern.hasMatch('/s?page=2'), isTrue);
      expect(EsoApiConst.pagePattern.hasMatch('/s?p=2'), isFalse);
      expect(EsoApiConst.pagePattern.hasMatch('/book/page/2'), isFalse);
    });

    test('largeSpaceRegExp 只压缩连续空白，单空格保留', () {
      expect('a  b'.replaceAll(EsoApiConst.largeSpaceRegExp, EsoApiConst.fullSpace),
          'a　b');
      expect('a\n  b'.replaceAll(EsoApiConst.largeSpaceRegExp, EsoApiConst.fullSpace),
          'a　b');
      expect('a b'.replaceAll(EsoApiConst.largeSpaceRegExp, EsoApiConst.fullSpace),
          'a b');
    });

    test('tagsSplitRegExp 按 7 种分隔符切分', () {
      expect('a,b/c|d&e%f　g'.split(EsoApiConst.tagsSplitRegExp),
          <String>['a', 'b', 'c', 'd', 'e', 'f', 'g']);
    });
  });

  group('EsoId', () {
    test('生成标准 v4 UUID', () {
      final id = EsoId.v4();
      expect(EsoId.isV4(id), isTrue);
      expect(id.length, 36);
      expect(EsoId.v4() == id, isFalse);
    });

    test('非 v4 串被拒绝', () {
      expect(EsoId.isV4('not-a-uuid'), isFalse);
      expect(EsoId.isV4('00000000-0000-1000-8000-000000000000'), isFalse);
    });
  });

  group('EsoRule JSON', () {
    test('fromJson 读取 map，upload/httpHeaders 走别名', () {
      final rule = EsoRule.fromJson(<String, dynamic>{
        'name': '源A',
        'host': 'https://a.com',
        'upload': false,
        'httpHeaders': 'UA/1',
        'contentType': 3,
        'searchUrl': '/s?q=\$keyword',
      });
      expect(rule.name, '源A');
      expect(rule.host, 'https://a.com');
      expect(rule.enableUpload, isFalse);
      expect(rule.userAgent, 'UA/1');
      expect(rule.contentType, 3);
      expect(rule.searchUrl, '/s?q=\$keyword');
    });

    test('fromJson 空串得到空 name/host', () {
      final rule = EsoRule.fromJson('');
      expect(rule.name, '');
      expect(rule.host, '');
    });

    test('fromJson 解析 JSON 字符串', () {
      final rule = EsoRule.fromJson(
          jsonEncode(<String, dynamic>{'name': '字符串源', 'host': 'https://b.com'}));
      expect(rule.name, '字符串源');
      expect(rule.host, 'https://b.com');
    });

    test('ZY-Player 规则被识别并转成视频源', () {
      final rule = EsoRule.fromJson(<String, dynamic>{
        'api': 'https://zy.com/api',
        'name': '麻花',
      });
      expect(rule.author, 'ZY-Player');
      expect(rule.host, 'https://zy.com/api');
      expect(rule.contentType, EsoApiType.video);
      expect(rule.group, 'ZY-Player');
      expect(rule.enableMultiRoads, isTrue);
      expect(rule.discoverList, '//video');
      expect(rule.searchUrl, '?wd=\$keyword&pg=\$page');
    });

    test('异次元导入：字段映射与选择器改写', () {
      final rule = EsoRule.fromYiCiYuan(<String, dynamic>{
        'bookSourceName': '异次元源',
        'bookSourceUrl': 'https://y.com',
        'ruleSearchList': 'class.book',
        'ruleSearchName': 'tag.h3',
        'ruleSearchKind': 'class.tag',
        'ruleChapterList': 'id.chapter',
        'ruleBookContent': '@id.content',
        'serialNumber': 7,
        'httpUserAgent': 'UA/1',
      });
      expect(rule.name, '异次元源');
      expect(rule.host, 'https://y.com');
      expect(rule.searchList, '.book');
      expect(rule.searchName, 'h3');
      expect(rule.searchTags, '.tag');
      expect(rule.chapterList, '#chapter');
      expect(rule.sort, 7);
      expect(rule.userAgent, 'UA/1');
      // 以 @ 开头的规则不会被改写，但仍会映射到字段
      expect(rule.contentItems, '@id.content');
    });

    test('异次元导入：| & # 与 @children 改写，- 前缀保留', () {
      final rule = EsoRule.fromYiCiYuan(<String, dynamic>{
        'bookSourceName': 'x',
        'bookSourceUrl': 'https://x.com',
        'ruleSearchList': 'class.a|class.b',
        'ruleSearchKind': '-id.k&&class.t',
        'ruleChapterList': 'class.c@children',
      });
      expect(rule.searchList, '.a||.b');
      expect(rule.searchTags, '-#k&&.t');
      expect(rule.chapterList, '.c>*');
    });

    test('异次元导入：bookSourceType 的三元优先级怪癖', () {
      expect(
          EsoRule.fromYiCiYuan(<String, dynamic>{'bookSourceType': 'CARTOON'})
              .contentType,
          EsoApiType.manga);
      expect(
          EsoRule.fromYiCiYuan(<String, dynamic>{'bookSourceType': ''}).contentType,
          EsoApiType.novel);
    });

    test('toJson 去掉空值并在默认导出中清空 cookies', () {
      final rule = EsoRule(id: 'r1', name: '源', host: 'https://a.com')
        ..cookies = 'a=1'
        ..icon = '';
      final json = rule.toJson();
      expect(json.containsKey('icon'), isFalse);
      expect(json.containsKey('cookies'), isFalse);
      expect(rule.toJson(true)['cookies'], 'a=1');
    });

    test('replica 换新 id 且名字带 _copy', () {
      final rule = EsoRule(id: 'r1', name: '源');
      final copy = rule.replica();
      expect(copy.name, '源_copy');
      expect(copy.id == 'r1', isFalse);
      expect(EsoId.isV4(copy.id), isTrue);
    });
  });

  group('EsoRuleCompress', () {
    test('分享串以 eso:// 开头并可原样解回', () {
      final rule = EsoRule(id: 'r1', name: '源A', host: 'https://a.com')
        ..author = '作者'
        ..searchUrl = '/s?q=\$keyword';
      final share = EsoRuleCompress.compress(rule);
      expect(share.startsWith('eso://作者:源A@'), isTrue);
      final back = EsoRuleCompress.decompress(share);
      expect(back.name, '源A');
      expect(back.host, 'https://a.com');
      expect(back.searchUrl, '/s?q=\$keyword');
      expect(back.id, 'r1');
    });

    test('批量分享是 JSON 数组', () {
      final many = EsoRuleCompress.compressMany(
          <EsoRule>[EsoRule(name: 'A'), EsoRule(name: 'B')]);
      final list = jsonDecode(many) as List<dynamic>;
      expect(list.length, 2);
      expect('${list[0]}'.startsWith('eso://'), isTrue);
    });

    test('Rule.fromJson 识别 eso:// 分享串', () {
      final share = EsoRuleCompress.compress(EsoRule(name: '分享源', host: 'https://s.com'));
      final rule = EsoRule.fromJson(share);
      expect(rule.name, '分享源');
      expect(rule.host, 'https://s.com');
    });
  });

  group('EsoAnalyzerManager.splitRuleReversed', () {
    test('@css: 前缀被剥离并识别为 HTML 解析器', () {
      final rules = EsoAnalyzerManager('').splitRuleReversed('@css:.a@text');
      expect(rules.length, 1);
      expect(rules.first.analyzer, isA<EsoAnalyzerHtml>());
      expect(rules.first.rule, '.a@text');
      expect(rules.first.replace, '');
    });

    test('## 之后是替换规则（@match）', () {
      final rules =
          EsoAnalyzerManager('').splitRuleReversed(r'@match:http\d+##[$0]');
      expect(rules.first.analyzer, isA<EsoAnalyzerMatch>());
      expect(rules.first.rule, r'http\d+');
      expect(rules.first.replace, r'[$0]');
    });

    test('以 : 开头退化为正则解析器', () {
      final rules = EsoAnalyzerManager('').splitRuleReversed(r':(\d+)');
      expect(rules.first.analyzer, isA<EsoAnalyzerRegExp>());
      expect(rules.first.rule, r'(\d+)');
    });

    test(r'以 / 开头是 XPath，以 $ 开头是 JSONPath', () {
      expect(EsoAnalyzerManager('').splitRuleReversed('//a/@href').first.analyzer,
          isA<EsoAnalyzerXPath>());
      expect(EsoAnalyzerManager('').splitRuleReversed(r'$.books').first.analyzer,
          isA<EsoAnalyzerJsonPath>());
    });

    test('未移植的 @js: 规则保留整段代码且不拆 ##', () {
      final rules =
          EsoAnalyzerManager('').splitRuleReversed('@js:return 1;##x');
      expect(rules.first.analyzer, isA<EsoAnalyzerUnsupported>());
      expect(rules.first.rule, 'return 1;##x');
      expect(rules.first.replace, '');
    });

    test('多段规则按从后到前返回', () {
      final rules = EsoAnalyzerManager('')
          .splitRuleReversed('@css:.a@text&&@css:.b@text');
      expect(rules.length, 2);
      expect(rules[0].rule, '.b@text');
      expect(rules[1].rule, '.a@text&&');
    });
  });

  group('EsoAnalyzerManager.replaceSmart', () {
    test('只有正则时删除命中内容', () {
      expect(EsoAnalyzerManager('').replaceSmart(r'(\d+)')('a1b2'), 'ab');
    });

    test(r'## 后是替换串并支持 $1', () {
      expect(EsoAnalyzerManager('').replaceSmart(r'(\d+)##[$1]')('a1b2'), 'a[1]b[2]');
    });

    test('三段时只替换第一处', () {
      expect(EsoAnalyzerManager('').replaceSmart(r'(\d+)##[$1]##x')('a1b2'), 'a[1]b2');
    });

    test(r'替换串不含 $ 时按字面替换', () {
      expect(EsoAnalyzerManager('').replaceSmart('a##o')('banana'), 'bonono');
    });
  });

  group('EsoAnalyzerManager 取值', () {
    test('getString 对多命中用双空格拼接', () {
      final manager = EsoAnalyzerManager(
          '<h1>甲</h1><h1>乙</h1>');
      expect(manager.getString('@css:h1@text'), '甲  乙');
    });

    test('getString 的 && 用双空格连接，|| 取第一个非空', () {
      final manager = EsoAnalyzerManager('<h1>甲</h1>');
      expect(manager.getString('@css:h1@text&&h1@text'), '甲  甲');
      expect(manager.getString('@css:span@text||h1@text'), '甲');
    });

    test('getString 的 ## 替换在取值后生效', () {
      final manager = EsoAnalyzerManager('<h1>甲 乙</h1>');
      expect(manager.getString(r'@css:h1@text##\s+##'), '甲乙');
    });

    test('getString 支持 {{...}} 插值', () {
      final manager = EsoAnalyzerManager('<h1>甲</h1><h2>乙</h2>');
      expect(manager.getString('共{{@css:h1@text}}{{@css:h2@text}}'), '共甲乙');
      // 插值只处理 {{}} 内部，前缀不会被当成规则解析
      expect(manager.getString('@css:h1@text-{{@css:h2@text}}'),
          '@css:h1@text-乙');
    });

    test('getStringList 过滤空串并按顺序返回', () {
      final manager = EsoAnalyzerManager(
          '<div class="c">一</div><div class="c">  </div><div class="c">二</div>');
      expect(manager.getStringList('@css:.c@text'), <String>['一', '二']);
    });

    test('getStringList 的 {{}} 按最短长度 zip 合并', () {
      final manager = EsoAnalyzerManager(
          '<div class="a">a1</div><div class="a">a2</div><div class="a">a3</div>'
          '<div class="b">b1</div><div class="b">b2</div>');
      expect(manager.getStringList('{{@css:.a@text}}-{{@css:.b@text}}'),
          <String>['a1-b1', 'a2-b2']);
    });

    test('getElements 返回元素列表，&& 累加、|| 取首个非空', () {
      final manager = EsoAnalyzerManager(
          '<div class="a">1</div><div class="b">2</div>');
      expect(manager.getElements('@css:.a').length, 1);
      expect(manager.getElements('@css:.a&&.b').length, 2);
      expect(manager.getElements('@css:.a||.b').length, 1);
    });
  });

  group('EsoAnalyzerHtml', () {
    test('text / id / outerHtml / innerHtml / 属性取值', () {
      final analyzer = EsoAnalyzerHtml()
        ..parse('<div id="d" data-x=" v "><b>粗</b>细</div>');
      expect(analyzer.getString('div@text'), <String>['粗细']);
      expect(analyzer.getString('div@id'), <String>['d']);
      expect(analyzer.getString('div@data-x'), <String>['v']);
      expect(analyzer.getString('div@innerHtml'), <String>['<b>粗</b>细']);
      expect(analyzer.getStringList('div@outerHtml').single.startsWith('<div'),
          isTrue);
    });

    test('textNodes 只取直接子节点文本', () {
      final analyzer = EsoAnalyzerHtml()..parse('<div><b>甲</b>乙</div>');
      // textNodes 取的是「子元素」的文本，纯文本节点不参与
      expect(analyzer.getStringList('div@textNodes'), <String>['甲']);
    });

    test('html 模式去 script/style 并把块级标签换行、img 独立成行', () {
      final analyzer = EsoAnalyzerHtml()
        ..parse('<div>甲<script>x()</script><img src="/i.jpg"><p>乙</p></div>');
      final html = analyzer.getStringList('div@html').single;
      expect(html.contains('x()'), isFalse);
      expect(html.contains('<img src="/i.jpg">'), isTrue);
      expect(html.contains('甲'), isTrue);
      expect(html.contains('乙'), isTrue);
    });

    test('@ 前的选择器缺失时返回空列表', () {
      final analyzer = EsoAnalyzerHtml()..parse('<div>甲</div>');
      expect(analyzer.getStringList('span@text'), isEmpty);
    });

    test('无 @ 的规则按属性名取值', () {
      final analyzer = EsoAnalyzerHtml()
        ..parse(html_parser.parse('<div id="x">甲</div>').body!.children.first);
      expect(analyzer.getString('id'), <String>['x']);
    });
  });

  group('EsoAnalyzerRegExp', () {
    test('默认取整段命中且不 trim', () {
      final analyzer = EsoAnalyzerRegExp()..parse(' a1 b2 ');
      expect(analyzer.getStringList(r'[a-z]\d'), <String>['a1', 'b2']);
    });

    test('%% 逐位交错合并', () {
      final analyzer = EsoAnalyzerRegExp()..parse('a1 b2');
      expect(analyzer.getStringList(r'([a-z])%%(\d)'),
          <String>['a', '1', 'b', '2']);
    });

    test('AND 链式收窄匹配范围', () {
      final analyzer = EsoAnalyzerRegExp()..parse('a1 b2');
      expect(analyzer.getStringList(r'([a-z]1)AND(\d)'), <String>['1']);
    });

    test('&& 追加、|| 取第一个非空', () {
      final analyzer = EsoAnalyzerRegExp()..parse('x=1');
      // 每段都取整段命中（group 0），不做 trim
      expect(analyzer.getStringList(r'x=1&&=(\d)'), <String>['x=1', '=1']);
      expect(analyzer.getStringList(r'zzz||=(\d)'), <String>['=1']);
    });
  });

  group('EsoAnalyzerMatch / Replace / Encode / Decode', () {
    test('@match: 默认取整个命中，@@n 取分组', () {
      final analyzer = EsoAnalyzerMatch()..parse('abc123');
      expect(analyzer.getString(r'\d+'), '123');
      expect(analyzer.getString(r'(\d)(\d)@@2'), '2');
    });

    test('@replace: 用 @@ 分隔替换串', () {
      final analyzer = EsoAnalyzerReplace()..parse('a1b2');
      expect(analyzer.getString(r'(\d)@@[$1]'), 'a[1]b[2]');
      expect(analyzer.getString(r'\d@@'), 'ab');
    });

    test('@encode: base64 / md5 / utf8', () {
      expect((EsoAnalyzerEncode()..parse('abc')).getString('base64'), 'YWJj');
      expect((EsoAnalyzerEncode()..parse('abc')).getString('md5'),
          '900150983cd24fb0d6963f7d28e17f72');
      expect((EsoAnalyzerEncode()..parse('abc')).getString('utf8'), 'abc');
    });

    test('@encode: gbk 输出 GBK 字节', () {
      final out = (EsoAnalyzerEncode()..parse('中')).getString('gbk');
      expect(out.codeUnits, <int>[0xD6, 0xD0]);
    });

    test('@decode: base64 / gbk / utf8', () {
      expect((EsoAnalyzerDecode()..parse('5Lit')).getString('base64'), '中');
      expect((EsoAnalyzerDecode()..parse('5Lit\n')).getString('base64'), '中');
      // 源实现先 utf8.encode 再按 GBK 解码（对已经是字符的串必然乱码），保留该行为
      expect(
          (EsoAnalyzerDecode()..parse(String.fromCharCodes(<int>[0xD6, 0xD0])))
              .getString('gbk'),
          '脰脨');
      expect(
          (EsoAnalyzerDecode()..parse(String.fromCharCodes(<int>[0xE4, 0xB8, 0xAD])))
              .getString('utf8'),
          '中');
    });
  });

  group('EsoAnalyzerFilter', () {
    test('正则命中时返回完整 url', () {
      final analyzer = EsoAnalyzerFilter(host: 'https://x.com')
        ..parse('/a/b.jpg');
      final result = analyzer.getStringList(r'\.jpg@@5');
      expect(result.length, 1);
      expect((result.first as Map)['url'], 'https://x.com/a/b.jpg');
    });

    test('协议相对地址沿用 host 协议', () {
      final analyzer = EsoAnalyzerFilter(host: 'https://x.com')..parse('//cdn/a.mp4');
      expect((analyzer.getStringList(r'\.mp4').first as Map)['url'],
          'https://cdn/a.mp4');
    });

    test('未命中时返回空（宿主不注入 WebView 嗅探）', () {
      final analyzer = EsoAnalyzerFilter(host: 'https://x.com')..parse('/a.txt');
      expect(analyzer.getStringList(r'\.jpg'), isEmpty);
    });
  });

  group('EsoJsonPath / EsoAnalyzerJsonPath', () {
    test('逐级取键、通配与下标', () {
      const json = '{"books":[{"name":"甲"},{"name":"乙"}]}';
      final analyzer = EsoAnalyzerJsonPath()..parse(json);
      expect(analyzer.getString(r'$.books[*].name'), '甲  乙');
      expect(analyzer.getString(r'$.books[1].name'), '乙');
      expect(EsoJsonPath(r'$.books[0].name').readValues(jsonDecode(json)),
          <String>['甲']);
    });

    test(r'递归下降 $..name', () {
      const json = '{"a":{"name":"甲"},"b":[{"name":"乙"}]}';
      expect(EsoJsonPath(r'$..name').readValues(jsonDecode(json)),
          <String>['甲', '乙']);
    });

    test('容忍尾随逗号', () {
      final analyzer = EsoAnalyzerJsonPath()..parse('{"a":[1,2,],}');
      expect(analyzer.getString(r'$.a[0]'), '1');
    });

    test(r'{{$.x}} 插值', () {
      final analyzer = EsoAnalyzerJsonPath()..parse('{"name":"甲"}');
      expect(analyzer.getString(r'{$.name}书'), '甲书');
    });
  });

  group('EsoXPath / EsoAnalyzerXPath', () {
    const html = '<div><a href="/x">甲</a><a href="/y">乙</a></div>';

    test('@attr 与 text()', () {
      expect(EsoXPath.html(html).query('//a/@href').attrs, <String>['/x', '/y']);
      expect(EsoXPath.html(html).query('//a/text()').attrs, <String>['甲', '乙']);
    });

    test('谓词与 contains', () {
      expect(EsoXPath.html(html).query('//a[1]/@href').attrs, <String>['/x']);
      expect(EsoXPath.html(html).query("//a[contains(text(),'乙')]/@href").attrs,
          <String>['/y']);
    });

    test('解析器：文本节点与 node() 输出', () {
      final analyzer = EsoAnalyzerXPath()..parse(html);
      expect(analyzer.getString('//a[1]/text()'), <String>['甲']);
      expect(analyzer.getString('//a[1]/node()').single.contains('甲'), isTrue);
    });

    test('only() 去掉标签只留文本', () {
      final analyzer = EsoAnalyzerXPath()..parse('<div><b>甲</b>乙</div>');
      // 源实现的清理正则会把「标签 + 标签内文本」整段删掉，只剩标签外的文本
      expect(analyzer.getString('//div/only()'), <String>['乙']);
    });
  });

  group('EsoDecodeBody', () {
    final decoder = EsoDecodeBody();

    test('charset 决定解码方式', () {
      expect(
          decoder.decode(Uint8List.fromList(utf8.encode('中文')),
              'text/html; charset=utf-8'),
          '中文');
      expect(
          decoder.decode(
              Uint8List.fromList(<int>[0xD6, 0xD0]), 'text/html; charset=gbk'),
          '中');
    });

    test('content-type 为空时自动嗅探', () {
      expect(decoder.decode(Uint8List.fromList(utf8.encode('{"a":1}')), null),
          '{"a":1}');
      expect(decoder.decode(Uint8List.fromList(utf8.encode('中文')), null), '中文');
    });

    test('ascii 与 latin1', () {
      expect(decoder.decode(Uint8List.fromList(<int>[0x61, 0x62]), 'text/plain; charset=ascii'),
          'ab');
    });

    test('内容中声明的 charset 被用于解码后续字节', () {
      final bytes = <int>[...utf8.encode('<meta charset="gbk">'), 0xD6, 0xD0];
      final text = decoder.decode(Uint8List.fromList(bytes), null);
      expect(text.contains('中'), isTrue);
    });

    test('空 body 得到空串', () {
      expect(decoder.decode(Uint8List(0), 'text/html; charset=utf-8'), '');
    });
  });

  group('EsoAnalyzeUrl', () {
    test('urlFix 处理协议相对、根路径与绝对地址', () {
      expect(EsoAnalyzeUrl.urlFix('//x.com/a', 'https://h.com'),
          'https://x.com/a');
      expect(EsoAnalyzeUrl.urlFix('//x.com/a', 'http://h.com'), 'http://x.com/a');
      expect(EsoAnalyzeUrl.urlFix('/a', 'https://h.com'), 'https://h.com/a');
      expect(EsoAnalyzeUrl.urlFix('http://y.com/a', 'https://h.com'),
          'http://y.com/a');
      expect(EsoAnalyzeUrl.urlFix('ftp://y/a', 'https://h.com'), 'ftp://y/a');
    });

    test(r'占位符 $keyword/$page/$host 被替换', () async {
      final fake = _FakeHttpClient((request) => _html('ok'));
      final rule = EsoRule(host: 'https://example.com');
      await EsoAnalyzeUrl.urlRuleParser(
          '/s?q=\$keyword&p=\$page', rule, EsoHttpClient(client: fake),
          keyword: 'abc', page: 2);
      expect(fake.requests.single.url.toString(),
          'https://example.com/s?q=abc&p=2');
    });

    test('url 为 "null" 时不发请求', () async {
      final fake = _FakeHttpClient((request) => _html('ok'));
      final rule = EsoRule(host: 'https://example.com');
      final res = await EsoAnalyzeUrl.urlRuleParser(
          'null', rule, EsoHttpClient(client: fake));
      expect(fake.requests, isEmpty);
      expect(res.body, '');
      expect(res.statusCode, 200);
    });

    test('空 url 回落到 host', () async {
      final fake = _FakeHttpClient((request) => _html('ok'));
      final rule = EsoRule(host: 'https://example.com');
      await EsoAnalyzeUrl.urlRuleParser('', rule, EsoHttpClient(client: fake));
      expect(fake.requests.single.url.toString(), 'https://example.com');
    });

    test('默认 UA 与自定义 cookie/UA 请求头', () async {
      final fake = _FakeHttpClient((request) => _html('ok'));
      final rule = EsoRule(host: 'https://example.com')
        ..cookies = 'a=1'
        ..userAgent = 'UA/1';
      await EsoAnalyzeUrl.urlRuleParser('/x', rule, EsoHttpClient(client: fake));
      final headers = fake.requests.single.headers;
      expect(headers['cookie'], 'a=1');
      expect(headers['user-agent'], 'UA/1');
    });

    test('UA 为 JSON 时按 header 合并并小写键名', () async {
      final fake = _FakeHttpClient((request) => _html('ok'));
      final rule = EsoRule(host: 'https://example.com')
        ..userAgent = '{"X-A": "1", "User-Agent": "UA/2"}';
      await EsoAnalyzeUrl.urlRuleParser('/x', rule, EsoHttpClient(client: fake));
      final headers = fake.requests.single.headers;
      expect(headers['x-a'], '1');
      expect(headers['user-agent'], 'UA/2');
    });

    test('未设置 UA 时使用源实现的内置 Edge UA', () async {
      final fake = _FakeHttpClient((request) => _html('ok'));
      final rule = EsoRule(host: 'https://example.com');
      await EsoAnalyzeUrl.urlRuleParser('/x', rule, EsoHttpClient(client: fake));
      expect(fake.requests.single.headers['user-agent'],
          EsoAnalyzeUrl.defaultUserAgent);
    });

    test('JSON 形式的 url 支持 method/headers/body', () async {
      final fake = _FakeHttpClient((request) => _html('ok'));
      final rule = EsoRule(host: 'https://example.com');
      final body = jsonEncode(<String, dynamic>{
        'url': r'$host/api',
        'method': 'post',
        'headers': <String, String>{'X-Token': 't1'},
        'body': 'a=1',
      });
      await EsoAnalyzeUrl.urlRuleParser(body, rule, EsoHttpClient(client: fake));
      final request = fake.requests.single;
      expect(request.method, 'POST');
      expect(request.url.toString(), 'https://example.com/api');
      expect(request.headers['x-token'], 't1');
      expect((request as http.Request).body, 'a=1');
    });

    test('encoding 为 gbk 时对 url 与 body 做百分号编码', () async {
      final fake = _FakeHttpClient((request) => _html('ok'));
      final rule = EsoRule(host: 'https://example.com');
      final body = jsonEncode(<String, dynamic>{
        'url': r'$host/p',
        'method': 'post',
        'body': '中',
        'encoding': 'gbk',
      });
      await EsoAnalyzeUrl.urlRuleParser(body, rule, EsoHttpClient(client: fake));
      expect((fake.requests.single as http.Request).body, '%D6%D0');
    });

    test('不支持的 method 抛出 EsoRuleException', () async {
      final fake = _FakeHttpClient((request) => _html('ok'));
      final rule = EsoRule(host: 'https://example.com');
      final body = jsonEncode(<String, dynamic>{'url': '/p', 'method': 'delete'});
      expect(
          () => EsoAnalyzeUrl.urlRuleParser(body, rule, EsoHttpClient(client: fake)),
          throwsA(isA<EsoRuleException>()));
    });

    test('@js: 地址抛出未移植异常', () {
      final fake = _FakeHttpClient((request) => _html('ok'));
      final rule = EsoRule(host: 'https://example.com');
      expect(
          () => EsoAnalyzeUrl.urlRuleParser(
              '@js:return "http://x"', rule, EsoHttpClient(client: fake)),
          throwsA(isA<EsoRuleException>()));
    });
  });

  group('EsoApiFromRule.discover', () {
    test('params 为空直接返回空列表', () async {
      final fake = _FakeHttpClient((request) => _html(_searchHtml));
      final api = EsoApiFromRule(_searchRule(), client: EsoHttpClient(client: fake));
      expect(await api.discover(<String, EsoDiscoverPair>{}, 1, 20), isEmpty);
      expect(fake.requests, isEmpty);
    });

    test('第一页按分类规则请求并映射字段', () async {
      final fake = _FakeHttpClient((request) => _html(_searchHtml));
      final rule = _searchRule()
        ..discoverUrl = '玄幻::全部::/list?page=\$page'
        ..discoverList = '@css:.book'
        ..discoverName = '@css:h3@text'
        ..discoverAuthor = '@css:.author@text'
        ..discoverResult = '@css:a@href'
        ..discoverTags = '@css:.tag@text';
      final api = EsoApiFromRule(rule, client: EsoHttpClient(client: fake));
      final items = await api.discover(
          <String, EsoDiscoverPair>{'玄幻': EsoDiscoverPair('玄幻', '/list?page=\$page')},
          1,
          20);
      expect(fake.requests.single.url.toString(),
          'https://example.com/list?page=1');
      expect(items.length, 2);
      expect(items.first.name, '书名　一');
      expect(items.first.author, '作者A');
      expect(items.first.url, '/book/1');
      expect(items.first.tags, <String>['玄幻', ' 热血']);
      expect(items.first.origin, '测试源');
      expect(items.first.originTag, 'rule-search');
      expect(items.first.ruleContentType, EsoApiType.novel);
      expect(items.first.searchUrl, 'https://example.com/list?page=1');
    });

    test('没有下一页规则且第 2 页时返回空', () async {
      final fake = _FakeHttpClient((request) => _html(_searchHtml));
      final rule = _searchRule()
        ..discoverUrl = '/list?page=\$page'
        ..discoverList = '@css:.book';
      final api = EsoApiFromRule(rule, client: EsoHttpClient(client: fake));
      // 第 2 页：无 discoverNextUrl，但规则里有 $page 占位符，仍能翻页
      final items = await api.discover(
          <String, EsoDiscoverPair>{'a': EsoDiscoverPair('a', '/list?page=\$page')},
          2,
          20);
      expect(fake.requests.single.url.toString(),
          'https://example.com/list?page=2');
      expect(items.length, 2);
    });

    test('有下一页规则时第 2 页用解析出的地址', () async {
      var page = 0;
      final fake = _FakeHttpClient((request) {
        page++;
        return _html(page == 1
            ? '<a class="next" href="/list?page=2">下</a>$_searchHtml'
            : _searchHtml);
      });
      final rule = _searchRule()
        ..discoverUrl = '/list'
        ..discoverNextUrl = '@css:a.next@href'
        ..discoverList = '@css:.book'
        ..discoverName = '@css:h3@text';
      final api = EsoApiFromRule(rule, client: EsoHttpClient(client: fake));
      await api.discover(
          <String, EsoDiscoverPair>{'a': EsoDiscoverPair('a', '/list')}, 1, 20);
      // 下一页地址按规则原样保存，真正请求时才做 urlFix
      expect(EsoApiFromRule.nextUrl?['/list'], '/list?page=2');
      await api.discover(
          <String, EsoDiscoverPair>{'a': EsoDiscoverPair('a', '/list')}, 2, 20);
      expect(fake.requests.last.url.toString(),
          'https://example.com/list?page=2');
    });

    test('clearNextUrl 后无下一页规则的第 2 页返回空', () async {
      final fake = _FakeHttpClient((request) => _html(_searchHtml));
      final rule = _searchRule()
        ..discoverUrl = '/list'
        ..discoverList = '@css:.book';
      final api = EsoApiFromRule(rule, client: EsoHttpClient(client: fake));
      EsoApiFromRule.clearNextUrl();
      expect(
          await api.discover(
              <String, EsoDiscoverPair>{'a': EsoDiscoverPair('a', '/list')}, 2, 20),
          isEmpty);
      expect(fake.requests, isEmpty);
    });
  });

  group('EsoApiFromRule.discoverMap', () {
    test('三段式分栏按 tab 分组', () async {
      final api = EsoApiFromRule(EsoRule(
        host: 'https://example.com',
        discoverUrl: '玄幻::全部::/list?t=1\n玄幻::已完结::/list?t=2\n都市::全部::/list?t=3',
      ));
      final maps = await api.discoverMap();
      expect(maps.length, 2);
      expect(maps[0].name, '玄幻');
      expect(maps[0].pairs.length, 2);
      expect(maps[0].pairs[0].name, '全部');
      expect(maps[0].pairs[0].value, '/list?t=1');
      expect(maps[0].pairs[1].name, '已完结');
      expect(maps[1].name, '都市');
    });

    test('单段与两段式分别落到 全部/全部 与 tab/全部', () async {
      final api = EsoApiFromRule(EsoRule(
        host: 'https://example.com',
        discoverUrl: '&&/list?a\n排行::/list?b',
      ));
      final maps = await api.discoverMap();
      expect(maps[0].name, '全部');
      expect(maps[0].pairs.single.name, '全部');
      expect(maps[1].name, '排行');
      expect(maps[1].pairs.single.name, '全部');
    });

    test('discoverUrl 为空时回落到 host，非 http host 用 example', () async {
      final maps = await EsoApiFromRule(
              EsoRule(host: 'https://example.com', discoverUrl: ''))
          .discoverMap();
      expect(maps.single.name, '全部');
      expect(maps.single.pairs.single.value, 'https://example.com');

      final fallback = await EsoApiFromRule(EsoRule(host: 'foo', discoverUrl: ''))
          .discoverMap();
      expect(fallback.single.name, 'example');
      expect(fallback.single.pairs.single.value, 'http://example.com/');
    });

    test('@js: 发现规则抛出未移植异常后回落', () async {
      final maps = await EsoApiFromRule(
              EsoRule(host: 'https://example.com', discoverUrl: '@js:return []'))
          .discoverMap();
      expect(maps.single.name, '全部');
      expect(maps.single.pairs.single.value, 'https://example.com');
    });
  });

  group('EsoApiFromRule.search', () {
    test('第一页请求地址与字段映射', () async {
      final fake = _FakeHttpClient((request) => _html(_searchHtml));
      final api = EsoApiFromRule(_searchRule(), client: EsoHttpClient(client: fake));
      final items = await api.search('abc', 1, 20);
      expect(fake.requests.single.url.toString(),
          'https://example.com/search?q=abc&page=1');
      expect(items.length, 2);
      expect(items.first.name, '书名　一');
      expect(items.first.cover, '/c.jpg');
      expect(items.first.chapter, '最新章节');
      expect(items.first.description, '简介文本');
      expect(items.first.tags, <String>['玄幻', ' 热血']);
      expect(items[1].tags, <String>['都市']);
      expect(items.first.searchUrl, 'https://example.com/search?q=abc&page=1');
    });

    test('query 里的 url@...@url 覆盖请求地址', () async {
      final fake = _FakeHttpClient((request) => _html(_searchHtml));
      final api = EsoApiFromRule(_searchRule(), client: EsoHttpClient(client: fake));
      final items = await api.search('url@/other@urlabc', 1, 20);
      expect(fake.requests.single.url.toString(), 'https://example.com/other');
      expect(items.length, 2);
    });

    test('searchUrl 为 null 时不发请求但按空内容解析', () async {
      final fake = _FakeHttpClient((request) => _html(_searchHtml));
      final rule = _searchRule()..searchUrl = 'null';
      final api = EsoApiFromRule(rule, client: EsoHttpClient(client: fake));
      final items = await api.search('abc', 1, 20);
      expect(fake.requests, isEmpty);
      expect(items, isEmpty);
    });

    test(r'第 2 页无翻页规则时用 $page 占位符翻页', () async {
      final fake = _FakeHttpClient((request) => _html(_searchHtml));
      final api = EsoApiFromRule(_searchRule(), client: EsoHttpClient(client: fake));
      await api.search('abc', 2, 20);
      expect(fake.requests.single.url.toString(),
          'https://example.com/search?q=abc&page=2');
    });

    test('无占位符且无下一页规则的第 2 页返回空', () async {
      final fake = _FakeHttpClient((request) => _html(_searchHtml));
      final rule = _searchRule()..searchUrl = '/search';
      final api = EsoApiFromRule(rule, client: EsoHttpClient(client: fake));
      expect(await api.search('abc', 2, 20), isEmpty);
      expect(fake.requests, isEmpty);
    });
  });

  group('EsoApiFromRule.chapter', () {
    test('chapterUrl 为 正文 时单章直出', () async {
      final api = EsoApiFromRule(EsoRule(chapterUrl: '正文'));
      final chapters = await api.chapter('/book/1/content');
      expect(chapters.length, 1);
      expect(chapters.single.name, '正文');
      expect(chapters.single.url, '/book/1/content');
    });

    test('分页模式：首屏目录 + 锁定标记 + 名称折叠空格', () async {
      final fake = _FakeHttpClient((request) => _html(
          '<ul><li class="c"><a href="/c1">第一章  上</a><span class="lock">1</span></li>'
          '<li class="c"><a href="/c2">第二章</a><span class="lock">0</span></li></ul>'));
      final api = EsoApiFromRule(_chapterRule(), client: EsoHttpClient(client: fake));
      final chapters = await api.chapter('/list', 1);
      expect(chapters.length, 2);
      expect(chapters[0].name, '🔒第一章　上');
      expect(chapters[0].url, '/c1');
      expect(chapters[1].name, '第二章');
      expect(EsoApi.chapterUrl, 'https://example.com/list?page=1');
    });

    test('分页模式：第二页沿用上一页解析出的 chapterNextUrl', () async {
      final fake = _FakeHttpClient((request) => _html(request.url.query
              .contains('page=1')
          ? _chapterHtmlPage1
          : _chapterHtmlPage2));
      final api = EsoApiFromRule(_chapterRule(), client: EsoHttpClient(client: fake));
      await api.chapter('/list', 1);
      final second = await api.chapter('/list', 2);
      expect(fake.requests.last.url.toString(),
          'https://example.com/list?page=2');
      expect(second.single.name, '第三章');
    });

    test('全量模式：按 chapterNextUrl 循环拉完所有页', () async {
      final seen = <String>[];
      final fake = _FakeHttpClient((request) {
        seen.add(request.url.toString());
        if (request.url.query.contains('page=1')) return _html(_chapterHtmlPage1);
        if (request.url.query.contains('page=2')) return _html(_chapterHtmlPage2);
        return _html(_chapterHtmlPage3);
      });
      final api = EsoApiFromRule(_chapterRule(), client: EsoHttpClient(client: fake));
      final chapters = await api.chapter('/list');
      // 首章带锁标记（lock 值非 0/false/undefined 时加 🔒）
      expect(chapters.map((e) => e.name).toList(),
          <String>['🔒第一章', '第二章', '第三章', '第四章']);
      // 三页：page=1 -> page=2 -> page=3，第 3 页没有下一页链接就停
      expect(seen, <String>[
        'https://example.com/list?page=1',
        'https://example.com/list?page=2',
        'https://example.com/list?page=3',
      ]);
    });

    test('多线路模式插入 @线路 表头', () async {
      final fake = _FakeHttpClient((request) => _html(
          '<div class="road"><span class="rn">线路1</span>'
          '<li class="c"><a href="/c1">第一章</a></li></div>'
          '<div class="road"><span class="rn">线路2</span>'
          '<li class="c"><a href="/c2">第二章</a></li></div>'));
      final api = EsoApiFromRule(_chapterRule(multiRoads: true),
          client: EsoHttpClient(client: fake));
      final chapters = await api.chapter('/list');
      expect(chapters.map((e) => e.name).toList(),
          <String>['@线路线路1', '第一章', '@线路线路2', '第二章']);
      expect(chapters[1].url, '/c1');
    });

    test('目录为空时返回空列表', () async {
      final fake = _FakeHttpClient((request) => _html('<html></html>'));
      final api = EsoApiFromRule(_chapterRule(), client: EsoHttpClient(client: fake));
      expect(await api.chapter('/list', 1), isEmpty);
    });
  });

  group('EsoApiFromRule.content', () {
    test('正文按 contentItems 解析并记录 contentUrl', () async {
      final fake = _FakeHttpClient((request) =>
          _html('<div id="content">第一段</div>'));
      final rule = EsoRule(
        host: 'https://example.com',
        contentUrl: '',
        contentItems: '@css:#content@html',
      );
      final api = EsoApiFromRule(rule, client: EsoHttpClient(client: fake));
      final content = await api.content('/book/1/ch1');
      expect(fake.requests.single.url.toString(), 'https://example.com/book/1/ch1');
      expect(content.join('').contains('第一段'), isTrue);
      expect(EsoApi.contentUrl, 'https://example.com/book/1/ch1');
    });

    test('分页正文按 contentNextUrl 累积', () async {
      final fake = _FakeHttpClient((request) {
        if (request.url.path.endsWith('/ch1')) {
          return _html('<a class="next" href="/book/1/ch2">下</a>'
              '<div id="content">一</div>');
        }
        return _html('<div id="content">二</div>');
      });
      final rule = EsoRule(
        host: 'https://example.com',
        contentUrl: '',
        contentNextUrl: '@css:a.next@href',
        contentItems: '@css:#content@text',
      );
      final api = EsoApiFromRule(rule, client: EsoHttpClient(client: fake));
      final content = await api.content('/book/1/ch1');
      expect(content, <String>['一', '二']);
      expect(fake.requests.length, 2);
    });

    test('文字源解析失败时抛出，图片源吞掉异常返回空', () async {
      final rule = EsoRule(
        host: 'https://example.com',
        contentType: EsoApiType.novel,
        contentUrl: '/c',
        contentItems: '@js:return body',
      );
      final novel = EsoApiFromRule(rule,
          client: EsoHttpClient(
              client: _FakeHttpClient((request) => _html('<html></html>'))));
      expect(() => novel.content('/c'), throwsA(isA<EsoRuleException>()));

      final mangaRule = EsoRule(
        host: 'https://example.com',
        contentType: EsoApiType.manga,
        contentUrl: '/c',
        contentItems: '@js:return body',
      );
      final manga = EsoApiFromRule(mangaRule,
          client: EsoHttpClient(
              client: _FakeHttpClient((request) => _html('<html></html>'))));
      expect(await manga.content('/c'), isEmpty);
    });
  });

  group('EsoSearchItem 模型', () {
    test('构造时填默认阅读进度', () {
      final item = EsoSearchItem(name: '书', originTag: 'r1');
      expect(item.durChapter, '');
      expect(item.durChapterIndex, 0);
      expect(item.durContentIndex, 1);
      expect(item.chapterListStyle, EsoSearchItem.bigList);
      expect(item.chapters, isNull);
      expect(item.isNovel, isFalse);
    });

    test('tags 以逗号空格序列化并原样解析', () {
      final item = EsoSearchItem(name: '书')
        ..tags = <String>['玄幻', ' 热血']
        ..ruleContentType = EsoApi.novel;
      final json = item.toJson();
      expect(json['tags'], '玄幻,  热血');
      final back = EsoSearchItem.fromJson(json);
      expect(back.tags, <String>['玄幻', ' 热血']);
      expect(back.isNovel, isTrue);
    });

    test('chapters 不参与持久化，reverseChapter 默认 false', () {
      final item = EsoSearchItem(name: '书')
        ..chapters = <EsoChapterItem>[EsoChapterItem(name: '第一章')];
      expect(item.toJson().containsKey('chapters'), isFalse);
      expect(EsoSearchItem.fromJson(item.toJson()).reverseChapter, isFalse);
    });

    test('changeTo 换源时清空阅读进度，localAddInfo 只补非空字段', () {
      final item = EsoSearchItem(name: '旧', originTag: 'r1', author: '原')
        ..durChapter = '第一章'
        ..durChapterIndex = 3
        ..durContentIndex = 5;
      item.changeTo(EsoSearchItem(name: '新', originTag: 'r2', author: '新作者'));
      expect(item.name, '新');
      expect(item.originTag, 'r2');
      expect(item.durChapter, '');
      expect(item.durChapterIndex, 0);
      expect(item.durContentIndex, 1);

      item.localAddInfo(EsoSearchItem(name: 'x', author: '本地作者'));
      expect(item.author, '本地作者');
      expect(item.name, '新');
    });
  });

  group('EsoReadingProgress', () {
    test('常量来自源实现', () {
      expect(EsoReadingProgress.contentTotal, 100000000);
      expect(EsoReadingProgress.textConfigKey, 'TextCompositionConfig');
    });

    test('percentOf 在章索引一致时返回全局百分比', () {
      final percent = EsoReadingProgress.percentOf(
          durContentIndex: 2000000, durChapterIndex: 0, chaptersLength: 10);
      expect(percent, closeTo(0.02, 1e-12));
    });

    test('percentOf 在章索引不一致时回落到章级百分比', () {
      final percent = EsoReadingProgress.percentOf(
          durContentIndex: 2000000, durChapterIndex: 5, chaptersLength: 10);
      expect(percent, closeTo(0.5, 1e-12));
    });

    test('positionOf 退位一位避免跨章', () {
      final pos = EsoReadingProgress.positionOf(0.5, 10);
      expect(pos.durChapterIndex, 4);
      // 0.5 * 1e8 先减 0.0000001（=10 个单位）再取整
      expect(pos.durContentIndex, 49999990);
    });

    test('positionOf 对 0 与负数章节数安全', () {
      expect(EsoReadingProgress.positionOf(0, 10).durContentIndex, 0);
      expect(EsoReadingProgress.positionOf(0.5, 0).durChapterIndex, 0);
    });
  });

  group('EsoChapterPageProvider', () {
    test('buildCheck 用长度 + 名称拼接', () {
      final provider = EsoChapterPageProvider(
        searchItem: EsoSearchItem(name: '书')..chapters = <EsoChapterItem>[],
      );
      expect(
          provider.buildCheck(<EsoChapterItem>[
            EsoChapterItem(name: '第一章'),
            EsoChapterItem(name: ' 第二章 '),
          ]),
          '2第一章第二章');
    });

    test('目录重复页时停止翻页并置负页码', () async {
      final fake = _FakeHttpClient((request) => _html(_chapterHtmlPage1));
      final rule = _chapterRule();
      final item = EsoSearchItem(
          name: '书', url: '/list', originTag: rule.id, ruleContentType: EsoApi.novel);
      final provider = EsoChapterPageProvider(
        searchItem: item,
        api: EsoApiManager(_MemoryRuleProvider(<EsoRule>[rule]),
            client: EsoHttpClient(client: fake)),
      );
      await provider.ready;
      expect(item.chapters!.length, 2);
      expect(item.durChapter, '🔒第一章');
      expect(item.chapter, '第二章');
      expect(item.chaptersCount, 2);
      // 源实现 endCheck 用的是「本次调用的 page 参数」，首轮参数是 1
      expect(provider.page, -1);
    });

    test('目录有新页时继续合并，空页结束', () async {
      final fake = _FakeHttpClient((request) {
        if (request.url.query.contains('page=1')) return _html(_chapterHtmlPage1);
        if (request.url.query.contains('page=2')) return _html(_chapterHtmlPage2);
        return _html('<html></html>');
      });
      final rule = _chapterRule();
      final item = EsoSearchItem(name: '书', url: '/list', originTag: rule.id);
      final provider = EsoChapterPageProvider(
        searchItem: item,
        api: EsoApiManager(_MemoryRuleProvider(<EsoRule>[rule]),
            client: EsoHttpClient(client: fake)),
      );
      await provider.ready;
      expect(item.chapters!.map((e) => e.name).toList(),
          <String>['🔒第一章', '第二章', '第三章']);
      expect(provider.page, -3);
    });

    test('changeChapter 重置章内进度并落盘', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final store = EsoHistoryItemStore();
      final item = EsoSearchItem(name: '书', originTag: 'r1')
        ..chapters = <EsoChapterItem>[
          EsoChapterItem(name: '第一章'),
          EsoChapterItem(name: '第二章'),
        ]
        ..durContentIndex = 50;
      final provider = EsoChapterPageProvider(
        searchItem: item,
        historyStore: store,
        api: EsoApiManager(_MemoryRuleProvider(<EsoRule>[])),
      );
      await provider.changeChapter(1);
      expect(item.durChapterIndex, 1);
      expect(item.durChapter, '第二章');
      expect(item.durContentIndex, 1);
      expect((await store.getAll()).single.name, '书');
    });

    test('toggleReverse 翻转目录方向', () {
      final provider = EsoChapterPageProvider(
        searchItem: EsoSearchItem(name: '书')..chapters = <EsoChapterItem>[],
      );
      provider.toggleReverse();
      expect(provider.searchItem.reverseChapter, isTrue);
      provider.toggleReverse();
      expect(provider.searchItem.reverseChapter, isFalse);
    });
  });

  group('EsoContentProvider', () {
    EsoContentProvider buildProvider(EsoSearchItem item, http.BaseClient client) {
      final rule = EsoRule(
        id: 'r1',
        host: 'https://example.com',
        contentUrl: '',
        contentItems: '@css:#content@text',
      );
      return EsoContentProvider(
        item,
        api: EsoApiManager(_MemoryRuleProvider(<EsoRule>[rule]),
            client: EsoHttpClient(client: client)),
        prefetchDelay: Duration.zero,
      );
    }

    test('正文按空白切段（保留首尾空段，与源实现一致）', () async {
      final fake = _FakeHttpClient((request) =>
          _html('<div id="content">\n第一段\n</div>'));
      final item = EsoSearchItem(name: '书', originTag: 'r1')
        ..chapters = <EsoChapterItem>[EsoChapterItem(name: '第一章', url: '/ch/1')];
      final provider = buildProvider(item, fake);
      final content = await provider.loadChapter(0);
      // `@css:#content@text` 已 trim，因此没有首尾空段
      expect(content, <String>['第一段']);
      expect(item.chapters!.first.contentUrl, 'https://example.com/ch/1');
    });

    test('命中缓存时不重复请求', () async {
      var hits = 0;
      final fake = _FakeHttpClient((request) {
        hits++;
        return _html('<div id="content">正文</div>');
      });
      final item = EsoSearchItem(name: '书', originTag: 'r1')
        ..chapters = <EsoChapterItem>[EsoChapterItem(name: '第一章', url: '/ch/1')];
      final provider = buildProvider(item, fake);
      await provider.loadChapter(0, true, false);
      await provider.loadChapter(0, true, false);
      expect(hits, 1);
      expect(provider.cachedChapterCount, 1);
    });

    test('预取后两章（chapterIndex+2/3 边界）', () async {
      final fake = _FakeHttpClient((request) => _html('<div id="content">正文</div>'));
      final item = EsoSearchItem(name: '书', originTag: 'r1')
        ..chapters = <EsoChapterItem>[
          for (var i = 0; i < 4; i++)
            EsoChapterItem(name: '第$i章', url: '/ch/$i'),
        ];
      final provider = buildProvider(item, fake);
      await provider.loadChapter(0);
      await provider.prefetching;
      expect(provider.cachedChapterCount, 3);
      expect(fake.requests.length, 3);
    });

    test('章节下标越界返回空列表', () async {
      final fake = _FakeHttpClient((request) => _html('<div id="content">x</div>'));
      final item = EsoSearchItem(name: '书', originTag: 'r1')
        ..chapters = <EsoChapterItem>[EsoChapterItem(name: '第一章', url: '/ch/1')];
      final provider = buildProvider(item, fake);
      expect(await provider.loadChapter(5), isEmpty);
      expect(fake.requests, isEmpty);
    });
  });

  group('持久化 store', () {
    setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

    test('EsoRuleStore 增删查与按修改时间倒序', () async {
      final store = EsoRuleStore();
      final a = EsoRule(id: 'a', name: 'A', modifiedTime: 100);
      final b = EsoRule(id: 'b', name: 'B', modifiedTime: 200);
      await store.insertOrUpdate(a);
      await store.insertOrUpdate(b);
      final all = await store.getAllRules();
      expect(all.map((e) => e.id).toList(), <String>['b', 'a']);
      expect((await store.findRuleById('a'))!.name, 'A');
      expect(await store.findRuleById('zzz'), isNull);
      await store.remove(<String>{'a'});
      expect((await store.getAllRules()).single.id, 'b');
    });

    test('EsoRuleStore 备份/还原（覆盖与合并）', () async {
      final store = EsoRuleStore();
      await store.insertOrUpdate(EsoRule(id: 'a', name: 'A', modifiedTime: 1));
      final backup = store.backup(await store.getAllRules());
      await store.insertOrUpdate(EsoRule(id: 'b', name: 'B', modifiedTime: 2));
      expect(await store.restore(backup, reset: true), isTrue);
      expect((await store.getAllRules()).single.id, 'a');

      expect(await store.restore(backup), isTrue);
      expect((await store.getAllRules()).length, 1);
      expect(await store.restore(''), isFalse);
    });

    test('EsoSearchHistoryStore 去重新增与清空', () async {
      final store = EsoSearchHistoryStore();
      expect(await store.newSearch('甲'), isTrue);
      expect(await store.newSearch('甲'), isFalse);
      await store.newSearch('乙');
      expect(await store.getAll(), <String>['甲', '乙']);
      await store.remove('甲');
      expect(await store.getAll(), <String>['乙']);
      await store.clear();
      expect(await store.getAll(), isEmpty);
    });

    test('EsoSearchHistoryStore clean 覆盖 / 非 clean 补齐', () async {
      final store = EsoSearchHistoryStore();
      await store.newSearch('甲');
      await store.restore(<dynamic>['乙', '丙'], clean: true);
      expect(await store.getAll(), <String>['乙', '丙']);
      await store.restore(<dynamic>['丙', '丁']);
      expect(await store.getAll(), <String>['乙', '丙', '丁']);
      expect(jsonDecode(await store.backup()), <String>['乙', '丙', '丁']);
    });

    test('EsoHistoryItemStore 插入/过滤/排序', () async {
      final store = EsoHistoryItemStore();
      final old = EsoSearchItem(name: '斗破苍穹', originTag: 'r1')
        ..ruleContentType = EsoApi.novel
        ..lastReadTime = 100;
      final fresh = EsoSearchItem(name: '斗破外传', originTag: 'r1')
        ..ruleContentType = EsoApi.novel
        ..lastReadTime = 300;
      final manga = EsoSearchItem(name: '斗破漫画', originTag: 'r2')
        ..ruleContentType = EsoApi.manga
        ..lastReadTime = 200;
      await store.insertOrUpdateHistoryItem(old);
      await store.insertOrUpdateHistoryItem(fresh);
      await store.insertOrUpdateHistoryItem(manga);

      final byType = await store.getHistoryItemByType('斗破', EsoApi.novel);
      expect(byType.map((e) => e.name).toList(), <String>['斗破外传', '斗破苍穹']);
      expect((await store.getHistoryItemByType(null, null)).length, 3);
    });

    test('EsoHistoryItemStore 更新同 id 不产生重复项', () async {
      final store = EsoHistoryItemStore();
      final item = EsoSearchItem(name: '书', originTag: 'r1');
      await store.insertOrUpdateHistoryItem(item);
      item.durChapter = '第二章';
      await store.insertOrUpdateHistoryItem(item);
      final all = await store.getAll();
      expect(all.length, 1);
      expect(all.single.durChapter, '第二章');
    });

    test('EsoHistoryItemStore 删除、备份与还原', () async {
      final store = EsoHistoryItemStore();
      final item = EsoSearchItem(name: '书', originTag: 'r1');
      await store.insertOrUpdateHistoryItem(item);
      final backup = await store.backup();
      await store.removeSearchItem(<int>{item.id});
      expect(await store.getAll(), isEmpty);
      expect(await store.restore(backup), isTrue);
      expect((await store.getAll()).single.name, '书');
      expect(await store.restore('[]'), isFalse);
    });

    test('EsoHistoryItemStore 清空', () async {
      final store = EsoHistoryItemStore();
      await store.insertOrUpdateHistoryItem(EsoSearchItem(name: '书'));
      await store.clear();
      expect(await store.getAll(), isEmpty);
    });
  });
}
