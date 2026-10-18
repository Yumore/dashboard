// Network-free tests for the ported flutternovel module.
//
// The fixtures below are the public zhuishushenqi / dmzj **response shapes**
// copied from the source app's own expected payloads (`book/{id}`,
// `atoc/{sourceid}?view=chapters`, `chapterup.../chapter/{link}`, `btoc`,
// `book/fuzzy-search`, `book/hot-word`, `book/auto-complete`,
// `post/short-review`, `post/review/by-book`, `book/{id}/recommend` and the
// dmzj v3 `novel/recommend.json` feed). Every network call is served by an
// `http.MockClient`, so nothing here touches the network.
import 'package:dashboard/features/novel/flutternovel/api/dmzj_v3_api.dart';
import 'package:dashboard/features/novel/flutternovel/api/zssq_api.dart';
import 'package:dashboard/features/novel/flutternovel/models/flutter_novel_progress.dart';
import 'package:dashboard/features/novel/flutternovel/models/flutter_novel_shelf_entry.dart';
import 'package:dashboard/features/novel/flutternovel/models/novel_chapter_content.dart';
import 'package:dashboard/features/novel/flutternovel/models/reader_config.dart';
import 'package:dashboard/features/novel/flutternovel/reader/content_state.dart';
import 'package:dashboard/features/novel/flutternovel/reader/novel_page_turn_engine.dart';
import 'package:dashboard/features/novel/flutternovel/reader/novel_reader_controller.dart';
import 'package:dashboard/features/novel/flutternovel/reader/reader_animation_host.dart';
import 'package:dashboard/features/novel/flutternovel/reader/reader_animation_type.dart';
import 'package:dashboard/features/novel/flutternovel/reader/reader_canvas_page.dart';
import 'package:dashboard/features/novel/flutternovel/reader/reader_content_provider.dart';
import 'package:dashboard/features/novel/flutternovel/reader/reader_page_content_config.dart';
import 'package:dashboard/features/novel/flutternovel/store/in_memory_flutter_novel_store.dart';
import 'package:dashboard/features/novel/flutternovel/store/novel_chapter_cache.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

// ---------------------------------------------------------------------------
// Fixtures — the real response shapes
// ---------------------------------------------------------------------------

const String _bookId = '51b1c1a5e5f1e0d3b1000036';
const String _sourceId = 'qiushubang';
const String _chapterOneLink = 'http://www.qiushubang.com/book/0/1.html';

const String _detailJson = r'''
{
  "_id": "51b1c1a5e5f1e0d3b1000036",
  "title": "斗破苍穹",
  "author": "天蚕土豆",
  "majorCate": "玄幻",
  "cover": "/agent/last/51b1c1a5e5f1e0d3b1000036.jpg",
  "longIntro": "这里是属于斗气的世界，没有花俏艳丽的魔法。",
  "starRatingCount": 2481,
  "starRatings": [
    {"count": 1998, "star": 5},
    {"count": 301, "star": 4}
  ],
  "isMakeMoneyLimit": false,
  "contentLevel": 1,
  "isFineBook": true,
  "safelevel": 1,
  "allowFree": true,
  "originalAuthor": "",
  "authorDesc": "",
  "rating": {"score": 8.9, "count": 2481, "tip": "好评如潮", "isEffect": true},
  "hasCopyright": false,
  "buytype": 0,
  "sizetype": 0,
  "superscript": "",
  "currency": 0,
  "contentType": "txt",
  "_le": false,
  "allowMonthly": false,
  "allowVoucher": false,
  "allowBeanVoucher": false,
  "hasCp": true,
  "banned": 0,
  "postCount": 1303,
  "totalFollower": 12961,
  "latelyFollower": 1086,
  "followerCount": 12961,
  "wordCount": 5432198,
  "serializeWordCount": 0,
  "retentionRatio": "85.4",
  "updated": "2023-05-01T00:00:00.000Z",
  "isSerial": false,
  "chaptersCount": 1648,
  "lastChapter": "第1648章 大结局",
  "gender": ["male"],
  "tags": ["热血", "升级流"],
  "_gg": false,
  "advertRead": false,
  "donate": false,
  "copyright": "",
  "isForbidForFreeApp": false,
  "isAllowNetSearch": false,
  "limit": false,
  "copyrightInfo": "",
  "copyrightDesc": ""
}
''';

const String _catalogJson = r'''
{
  "_id": "5816b4b3a22c8e6b1cfd0d2c",
  "name": "斗破苍穹",
  "source": "qiushubang",
  "book": "51b1c1a5e5f1e0d3b1000036",
  "link": "",
  "chapters": [
    {"_id":"5816b4b4a22c8e6b1cfd0d31","title":"第一章 陨落的天才","link":"http://www.qiushubang.com/book/0/1.html","id":"1","time":1478653200000,"chapterCover":"","totalpage":0,"partsize":0,"order":1,"currency":0,"unreadble":false,"isVip":false},
    {"_id":"5816b4b4a22c8e6b1cfd0d32","title":"第二章 斗之气","link":"http://www.qiushubang.com/book/0/2.html","id":"2","time":1478653200000,"chapterCover":"","totalpage":0,"partsize":0,"order":2,"currency":0,"unreadble":false,"isVip":false},
    {"_id":"5816b4b4a22c8e6b1cfd0d33","title":"第三章 测试","link":"http://www.qiushubang.com/book/0/3.html","id":"3","time":1478653200000,"chapterCover":"","totalpage":0,"partsize":0,"order":3,"currency":0,"unreadble":false,"isVip":true}
  ],
  "updated": "2023-05-01T00:00:00.000Z",
  "host": "www.qiushubang.com"
}
''';

const String _chapterContentJson = r'''
{"chapter":{"title":"第一章 陨落的天才","cpContent":"斗之气，三段！\n少年萧炎笑了笑。","link":"http://www.qiushubang.com/book/0/1.html"}}
''';

const String _sourceListJson = r'''
[
  {"_id":"qiushubang","isCharge":false,"name":"秋书帮","lastChapter":"第1648章 大结局","updated":"2023-05-01T00:00:00.000Z","source":"qiushubang","link":"http://www.qiushubang.com","starting":false,"chaptersCount":1648,"host":"www.qiushubang.com"}
]
''';

const String _searchWordJson = r'''
{"keywords":["斗破苍穹","武动乾坤"]}
''';

const String _hotWordJson = r'''
{"hotWords":["斗破苍穹","完美世界"]}
''';

const String _keyWordSearchJson = r'''
{
  "books": [
    {
      "_id": "51b1c1a5e5f1e0d3b1000036",
      "hasCp": true,
      "title": "斗破苍穹",
      "aliases": "",
      "cat": "玄幻",
      "author": "天蚕土豆",
      "site": "zhuishushenqi",
      "cover": "/agent/last/51b1c1a5e5f1e0d3b1000036.jpg",
      "shortIntro": "这里是属于斗气的世界。",
      "lastChapter": "第1648章 大结局",
      "retentionRatio": 85.4,
      "banned": 0,
      "allowMonthly": false,
      "latelyFollower": 1086,
      "wordCount": 5432198,
      "contentType": "txt",
      "superscript": "",
      "sizetype": 0,
      "highlight": {"title": ["斗破苍穹"]}
    }
  ],
  "total": 1,
  "ok": true
}
''';

