import 'package:dashboard/features/reading/easymygo/component/home_component.dart';
import 'package:dashboard/features/reading/easymygo/component/manga_component.dart';
import 'package:dashboard/features/reading/easymygo/component/novel_component.dart';
import 'package:dashboard/features/reading/easymygo/component/search_component.dart';
import 'package:dashboard/features/reading/easymygo/entity/book_cover.dart';
import 'package:dashboard/features/reading/easymygo/entity/book_detailed.dart';
import 'package:dashboard/features/reading/easymygo/entity/book_home_page.dart';
import 'package:dashboard/features/reading/easymygo/entity/book_home_tab.dart';
import 'package:dashboard/features/reading/easymygo/entity/book_second_tab.dart';
import 'package:dashboard/features/reading/easymygo/entity/book_status.dart';
import 'package:dashboard/features/reading/easymygo/entity/book_summary.dart';
import 'package:dashboard/features/reading/easymygo/entity/component_payload.dart';
import 'package:dashboard/features/reading/easymygo/entity/manga_chapter.dart';
import 'package:dashboard/features/reading/easymygo/entity/manga_picture.dart';
import 'package:dashboard/features/reading/easymygo/entity/novel_chapter.dart';
import 'package:dashboard/features/reading/easymygo/entity/novel_volume.dart';
import 'package:dashboard/features/reading/easymygo/entity/source_info.dart';
import 'package:dashboard/features/reading/easymygo/rule/rule_engine.dart';
import 'package:dashboard/features/reading/easymygo/rule/rule_exception.dart';
import 'package:dashboard/features/reading/easymygo/rule/rule_request.dart';
import 'package:dashboard/features/reading/easymygo/rule/rule_result.dart';
import 'package:dashboard/features/reading/easymygo/rule/rule_scope.dart';
import 'package:dashboard/features/reading/easymygo/rule/rule_source_definition.dart';

