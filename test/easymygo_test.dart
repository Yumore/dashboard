import 'dart:convert';

import 'package:dashboard/features/reading/easymygo/component/demo_manga_component.dart';
import 'package:dashboard/features/reading/easymygo/component/demo_novel_component.dart';
import 'package:dashboard/features/reading/easymygo/component/manga_component.dart';
import 'package:dashboard/features/reading/easymygo/component/novel_component.dart';
import 'package:dashboard/features/reading/easymygo/component/rule_source_component.dart';
import 'package:dashboard/features/reading/easymygo/detail/book_detail_page.dart';
import 'package:dashboard/features/reading/easymygo/easymygo_page.dart';
import 'package:dashboard/features/reading/easymygo/entity/book_cover.dart';
import 'package:dashboard/features/reading/easymygo/entity/book_detailed.dart';
import 'package:dashboard/features/reading/easymygo/entity/book_status.dart';
import 'package:dashboard/features/reading/easymygo/entity/book_summary.dart';
import 'package:dashboard/features/reading/easymygo/entity/component_payload.dart';
import 'package:dashboard/features/reading/easymygo/entity/manga_chapter.dart';
import 'package:dashboard/features/reading/easymygo/entity/manga_picture.dart';
import 'package:dashboard/features/reading/easymygo/entity/novel_chapter.dart';
import 'package:dashboard/features/reading/easymygo/entity/novel_volume.dart';
import 'package:dashboard/features/reading/easymygo/entity/source_config_item.dart';
import 'package:dashboard/features/reading/easymygo/entity/source_data.dart';
import 'package:dashboard/features/reading/easymygo/entity/source_info.dart';
import 'package:dashboard/features/reading/easymygo/entity/source_type.dart';
import 'package:dashboard/features/reading/easymygo/library/library_store.dart';
import 'package:dashboard/features/reading/easymygo/library/reading_progress.dart';
import 'package:dashboard/features/reading/easymygo/reader/manga_reader_controller.dart';
import 'package:dashboard/features/reading/easymygo/reader/manga_reader_page.dart';
import 'package:dashboard/features/reading/easymygo/reader/novel_paginator.dart';
import 'package:dashboard/features/reading/easymygo/reader/novel_reader_controller.dart';
import 'package:dashboard/features/reading/easymygo/reader/novel_reader_page.dart';
import 'package:dashboard/features/reading/easymygo/reader/reader_state.dart';
import 'package:dashboard/features/reading/easymygo/rule/json_path_action.dart';
import 'package:dashboard/features/reading/easymygo/rule/rule_definition_parser.dart';
import 'package:dashboard/features/reading/easymygo/rule/rule_engine.dart';
import 'package:dashboard/features/reading/easymygo/rule/rule_exception.dart';
import 'package:dashboard/features/reading/easymygo/rule/rule_request.dart';
import 'package:dashboard/features/reading/easymygo/rule/rule_scope.dart';
import 'package:dashboard/features/reading/easymygo/rule/xpath_to_css.dart';
import 'package:dashboard/features/reading/easymygo/search/book_search_page.dart';
import 'package:dashboard/features/reading/easymygo/service/reading_service.dart';
import 'package:dashboard/features/reading/easymygo/setting/source_setting_page.dart';
import 'package:dashboard/features/reading/easymygo/shelf/shelf_page.dart';
import 'package:dashboard/features/reading/easymygo/source/rule_source_loader.dart';
import 'package:dashboard/features/reading/easymygo/source/test_manga_source.dart';
import 'package:dashboard/features/reading/easymygo/source/test_novel_source.dart';
import 'package:dashboard/features/reading/easymygo/store/source_config_store.dart';
import 'package:enough_convert/enough_convert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _innerPackage = 'com.heyanle.easymygo.extension.inner';
const String _mangaIdentify = 'com.heyanle.easymygo.extension.inner-|-test_manga';
const String _novelIdentify = 'com.heyanle.easymygo.extension.inner-|-test_novel';
const String _ruleIdentify = 'com.example.pack-|-html_demo';

const String _searchHtml = '''
<html><head><meta charset="utf-8"></head><body>
<div class="item" data-id="m1"><a class="title" href="/manga/m1">孤独摇滚</a><img class="cover" src="https://cdn.example.com/m1.jpg"></div>
<div class="item" data-id="m2"><a class="title" href="/manga/m2">轻音少女</a><img class="cover" src="https://cdn.example.com/m2.jpg"></div>
<span class="next">2</span>
</body></html>
''';

const String _searchJson =
    '{"next":"3","data":{"list":['
    '{"id":"n1","name":"夜航","tags":["摇滚","深夜"]},'
    '{"id":"n2","name":"周末","tags":["流行"]}]}}';

Map<String, Object?> _field(
  String name,
  String action,
  String func, [
  List<Object?> constructor = const <Object?>[],
  List<Object?> args = const <Object?>[],
]) => <String, Object?>{
  'name': name,
  'expr': <String, Object?>{
    'action': action,
    'func': func,
    'constructor': constructor,
    if (args.isNotEmpty) 'args': args,
  },
};

Map<String, Object?> _item(String selector) => <String, Object?>{'var': selector};

/// A complete HTML rule source (search business) used by the engine tests.
String _htmlRuleJson() => jsonEncode(<String, Object?>{
  'key': 'html_demo',
  'label': 'HTML 示例源',
  'type': 'manga',
  'from_package': 'com.example.rules',
  'base_url': 'https://demo.example.com',
  'version_name': '2.0',
  'version_code': 2,
  'description': '测试用 HTML 规则源',
  'endpoints': <String, Object?>{
    'search': <String, Object?>{
      'initial_key': '1',
      'request': <String, Object?>{
        'url': r'${baseUrl}/search?kw=${keyword}&p=${key}',
        'headers': <String, String>{
          'Referer': r'${baseUrl}/',
          'X-Source': r'${source}',
        },
      },
      'fields': <Object?>[
        _field('next_key', 'HtmlQuerySelector', 'text', <Object?>[
          _item('body'),
          '.next',
        ]),
      ],
      'lists': <Object?>[
        <String, Object?>{
          'name': 'covers',
          'item_selector': '.item',
          'fields': <Object?>[
            _field('id', 'HtmlQuerySelector', 'attr', <Object?>[
              _item('item'),
              '.item',
            ], <Object?>['data-id']),
            _field('label', 'HtmlQuerySelector', 'text', <Object?>[
              _item('item'),
              'a.title',
            ]),
            _field('cover', 'HtmlQuerySelector', 'attr', <Object?>[
              _item('item'),
              'img.cover',
            ], <Object?>['src']),
            _field('jump_url', 'HtmlQuerySelector', 'attr', <Object?>[
              _item('item'),
              'a.title',
            ], <Object?>['href']),
          ],
        },
      ],
    },
  },
});

/// A JSON rule source with a POST request, a JsonPath list and a Buffer hop.
String _jsonRuleJson() => jsonEncode(<String, Object?>{
  'key': 'json_demo',
  'label': 'JSON 示例源',
  'type': 'manga',
  'from_package': 'com.example.rules',
  'base_url': 'https://api.example.com',
  'endpoints': <String, Object?>{
    'search': <String, Object?>{
      'request': <String, Object?>{
        'url': r'${baseUrl}/api/search',
        'method': 'POST',
        'encoding': 'utf-8',
        'headers': <String, String>{'Content-Type': 'application/json'},
        'body': r'{"q":"${keyword}","page":${key}}',
      },
      'fields': <Object?>[
        _field('next_key', 'JsonPath', 'text', <Object?>[
          _item('body'),
          r'$.next',
        ]),
      ],
      'lists': <Object?>[
        <String, Object?>{
          'name': 'covers',
          'item_selector': r'$.data.list[*]',
          'mode': 'json',
          'fields': <Object?>[
            _field('id', 'JsonPath', 'text', <Object?>[
              _item('item'),
              r'$.id',
            ]),
            _field('label', 'JsonPath', 'text', <Object?>[
              _item('item'),
              r'$.name',
            ]),
            _field('tags', 'JsonPath', 'all', <Object?>[
              _item('item'),
              r'$.tags[*]',
            ]),
          ],
        },
      ],
    },
  },
});