const String _shortReviewJson = r'''
{
  "today": 3,
  "ok": true,
  "docs": [
    {
      "_id": "58a1f0c9a22c8e6b1cfd0e01",
      "rating": 5,
      "type": "short_review",
      "author": {"_id":"u1","avatar":"/avatar/u1.jpg","nickname":"书友123","activityAvatar":"","type":"normal","lv":5,"gender":"male"},
      "book": {"_id":"51b1c1a5e5f1e0d3b1000036","title":"斗破苍穹","cover":"/agent/last/51b1c1a5e5f1e0d3b1000036.jpg"},
      "likeCount": 12,
      "priority": 10.5,
      "block": "",
      "state": "normal",
      "updated": "2023-04-02T10:00:00.000Z",
      "created": "2023-04-01T10:00:00.000Z",
      "content": "经典之作，百看不厌。"
    }
  ]
}
''';

const String _reviewJson = r'''
{
  "total": 1,
  "today": 0,
  "ok": true,
  "reviews": [
    {
      "_id": "58a1f0c9a22c8e6b1cfd0e02",
      "rating": 5,
      "author": {"_id":"u2","avatar":"/avatar/u2.jpg","nickname":"老书虫","activityAvatar":"","type":"normal","lv":9,"gender":"female"},
      "helpful": {"total": 20, "yes": 18, "no": 2},
      "likeCount": 30,
      "state": "normal",
      "updated": "2023-04-05T10:00:00.000Z",
      "created": "2023-04-03T10:00:00.000Z",
      "commentCount": 4,
      "content": "斗气化马，恐怖如斯。",
      "title": "很不错"
    }
  ]
}
''';

const String _recommendJson = r'''
{
  "ok": true,
  "books": [
    {
      "_id": "51b1c1a5e5f1e0d3b1000037",
      "title": "武动乾坤",
      "author": "天蚕土豆",
      "site": "zhuishushenqi",
      "cover": "/agent/last/51b1c1a5e5f1e0d3b1000037.jpg",
      "shortIntro": "修炼一途，乃窃阴阳。",
      "lastChapter": "第1300章 大结局",
      "retentionRatio": 92.3,
      "latelyFollower": 860,
      "majorCate": "玄幻",
      "minorCate": "东方玄幻",
      "allowMonthly": false,
      "isSerial": true,
      "contentType": "txt",
      "allowFree": true,
      "otherReadRatio": 38.5
    }
  ]
}
''';

const String _dmzjRecommendJson = r'''
[
  {
    "title": "热门推荐",
    "data": [
      {
        "id": "58476",
        "name": "魔法禁书目录",
        "cover": "https://images.dmzj.com/novel/58476.jpg",
        "authors": "镰池和马",
        "status": "已完结",
        "last_update_chapter_name": "第22卷",
        "last_update_chapter_id": 123456,
        "last_update_volume_id": 22,
        "last_update_time": 1682928000,
        "hot_hits": 123456,
        "introduction": "科学与魔法交错的世界。",
        "types": ["冒险", "奇幻"],
        "first_letter": "m",
        "zone": "日本",
        "subscribe_num": 4821
      }
    ]
  },
  {
    "title": "最新更新",
    "data": []
  }
]
''';

/// 60 one-line paragraphs, separated by JSON-escaped newlines: three 400x800
/// pages at the reader's default 20/30/10 font metrics.
final String _longChapterContent = List<String>.generate(
  60,
  (index) => '这是第${index + 1}段正文。',
).join(r'\n');

String _longChapterJson() =>
    '{"chapter":{"title":"第一章 陨落的天才","cpContent":"$_longChapterContent",'
    '"link":"$_chapterOneLink"}}';

http.Response _json(String body, [int status = 200]) => http.Response(
  body,
  status,
  headers: const <String, String>{
    'content-type': 'application/json; charset=utf-8',
  },
);

/// Lets the controller's unawaited chapter loads drain.
Future<void> _settle() async {
  for (var index = 0; index < 8; index++) {
    await Future<void>.delayed(Duration.zero);
  }
}

ZssqApi _stubApi({
  void Function(Uri uri)? onRequest,
  http.Response Function(Uri uri)? respond,
}) => ZssqApi(
  client: MockClient((request) async {
    final uri = request.url;
    onRequest?.call(uri);
    final custom = respond?.call(uri);
    if (custom != null) return custom;
    if (uri.path == '/btoc') return _json(_sourceListJson);
    if (uri.path.startsWith('/atoc/')) return _json(_catalogJson);
    if (uri.path.startsWith('/book/')) return _json(_detailJson);
    if (uri.host == 'chapterup.zhuishushenqi.com') {
      return _json(_longChapterJson());
    }
    return _json('{}', 404);
  }),
);

/// A stand-in reader for the page-turn engine, with call counters.
class _FakeAnimationHost implements ReaderAnimationHost {
  _FakeAnimationHost({
    this.canGoNext = true,
    this.canGoPre = true,
    this.pageIndex = 0,
  });

  bool canGoNext;
  bool canGoPre;
  int pageIndex;
  int nextCalls = 0;
  int preCalls = 0;

  @override
  bool isCanGoNext() => canGoNext;

  @override
  bool isCanGoPre() => canGoPre;

  @override
  void nextPage() {
    nextCalls++;
    pageIndex++;
  }

  @override
  void prePage() {
    preCalls++;
    pageIndex--;
  }

  @override
  ReaderCanvasPage? getCurrentPage() => ReaderCanvasPage(pageIndex: pageIndex);

  @override
  ReaderCanvasPage? getNextPage() =>
      canGoNext ? ReaderCanvasPage(pageIndex: pageIndex + 1) : null;

  @override
  ReaderCanvasPage? getPrePage() =>
      canGoPre ? ReaderCanvasPage(pageIndex: pageIndex - 1) : null;

  @override
  Paint get bgPaint => Paint();
}

NovelPageTurnEngine _engine(
  int type,
  ReaderAnimationHost host, {
  Size size = const Size(400, 800),
}) => NovelPageTurnEngine(host: host, type: type)..setViewportSize(size);

