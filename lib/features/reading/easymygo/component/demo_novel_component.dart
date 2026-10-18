import 'package:dashboard/features/reading/easymygo/component/home_component.dart';
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
import 'package:dashboard/features/reading/easymygo/entity/novel_chapter.dart';
import 'package:dashboard/features/reading/easymygo/entity/novel_volume.dart';
import 'package:dashboard/features/reading/easymygo/entity/source_info.dart';

/// Ported from `NovelTestComponent`
/// (`lib/plugin/inner/test/component/novel/novel_test_component.dart`).
///
/// Deliberate deviation: the original declared its source as
/// `SourceType.manga` (a bug that made the novel test source unusable); the port
/// keeps `novel` so the novel flow actually works.
class DemoNovelComponent
    implements HomeComponent, SearchComponent, NovelComponent {
  const DemoNovelComponent({required this.sourceInfo});

  @override
  final SourceInfo sourceInfo;

  static const int _pageSize = 3;

  @override
  Future<(ComponentPayload, List<BookHomeTab>?)> getHomeTab() async => (
    const ComponentPayload.ok(),
    const <BookHomeTab>[
      BookHomeTab(id: 'recommend', label: '推荐', hasSecondTab: false),
      BookHomeTab(id: 'rank', label: '排行榜', hasSecondTab: true),
    ],
  );

  @override
  Future<(ComponentPayload, List<BookSecondTab>?)> getSecondTab(
    BookHomeTab tab,
  ) async {
    if (tab.id != 'rank') {
      return (const ComponentPayload.ok(), const <BookSecondTab>[]);
    }
    return (
      const ComponentPayload.ok(),
      const <BookSecondTab>[
        BookSecondTab(id: 'day', label: '日榜'),
        BookSecondTab(id: 'week', label: '周榜'),
      ],
    );
  }

  @override
  Future<(ComponentPayload, BookHomePage?)> getPageWithHomeTab(
    BookHomeTab tab,
  ) async => (
    const ComponentPayload.ok(),
    BookHomePage(
      id: '${tab.id}_page',
      label: tab.label,
      hasCover: true,
      initKey: '1',
    ),
  );

  @override
  Future<(ComponentPayload, BookHomePage?)> getPageWithSecondTab(
    BookHomeTab tab,
    BookSecondTab secondTab,
  ) async => (
    const ComponentPayload.ok(),
    BookHomePage(
      id: '${tab.id}_${secondTab.id}_page',
      label: '${tab.label} · ${secondTab.label}',
      hasCover: true,
      initKey: '1',
    ),
  );

  @override
  Future<(ComponentPayload, List<BookCover>, String?)> loadPageData(
    BookHomePage page,
    String key,
  ) async {
    final pageIndex = int.tryParse(key) ?? 1;
    final start = (pageIndex - 1) * _pageSize;
    if (start < 0 || start >= _catalog.length) {
      return (const ComponentPayload.ok(), const <BookCover>[], null);
    }
    final end = start + _pageSize;
    final slice = _catalog.sublist(start, end > _catalog.length ? _catalog.length : end);
    return (
      const ComponentPayload.ok(),
      <BookCover>[for (final row in slice) _cover(row)],
      end < _catalog.length ? '${pageIndex + 1}' : null,
    );
  }

  @override
  String getInitKey(String keyword) => '1';

  @override
  Future<(ComponentPayload, List<BookCover>, String?)> search(
    String key,
    String keyword,
  ) async {
    final trimmed = keyword.trim();
    final matched = <Map<String, String>>[
      for (final row in _catalog)
        if (trimmed.isEmpty || '${row['label']}'.contains(trimmed)) row,
    ];
    if (matched.isEmpty) {
      return (
        const ComponentPayload(code: ComponentPayload.codeBusinessError, msg: '没有找到相关作品'),
        const <BookCover>[],
        null,
      );
    }
    return (
      const ComponentPayload.ok(),
      <BookCover>[for (final row in matched) _cover(row)],
      null,
    );
  }

  @override
  Future<(ComponentPayload, BookDetailed?, List<NovelVolume>?)>
  getNovelDetailed(BookSummary summary) async {
    final row = _find(summary.id);
    if (row == null) {
      return (const ComponentPayload(code: ComponentPayload.codeParseResultError, msg: '详情为空'), null, null);
    }
    return (
      const ComponentPayload.ok(),
      BookDetailed(
        type: sourceInfo.type,
        source: sourceInfo.identify,
        id: row['id']!,
        label: row['label']!,
        cover: row['cover']!,
        intro: row['intro']!,
        jumpUrl: 'https://example.com/novel/${row['id']}',
        isDetailedLoad: true,
        genre: '轻小说',
        description: row['intro']!,
        status: BookStatus.ongoing,
      ),
      <NovelVolume>[
        for (var index = 1; index <= 2; index++)
          NovelVolume(
            label: '第 $index 卷',
            id: '${row['id']}_v$index',
            organizeType: NovelVolumeOrganizeType.multiChapter,
          ),
      ],
    );
  }

  @override
  Future<(ComponentPayload, List<NovelChapter>?)> getNovelChapters(
    NovelVolume volume,
    BookSummary summary,
  ) async => (
    const ComponentPayload.ok(),
    <NovelChapter>[
      for (var index = 1; index <= 3; index++)
        NovelChapter(
          label: '${volume.label} 第 $index 章',
          id: '${volume.id}_c$index',
          src: '${volume.id}_c$index',
          loadFrom: NovelChapterLoadFrom.direct,
          loadType: NovelChapterLoadType.txt,
        ),
    ],
  );

  @override
  Future<(ComponentPayload, String)> loadNovelChapter(
    NovelChapter chapter,
    BookSummary summary,
  ) async {
    final row = _find(summary.id);
    if (row == null) {
      return (const ComponentPayload(code: ComponentPayload.codeParseResultError, msg: '章节内容为空'), '');
    }
    final buffer = StringBuffer()
      ..writeln('《${row['label']}》')
      ..writeln(chapter.label)
      ..writeln();
    for (var index = 1; index <= 30; index++) {
      buffer
        ..writeln('第 $index 段。$_paragraph')
        ..writeln();
    }
    return (const ComponentPayload.ok(), buffer.toString());
  }

  BookCover _cover(Map<String, String> row) => BookCover(
    type: sourceInfo.type,
    id: row['id']!,
    label: row['label']!,
    cover: row['cover']!,
    intro: row['intro']!,
    jumpUrl: 'https://example.com/novel/${row['id']}',
    source: sourceInfo.identify,
  );

  Map<String, String>? _find(String id) {
    for (final row in _catalog) {
      if (row['id'] == id) return row;
    }
    return null;
  }
}