/// A novel rule source exercising detail / volumes / chapters / read.
String _novelRuleJson() => jsonEncode(<String, Object?>{
  'key': 'novel_demo',
  'label': '小说示例源',
  'type': 'novel',
  'from_package': 'com.example.rules',
  'base_url': 'https://novel.example.com',
  'endpoints': <String, Object?>{
    'detail': <String, Object?>{
      'request': <String, Object?>{'url': r'${baseUrl}/api/detail?id=${id}'},
      'fields': <Object?>[
        _field('id', 'JsonPath', 'text', <Object?>[_item('body'), r'$.id']),
        _field('label', 'JsonPath', 'text', <Object?>[_item('body'), r'$.name']),
        _field('genre', 'JsonPath', 'text', <Object?>[_item('body'), r'$.genre']),
        _field('status', 'JsonPath', 'text', <Object?>[
          _item('body'),
          r'$.status',
        ]),
      ],
    },
    'volumes': <String, Object?>{
      'request': <String, Object?>{'url': r'${baseUrl}/api/volumes?id=${id}'},
      'lists': <Object?>[
        <String, Object?>{
          'name': 'volumes',
          'item_selector': r'$.data[*]',
          'mode': 'json',
          'fields': <Object?>[
            _field('id', 'JsonPath', 'text', <Object?>[_item('item'), r'$.id']),
            _field('label', 'JsonPath', 'text', <Object?>[
              _item('item'),
              r'$.name',
            ]),
            _field('organize_type', 'JsonPath', 'text', <Object?>[
              _item('item'),
              r'$.type',
            ]),
          ],
        },
      ],
    },
    'chapters': <String, Object?>{
      'request': <String, Object?>{
        'url': r'${baseUrl}/api/chapters?volume=${volume_id}',
      },
      'lists': <Object?>[
        <String, Object?>{
          'name': 'chapters',
          'item_selector': r'$.data[*]',
          'mode': 'json',
          'fields': <Object?>[
            _field('id', 'JsonPath', 'text', <Object?>[_item('item'), r'$.id']),
            _field('label', 'JsonPath', 'text', <Object?>[
              _item('item'),
              r'$.name',
            ]),
            _field('src', 'JsonPath', 'text', <Object?>[_item('item'), r'$.src']),
            _field('load_type', 'JsonPath', 'text', <Object?>[
              _item('item'),
              r'$.load_type',
            ]),
          ],
        },
      ],
    },
    'read': <String, Object?>{
      'request': <String, Object?>{
        'url': r'${baseUrl}/api/read?chapter=${chapter_id}',
      },
      'fields': <Object?>[
        _field('content', 'JsonPath', 'text', <Object?>[
          _item('body'),
          r'$.content',
        ]),
      ],
    },
  },
});

/// A manifest wrapping one rule source, as `RuleExtensionLoader` expects it.
String _manifestJson(String package, String sourceJson) => jsonEncode(
  <String, Object?>{
    'package': package,
    'label': '示例规则包',
    'version_name': '1.0',
    'version_code': 1,
    'lib_version': 1,
    'sources': <Object?>[jsonDecode(sourceJson)],
  },
);

RuleSourceComponent _ruleComponent(String json, http.Client client) {
  final loader = RuleSourceLoader(engineFactory: () => RuleEngine(client: client));
  final info = loader.parseDefinition('com.example.pack', jsonDecode(json));
  final data = loader.load(info);
  expect(data.state, SourceState.loaded, reason: data.errorMsg);
  return data.components.whereType<RuleSourceComponent>().single;
}

http.Client _htmlClient(void Function(http.Request request)? onRequest) =>
    MockClient((request) async {
      onRequest?.call(request);
      return http.Response(
        _searchHtml,
        200,
        headers: <String, String>{'content-type': 'text/html; charset=utf-8'},
      );
    });

/// A client routing the novel rule source's four API paths.
http.Client _novelClient() => MockClient((request) async {
  final path = request.url.path;
  final body = switch (path) {
    '/api/detail' =>
      '{"id":"b1","name":"测试小说","genre":"科幻","status":"complete"}',
    '/api/volumes' =>
      '{"data":[{"id":"v1","name":"第一卷","type":"multiChapter"},'
          '{"id":"v2","name":"第二卷","type":"singleChapter"}]}',
    '/api/chapters' => request.url.queryParameters['volume'] == 'v1'
        ? '{"data":[{"id":"c1","name":"第一章","src":"/c1","load_type":"txt"},'
              '{"id":"c2","name":"第二章","src":"/c2","load_type":"html"}]}'
        : '{"data":[{"id":"c3","name":"第三章","src":"/c3","load_type":"txt"}]}',
    '/api/read' => '{"content":"第一章的正文内容。"}',
    _ => '{}',
  };
  return http.Response(
    body,
    200,
    headers: <String, String>{'content-type': 'application/json; charset=utf-8'},
  );
});

class _ErrorMangaComponent implements MangaComponent {
  const _ErrorMangaComponent(this.sourceInfo, this.message);

  @override
  final SourceInfo sourceInfo;

  final String message;

  @override
  Future<(ComponentPayload, BookDetailed?, List<MangaChapter>?)>
  getMangaDetailed(BookSummary summary) async =>
      (const ComponentPayload.ok(), null, null);

  @override
  Future<(ComponentPayload, List<MangaPicture>?)> getMangaPictures(
    MangaChapter chapter,
    BookSummary summary,
  ) async => (
    ComponentPayload(code: ComponentPayload.codeBusinessError, msg: message),
    null,
  );
}

class _EmptyMangaComponent implements MangaComponent {
  const _EmptyMangaComponent(this.sourceInfo);

  @override
  final SourceInfo sourceInfo;

  @override
  Future<(ComponentPayload, BookDetailed?, List<MangaChapter>?)>
  getMangaDetailed(BookSummary summary) async =>
      (const ComponentPayload.ok(), null, null);

  @override
  Future<(ComponentPayload, List<MangaPicture>?)> getMangaPictures(
    MangaChapter chapter,
    BookSummary summary,
  ) async => (const ComponentPayload.ok(), const <MangaPicture>[]);
}

class _ErrorNovelComponent implements NovelComponent {
  const _ErrorNovelComponent(this.sourceInfo, this.message);

  @override
  final SourceInfo sourceInfo;

  final String message;

  @override
  Future<(ComponentPayload, BookDetailed?, List<NovelVolume>?)>
  getNovelDetailed(BookSummary summary) async =>
      (const ComponentPayload.ok(), null, null);

  @override
  Future<(ComponentPayload, List<NovelChapter>?)> getNovelChapters(
    NovelVolume volume,
    BookSummary summary,
  ) async => (
    ComponentPayload(code: ComponentPayload.codeBusinessError, msg: message),
    null,
  );