void main() {
  // TextPainter needs the test font engine (the test font is 1em per glyph, so
  // the pagination assertions below are deterministic).
  TestWidgetsFlutterBinding.ensureInitialized();

  // -------------------------------------------------------------------------
  group('ZssqApi query builders (pure)', () {
    test('builds the auto-complete / hot-word / detail endpoints', () {
      expect(
        ZssqApi.autoCompleteUrl('斗破'),
        'http://api.zhuishushenqi.com/book/auto-complete?query=斗破',
      );
      expect(
        ZssqApi.hotWordUrl(),
        'http://api.zhuishushenqi.com/book/hot-word',
      );
      expect(
        ZssqApi.bookDetailUrl(_bookId),
        'http://api.zhuishushenqi.com/book/$_bookId',
      );
      expect(
        ZssqApi.bookRecommendUrl(_bookId),
        'http://api.zhuishushenqi.com/book/$_bookId/recommend',
      );
    });

    test('builds the fuzzy-search query with query/start/limit', () {
      final uri = ZssqApi.fuzzySearchUri('斗破');
      expect(uri.host, 'api.zhuishushenqi.com');
      expect(uri.path, '/book/fuzzy-search');
      expect(uri.queryParameters, <String, String>{
        'query': '斗破',
        'start': '0',
        'limit': '20',
      });

      final paged = ZssqApi.fuzzySearchUri('武动', start: 10, limit: 5);
      expect(paged.queryParameters['start'], '10');
      expect(paged.queryParameters['limit'], '5');
    });

    test('builds the short-review and long-review queries', () {
      final short = ZssqApi.shortReviewUri(_bookId);
      expect(short.path, '/post/short-review');
      expect(short.queryParameters, <String, String>{
        'book': _bookId,
        'sort': 'updated',
        'start': '0',
        'limit': '2',
      });

      final sorted = ZssqApi.reviewByBookUri(
        _bookId,
        sort: 'created',
        start: 4,
        limit: 9,
      );
      expect(sorted.path, '/post/review/by-book');
      expect(sorted.queryParameters, <String, String>{
        'book': _bookId,
        'sort': 'created',
        'start': '4',
        'limit': '9',
      });
    });

    test('builds the atoc / btoc / chapter-content endpoints', () {
      expect(
        ZssqApi.atocUrl(_sourceId),
        'http://api.zhuishushenqi.com/atoc/qiushubang?view=chapters',
      );

      final btoc = ZssqApi.btocUri(_bookId);
      expect(btoc.path, '/btoc');
      expect(btoc.queryParameters, <String, String>{
        'book': _bookId,
        'view': 'summary',
      });

      expect(
        ZssqApi.chapterContentUrl(_chapterOneLink),
        'http://chapterup.zhuishushenqi.com/chapter/$_chapterOneLink',
      );
      expect(ZssqApi.readerImageUrl, 'http://statics.zhuishushenqi.com');
    });
  });

  // -------------------------------------------------------------------------
  group('ZssqApi JSON -> model mapping (pure parsers)', () {
    test('maps the book detail payload onto NovelDetailInfo', () {
      final detail = ZssqApi.parseDetail(_detailJson);
      expect(detail.id, _bookId);
      expect(detail.title, '斗破苍穹');
      expect(detail.author, '天蚕土豆');
      expect(detail.majorCate, '玄幻');
      expect(detail.cover, '/agent/last/$_bookId.jpg');
      expect(detail.longIntro, '这里是属于斗气的世界，没有花俏艳丽的魔法。');
      expect(detail.starRatingCount, 2481);
      expect(detail.starRatings.length, 2);
      expect(detail.starRatings.first.star, 5);
      expect(detail.starRatings.first.count, 1998);
      expect(detail.rating?.score, 8.9);
      expect(detail.rating?.count, 2481);
      expect(detail.rating?.tip, '好评如潮');
      expect(detail.rating?.isEffect, isTrue);
      expect(detail.retentionRatio, '85.4');
      expect(detail.wordCount, 5432198);
      expect(detail.serializeWordCount, 0);
      expect(detail.chaptersCount, 1648);
      expect(detail.lastChapter, '第1648章 大结局');
      expect(detail.isSerial, isFalse);
      expect(detail.banned, 0);
      expect(detail.le, isFalse);
      expect(detail.gg, isFalse);
      expect(detail.hasCp, isTrue);
      expect(detail.gender, <dynamic>['male']);
      expect(detail.tags, <dynamic>['热血', '升级流']);
      expect(detail.anchors, isEmpty);
    });

    test('maps the atoc catalog and stamps the book id on every chapter', () {
      final catalog = ZssqApi.parseCatalog(_catalogJson);
      expect(catalog.id, '5816b4b3a22c8e6b1cfd0d2c');
      expect(catalog.name, '斗破苍穹');
      expect(catalog.book, _bookId);
      expect(catalog.host, 'www.qiushubang.com');
      expect(catalog.chapterCount, 3);

      final first = catalog.chapters.first;
      // The source's `_id` on a chapter row became the model's `bookId` field.
      expect(first.bookId, '5816b4b4a22c8e6b1cfd0d31');
      expect(first.title, '第一章 陨落的天才');
      expect(first.id, '1');
      expect(first.link, _chapterOneLink);
      expect(first.time, 1478653200000);
      expect(first.unreadble, isFalse);
      expect(first.isVip, isFalse);
      expect(first.novelId, _bookId);
      expect(catalog.chapters[2].isVip, isTrue);
      expect(
        catalog.chapters.every((chapter) => chapter.novelId == _bookId),
        isTrue,
      );
    });

    test('maps the chapter content wrapper and the flat form', () {
      final content = ZssqApi.parseChapterContent(_chapterContentJson);
      expect(content.title, '第一章 陨落的天才');
      expect(content.cpContent, '斗之气，三段！\n少年萧炎笑了笑。');
      expect(content.link, _chapterOneLink);
      expect(content.isEmpty, isFalse);

      final empty = ZssqApi.parseChapterContent(
        '{"title":"第一章","cpContent":""}',
      );
      expect(empty.cpContent, '');
      expect(empty.isEmpty, isTrue);
    });

    test('maps the btoc source list', () {
      final sources = ZssqApi.parseSourceList(_sourceListJson);
      expect(sources.length, 1);
      expect(sources.first.id, _sourceId);
      expect(sources.first.name, '秋书帮');
      expect(sources.first.isCharge, isFalse);
      expect(sources.first.starting, isFalse);
      expect(sources.first.chaptersCount, 1648);
      expect(sources.first.host, 'www.qiushubang.com');
    });

    test('maps the search word / hot word / keyword-search payloads', () {
      expect(ZssqApi.parseSearchWord(_searchWordJson), <String>[
        '斗破苍穹',
        '武动乾坤',
      ]);
      expect(ZssqApi.parseHotWords(_hotWordJson), <String>[
        '斗破苍穹',
        '完美世界',
      ]);

      final search = ZssqApi.parseKeyWordSearch(_keyWordSearchJson);
      expect(search.total, 1);
      expect(search.ok, isTrue);
      expect(search.isEmpty, isFalse);
      final book = search.books.single;
      expect(book.id, _bookId);
      expect(book.title, '斗破苍穹');
      expect(book.cat, '玄幻');
      expect(book.retentionRatio, 85.4);
      expect(book.latelyFollower, 1086);
      expect(book.highlight?.title, <String>['斗破苍穹']);
    });

    test('maps the short-comment payload', () {
      final comments = ZssqApi.parseShortReview(_shortReviewJson);
      expect(comments.today, 3);
      expect(comments.ok, isTrue);
      expect(comments.isEmpty, isFalse);
      final doc = comments.docs.single;
      expect(doc.id, '58a1f0c9a22c8e6b1cfd0e01');
      expect(doc.rating, 5);
      expect(doc.type, 'short_review');
      expect(doc.likeCount, 12);
      expect(doc.priority, 10.5);
      expect(doc.content, '经典之作，百看不厌。');
      expect(doc.author?.nickname, '书友123');
      expect(doc.author?.lv, 5);
      expect(doc.book?.title, '斗破苍穹');
    });

    test('maps the long-review payload', () {
      final reviews = ZssqApi.parseReview(_reviewJson);
      expect(reviews.total, 1);
      expect(reviews.today, 0);
      expect(reviews.isEmpty, isFalse);
      final review = reviews.reviews.single;
      expect(review.id, '58a1f0c9a22c8e6b1cfd0e02');
      expect(review.rating, 5);
      expect(review.title, '很不错');
      expect(review.commentCount, 4);
      expect(review.likeCount, 30);
      expect(review.helpful?.yes, 18);
      expect(review.helpful?.no, 2);
      expect(review.author?.nickname, '老书虫');
      expect(review.author?.gender, 'female');
    });

    test('maps the book-recommend payload', () {
      final recommend = ZssqApi.parseRecommend(_recommendJson);
      expect(recommend.ok, isTrue);
      expect(recommend.isEmpty, isFalse);
      final book = recommend.books.single;
      expect(book.id, '51b1c1a5e5f1e0d3b1000037');
      expect(book.title, '武动乾坤');
      expect(book.retentionRatio, 92.3);
      expect(book.otherReadRatio, 38.5);
      expect(book.majorCate, '玄幻');
      expect(book.minorCate, '东方玄幻');
      expect(book.isSerial, isTrue);
      expect(book.allowFree, isTrue);
    });

    test('tolerates a missing payload instead of throwing', () {
      expect(ZssqApi.parseDetail('{}').title, isNull);
      expect(ZssqApi.parseCatalog('{}').chapterCount, 0);
      expect(ZssqApi.parseSourceList('{"not":"a list"}'), isEmpty);
      expect(ZssqApi.parseKeyWordSearch('{}').isEmpty, isTrue);
    });
  });

  // -------------------------------------------------------------------------
  group('DmzjV3Api recommend feed', () {
    test('parses a top-level array of sections', () {
      expect(
        DmzjV3Api.recommendUri().toString(),
        'https://v3api.dmzj.com/novel/recommend.json',
      );
      final sections = DmzjV3Api.parseRecommend(_dmzjRecommendJson);
      expect(sections.length, 2);
      expect(sections.first.title, '热门推荐');
      expect(sections.first.isEmpty, isFalse);

      final brief = sections.first.books.single;
      expect(brief.id, '58476');
      expect(brief.name, '魔法禁书目录');
      expect(brief.authors, '镰池和马');
      expect(brief.status, '已完结');
      expect(brief.lastUpdateChapterName, '第22卷');
      expect(brief.lastUpdateChapterId, 123456);
      expect(brief.lastUpdateVolumeId, 22);
      expect(brief.hotHits, 123456);
      expect(brief.types, <String>['冒险', '奇幻']);
      expect(brief.firstLetter, 'm');
      expect(brief.zone, '日本');
      expect(brief.subscribeNum, 4821);

      expect(sections[1].title, '最新更新');
      expect(sections[1].isEmpty, isTrue);
    });

    test('accepts a bare data wrapper, a single section and the books key', () {
      final wrapped = DmzjV3Api.parseRecommend(
        '{"data":[{"title":"单块","data":[{"id":"1","name":"x"}]}]}',
      );
      expect(wrapped.length, 1);
      expect(wrapped.single.title, '单块');
      expect(wrapped.single.books.single.name, 'x');

      final single = DmzjV3Api.parseRecommend(
        '{"title":"一块","data":[{"id":"2","name":"y"}]}',
      );
      expect(single.length, 1);
      expect(single.single.books.single.id, '2');

      final fallback = DmzjV3Api.parseRecommend(
        '{"title":"fallback","books":[{"id":"3","name":"z"}]}',
      );
      expect(fallback.single.title, 'fallback');
      expect(fallback.single.books.single.name, 'z');

      expect(DmzjV3Api.parseRecommend('"nope"'), isEmpty);
    });
  });

  // -------------------------------------------------------------------------
  group('ZssqApi network results', () {
    test('GETs book/{id} and reports an HTTP failure without throwing', () async {
      final requested = <Uri>[];
      final api = ZssqApi(
        client: MockClient((request) async {
          requested.add(request.url);
          return _json(_detailJson);
        }),
      );

      final result = await api.getNovelDetailInfo(_bookId);
      expect(result.isSuccess, isTrue);
      expect(result.hasData, isTrue);
      expect(result.data?.title, '斗破苍穹');
      expect(
        requested.single.toString(),
        'http://api.zhuishushenqi.com/book/$_bookId',
      );

      final broken = ZssqApi(
        client: MockClient((request) async => _json('{}', 500)),
      );
      final failed = await broken.getNovelDetailInfo(_bookId);
      expect(failed.isSuccess, isFalse);
      expect(failed.hasData, isFalse);
      expect(failed.data, isNull);
    });

    test('getNovelCatalog stamps the book id on the chapters', () async {
      final api = ZssqApi(
        client: MockClient((request) async => _json(_catalogJson)),
      );
      final result = await api.getNovelCatalog(_sourceId);
      expect(result.data?.chapterCount, 3);
      expect(
        result.data?.chapters.every((chapter) => chapter.novelId == _bookId),
        isTrue,
      );
    });
  });

  // -------------------------------------------------------------------------
  group('FlutterNovelReaderConfig', () {
    test('matches the source defaults and subtracts the reader chrome', () {
      final config = FlutterNovelReaderConfig();
      expect(config.currentAnimationMode, ReaderAnimationType.simulationTurn);
      expect(
        config.currentCanvasBgColor,
        FlutterNovelReaderConfig.defaultCanvasBgColor,
      );
      expect(config.fontSize, 20);
      expect(config.lineHeight, 30);
      expect(config.paragraphSpacing, 10);
      expect(config.brightness, FlutterNovelReaderConfig.defaultBrightness);
      expect(config.contentHeight(800), 735);
      expect(config.contentWidth(400), 380);

      expect(ReaderAnimationType.simulationTurn, 1);
      expect(ReaderAnimationType.coverTurn, 2);
      expect(ReaderAnimationType.slideTurn, 3);
      expect(ReaderAnimationType.all, <int>[1, 2, 3]);
      expect(ReaderAnimationType.label(ReaderAnimationType.simulationTurn), '仿真');
      expect(ReaderAnimationType.label(ReaderAnimationType.coverTurn), '覆盖');
      expect(ReaderAnimationType.label(ReaderAnimationType.slideTurn), '滑动');
    });

    test('round-trips through toMap / fromMap and copies independently', () {
      final config = FlutterNovelReaderConfig()
        ..currentAnimationMode = ReaderAnimationType.slideTurn
        ..fontSize = 24
        ..lineHeight = 36
        ..paragraphSpacing = 12
        ..brightness = 0.5
        ..pageSize = const Size(400, 800)
        ..novelId = 'book-1'
        ..currentChapterIndex = 3
        ..currentPageIndex = 2;
      final restored = FlutterNovelReaderConfig.fromMap(config.toMap());
      expect(restored.currentAnimationMode, ReaderAnimationType.slideTurn);
      expect(restored.fontSize, 24);
      expect(restored.lineHeight, 36);
      expect(restored.paragraphSpacing, 12);
      expect(restored.brightness, 0.5);
      expect(restored.pageSize, const Size(400, 800));
      expect(restored.novelId, 'book-1');
      expect(restored.currentChapterIndex, 3);
      expect(restored.currentPageIndex, 2);
      expect(restored.currentCanvasBgColor, config.currentCanvasBgColor);

      final copy = config.copy();
      copy.fontSize = 30;
      expect(copy.fontSize, 30);
      expect(config.fontSize, 24);
    });
  });

  // -------------------------------------------------------------------------
  group('ReaderContentProvider pagination', () {
    test('fills a page while the consumed height stays under it', () {
      const content = '第一段\n第二段\n第三段\n第四段\n第五段\n第六段';
      final pages = ReaderContentProvider.getChapterPageContentConfigList(
        7,
        content,
        160,
        300,
        20,
        30,
        10,
      );
      expect(pages.length, 2);
      expect(pages.first.currentChapterId, 7);
      expect(pages.first.currentContentFontSize, 20);
      expect(pages.first.currentContentLineHeight, 30);
      expect(pages.first.currentContentParagraphSpacing, 10);
      expect(pages.first.currentPageIndex, 0);
      expect(pages.last.currentPageIndex, 1);
      expect(pages.first.paragraphContents, <String>[
        '第一段',
        '第二段',
        '第三段',
        '第四段',
      ]);
      expect(pages.last.paragraphContents, <String>['第五段', '第六段']);
      expect(pages.first.text, '第一段\n第二段\n第三段\n第四段');
      expect(
        pages.expand((page) => page.paragraphContents).toList(),
        content.split('\n'),
      );
    });

    test('lets paragraph spacing decide how many paragraphs fit', () {
      const content = '一\n二\n三\n四\n五\n六';
      final tight = ReaderContentProvider.getChapterPageContentConfigList(
        1,
        content,
        160,
        300,
        20,
        30,
        0,
      );
      final spaced = ReaderContentProvider.getChapterPageContentConfigList(
        1,
        content,
        160,
        300,
        20,
        30,
        10,
      );
      expect(tight.first.paragraphContents.length, 5);
      expect(spaced.first.paragraphContents.length, 4);
    });

    test('splits an over-long paragraph without losing a character', () {
      final content = List<String>.filled(200, 'A').join();
      final pages = ReaderContentProvider.getChapterPageContentConfigList(
        1,
        content,
        100,
        300,
        20,
        30,
        10,
      );
      expect(pages.length, greaterThan(1));
      expect(pages.every((page) => page.paragraphContents.length == 1), isTrue);
      expect(pages.map((page) => page.text).join(), content);
      expect(pages.first.paragraphContents.single.length, lessThan(content.length));
    });

    test('returns no pages for empty content or degenerate geometry', () {
      const content = '正文';
      expect(
        ReaderContentProvider.getChapterPageContentConfigList(
          1,
          null,
          100,
          300,
          20,
          30,
          10,
        ),
        isEmpty,
      );
      expect(
        ReaderContentProvider.getChapterPageContentConfigList(
          1,
          '',
          100,
          300,
          20,
          30,
          10,
        ),
        isEmpty,
      );
      for (final geometry in <List<double>>[
        <double>[0, 300, 20, 30],
        <double>[100, 0, 20, 30],
        <double>[100, -1, 20, 30],
        <double>[100, 300, 0, 30],
        <double>[100, 300, 20, 0],
      ]) {
        expect(
          ReaderContentProvider.getChapterPageContentConfigList(
            1,
            content,
            geometry[0],
            geometry[1],
            geometry[2].toInt(),
            geometry[3].toInt(),
            10,
          ),
          isEmpty,
          reason: 'geometry $geometry must not paginate',
        );
      }
    });

    test('round-trips a page config through its JSON shape', () {
      final config = ReaderPageContentConfig()
        ..currentChapterId = 3
        ..currentContentFontSize = 20
        ..currentContentLineHeight = 30
        ..currentContentParagraphSpacing = 10
        ..currentPageIndex = 2
        ..paragraphContents = <String>['甲', '乙'];
      final restored = ReaderPageContentConfig.fromJson(config.toJson());
      expect(restored, config);
      expect(restored.toJson()['paragraphConfigs'], <String>['甲', '乙']);
      expect(restored.text, '甲\n乙');
      expect(
        ReaderPageContentConfig.fromJson(config.toJson()).hashCode,
        config.hashCode,
      );
    });
  });

  // -------------------------------------------------------------------------
  group('NovelPageTurnEngine cover animation', () {
    test('confirms a forward drag past a quarter of the height', () {
      final host = _FakeAnimationHost();
      final engine = _engine(ReaderAnimationType.coverTurn, host);

      engine.begin(const Offset(200, 400));
      engine.update(const Offset(200, 100));
      expect(engine.turnNext, isTrue);
      expect(engine.offset, -300.0);
      expect(engine.isConfirmArea(), isTrue);
      expect(engine.snapshot().type, ReaderAnimationType.coverTurn);

      engine.end();
      expect(engine.state, NovelPageTurnState.confirming);
      expect(engine.targetAnimationValue, 1);
      expect(engine.isAnimating, isTrue);

      engine.animationValue(0.5);
      expect(engine.progress, 0.5);
      expect(engine.offset, -100.0);

      expect(engine.animationCompleted(), isTrue);
      expect(host.nextCalls, 1);
      expect(host.pageIndex, 1);
      expect(engine.state, NovelPageTurnState.idle);
      expect(engine.offset, 0);
      expect(engine.progress, 0);
    });

    test('rewinds a drag under the threshold without turning the page', () {
      final host = _FakeAnimationHost();
      final engine = _engine(ReaderAnimationType.coverTurn, host);

      engine.begin(const Offset(200, 400));
      engine.update(const Offset(200, 340));
      expect(engine.offset, -60.0);
      expect(engine.isCancelArea(), isTrue);

      engine.end();
      expect(engine.state, NovelPageTurnState.cancelling);
      expect(engine.targetAnimationValue, 0);
      expect(engine.progress, 1.0);

      engine.animationValue(0.25);
      expect(engine.offset, -150.0);
      expect(engine.animationCompleted(), isFalse);
      expect(host.nextCalls, 0);
      expect(engine.state, NovelPageTurnState.idle);
    });

    test('turns backwards when the finger drags down', () {
      final host = _FakeAnimationHost(pageIndex: 2);
      final engine = _engine(ReaderAnimationType.coverTurn, host);

      engine.begin(const Offset(200, 400));
      engine.update(const Offset(200, 700));
      expect(engine.turnNext, isFalse);
      expect(engine.offset, 300.0);
      expect(engine.isConfirmArea(), isTrue);

      engine.end();
      expect(engine.state, NovelPageTurnState.confirming);
      expect(engine.animationCompleted(), isTrue);
      expect(host.preCalls, 1);
      expect(host.nextCalls, 0);
      expect(host.pageIndex, 1);
    });

    test('refuses a confirmed turn the host cannot make', () {
      final host = _FakeAnimationHost(canGoNext: false);
      final engine = _engine(ReaderAnimationType.coverTurn, host);

      engine.begin(const Offset(200, 400));
      engine.update(const Offset(200, 100));
      expect(engine.isConfirmArea(), isTrue);

      engine.end();
      expect(engine.state, NovelPageTurnState.cancelling);
      engine.animationValue(0);
      expect(engine.offset, -200.0);
      expect(engine.animationCompleted(), isFalse);
      expect(host.nextCalls, 0);
      expect(engine.state, NovelPageTurnState.idle);
    });

    test('refuses a confirmed backwards drag on the first page', () {
      final host = _FakeAnimationHost(canGoPre: false);
      final engine = _engine(ReaderAnimationType.coverTurn, host);

      engine.begin(const Offset(200, 400));
      engine.update(const Offset(200, 700));
      expect(engine.turnNext, isFalse);
      expect(engine.isConfirmArea(), isTrue);

      engine.end();
      expect(engine.state, NovelPageTurnState.cancelling);
      engine.animationValue(1);
      expect(engine.animationCompleted(), isFalse);
      expect(host.preCalls, 0);
      expect(host.pageIndex, 0);
    });

    test('ignores a new touch while a confirm animation is running', () {
      final host = _FakeAnimationHost();
      final engine = _engine(ReaderAnimationType.coverTurn, host);

      engine.begin(const Offset(200, 400));
      engine.update(const Offset(200, 100));
      engine.end();
      expect(engine.state, NovelPageTurnState.confirming);

      engine.begin(const Offset(10, 10));
      expect(engine.state, NovelPageTurnState.confirming);
      expect(engine.touch, const Offset(200, 100));

      engine.animationValue(1);
      expect(engine.animationCompleted(), isTrue);
      expect(host.nextCalls, 1);
    });
  });

  // -------------------------------------------------------------------------
  group('NovelPageTurnEngine simulation animation', () {
    test('turns forward when the touch starts on the right half', () {
      final host = _FakeAnimationHost();
      final engine = _engine(ReaderAnimationType.simulationTurn, host);

      engine.begin(const Offset(300, 400));
      engine.update(const Offset(-50, 400));
      expect(engine.turnNext, isTrue);
      expect(engine.offset, -350.0);
      expect(engine.isConfirmArea(), isTrue);

      engine.end();
      expect(engine.state, NovelPageTurnState.confirming);
      engine.animationValue(1);
      expect(engine.offset, -300.0);
      expect(engine.animationCompleted(), isTrue);
      expect(host.nextCalls, 1);
      expect(host.pageIndex, 1);
    });

    test('turns backwards when the touch starts on the left half', () {
      final host = _FakeAnimationHost(pageIndex: 2);
      final engine = _engine(ReaderAnimationType.simulationTurn, host);

      engine.begin(const Offset(100, 400));
      engine.update(const Offset(450, 400));
      expect(engine.turnNext, isFalse);
      expect(engine.offset, 350.0);

      engine.end();
      expect(engine.state, NovelPageTurnState.confirming);
      expect(engine.animationCompleted(), isTrue);
      expect(host.preCalls, 1);
      expect(host.pageIndex, 1);
    });

    test('cancels a short drag', () {
      final host = _FakeAnimationHost();
      final engine = _engine(ReaderAnimationType.simulationTurn, host);

      engine.begin(const Offset(300, 400));
      engine.update(const Offset(200, 400));
      expect(engine.offset, -100.0);
      expect(engine.isCancelArea(), isTrue);

      engine.end();
      expect(engine.state, NovelPageTurnState.cancelling);
      engine.animationValue(0.5);
      expect(engine.offset, -150.0);
      expect(engine.animationCompleted(), isFalse);
      expect(host.nextCalls, 0);
    });
  });

  // -------------------------------------------------------------------------
  group('NovelPageTurnEngine slide animation', () {
    test('accumulates the drag without turning a page below a whole page', () {
      final host = _FakeAnimationHost();
      final engine = _engine(ReaderAnimationType.slideTurn, host);

      engine.begin(const Offset(200, 700));
      engine.update(const Offset(200, 400));
      expect(engine.offset, -300.0);
      engine.update(const Offset(200, 300));
      expect(engine.offset, -400.0);
      expect(engine.turnNext, isTrue);
      expect(engine.state, NovelPageTurnState.dragging);

      engine.end();
      expect(host.nextCalls, 0);
      expect(engine.state, NovelPageTurnState.idle);
      expect(engine.offset, 0);
    });

    test('flings across the boundary and turns one page', () {
      final host = _FakeAnimationHost();
      final engine = _engine(ReaderAnimationType.slideTurn, host);

      engine.begin(const Offset(200, 700));
      engine.update(const Offset(200, 0));
      expect(engine.offset, -700.0);

      engine.end(velocity: -1200);
      expect(host.nextCalls, 1);
      expect(host.pageIndex, 1);
      expect(engine.state, NovelPageTurnState.idle);
    });

    test('turns two pages for a two-page drag', () {
      final host = _FakeAnimationHost();
      final engine = _engine(ReaderAnimationType.slideTurn, host);

      engine.begin(const Offset(200, 2000));
      engine.update(const Offset(200, 0));
      expect(engine.offset, -2000.0);

      engine.end();
      expect(host.nextCalls, 2);
      expect(host.pageIndex, 2);
    });

    test('turns previous pages for a backwards drag', () {
      final host = _FakeAnimationHost(pageIndex: 3);
      final engine = _engine(ReaderAnimationType.slideTurn, host);

      engine.begin(const Offset(200, 0));
      engine.update(const Offset(200, 1700));
      expect(engine.offset, 1700.0);

      engine.end();
      expect(host.preCalls, 2);
      expect(host.nextCalls, 0);
      expect(host.pageIndex, 1);
    });

    test('respects the host boundary and a cancelled gesture', () {
      final boundaryHost = _FakeAnimationHost(canGoNext: false);
      final boundary = _engine(ReaderAnimationType.slideTurn, boundaryHost);
      boundary.begin(const Offset(200, 2000));
      boundary.update(const Offset(200, 0));
      boundary.end();
      expect(boundaryHost.nextCalls, 0);
      expect(boundary.state, NovelPageTurnState.idle);

      final cancelledHost = _FakeAnimationHost();
      final cancelled = _engine(ReaderAnimationType.slideTurn, cancelledHost);
      cancelled.begin(const Offset(200, 2000));
      cancelled.update(const Offset(200, 0));
      cancelled.end(cancelled: true);
      expect(cancelledHost.nextCalls, 0);
      expect(cancelled.state, NovelPageTurnState.idle);
    });
  });

  // -------------------------------------------------------------------------
  group('NovelPageTurnEngine thresholds and switching', () {
    test('uses the source threshold per animation type', () {
      const size = Size(400, 800);
      expect(
        _engine(ReaderAnimationType.coverTurn, _FakeAnimationHost(), size: size)
            .confirmThreshold,
        200.0,
      );
      expect(
        _engine(
          ReaderAnimationType.simulationTurn,
          _FakeAnimationHost(),
          size: size,
        ).confirmThreshold,
        300.0,
      );
      expect(
        _engine(ReaderAnimationType.slideTurn, _FakeAnimationHost(), size: size)
            .confirmThreshold,
        400.0,
      );
    });

    test('switches the animation only while idle', () {
      final host = _FakeAnimationHost();
      final engine = _engine(ReaderAnimationType.simulationTurn, host);

      expect(engine.type, ReaderAnimationType.simulationTurn);
      expect(engine.setType(ReaderAnimationType.coverTurn), isTrue);
      expect(engine.type, ReaderAnimationType.coverTurn);
      expect(engine.setType(ReaderAnimationType.coverTurn), isFalse);
      expect(engine.setType(99), isFalse);
      expect(engine.type, ReaderAnimationType.coverTurn);

      // The switched-to animation is the cover turn, which reads the vertical
      // drag (the source's ORIENTATION_VERTICAL).
      engine.begin(const Offset(200, 400));
      engine.update(const Offset(200, 100));
      engine.end();
      expect(engine.state, NovelPageTurnState.confirming);
      expect(engine.setType(ReaderAnimationType.slideTurn), isFalse);
      expect(engine.type, ReaderAnimationType.coverTurn);

      engine.animationValue(1);
      expect(engine.animationCompleted(), isTrue);
      expect(engine.setType(ReaderAnimationType.slideTurn), isTrue);
      expect(engine.type, ReaderAnimationType.slideTurn);
    });

    test('resets on a viewport change and exposes pure slide arithmetic', () {
      final host = _FakeAnimationHost();
      final engine = _engine(
        ReaderAnimationType.coverTurn,
        host,
        size: const Size(400, 800),
      );
      engine.begin(const Offset(200, 400));
      engine.update(const Offset(200, 100));
      expect(engine.state, NovelPageTurnState.dragging);

      engine.setViewportSize(const Size(400, 600));
      expect(engine.size, const Size(400, 600));
      expect(engine.state, NovelPageTurnState.idle);
      expect(engine.offset, 0);

      expect(NovelPageTurnEngine.slideOffsetFor(0, 800, -300), -500.0);
      expect(NovelPageTurnEngine.slideOffsetFor(1, 800, -300), -1300.0);
      expect(NovelPageTurnEngine.slideOffsetFor(0, 800, -900), -700.0);
      expect(NovelPageTurnEngine.slideOffsetFor(0, 800, -800), 0);
      expect(NovelPageTurnEngine.slideOffsetFor(0, 800, 300), -300.0);
      expect(NovelPageTurnEngine.slideOffsetFor(0, 0, 300), 0);
    });
  });

  // -------------------------------------------------------------------------
  group('NovelChapterCache', () {
    const link = 'http://www.qiushubang.com/book/0/1.html';

    test('counts a miss then serves the next read from its memo', () async {
      final store = InMemoryFlutterNovelStore();
      final cache = NovelChapterCache(store: store);
      final content = NovelChapterContent(
        title: '第一章',
        cpContent: '斗之气，三段！',
        link: link,
      );

      expect(await cache.get(link), isNull);
      expect(cache.misses, 1);
      expect(store.chapterLoads, 1);

      await cache.put(link, content);
      expect(store.cachedChapterCount, 1);

      final second = await cache.get(link);
      expect(second?.cpContent, '斗之气，三段！');
      expect(cache.hits, 1);
      expect(cache.misses, 1);
      expect(
        store.chapterLoads,
        1,
        reason: 'the memo must avoid a second store read',
      );
    });

    test('serves a cold process from the store and expires after the ttl', () async {
      final store = InMemoryFlutterNovelStore();
      var now = DateTime(2026, 1, 1, 12);
      final first = NovelChapterCache(store: store, now: () => now);
      await first.put(
        link,
        NovelChapterContent(title: 't', cpContent: '正文', link: link),
      );

      final second = NovelChapterCache(store: store, now: () => now);
      expect((await second.get(link))?.cpContent, '正文');
      expect(store.chapterLoads, 1);
      expect(second.expiresAt(link), DateTime(2026, 1, 2, 12));
      expect((await second.peek(link))?.cpContent, '正文');
      expect(store.chapterLoads, 1);

      now = now.add(const Duration(hours: 24));
      expect(await second.get(link), isNull);
      expect(second.misses, 1);
      expect(store.cachedChapterCount, 0);
    });

    test('putIfAbsent keeps a fresh payload and replaces an expired one', () async {
      final store = InMemoryFlutterNovelStore();
      var now = DateTime(2026, 6, 1, 8);
      final cache = NovelChapterCache(store: store, now: () => now);
      final original = NovelChapterContent(
        title: 'a',
        cpContent: '第一版',
        link: link,
      );
      final replacement = NovelChapterContent(
        title: 'b',
        cpContent: '第二版',
        link: link,
      );

      expect((await cache.putIfAbsent(link, original)).cpContent, '第一版');
      expect((await cache.putIfAbsent(link, replacement)).cpContent, '第一版');

      now = now.add(const Duration(hours: 24));
      expect((await cache.putIfAbsent(link, replacement)).cpContent, '第二版');
      expect((await cache.get(link))?.cpContent, '第二版');
    });

    test('treats an empty payload as a miss and evicts it', () async {
      final store = InMemoryFlutterNovelStore();
      final cache = NovelChapterCache(store: store);
      await cache.put(
        link,
        NovelChapterContent(title: 'empty', cpContent: '', link: link),
      );

      expect(await cache.get(link), isNull);
      expect(cache.misses, 1);
      expect(store.cachedChapterCount, 0);
    });
  });

  // -------------------------------------------------------------------------
  group('FlutterNovelStore rows', () {
    test('sorts the shelf newest-first and removes entries', () async {
      final store = InMemoryFlutterNovelStore();
      await store.open();
      expect(store.opened, isTrue);

      await store.saveShelfEntry(
        FlutterNovelShelfEntry(
          bookId: 'a',
          title: 'A',
          addedAt: DateTime(2026, 1, 1),
        ),
      );
      await store.saveShelfEntry(
        FlutterNovelShelfEntry(
          bookId: 'b',
          title: 'B',
          addedAt: DateTime(2026, 2, 1),
        ),
      );
      await store.saveShelfEntry(
        FlutterNovelShelfEntry(
          bookId: 'a',
          title: 'A2',
          addedAt: DateTime(2026, 1, 1),
        ),
      );

      final shelf = await store.loadShelf();
      expect(shelf.map((entry) => entry.bookId).toList(), <String>['b', 'a']);
      expect(shelf.last.title, 'A2');
      expect(await store.containsShelfEntry('b'), isTrue);

      await store.removeShelfEntry('b');
      expect(await store.containsShelfEntry('b'), isFalse);
      expect((await store.loadShelf()).length, 1);

      await store.close();
      expect(store.closed, isTrue);
    });

    test('round-trips a shelf row through the sqflite map', () {
      final entry = FlutterNovelShelfEntry(
        bookId: _bookId,
        title: '斗破苍穹',
        author: '天蚕土豆',
        cover: '/agent/last/$_bookId.jpg',
        sourceId: _sourceId,
        lastChapter: '第1648章 大结局',
        chaptersCount: 1648,
        addedAt: DateTime.fromMillisecondsSinceEpoch(1767225600000),
      );
      final restored = FlutterNovelShelfEntry.fromMap(entry.toMap());
      expect(restored.bookId, _bookId);
      expect(restored.title, '斗破苍穹');
      expect(restored.author, '天蚕土豆');
      expect(restored.cover, entry.cover);
      expect(restored.sourceId, _sourceId);
      expect(restored.lastChapter, '第1648章 大结局');
      expect(restored.chaptersCount, 1648);
      expect(restored.addedAt, entry.addedAt);
      expect(restored, entry);

      final fromJson = FlutterNovelShelfEntry.fromJson(entry.toJson());
      expect(fromJson.bookId, _bookId);
      expect(fromJson.addedAt, entry.addedAt);
    });

    test('builds a shelf row from the detail payload', () {
      final entry = FlutterNovelShelfEntry.fromDetail(
        ZssqApi.parseDetail(_detailJson),
      );
      expect(entry.bookId, _bookId);
      expect(entry.title, '斗破苍穹');
      expect(entry.author, '天蚕土豆');
      expect(entry.lastChapter, '第1648章 大结局');
      expect(entry.chaptersCount, 1648);
      expect(entry.addedAt, isNotNull);

      final copy = entry.copyWith(title: '改名');
      expect(copy.title, '改名');
      expect(copy.bookId, _bookId);
    });

    test('round-trips a progress row through both shapes', () {
      final progress = FlutterNovelProgress(
        bookId: _bookId,
        chapterIndex: 3,
        pageIndex: 2,
        chapterId: '5816b4b4a22c8e6b1cfd0d33',
        chapterTitle: '第三章 测试',
        updatedAt: DateTime.fromMillisecondsSinceEpoch(1767225600000),
      );

      final fromMap = FlutterNovelProgress.fromMap(progress.toMap());
      expect(fromMap, progress);
      expect(fromMap.chapterTitle, '第三章 测试');
      expect(fromMap.updatedAt, progress.updatedAt);

      final fromJson = FlutterNovelProgress.fromJson(progress.toJson());
      expect(fromJson.bookId, _bookId);
      expect(fromJson.chapterIndex, 3);
      expect(fromJson.pageIndex, 2);
      expect(fromJson.chapterTitle, '第三章 测试');

      final moved = progress.copyWith(pageIndex: 9);
      expect(moved.pageIndex, 9);
      expect(moved.chapterIndex, 3);
      expect(progress.pageIndex, 2);
    });

    test('saves, reads and clears chapter content keyed by link', () async {
      final store = InMemoryFlutterNovelStore();
      final content = NovelChapterContent(
        title: '第一章 陨落的天才',
        cpContent: '斗之气，三段！',
        link: _chapterOneLink,
      );

      await store.saveChapter(_chapterOneLink, content);
      expect(store.cachedChapterCount, 1);
      expect((await store.loadChapter(_chapterOneLink))?.title, '第一章 陨落的天才');

      await store.removeChapter(_chapterOneLink);
      expect(await store.loadChapter(_chapterOneLink), isNull);

      await store.saveChapter(_chapterOneLink, content);
      await store.clearChapters();
      expect(store.cachedChapterCount, 0);
    });
  });

  // -------------------------------------------------------------------------
  group('NovelReaderController', () {
    test('loads the catalog, paginates and turns pages through the engine', () async {
      final store = InMemoryFlutterNovelStore();
      var chapterRequests = 0;
      final api = _stubApi(
        onRequest: (uri) {
          if (uri.host == 'chapterup.zhuishushenqi.com') chapterRequests++;
        },
      );
      final controller = NovelReaderController(
        api: api,
        store: store,
        cache: NovelChapterCache(store: store),
        bookId: _bookId,
      );

      expect(await controller.loadCatalog(), isTrue);
      expect(controller.chapterCount, 3);
      expect(controller.catalogSource, _sourceId);
      expect(controller.loading, isFalse);
      expect(controller.error, isNull);

      controller.setViewport(const Size(400, 800));
      await controller.loadChapter(0);
      expect(controller.contentState, ContentState.normal);
      expect(controller.pageCount, 3);
      expect(controller.pageIndex, 0);
      expect(controller.currentParagraphs.length, 20);
      expect(controller.currentChapterTitle, '第一章 陨落的天才');
      expect(controller.isCanGoNext(), isTrue);
      expect(controller.isCanGoPre(), isFalse);
      expect(chapterRequests, 1);

      expect(controller.setAnimationType(ReaderAnimationType.coverTurn), isTrue);
      expect(
        controller.config.currentAnimationMode,
        ReaderAnimationType.coverTurn,
      );
      expect(controller.setAnimationType(ReaderAnimationType.slideTurn), isTrue);
      expect(
        controller.config.currentAnimationMode,
        ReaderAnimationType.slideTurn,
      );
      expect(controller.setAnimationType(ReaderAnimationType.slideTurn), isFalse);

      // A cover turn applies its page change exactly once, on completion.
      controller.setAnimationType(ReaderAnimationType.coverTurn);
      controller.onTouchBegin(const Offset(200, 400));
      controller.onTouchUpdate(const Offset(200, 100));
      expect(controller.turnState, NovelPageTurnState.dragging);
      controller.onTouchEnd();
      expect(controller.turnState, NovelPageTurnState.confirming);
      expect(controller.pageIndex, 0);
      controller.onAnimationTick(1);
      controller.onAnimationCompleted();
      expect(controller.turnState, NovelPageTurnState.idle);
      expect(controller.pageIndex, 1);
      expect(controller.progressRatio, closeTo(2 / 9, 0.0001));

      // The slide animation turns whole pages when the drag settles.
      expect(controller.setAnimationType(ReaderAnimationType.slideTurn), isTrue);
      controller.onTouchBegin(const Offset(200, 900));
      controller.onTouchUpdate(const Offset(200, 100));
      controller.onTouchEnd();
      expect(controller.pageIndex, 2);
      await _settle();
      expect((await store.loadProgress(_bookId))?.pageIndex, 2);

      controller.jumpToPage(0);
      expect(controller.pageIndex, 0);
      // A jump to the page already shown is a no-op.
      controller.jumpToPage(0);
      expect(controller.pageIndex, 0);
      await _settle();
      expect((await store.loadProgress(_bookId))?.pageIndex, 0);

      // The last page of a chapter rolls into the next chapter's first page.
      controller.jumpToPage(2);
      controller.nextPage();
      expect(controller.chapterIndex, 1);
      await _settle();
      expect(controller.contentState, ContentState.normal);
      expect(controller.pageCount, 3);
      expect(controller.chapterIndex, 1);
      expect(controller.pageIndex, 0);
      expect(controller.currentChapterTitle, '第二章 斗之气');
      expect(chapterRequests, 2);

      controller.prePage();
      expect(controller.chapterIndex, 0);
      expect(controller.pageIndex, 0);
      await _settle();
      expect(controller.currentChapterTitle, '第一章 陨落的天才');
      expect(controller.isCanGoPre(), isFalse);

      controller.dispose();
    });

    test('restores the saved chapter and page from a progress row', () async {
      final store = InMemoryFlutterNovelStore();
      await store.saveProgress(
        FlutterNovelProgress(
          bookId: _bookId,
          chapterIndex: 2,
          pageIndex: 1,
          chapterId: '5816b4b4a22c8e6b1cfd0d33',
          chapterTitle: '第三章 测试',
        ),
      );
      final controller = NovelReaderController(
        api: _stubApi(),
        store: store,
        cache: NovelChapterCache(store: store),
        bookId: _bookId,
      );

      await controller.loadCatalog();
      controller.setViewport(const Size(400, 800));
      await controller.bindCatalog(null);

      expect(controller.chapterIndex, 2);
      expect(controller.pageIndex, 1);
      expect(controller.currentChapterTitle, '第三章 测试');
      expect(controller.chapterCount, 3);
      expect(controller.contentState, ContentState.normal);

      controller.bindCatalog(
        null,
        progress: FlutterNovelProgress(
          bookId: _bookId,
          chapterIndex: 0,
          pageIndex: 2,
        ),
      );
      await _settle();
      expect(controller.chapterIndex, 0);
      expect(controller.pageIndex, 2);

      controller.dispose();
    });

    test('serves a repeated chapter from the store-backed cache', () async {
      final store = InMemoryFlutterNovelStore();
      var chapterRequests = 0;
      final api = _stubApi(
        onRequest: (uri) {
          if (uri.host == 'chapterup.zhuishushenqi.com') chapterRequests++;
        },
      );

      final first = NovelReaderController(
        api: api,
        store: store,
        cache: NovelChapterCache(store: store),
        bookId: _bookId,
      );
      await first.loadCatalog();
      first.setViewport(const Size(400, 800));
      await first.loadChapter(0);
      expect(chapterRequests, 1);

      final second = NovelReaderController(
        api: api,
        store: store,
        cache: NovelChapterCache(store: store),
        bookId: _bookId,
      );
      await second.loadCatalog();
      second.setViewport(const Size(400, 800));
      await second.loadChapter(0);
      expect(
        chapterRequests,
        1,
        reason: 'the second load must come from the chapter cache',
      );
      expect(second.pageCount, 3);
      expect(second.contentState, ContentState.normal);

      first.dispose();
      second.dispose();
    });

    test('reports an error when the book has no source', () async {
      final store = InMemoryFlutterNovelStore();
      final controller = NovelReaderController(
        api: ZssqApi(
          client: MockClient((request) async => _json('[]')),
        ),
        store: store,
        cache: NovelChapterCache(store: store),
        bookId: _bookId,
      );

      expect(await controller.loadCatalog(), isFalse);
      expect(controller.loading, isFalse);
      expect(controller.error, '没有可用的书源');
      expect(controller.chapterCount, 0);

      controller.dispose();
    });
  });
}