const String _paragraph =
    '海边的风把书页吹得哗哗作响，她伸手按住那一页，继续读了很久，直到天色完全暗下来。';

const List<Map<String, String>> _catalog = <Map<String, String>>[
  <String, String>{
    'id': 'novel_1',
    'label': '深海之灯',
    'cover': 'https://example.com/cover/novel_1.jpg',
    'intro': '观测站的灯每晚都会亮起。',
  },
  <String, String>{
    'id': 'novel_2',
    'label': '春日回声',
    'cover': 'https://example.com/cover/novel_2.jpg',
    'intro': '毕业前最后一个春天。',
  },
  <String, String>{
    'id': 'novel_3',
    'label': '雨与旧唱片',
    'cover': 'https://example.com/cover/novel_3.jpg',
    'intro': '唱片行老板与常客的故事。',
  },
  <String, String>{
    'id': 'novel_4',
    'label': '星轨列车',
    'cover': 'https://example.com/cover/novel_4.jpg',
    'intro': '午夜发车的银河铁道。',
  },
  <String, String>{
    'id': 'novel_5',
    'label': '纸上花园',
    'cover': 'https://example.com/cover/novel_5.jpg',
    'intro': '古籍修复师的四季。',
  },
  <String, String>{
    'id': 'novel_6',
    'label': '安静的信号',
    'cover': 'https://example.com/cover/novel_6.jpg',
    'intro': '写给十年前自己的电波。',
  },
];