  @override
  Future<(ComponentPayload, String)> loadNovelChapter(
    NovelChapter chapter,
    BookSummary summary,
  ) async => (
    ComponentPayload(code: ComponentPayload.codeBusinessError, msg: message),
    '',
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('RuleDefinitionParser', () {
    test('parses metadata, request and parse rules of a source', () {
      const parser = RuleDefinitionParser();
      final definition = parser.parseString(_htmlRuleJson());

      expect(definition.info.key, 'html_demo');
      expect(definition.info.label, 'HTML 示例源');
      expect(definition.info.type, SourceType.manga);
      expect(definition.info.fromPackage, 'com.example.rules');
      expect(definition.info.versionName, '2.0');
      expect(definition.info.versionCode, 2);
      expect(definition.info.identify, 'com.example.rules-|-html_demo');
      expect(definition.baseUrl, 'https://demo.example.com');
      expect(definition.implementedBusinesses, <String>['search']);
      expect(definition.has('search'), isTrue);
      expect(definition.has('read'), isFalse);

      final search = definition.search!;
      expect(search.business, 'search');
      expect(search.initialKey, '1');
      expect(search.request.url, r'${baseUrl}/search?kw=${keyword}&p=${key}');
      expect(search.request.method, 'GET');
      expect(search.request.isPost, isFalse);
      expect(search.listSpec('covers')!.itemSelector, '.item');
      expect(search.listSpec('covers')!.fields.map((f) => f.name), <String>[
        'id',
        'label',
        'cover',
        'jump_url',
      ]);
      expect(search.fields.single.name, 'next_key');
    });

    test('rejects a source without key or label', () {
      const parser = RuleDefinitionParser();
      expect(
        () => parser.parse(<String, Object?>{'label': 'x'}),
        throwsA(
          isA<RuleException>().having((e) => e.message, 'message', '书源缺少 key'),
        ),
      );
      expect(
        () => parser.parse(<String, Object?>{'key': 'x'}),
        throwsA(
          isA<RuleException>().having(
            (e) => e.message,
            'message',
            '书源缺少 label',
          ),
        ),
      );
    });

    test('reports malformed JSON and unknown actions', () {
      const parser = RuleDefinitionParser();
      expect(
        () => parser.parseString('{oops'),
        throwsA(
          isA<RuleException>().having(
            (e) => e.message,
            'message',
            startsWith('书源 JSON 解析失败:'),
          ),
        ),
      );
      expect(
        () => parser.parse(<String, Object?>{
          'key': 'x',
          'label': 'x',
          'endpoints': <String, Object?>{
            'search': <String, Object?>{
              'request': <String, Object?>{'url': 'https://x'},
              'fields': <Object?>[
                _field('a', 'NoSuchAction', 'text', <Object?>['a', 'b']),
              ],
            },
          },
        }),
        throwsA(
          isA<RuleException>().having(
            (e) => e.message,
            'message',
            '未找到动作类型: NoSuchAction',
          ),
        ),
      );
    });
  });

  group('RuleRequest', () {
    test('interpolates variables into url, headers and body', () {
      const request = RuleRequest(
        url: r'${baseUrl}/search?kw=${keyword}&p=${key}',
        method: 'POST',
        headers: <String, String>{'Referer': r'${baseUrl}/'},
        body: r'{"q":"${keyword}"}',
        encoding: 'gbk',
      );
      final variables = <String, String>{
        'baseUrl': 'https://demo.example.com',
        'keyword': '孤独摇滚',
        'key': '2',
      };

      expect(
        RuleRequest.interpolate(request.url, variables),
        'https://demo.example.com/search?kw=孤独摇滚&p=2',
      );
      expect(
        request.buildUri(variables).queryParameters,
        <String, String>{'kw': '孤独摇滚', 'p': '2'},
      );
      expect(request.buildHeaders(variables), <String, String>{
        'Referer': 'https://demo.example.com/',
      });
      expect(request.buildBody(variables), '{"q":"孤独摇滚"}');
      expect(request.isPost, isTrue);
      expect(request.isGbk, isTrue);
    });

    test('fills a missing variable with an empty string', () {
      expect(
        RuleRequest.interpolate(r'a${missing}b', <String, String>{}),
        'ab',
      );
    });

    test('rejects an empty or schemeless url', () {
      const empty = RuleRequest(url: '  ');
      expect(
        () => empty.buildUri(<String, String>{}),
        throwsA(
          isA<RuleException>().having(
            (e) => e.message,
            'message',
            '请求地址为空',
          ),
        ),
      );
      const schemeless = RuleRequest(url: 'example.com/path');
      expect(
        () => schemeless.buildUri(<String, String>{}),
        throwsA(
          isA<RuleException>().having(
            (e) => e.message,
            'message',
            '请求地址非法: example.com/path',
          ),
        ),
      );
    });
  });

  group('RuleEngine', () {
    test('builds the request from variables and extracts HTML rules', () async {
      http.Request? captured;
      final definition = const RuleDefinitionParser().parseString(
        _htmlRuleJson(),
      );
      final engine = RuleEngine(client: _htmlClient((r) => captured = r));
      final result = await engine.execute(
        definition.search!,
        RuleScope(
          sourceInfo: definition.info,
          baseUrl: definition.baseUrl,
          variables: <String, String>{'key': '1', 'keyword': '孤独'},
        ),
      );

      expect(captured, isNotNull);
      expect(captured!.method, 'GET');
      expect(captured!.url.path, '/search');
      expect(captured!.url.queryParameters, <String, String>{
        'kw': '孤独',
        'p': '1',
      });
      expect(captured!.headers['Referer'], 'https://demo.example.com/');
      expect(
        captured!.headers['X-Source'],
        'com.example.rules-|-html_demo',
      );

      expect(result.optional('next_key'), '2');
      final covers = result.list('covers');
      expect(covers, hasLength(2));
      expect(covers.first, containsPair('id', 'm1'));
      expect(covers.first, containsPair('label', '孤独摇滚'));
      expect(covers.first, containsPair('cover', 'https://cdn.example.com/m1.jpg'));
      expect(covers.first, containsPair('jump_url', '/manga/m1'));
      expect(covers.last['label'], '轻音少女');
    });

    test('evaluates JsonPath rules over a POST body answer', () async {
      http.Request? captured;
      final definition = const RuleDefinitionParser().parseString(
        _jsonRuleJson(),
      );
      final engine = RuleEngine(
        client: MockClient((request) async {
          captured = request;
          return http.Response(
            _searchJson,
            200,
            headers: <String, String>{
              'content-type': 'application/json; charset=utf-8',
            },
          );
        }),
      );
      final result = await engine.execute(
        definition.search!,
        RuleScope(
          sourceInfo: definition.info,
          baseUrl: definition.baseUrl,
          variables: <String, String>{'key': '2', 'keyword': '夜'},
        ),
      );

      expect(captured!.method, 'POST');
      expect(captured!.body, '{"q":"夜","page":2}');
      expect(captured!.headers['Content-Type'], 'application/json');
      expect(result.optional('next_key'), '3');
      final covers = result.list('covers');
      expect(covers, hasLength(2));
      expect(covers.first, containsPair('id', 'n1'));
      expect(covers.first, containsPair('label', '夜航'));
      expect(covers.first['tags'], '["摇滚","深夜"]');
      expect(covers.last, containsPair('label', '周末'));
    });

    test('keeps the Buffer hop between two rules', () async {
      final definition = const RuleDefinitionParser().parseString(
        jsonEncode(<String, Object?>{
          'key': 'buffer_demo',
          'label': 'Buffer 源',
          'base_url': 'https://demo.example.com',
          'endpoints': <String, Object?>{
            'search': <String, Object?>{
              'request': <String, Object?>{'url': r'${baseUrl}/b'},
              'lists': <Object?>[
                <String, Object?>{
                  'name': 'covers',
                  'item_selector': '.item',
                  'fields': <Object?>[
                    _field('key', 'Buffer', 'put', const <Object?>[], <Object?>[
                      _item('item'),
                    ]),
                    _field('value', 'Buffer', 'get', const <Object?>[], <Object?>[
                      'buffer@0',
                    ]),
                  ],
                },
              ],
            },
          },
        }),
      );
      final engine = RuleEngine(client: _htmlClient(null));
      final result = await engine.execute(
        definition.search!,
        RuleScope(sourceInfo: definition.info, baseUrl: definition.baseUrl),
      );

      final first = result.list('covers').first;
      expect(first['key'], 'buffer@0');
      expect(first['value'], contains('data-id="m1"'));
    });

    test('decodes a GBK body from its meta charset', () async {
      final definition = const RuleDefinitionParser().parseString(
        jsonEncode(<String, Object?>{
          'key': 'gbk_demo',
          'label': 'GBK 源',
          'base_url': 'https://gbk.example.com',
          'endpoints': <String, Object?>{
            'search': <String, Object?>{
              'request': <String, Object?>{'url': r'${baseUrl}/gbk'},
              'fields': <Object?>[
                _field('title', 'HtmlQuerySelector', 'text', <Object?>[
                  _item('body'),
                  'h1',
                ]),
              ],
            },
          },
        }),
      );
      final bytes = gbk.encode(
        '<html><head><meta charset="gbk"></head>'
        '<body><h1>孤独摇滚</h1></body></html>',
      );
      final engine = RuleEngine(
        client: MockClient(
          (request) async => http.Response.bytes(
            bytes,
            200,
            headers: <String, String>{'content-type': 'text/html'},
          ),
        ),
      );
      final result = await engine.execute(
        definition.search!,
        RuleScope(sourceInfo: definition.info, baseUrl: definition.baseUrl),
      );

      expect(result.value('title'), '孤独摇滚');
    });

    test('reports HTTP, empty and unparsable answers', () async {
      final definition = const RuleDefinitionParser().parseString(
        _htmlRuleJson(),
      );
      final scope = RuleScope(
        sourceInfo: definition.info,
        baseUrl: definition.baseUrl,
      );

      Future<void> expectFailure(http.Client client, String message) async {
        final engine = RuleEngine(client: client);
        await expectLater(
          engine.execute(definition.search!, scope),
          throwsA(
            isA<RuleException>().having((e) => e.message, 'message', message),
          ),
        );
      }

      await expectFailure(
        MockClient((request) async => http.Response('boom', 503)),
        '请求失败: HTTP 503',
      );
      await expectFailure(
        MockClient((request) async => http.Response('   ', 200)),
        'search 响应内容为空',
      );
      await expectFailure(
        MockClient((request) async => http.Response('<p>nothing</p>', 200)),
        'search 未解析出任何数据',
      );
    });

    test('fails when a JSON answer is not JSON', () async {
      final definition = const RuleDefinitionParser().parseString(
        _jsonRuleJson(),
      );
      final engine = RuleEngine(
        client: MockClient((request) async => http.Response('<html>', 200)),
      );
      await expectLater(
        engine.execute(
          definition.search!,
          RuleScope(sourceInfo: definition.info, baseUrl: definition.baseUrl),
        ),
        throwsA(
          isA<RuleException>().having(
            (e) => e.message,
            'message',
            startsWith('JsonPath 输入不是合法 JSON:'),
          ),
        ),
      );
    });
  });

  group('JsonPathAction', () {
    final root = jsonDecode(
      '{"data":{"list":[{"id":"n1","name":"夜航"},{"id":"n2","name":"周末"}]},'
      '"deep":{"a":{"id":"n3"}}}',
    );

    test('walks the supported path grammar', () {
      expect(JsonPathAction.queryPath(root, r'$.data.list[*].id'), <Object?>[
        'n1',
        'n2',
      ]);
      expect(JsonPathAction.queryPath(root, r'$.data.list[0].name'), <Object?>[
        '夜航',
      ]);
      expect(JsonPathAction.queryPath(root, r"$['deep']['a']['id']"), <Object?>[
        'n3',
      ]);
      expect(JsonPathAction.queryPath(root, r'$..id'), <Object?>['n1', 'n2', 'n3']);
      expect(JsonPathAction.queryPath(root, r'$.data.list[*]'), hasLength(2));
    });

    test('renders scalars and containers', () {
      expect(JsonPathAction.asString(null), '');
      expect(JsonPathAction.asString('x'), 'x');
      expect(JsonPathAction.asString(2), '2');
      expect(JsonPathAction.asString(true), 'true');
      expect(
        JsonPathAction.asString(<String, Object?>{'a': 1}),
        '{"a":1}',
      );
    });
  });

  group('xpathToCss + HtmlXPath', () {
    test('translates the supported XPath subset', () {
      expect(xpathToCss('//div[@class="item"]'), 'div[class="item"]');
      expect(xpathToCss("//a[@id='main']"), 'a#main');
      expect(xpathToCss("//span[contains(@class,'title')]"), 'span.title');
      expect(xpathToCss('//img[@src]'), 'img[src]');
      expect(xpathToCss('//div//a'), 'div a');
      expect(xpathToCss('//div[text()="x"]'), '');
      expect(xpathToCss('//div[2]'), '');
    });

    test('extracts through the translated selector', () {
      final definition = const RuleDefinitionParser().parseString(
        jsonEncode(<String, Object?>{
          'key': 'xpath_demo',
          'label': 'XPath 源',
          'base_url': 'https://demo.example.com',
          'endpoints': <String, Object?>{
            'search': <String, Object?>{
              'request': <String, Object?>{'url': r'${baseUrl}/x'},
              'fields': <Object?>[
                _field('first', 'HtmlXPath', 'text', <Object?>[
                  _item('body'),
                  '//div[@class="item"]',
                ]),
                _field('href', 'HtmlXPath', 'attr', <Object?>[
                  _item('body'),
                  "//a[@class='title']",
                ], <Object?>['href']),
              ],
            },
          },
        }),
      );
      final engine = RuleEngine(client: _htmlClient(null));
      return engine
          .execute(
            definition.search!,
            RuleScope(sourceInfo: definition.info, baseUrl: definition.baseUrl),
          )
          .then((result) {
            expect(result.value('first'), '孤独摇滚');
            expect(result.value('href'), '/manga/m1');
          });
    });
  });

  group('entities', () {
    test('ComponentPayload maps codes to messages', () {
      const ok = ComponentPayload.ok();
      expect(ok.isError, isFalse);
      // Faithful to the source app: the success code falls through to the
      // `unknown` branch, so callers must check `isError` before showing it.
      expect(ok.errorMsg, '未知错误 0 ');

      const call = ComponentPayload(code: ComponentPayload.codeCallError, msg: '炸了');
      expect(call.isError, isTrue);
      expect(call.errorMsg, '调用错误 炸了');

      const parse = ComponentPayload(
        code: ComponentPayload.codeParseResultError,
        msg: '空',
      );
      expect(parse.errorMsg, '解析错误 空');

      const business = ComponentPayload(
        code: ComponentPayload.codeBusinessError,
        msg: '没有找到相关作品',
      );
      expect(business.errorMsg, '没有找到相关作品');

      const unknown = ComponentPayload(code: 42, msg: 'x');
      expect(unknown.errorMsg, '未知错误 42 x');
    });

    test('BookCover round-trips and derives its summary', () {
      const cover = BookCover(
        type: SourceType.novel,
        id: 'n1',
        label: '测试书',
        cover: 'https://cdn.example.com/n1.jpg',
        intro: '简介',
        jumpUrl: 'https://example.com/n1',
        source: 'pkg-|-src',
        ext: 'e',
      );
      expect(cover.identify, 'n1-|-pkg-|-src');
      expect(cover.summary.id, 'n1');
      expect(cover.summary.source, 'pkg-|-src');
      expect(cover.summary.ext, 'e');

      final restored = BookCover.fromJson(cover.toJson());
      expect(restored.id, 'n1');
      expect(restored.type, SourceType.novel);
      expect(restored.jumpUrl, 'https://example.com/n1');
      expect(restored.identify, cover.identify);
    });
  });

  group('SourceConfigStore', () {
    test('round-trips the settings list and skips malformed payloads', () {
      const items = <SourceConfigItem>[
        SourceConfigItem(key: 'a', fromPackage: 'p', enabled: false, order: 3),
        SourceConfigItem(key: 'b', fromPackage: 'p', order: 1),
      ];
      final decoded = SourceConfigStore.decodeConfigs(
        SourceConfigStore.encodeConfigs(items),
      );
      expect(decoded, hasLength(2));
      expect(decoded.first.key, 'a');
      expect(decoded.first.identify, 'p-|-a');
      expect(decoded.first.enabled, isFalse);
      expect(decoded.first.order, 3);
      expect(decoded.last.order, 1);

      expect(SourceConfigStore.decodeConfigs('{oops'), isEmpty);
      expect(SourceConfigStore.decodeConfigs('{"a":1}'), isEmpty);
    });

    test('syncConfigs keeps touched settings and drops removed sources',
        () async {
      final store = SourceConfigStore();
      const first = SourceInfo(
        key: 'a',
        fromPackage: 'p',
        label: 'A',
        type: SourceType.manga,
      );
      const second = SourceInfo(
        key: 'b',
        fromPackage: 'p',
        label: 'B',
        type: SourceType.novel,
      );

      final fresh = await store.syncConfigs(<SourceInfo>[first, second]);
      expect(fresh.map((e) => e.identify), <String>['p-|-a', 'p-|-b']);
      expect(fresh.map((e) => e.order), <int>[0, 1]);
      expect(fresh.every((e) => e.enabled), isTrue);

      await store.save(
        const SourceConfigItem(
          key: 'a',
          fromPackage: 'p',
          enabled: false,
          order: 9,
        ),
      );
      final merged = await store.syncConfigs(<SourceInfo>[second, first]);
      expect(merged.map((e) => e.identify), <String>['p-|-b', 'p-|-a']);
      expect(merged.last.enabled, isFalse);
      expect(merged.last.order, 9);
    });

    test('persists configs and imported packages', () async {
      final store = SourceConfigStore();
      await store.save(
        const SourceConfigItem(
          key: 'a',
          fromPackage: 'p',
          enabled: false,
          order: 2,
        ),
      );
      final reloaded = SourceConfigStore();
      final configs = await reloaded.readConfigs();
      expect(configs.single.identify, 'p-|-a');
      expect(configs.single.enabled, isFalse);

      await reloaded.addPackage('{"package":"com.example"}');
      await reloaded.addPackage('{"package":"com.example"}');
      expect(await reloaded.readPackages(), <String>['{"package":"com.example"}']);
      await reloaded.removePackageAt(0);
      expect(await reloaded.readPackages(), isEmpty);
      await reloaded.removePackageAt(5);
    });
  });

  group('LibraryStore + ReadingProgress', () {
    const cover = BookCover(
      type: SourceType.manga,
      id: 'm1',
      label: '孤独摇滚',
      cover: '',
      intro: '',
      jumpUrl: '',
      source: 'p-|-s',
    );

    test('ReadingProgress reports chapter and volume process', () {
      const progress = ReadingProgress(
        chapterId: 'c1',
        chapterLabel: '第 1 话',
        pageIndex: 1,
        pageCount: 4,
        chapterIndex: 1,
      );
      expect(progress.chapterProcess, 0.5);
      expect(progress.volumeProcess, 0.5);
      expect(const ReadingProgress(chapterId: 'c', chapterLabel: 'l').chapterProcess, 0);
      expect(const ReadingProgress(chapterId: 'c', chapterLabel: 'l').volumeProcess, 0);
    });

    test('remembers a book into history and keeps progress', () async {
      final store = LibraryStore();
      expect(await store.history(), isEmpty);
      expect(await store.shelf(), isEmpty);

      await store.remember(cover, now: 100);
      var all = await store.all();
      expect(all, hasLength(1));
      expect(all.single.identify, 'm1-|-p-|-s');
      expect(all.single.updatedAt, 100);
      expect(all.single.hasHistory, isFalse);

      await store.saveProgress(
        cover,
        const ReadingProgress(
          chapterId: 'c2',
          chapterLabel: '第 2 话',
          chapterIndex: 1,
          pageIndex: 2,
          pageCount: 3,
          updatedAt: 200,
        ),
      );
      final progress = await store.progressOf(cover.identify);
      expect(progress, isNotNull);
      expect(progress!.chapterLabel, '第 2 话');
      expect(progress.pageIndex, 2);
      final history = await store.history();
      expect(history, hasLength(1));
      expect(history.single.updatedAt, 200);

      final reloaded = LibraryStore();
      expect(await reloaded.itemOf(cover.identify), isNotNull);
    });

    test('star / pin / order / remove drive the shelf lists', () async {
      const other = BookCover(
        type: SourceType.novel,
        id: 'n1',
        label: '测试小说',
        cover: '',
        intro: '',
        jumpUrl: '',
        source: 'p-|-s',
      );
      final store = LibraryStore();
      await store.setStarred(cover, true);
      await store.setPinned(other, true);
      await store.setOrder(cover, 5);

      final shelf = await store.shelf();
      expect(shelf.map((e) => e.cover.id), <String>['n1', 'm1']);
      expect(shelf.first.pinned, isTrue);
      expect(shelf.last.starred, isTrue);
      expect(shelf.last.order, 5);

      await store.setStarred(cover, false);
      await store.setPinned(other, false);
      expect(await store.shelf(), isEmpty);

      await store.remove(cover.identify);
      expect((await store.all()).map((e) => e.cover.id), <String>['n1']);
      await store.clear();
      expect(await store.all(), isEmpty);
    });

    test('decode survives a broken payload', () {
      expect(LibraryStore.decode(null), isEmpty);
      expect(LibraryStore.decode('nope'), isEmpty);
      expect(LibraryStore.decode('[]'), isEmpty);
    });
  });

  group('NovelPaginator', () {
    test('breaks on paragraph boundaries', () {
      const paginator = NovelPaginator(maxChars: 5);
      expect(paginator.paginate('aaa\nbbb\nccc'), <String>['aaa', 'bbb', 'ccc']);
      expect(paginator.paginate('   \n\n'), isEmpty);
    });

    test('hard-splits a paragraph longer than one page', () {
      const paginator = NovelPaginator(maxChars: 4);
      final pages = paginator.paginate('abcdefghij');
      expect(pages, <String>['abcd', 'efgh', 'ij']);
    });

    test('normalises CRLF and keeps paragraph gaps', () {
      const paginator = NovelPaginator(maxChars: 100);
      expect(paginator.paginate('one\r\ntwo\r\n\r\nthree').single, 'one\ntwo\n\nthree');
    });
  });

  group('MangaReaderController', () {
    final source = TestMangaSource();
    final component = DemoMangaComponent(sourceInfo: source.info);
    const summary = BookSummary(source: 'inner-|-test_manga', id: 'manga_1');

    Future<List<MangaChapter>> chaptersOf() async {
      final (_, _, chapters) = await component.getMangaDetailed(summary);
      return chapters!;
    }

    test('loads a chapter and walks pages and chapters', () async {
      final controller = MangaReaderController(
        component: component,
        summary: summary,
        chapters: await chaptersOf(),
      );
      expect(controller.chapterCount, 12);
      expect(controller.state.status, ReaderStatus.idle);

      await controller.openChapter(0);
      expect(controller.state.status, ReaderStatus.ready);
      expect(controller.state.chapterLabel, '第 1 话');
      expect(controller.state.pictures, hasLength(3));
      expect(
        controller.state.pictures.first.url,
        'https://example.com/pic/manga_1/manga_1_c1/1.jpg',
      );
      expect(controller.state.pageCount, 3);
      expect(controller.state.process, closeTo(1 / 3, 0.001));

      await controller.nextPage();
      expect(controller.state.pageIndex, 1);
      await controller.nextPage();
      await controller.nextPage();
      expect(controller.state.chapterIndex, 1);
      expect(controller.state.chapterLabel, '第 2 话');
      expect(controller.state.pageIndex, 0);

      await controller.previousPage();
      expect(controller.state.chapterIndex, 0);
      expect(controller.state.pageIndex, 2);

      controller.jumpToPage(1);
      expect(controller.state.pageIndex, 1);

      final progress = controller.buildProgress(now: 1234);
      expect(progress.chapterId, 'manga_1_c1');
      expect(progress.chapterLabel, '第 1 话');
      expect(progress.pageIndex, 1);
      expect(progress.pageCount, 3);
      expect(progress.updatedAt, 1234);

      controller.jumpToPage(99);
      expect(controller.state.pageIndex, 2);
      controller.jumpToPage(-5);
      expect(controller.state.pageIndex, 0);

      await controller.openChapter(99);
      expect(controller.state.chapterIndex, 0);

      await controller.restore(
        const ReadingProgress(
          chapterId: 'manga_1_c2',
          chapterLabel: '第 2 话',
          chapterIndex: 1,
          pageIndex: 2,
          pageCount: 3,
        ),
      );
      expect(controller.state.chapterIndex, 1);
      expect(controller.state.pageIndex, 2);
    });

    test('surfaces payload errors and empty chapters', () async {
      final failing = MangaReaderController(
        component: _ErrorMangaComponent(source.info, '章节不存在'),
        summary: summary,
        chapters: await chaptersOf(),
      );
      await failing.openChapter(0);
      expect(failing.state.status, ReaderStatus.error);
      expect(failing.state.errorMsg, '章节不存在');

      final empty = MangaReaderController(
        component: _EmptyMangaComponent(source.info),
        summary: summary,
        chapters: await chaptersOf(),
      );
      await empty.openChapter(0);
      expect(empty.state.status, ReaderStatus.error);
      expect(empty.state.errorMsg, '本章没有图片');
    });
  });

  group('NovelReaderController', () {
    final source = TestNovelSource();
    final component = DemoNovelComponent(sourceInfo: source.info);
    const summary = BookSummary(source: 'inner-|-test_novel', id: 'novel_1');

    Future<List<NovelVolume>> volumesOf() async {
      final (_, detailed, volumes) = await component.getNovelDetailed(summary);
      expect(detailed!.label, '深海之灯');
      return volumes!;
    }

    test('loads volumes, chapters and crosses volume boundaries', () async {
      final controller = NovelReaderController(
        component: component,
        summary: summary,
        volumes: await volumesOf(),
        paginator: const NovelPaginator(maxChars: 200),
      );

      await controller.openVolume(0);
      expect(controller.chapters, hasLength(3));
      expect(controller.chapters.first.label, '第 1 卷 第 1 章');

      await controller.openChapter(0);
      expect(controller.state.status, ReaderStatus.ready);
      expect(controller.state.chapterLabel, '第 1 卷 第 1 章');
      expect(controller.state.pages, isNotEmpty);
      expect(controller.state.pages.first, startsWith('《深海之灯》'));
      expect(controller.state.pageCount, greaterThan(1));

      await controller.nextChapter();
      expect(controller.state.chapterIndex, 1);
      await controller.nextChapter();
      expect(controller.state.chapterIndex, 2);
      await controller.nextChapter();
      expect(controller.state.volumeIndex, 1);
      expect(controller.state.chapterIndex, 0);
      expect(controller.state.volumeLabel, '第 2 卷');

      await controller.previousChapter();
      expect(controller.state.volumeIndex, 0);
      expect(controller.state.chapterIndex, 2);

      final progress = controller.buildProgress(now: 55);
      expect(progress.volumeId, 'novel_1_v1');
      expect(progress.volumeLabel, '第 1 卷');
      expect(progress.chapterId, 'novel_1_v1_c3');
      expect(progress.updatedAt, 55);

      await controller.restore(
        const ReadingProgress(
          chapterId: 'novel_1_v2_c1',
          chapterLabel: '第 2 卷 第 1 章',
          volumeId: 'novel_1_v2',
          volumeLabel: '第 2 卷',
          volumeIndex: 1,
          chapterIndex: 0,
          pageIndex: 0,
        ),
      );
      expect(controller.state.volumeIndex, 1);
      expect(controller.state.chapterLabel, '第 2 卷 第 1 章');
    });

    test('reports a failing chapter load', () async {
      final controller = NovelReaderController(
        component: _ErrorNovelComponent(source.info, '章节内容为空'),
        summary: summary,
        volumes: await volumesOf(),
      );
      await controller.openVolume(0);
      expect(controller.state.status, ReaderStatus.error);
      expect(controller.state.errorMsg, '章节内容为空');
    });
  });

  group('ReadingService', () {
    Future<ReadingService> buildService() =>
        ReadingService.fromRegisters(persist: false);

    test('loads the inner extension and exposes both sources', () async {
      final service = await buildService();
      expect(service.extensions, hasLength(1));
      expect(service.extensions.single.info.fromPackage, _innerPackage);
      expect(service.allSources, hasLength(2));
      expect(service.bundle.length, 2);
      expect(service.bundle.getMangaHomeList(), <String>[_mangaIdentify]);
      expect(service.bundle.getNovelHomeList(), <String>[_novelIdentify]);
      expect(service.bundle.getMangaSearchList(), <String>[_mangaIdentify]);
      expect(service.typeOf(_novelIdentify), SourceType.novel);
      expect(service.isEnabled(_mangaIdentify), isTrue);
    });

    test('drives the manga home business end to end', () async {
      final service = await buildService();
      final (payload, tabs) = await service.getHomeTab(_mangaIdentify);
      expect(payload.isError, isFalse);
      expect(tabs!.map((e) => e.label), <String>['推荐', '排行榜']);
      expect(tabs.last.hasSecondTab, isTrue);

      final (secondPayload, secondTabs) = await service.getSecondTab(
        _mangaIdentify,
        tabs.last,
      );
      expect(secondPayload.isError, isFalse);
      expect(secondTabs!.map((e) => e.label), <String>['日榜', '周榜', '月榜']);

      final (pagePayload, page) = await service.getPageWithHomeTab(
        _mangaIdentify,
        tabs.last,
      );
      expect(pagePayload.isError, isFalse);
      expect(page!.id, 'rank_page');
      expect(page.label, '排行榜');

      final (coversPayload, covers, nextKey) = await service.loadHomeCovers(
        _mangaIdentify,
        page,
        '1',
      );
      expect(coversPayload.isError, isFalse);
      expect(covers.map((e) => e.label), <String>['孤独摇滚', '轻音少女', '少女终末旅行']);
      expect(covers.first.source, _mangaIdentify);
      expect(nextKey, '2');

      final (morePayload, moreCovers, moreKey) = await service.loadHomeCovers(
        _mangaIdentify,
        page,
        nextKey!,
      );
      expect(morePayload.isError, isFalse);
      expect(moreCovers.first.label, '摇曳露营');
      expect(moreKey, '3');
    });

    test('searches, reports empty results and loads detail', () async {
      final service = await buildService();
      final (payload, results, nextKey) = await service.search(
        _mangaIdentify,
        '轻音',
      );
      expect(payload.isError, isFalse);
      expect(results.single.label, '轻音少女');
      expect(results.single.type, SourceType.manga);
      expect(nextKey, isNull);

      final (emptyPayload, emptyResults, _) = await service.search(
        _mangaIdentify,
        '不存在',
      );
      expect(emptyPayload.code, ComponentPayload.codeBusinessError);
      expect(emptyPayload.errorMsg, '没有找到相关作品');
      expect(emptyResults, isEmpty);

      final summary = results.single.summary;
      final detail = await service.detail(_mangaIdentify, summary);
      expect(detail.isError, isFalse);
      expect(detail.detailed!.label, '轻音少女');
      expect(detail.chapters, hasLength(12));
      expect(detail.chapters.first.label, '第 1 话');

      final (picturePayload, pictures) = await service.getMangaPictures(
        _mangaIdentify,
        summary,
        detail.chapters.first,
      );
      expect(picturePayload.isError, isFalse);
      expect(pictures, hasLength(3));
      expect(
        pictures!.first.url,
        'https://example.com/pic/manga_2/manga_2_c1/1.jpg',
      );
    });

    test('drives the novel volumes, chapters and content', () async {
      final service = await buildService();
      const summary = BookSummary(source: _novelIdentify, id: 'novel_1');
      final detail = await service.detail(_novelIdentify, summary);
      expect(detail.isError, isFalse);
      expect(detail.detailed!.label, '深海之灯');
      expect(detail.volumes, hasLength(2));
      expect(detail.volumes.first.label, '第 1 卷');

      final (chapterPayload, chapters) = await service.getNovelChapters(
        _novelIdentify,
        summary,
        detail.volumes.first,
      );
      expect(chapterPayload.isError, isFalse);
      expect(chapters, hasLength(3));
      expect(chapters!.first.loadType, NovelChapterLoadType.txt);

      final (readPayload, content) = await service.loadNovelChapter(
        _novelIdentify,
        summary,
        chapters.first,
      );
      expect(readPayload.isError, isFalse);
      expect(content, startsWith('《深海之灯》'));
      expect(content, contains('第 30 段。'));
    });

    test('reports disabled and unknown sources', () async {
      final service = await buildService();
      await service.setEnabled(_mangaIdentify, false);
      expect(service.isEnabled(_mangaIdentify), isFalse);
      expect(service.bundle.length, 1);
      expect(service.bundle.getSourceConfigWrapperList().single.identify, _novelIdentify);

      final (disabledPayload, _, _) = await service.search(
        _mangaIdentify,
        '轻音',
      );
      expect(disabledPayload.code, ComponentPayload.codeBusinessError);
      expect(disabledPayload.errorMsg, contains('未启用'));

      await service.setEnabled(_mangaIdentify, true);
      expect(service.bundle.length, 2);

      final (unknownPayload, _, _) = await service.search('nope-|-nope', 'x');
      expect(unknownPayload.code, ComponentPayload.codeBusinessError);
      expect(unknownPayload.errorMsg, '书源未启用: nope-|-nope');
    });

    test('reorders sources through the settings API', () async {
      final service = await buildService();
      expect(
        service.bundle.getSourceConfigWrapperList().map((e) => e.identify),
        <String>[_mangaIdentify, _novelIdentify],
      );
      await service.setOrder(_novelIdentify, -1);
      expect(
        service.bundle.getSourceConfigWrapperList().map((e) => e.identify),
        <String>[_novelIdentify, _mangaIdentify],
      );
    });

    test('imports a rule package and runs it against a fake client', () async {
      http.Request? captured;
      final loader = RuleSourceLoader(
        engineFactory: () => RuleEngine(
          client: _htmlClient((request) => captured = request),
        ),
      );
      final service = await ReadingService.fromRegisters(
        ruleSourceLoader: loader,
        manifests: <String>[_manifestJson('com.example.pack', _htmlRuleJson())],
        persist: false,
      );

      expect(service.extensions, hasLength(2));
      expect(service.bundle.length, 3);
      expect(service.allSources.map((e) => e.source.key), contains('html_demo'));
      expect(service.ruleSourceLoader.registeredIdentifies, contains(_ruleIdentify));

      final identify = service.bundle
          .getSourceConfigWrapperList()
          .firstWhere((e) => e.info.key == 'html_demo')
          .identify;
      final (payload, covers, nextKey) = await service.search(identify, '孤独');
      expect(payload.isError, isFalse);
      expect(covers, hasLength(2));
      expect(covers.first.label, '孤独摇滚');
      expect(covers.first.source, identify);
      expect(nextKey, '2');
      expect(captured!.url.queryParameters['kw'], '孤独');
      expect(captured!.url.queryParameters['p'], '1');

      await service.removePackage(0);
      expect(service.allSources.map((e) => e.source.key), isNot(contains('html_demo')));
    });
  });

  group('RuleSourceComponent', () {
    test('maps every novel business onto entities', () async {
      final component = _ruleComponent(_novelRuleJson(), _novelClient());
      const summary = BookSummary(source: 'x', id: 'b1');

      final (detailPayload, detailed, volumes) = await component
          .getNovelDetailed(summary);
      expect(detailPayload.isError, isFalse);
      expect(detailed!.id, 'b1');
      expect(detailed.label, '测试小说');
      expect(detailed.genre, '科幻');
      expect(detailed.status, BookStatus.complete);
      expect(detailed.source, 'com.example.pack-|-novel_demo');
      expect(volumes, hasLength(2));
      expect(volumes!.first.id, 'v1');
      expect(volumes.first.organizeType, NovelVolumeOrganizeType.multiChapter);
      expect(volumes.last.organizeType, NovelVolumeOrganizeType.singleChapter);

      final (chapterPayload, chapters) = await component.getNovelChapters(
        volumes.first,
        summary,
      );
      expect(chapterPayload.isError, isFalse);
      expect(chapters, hasLength(2));
      expect(chapters!.first.label, '第一章');
      expect(chapters.first.loadType, NovelChapterLoadType.txt);
      expect(chapters.last.loadType, NovelChapterLoadType.html);

      final (readPayload, content) = await component.loadNovelChapter(
        chapters.first,
        summary,
      );
      expect(readPayload.isError, isFalse);
      expect(content, '第一章的正文内容。');
    });

    test('maps unsupported businesses and empty results to payloads', () async {
      final component = _ruleComponent(_htmlRuleJson(), _htmlClient(null));
      final (payload, tabs) = await component.getHomeTab();
      expect(payload.code, ComponentPayload.codeCallError);
      expect(payload.errorMsg, '调用错误 书源「HTML 示例源」未实现业务 home_tab');
      expect(tabs, isNull);

      final (nothingPayload, covers, nextKey) = await component.search(
        component.getInitKey('x'),
        'x',
      );
      expect(nothingPayload.isError, isFalse);
      expect(covers, hasLength(2));
      expect(nextKey, '2');
      expect(component.getInitKey('x'), '1');
    });
  });

  group('widgets', () {
    Future<ReadingService> buildService() async {
      final service = await ReadingService.fromRegisters(persist: false);
      return service;
    }

    testWidgets('EasyMyGoPage shows the module entries', (tester) async {
      final service = await buildService();
      await tester.pumpWidget(
        MaterialApp(home: EasyMyGoPage(service: service)),
      );
      await tester.pumpAndSettle();

      expect(find.text('EasyMyGo 插件阅读'), findsOneWidget);
      expect(find.text('已启用 2 / 2 个书源'), findsOneWidget);
      expect(find.byKey(const ValueKey('easymygo-entry-shelf')), findsOneWidget);
      expect(find.byKey(const ValueKey('easymygo-entry-search')), findsOneWidget);
      expect(
        find.byKey(const ValueKey('easymygo-entry-sources')),
        findsOneWidget,
      );
    });

    testWidgets('ShelfPage shows empty states then stored items', (tester) async {
      final service = await buildService();
      final store = LibraryStore();
      await tester.pumpWidget(
        MaterialApp(home: ShelfPage(service: service, libraryStore: store)),
      );
      await tester.pumpAndSettle();
      expect(find.text('书架还是空的，去搜索或从书源里收藏一本吧'), findsOneWidget);

      await tester.tap(find.text('历史'));
      await tester.pumpAndSettle();
      expect(find.text('还没有阅读记录'), findsOneWidget);

      const cover = BookCover(
        type: SourceType.manga,
        id: 'm1',
        label: '孤独摇滚',
        cover: '',
        intro: '',
        jumpUrl: '',
        source: 'p-|-s',
      );
      await store.setStarred(cover, true);
      await store.saveProgress(
        cover,
        const ReadingProgress(
          chapterId: 'c1',
          chapterLabel: '第 1 话',
          pageIndex: 1,
          pageCount: 3,
          updatedAt: 1,
        ),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: ShelfPage(
            key: const ValueKey<String>('shelf-reload'),
            service: service,
            libraryStore: store,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('孤独摇滚'), findsOneWidget);
      expect(find.text('第 1 话 · 第 2/3 页'), findsOneWidget);
    });

    testWidgets('BookSearchPage searches through the inner source', (
      tester,
    ) async {
      final service = await buildService();
      await tester.pumpWidget(
        MaterialApp(
          home: BookSearchPage(service: service, libraryStore: LibraryStore()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('选择书源并输入关键字'), findsOneWidget);

      await tester.enterText(
        find.byKey(const ValueKey<String>('easymygo-search-keyword')),
        '轻音',
      );
      await tester.tap(
        find.byKey(const ValueKey<String>('easymygo-search-submit')),
      );
      await tester.pumpAndSettle();

      expect(find.text('轻音少女'), findsOneWidget);
      await tester.tap(find.text('轻音少女'));
      await tester.pumpAndSettle();
      expect(find.byType(BookDetailPage), findsOneWidget);
    });

    testWidgets('BookSearchPage reports an empty result', (tester) async {
      final service = await buildService();
      await tester.pumpWidget(
        MaterialApp(
          home: BookSearchPage(service: service, libraryStore: LibraryStore()),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey<String>('easymygo-search-keyword')),
        '没有这本书',
      );
      await tester.tap(
        find.byKey(const ValueKey<String>('easymygo-search-submit')),
      );
      await tester.pumpAndSettle();

      expect(find.text('没有找到相关作品'), findsOneWidget);
    });

    testWidgets('BookDetailPage lists chapters and opens the reader', (
      tester,
    ) async {
      final service = await buildService();
      const cover = BookCover(
        type: SourceType.manga,
        id: 'manga_1',
        label: '孤独摇滚',
        cover: '',
        intro: '',
        jumpUrl: '',
        source: _mangaIdentify,
      );
      await tester.pumpWidget(
        MaterialApp(
          home: BookDetailPage(
            service: service,
            cover: cover,
            libraryStore: LibraryStore(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('章节（12）'), findsOneWidget);
      expect(find.text('第 1 话'), findsOneWidget);
      expect(find.text('状态：连载中'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey<String>('easymygo-chapter-0')));
      await tester.pumpAndSettle();
      expect(find.byType(MangaReaderPage), findsOneWidget);
    });

    testWidgets('BookDetailPage lists novel volumes', (tester) async {
      final service = await buildService();
      const cover = BookCover(
        type: SourceType.novel,
        id: 'novel_1',
        label: '深海之灯',
        cover: '',
        intro: '',
        jumpUrl: '',
        source: _novelIdentify,
      );
      await tester.pumpWidget(
        MaterialApp(
          home: BookDetailPage(
            service: service,
            cover: cover,
            libraryStore: LibraryStore(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('分卷（2）'), findsOneWidget);
      expect(find.text('第 1 卷'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey<String>('easymygo-volume-0')));
      await tester.pumpAndSettle();
      expect(find.text('从本卷开始阅读'), findsOneWidget);
    });

    testWidgets('MangaReaderPage pages through a chapter and persists it', (
      tester,
    ) async {
      final source = TestMangaSource();
      final component = DemoMangaComponent(sourceInfo: source.info);
      const summary = BookSummary(source: _mangaIdentify, id: 'manga_1');
      final (_, _, chapters) = await component.getMangaDetailed(summary);
      const cover = BookCover(
        type: SourceType.manga,
        id: 'manga_1',
        label: '孤独摇滚',
        cover: '',
        intro: '',
        jumpUrl: '',
        source: _mangaIdentify,
      );
      final store = LibraryStore();

      await tester.pumpWidget(
        MaterialApp(
          home: MangaReaderPage(
            component: component,
            summary: summary,
            cover: cover,
            chapters: chapters!,
            libraryStore: store,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('第 1 话'), findsOneWidget);
      expect(find.text('1 / 3'), findsOneWidget);

      await tester.tap(
        find.byKey(const ValueKey<String>('easymygo-manga-next')),
      );
      await tester.pumpAndSettle();
      expect(find.text('2 / 3'), findsOneWidget);

      final progress = await store.progressOf(cover.identify);
      expect(progress, isNotNull);
      expect(progress!.pageIndex, 1);
      expect(progress.chapterLabel, '第 1 话');
    });

    testWidgets('NovelReaderPage renders text and turns the page', (
      tester,
    ) async {
      final source = TestNovelSource();
      final component = DemoNovelComponent(sourceInfo: source.info);
      const summary = BookSummary(source: _novelIdentify, id: 'novel_1');
      final (_, _, volumes) = await component.getNovelDetailed(summary);
      const cover = BookCover(
        type: SourceType.novel,
        id: 'novel_1',
        label: '深海之灯',
        cover: '',
        intro: '',
        jumpUrl: '',
        source: _novelIdentify,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: NovelReaderPage(
            component: component,
            summary: summary,
            cover: cover,
            volumes: volumes!,
            libraryStore: LibraryStore(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final text = tester.widget<SelectableText>(
        find.byKey(const ValueKey<String>('easymygo-novel-text')),
      );
      expect(text.data, startsWith('《深海之灯》'));
      expect(find.textContaining('第 1 卷 第 1 章'), findsWidgets);

      final indicator = find.descendant(
        of: find.byType(NovelReaderPage),
        matching: find.textContaining(' / '),
      );
      final before = tester.widget<Text>(indicator).data;
      await tester.tap(
        find.byKey(const ValueKey<String>('easymygo-novel-next')),
      );
      await tester.pumpAndSettle();
      final after = tester.widget<Text>(indicator).data;
      expect(after, isNot(before));
    });

    testWidgets('SourceSettingPage imports a rule package', (tester) async {
      final service = await buildService();
      await tester.pumpWidget(
        MaterialApp(home: SourceSettingPage(service: service)),
      );
      await tester.pumpAndSettle();
      expect(find.text('书源管理'), findsOneWidget);
      expect(find.text('书源（已启用 2）'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.byKey(const ValueKey<String>('easymygo-import-input')),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.enterText(
        find.byKey(const ValueKey<String>('easymygo-import-input')),
        _manifestJson('com.example.pack', _htmlRuleJson()),
      );
      await tester.tap(
        find.byKey(const ValueKey<String>('easymygo-import-submit')),
      );
      await tester.pumpAndSettle();

      expect(find.text('已导入扩展包 示例规则包'), findsOneWidget);
      expect(
        find.byKey(const ValueKey<String>('easymygo-source-$_ruleIdentify')),
        findsOneWidget,
      );
      expect(service.allSources.map((e) => e.source.key), contains('html_demo'));
    });
  });
}