/// The Dart replacement for EasyMyGo's eight `Js*Component` wrappers.
///
/// Each EasyMyGo JS source exposed functions such as `manga_search_search`; the
/// eight `JsManga*`/`JsNovel*` components marshalled arguments into JS and parsed
/// the JSON answer back into entities. Here one [RuleSourceDefinition] supplies
/// those same nine businesses as declarative rules and this class performs the
/// identical argument marshalling / entity mapping around [RuleEngine].
///
/// Substitution note: EasyMyGo evaluated source code with `flutter_js`. The host
/// has no JS runtime dependency and none may be added, so the JS *rule model*
/// (request + parse expressions, the `Buffer`/`HtmlQuerySelector`/`HtmlXPath`
/// action set) was ported faithfully and is evaluated in Dart instead.
class RuleSourceComponent
    implements HomeComponent, SearchComponent, MangaComponent, NovelComponent {
  RuleSourceComponent({
    required this.sourceInfo,
    required this.definition,
    RuleEngine? engine,
  }) : engine = engine ?? RuleEngine();

  @override
  final SourceInfo sourceInfo;

  final RuleSourceDefinition definition;
  final RuleEngine engine;

  /// Releases this component's engine. [RuleEngine.close] itself only closes a
  /// client the engine created, so an injected test client stays usable.
  void close() {
    engine.close();
  }

  RuleScope _scope([Map<String, String>? variables]) => RuleScope(
    sourceInfo: sourceInfo,
    baseUrl: definition.baseUrl,
    variables: variables,
  );

  Future<RuleResult> _run(String business, RuleScope scope) {
    final endpoint = definition.endpoint(business);
    if (endpoint == null) {
      throw RuleException('书源「${sourceInfo.label}」未实现业务 $business');
    }
    return engine.execute(endpoint, scope);
  }

  /// Ported from the original's `codeCallError` channel.
  ComponentPayload _errorPayload(Object error) => ComponentPayload(
    code: ComponentPayload.codeCallError,
    msg: error is RuleException ? error.message : '$error',
  );

  ComponentPayload _emptyPayload(String message) =>
      ComponentPayload(code: ComponentPayload.codeParseResultError, msg: message);

  @override
  Future<(ComponentPayload, List<BookHomeTab>?)> getHomeTab() async {
    try {
      final result = await _run('home_tab', _scope());
      final rows = result.list('tabs');
      if (rows.isEmpty) {
        return (_emptyPayload('首页 Tab 为空'), null);
      }
      return (const ComponentPayload.ok(), <BookHomeTab>[
        for (final row in rows)
          BookHomeTab(
            id: row['id'] ?? '',
            label: row['label'] ?? '',
            hasSecondTab: _truthy(row['has_second_tab']),
            ext: row['ext'] ?? '',
          ),
      ]);
    } catch (error) {
      return (_errorPayload(error), null);
    }
  }

  @override
  Future<(ComponentPayload, List<BookSecondTab>?)> getSecondTab(
    BookHomeTab tab,
  ) async {
    try {
      final result = await _run(
        'second_tab',
        _scope(<String, String>{
          'home_tab_id': tab.id,
          'home_tab_label': tab.label,
          'home_tab_ext': tab.ext,
        }),
      );
      final rows = result.list('tabs');
      if (rows.isEmpty) {
        return (_emptyPayload('二级 Tab 为空'), null);
      }
      return (const ComponentPayload.ok(), <BookSecondTab>[
        for (final row in rows)
          BookSecondTab(
            id: row['id'] ?? '',
            label: row['label'] ?? '',
            ext: row['ext'] ?? '',
          ),
      ]);
    } catch (error) {
      return (_errorPayload(error), null);
    }
  }

  @override
  Future<(ComponentPayload, BookHomePage?)> getPageWithHomeTab(
    BookHomeTab tab,
  ) async {
    try {
      final result = await _run(
        'home_page',
        _scope(<String, String>{
          'home_tab_id': tab.id,
          'home_tab_label': tab.label,
          'home_tab_ext': tab.ext,
        }),
      );
      final page = _page(result);
      if (page == null) {
        return (_emptyPayload('首页分页为空'), null);
      }
      return (const ComponentPayload.ok(), page);
    } catch (error) {
      return (_errorPayload(error), null);
    }
  }

  @override
  Future<(ComponentPayload, BookHomePage?)> getPageWithSecondTab(
    BookHomeTab tab,
    BookSecondTab secondTab,
  ) async {
    try {
      final result = await _run(
        'home_page',
        _scope(<String, String>{
          'home_tab_id': tab.id,
          'home_tab_label': tab.label,
          'second_tab_id': secondTab.id,
          'second_tab_label': secondTab.label,
          'second_tab_ext': secondTab.ext,
        }),
      );
      final page = _page(result);
      if (page == null) {
        return (_emptyPayload('二级分页为空'), null);
      }
      return (const ComponentPayload.ok(), page);
    } catch (error) {
      return (_errorPayload(error), null);
    }
  }

  @override
  Future<(ComponentPayload, List<BookCover>, String?)> loadPageData(
    BookHomePage page,
    String key,
  ) async {
    try {
      final result = await _run(
        'home_covers',
        _scope(<String, String>{
          'page_id': page.id,
          'page_label': page.label,
          'page_ext': page.ext,
          'key': key,
        }),
      );
      return (
        const ComponentPayload.ok(),
        <BookCover>[for (final row in result.list('covers')) _cover(row)],
        result.optional('next_key'),
      );
    } catch (error) {
      return (_errorPayload(error), const <BookCover>[], null);
    }
  }

  @override
  String getInitKey(String keyword) {
    final endpoint = definition.search;
    if (endpoint == null || endpoint.initialKey.isEmpty) {
      return '1';
    }
    return RuleRequest.interpolate(
      endpoint.initialKey,
      _scope(<String, String>{'keyword': keyword}).variables,
    );
  }

  @override
  Future<(ComponentPayload, List<BookCover>, String?)> search(
    String key,
    String keyword,
  ) async {
    try {
      final result = await _run(
        'search',
        _scope(<String, String>{'key': key, 'keyword': keyword}),
      );
      return (
        const ComponentPayload.ok(),
        <BookCover>[for (final row in result.list('covers')) _cover(row)],
        result.optional('next_key'),
      );
    } catch (error) {
      return (_errorPayload(error), const <BookCover>[], null);
    }
  }

  @override
  Future<(ComponentPayload, BookDetailed?, List<MangaChapter>?)>
  getMangaDetailed(BookSummary summary) async {
    try {
      final scope = _summaryScope(summary);
      final detailed = _detailed(await _run('detail', scope));
      List<MangaChapter>? chapters;
      if (definition.has('chapters')) {
        final result = await _run('chapters', scope);
        chapters = <MangaChapter>[
          for (final row in result.list('chapters'))
            MangaChapter(
              label: row['label'] ?? '',
              id: row['id'] ?? '',
              showType: ChapterShowType.fromName(row['show_type']),
              ext: row['ext'] ?? '',
            ),
        ];
      }
      if (detailed == null) {
        return (_emptyPayload('详情为空'), null, null);
      }
      return (const ComponentPayload.ok(), detailed, chapters);
    } catch (error) {
      return (_errorPayload(error), null, null);
    }
  }

  @override
  Future<(ComponentPayload, List<MangaPicture>?)> getMangaPictures(
    MangaChapter chapter,
    BookSummary summary,
  ) async {
    try {
      final result = await _run(
        'read',
        _scope(<String, String>{
          'id': summary.id,
          'ext': summary.ext,
          'chapter_id': chapter.id,
          'chapter_label': chapter.label,
          'chapter_ext': chapter.ext,
        }),
      );
      final pictures = <MangaPicture>[
        for (final row in result.list('pictures'))
          MangaPicture(
            url: row['url'] ?? '',
            type: PictureLoadType.fromName(row['type']),
          ),
      ];
      if (pictures.isEmpty) {
        return (_emptyPayload('图片列表为空'), null);
      }
      return (const ComponentPayload.ok(), pictures);
    } catch (error) {
      return (_errorPayload(error), null);
    }
  }

  @override
  Future<(ComponentPayload, BookDetailed?, List<NovelVolume>?)>
  getNovelDetailed(BookSummary summary) async {
    try {
      final scope = _summaryScope(summary);
      final detailed = _detailed(await _run('detail', scope));
      if (detailed == null) {
        return (_emptyPayload('详情为空'), null, null);
      }
      List<NovelVolume>? volumes;
      if (definition.has('volumes')) {
        final result = await _run('volumes', scope);
        volumes = <NovelVolume>[
          for (final row in result.list('volumes'))
            NovelVolume(
              label: row['label'] ?? '',
              id: row['id'] ?? '',
              organizeType: NovelVolumeOrganizeType.fromName(
                row['organize_type'],
              ),
              ext: row['ext'] ?? '',
            ),
        ];
      }
      if (volumes == null || volumes.isEmpty) {
        // 单分卷源：详情页直接给章节，这里合成唯一分卷，与源工程
        // `organizeType: multiChapter` 的默认行为一致。
        volumes = <NovelVolume>[NovelVolume(label: detailed.label, id: 'default')];
      }
      return (const ComponentPayload.ok(), detailed, volumes);
    } catch (error) {
      return (_errorPayload(error), null, null);
    }
  }

  @override
  Future<(ComponentPayload, List<NovelChapter>?)> getNovelChapters(
    NovelVolume volume,
    BookSummary summary,
  ) async {
    try {
      final result = await _run(
        'chapters',
        _scope(<String, String>{
          'id': summary.id,
          'ext': summary.ext,
          'volume_id': volume.id,
          'volume_label': volume.label,
          'organize_type': volume.organizeType.name,
        }),
      );
      final chapters = <NovelChapter>[
        for (final row in result.list('chapters'))
          NovelChapter(
            label: row['label'] ?? '',
            id: row['id'] ?? '',
            src: row['src'] ?? '',
            loadFrom: NovelChapterLoadFrom.fromName(row['load_from']),
            loadType: NovelChapterLoadType.fromName(row['load_type']),
          ),
      ];
      if (chapters.isEmpty) {
        return (_emptyPayload('章节列表为空'), null);
      }
      return (const ComponentPayload.ok(), chapters);
    } catch (error) {
      return (_errorPayload(error), null);
    }
  }

  @override
  Future<(ComponentPayload, String)> loadNovelChapter(
    NovelChapter chapter,
    BookSummary summary,
  ) async {
    try {
      final result = await _run(
        'read',
        _scope(<String, String>{
          'id': summary.id,
          'ext': summary.ext,
          'chapter_id': chapter.id,
          'chapter_label': chapter.label,
          'chapter_src': chapter.src,
          'load_from': chapter.loadFrom.name,
          'load_type': chapter.loadType.name,
        }),
      );
      var content = result.value('content');
      if (content.isEmpty) {
        for (final row in result.list('chapters')) {
          if ((row['id'] ?? '') == chapter.id) {
            content = row['content'] ?? '';
            break;
          }
        }
      }
      if (content.isEmpty) {
        return (_emptyPayload('章节内容为空'), '');
      }
      return (const ComponentPayload.ok(), content);
    } catch (error) {
      return (_errorPayload(error), '');
    }
  }

  RuleScope _summaryScope(BookSummary summary) => _scope(<String, String>{
    'id': summary.id,
    'ext': summary.ext,
    'summary_source': summary.source,
  });

  BookCover _cover(Map<String, String> row) => BookCover(
    type: sourceInfo.type,
    id: row['id'] ?? '',
    label: row['label'] ?? '',
    cover: row['cover'] ?? '',
    intro: row['intro'] ?? '',
    jumpUrl: row['jump_url'] ?? '',
    source: sourceInfo.identify,
    ext: row['ext'] ?? '',
  );

  BookHomePage? _page(RuleResult result) {
    final id = result.value('page_id');
    final label = result.value('page_label');
    if (id.isEmpty && label.isEmpty) {
      return null;
    }
    return BookHomePage(
      id: id.isEmpty ? label : id,
      label: label.isEmpty ? id : label,
      hasCover: result.value('has_cover') != 'false',
      initKey: result.value('init_key'),
      ext: result.value('page_ext'),
    );
  }

  BookDetailed? _detailed(RuleResult result) {
    final id = result.value('id');
    final label = result.value('label');
    if (id.isEmpty && label.isEmpty) {
      return null;
    }
    return BookDetailed(
      type: sourceInfo.type,
      source: sourceInfo.identify,
      id: id,
      label: label,
      cover: result.value('cover'),
      intro: result.value('intro'),
      jumpUrl: result.value('jump_url'),
      isDetailedLoad: true,
      genre: result.value('genre'),
      description: result.value('description'),
      updateStrategy: BookUpdateStrategy.fromName(
        result.optional('update_strategy'),
      ),
      status: BookStatus.fromName(result.optional('status')),
      ext: result.value('ext'),
    );
  }
}

bool _truthy(String? value) => value == 'true' || value == '1';
