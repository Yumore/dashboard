import 'package:dashboard/features/reading/easymygo/component/home_component.dart';
import 'package:dashboard/features/reading/easymygo/component/manga_component.dart';
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
import 'package:dashboard/features/reading/easymygo/entity/source_info.dart';

/// Ported from `MangaTestComponent`
/// (`lib/plugin/inner/test/component/manga/manga_test_component.dart`).
///
/// The original was an offline inner source used to exercise the UI; the port
/// keeps it as the deterministic, network-free source the host app ships and the
/// widget tests drive. The tab/chapter/paging shape (and the `key == 10` paging
/// bound, here `key`-driven) follows the original.
class DemoMangaComponent
    implements HomeComponent, SearchComponent, MangaComponent {
  const DemoMangaComponent({required this.sourceInfo});

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
        BookSecondTab(id: 'month', label: '月榜'),
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
  Future<(ComponentPayload, BookDetailed?, List<MangaChapter>?)>
  getMangaDetailed(BookSummary summary) async {
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
        jumpUrl: 'https://example.com/manga/${row['id']}',
        isDetailedLoad: true,
        genre: '日常 / 音乐',
        description: row['intro']!,
        status: BookStatus.ongoing,
      ),
      <MangaChapter>[
        for (var index = 1; index <= 12; index++)
          MangaChapter(label: '第 $index 话', id: '${row['id']}_c$index'),
      ],
    );
  }

  @override
  Future<(ComponentPayload, List<MangaPicture>?)> getMangaPictures(
    MangaChapter chapter,
    BookSummary summary,
  ) async => (
    const ComponentPayload.ok(),
    <MangaPicture>[
      for (var index = 1; index <= 3; index++)
        MangaPicture(
          url: 'https://example.com/pic/${summary.id}/${chapter.id}/$index.jpg',
        ),
    ],
  );

  BookCover _cover(Map<String, String> row) => BookCover(
    type: sourceInfo.type,
    id: row['id']!,
    label: row['label']!,
    cover: row['cover']!,
    intro: row['intro']!,
    jumpUrl: 'https://example.com/manga/${row['id']}',
    source: sourceInfo.identify,
  );

  Map<String, String>? _find(String id) {
    for (final row in _catalog) {
      if (row['id'] == id) return row;
    }
    return null;
  }
}

const List<Map<String, String>> _catalog = <Map<String, String>>[
  <String, String>{
    'id': 'manga_1',
    'label': '孤独摇滚',
    'cover': 'https://example.com/cover/manga_1.jpg',
    'intro': '结束乐队四人组的日常。',
  },
  <String, String>{
    'id': 'manga_2',
    'label': '轻音少女',
    'cover': 'https://example.com/cover/manga_2.jpg',
    'intro': '放学后茶会的轻音乐日常。',
  },
  <String, String>{
    'id': 'manga_3',
    'label': '少女终末旅行',
    'cover': 'https://example.com/cover/manga_3.jpg',
    'intro': '两名少女在终末世界的旅途。',
  },
  <String, String>{
    'id': 'manga_4',
    'label': '摇曳露营',
    'cover': 'https://example.com/cover/manga_4.jpg',
    'intro': '冬日湖畔的露营与美食。',
  },
  <String, String>{
    'id': 'manga_5',
    'label': '白箱',
    'cover': 'https://example.com/cover/manga_5.jpg',
    'intro': '动画制作现场的五人组。',
  },
  <String, String>{
    'id': 'manga_6',
    'label': '别对映像研出手',
    'cover': 'https://example.com/cover/manga_6.jpg',
    'intro': '三人组做动画的冒险。',
  },
  <String, String>{
    'id': 'manga_7',
    'label': '夏日重现',
    'cover': 'https://example.com/cover/manga_7.jpg',
    'intro': '小岛上的时间循环悬疑。',
  },
  <String, String>{
    'id': 'manga_8',
    'label': '深海的灯',
    'cover': 'https://example.com/cover/manga_8.jpg',
    'intro': '深海观测站的短篇集。',
  },
];
