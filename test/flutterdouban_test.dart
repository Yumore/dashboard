import 'dart:convert';
import 'dart:io';

import 'package:dashboard/features/movie/flutterdouban/flutterdouban_api.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_category.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_celebrity.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_comment_page.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_credits.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_endpoint.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_exception.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_image.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_images.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_mock_request.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_mock_source.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_network_source.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_review_page.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_search_result.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_settings_store.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_source_factory.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_source_kind.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_subject_detail.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_subject_list.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_us_box_result.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_weekly_result.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// No-network Dio helpers (same pattern as the host's `movieapp_test.dart`).
// ---------------------------------------------------------------------------

Response<dynamic> _ok(Object data, RequestOptions options) =>
    Response<dynamic>(requestOptions: options, statusCode: 200, data: data);

Response<dynamic> _status(int code, Object data, RequestOptions options) =>
    Response<dynamic>(requestOptions: options, statusCode: code, data: data);

Dio _fakeDio(Response<dynamic> Function(RequestOptions options) respond) {
  final dio = Dio(BaseOptions(baseUrl: FlutterDouBanEndpoint.baseUrl));
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) => handler.resolve(respond(options)),
    ),
  );
  return dio;
}

Dio _rejectingDio(DioException Function(RequestOptions options) build) {
  final dio = Dio(BaseOptions(baseUrl: FlutterDouBanEndpoint.baseUrl));
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) => handler.reject(build(options)),
    ),
  );
  return dio;
}

/// Reads a ported fixture straight off disk, so the mock path is exercised
/// against the real bytes without an asset bundle.
Future<String> _diskLoader(String assetPath) => File(assetPath).readAsString();

const String _fixtureRoot = 'lib/features/movie/flutterdouban/mock/';

// ---------------------------------------------------------------------------
// Hand-written fixtures shaped like real douban v2 payloads.
// ---------------------------------------------------------------------------

const String _subjectListJson = r'''
{
  "count": 2,
  "start": 0,
  "total": 42,
  "title": "正在上映的电影-北京",
  "subjects": [
    {
      "rating": {
        "max": 10, "average": 7.9, "stars": "40", "min": 0,
        "details": {"1": 1956.0, "2": 3862.0, "3": 18408.0, "4": 32828.0, "5": 25995.0}
      },
      "genres": ["科幻", "灾难"],
      "title": "流浪地球",
      "casts": [
        {
          "id": "1359081", "name": "屈楚萧", "name_en": "Chuxiao Qu",
          "alt": "https://movie.douban.com/celebrity/1359081/",
          "avatars": {
            "small": "https://img1.doubanio.com/view/celebrity/s_ratio_celebrity/public/p1515662726.32.webp",
            "medium": "https://img1.doubanio.com/view/celebrity/m/public/p1515662726.32.webp",
            "large": "https://img1.doubanio.com/view/celebrity/l/public/p1515662726.32.webp"
          }
        }
      ],
      "durations": ["125分钟"],
      "collect_count": 942919,
      "mainland_pubdate": "2019-02-05",
      "has_video": false,
      "original_title": "The Wandering Earth",
      "subtype": "movie",
      "directors": [
        {
          "id": "1276086", "name": "郭帆", "name_en": "Frant Gwo",
          "alt": "https://movie.douban.com/celebrity/1276086/", "avatars": {}
        }
      ],
      "pubdates": ["2019-02-05(中国大陆)"],
      "year": "2019",
      "images": {
        "small": "https://img3.doubanio.com/view/photo/s_ratio_poster/public/p2545472803.webp",
        "medium": "https://img3.doubanio.com/view/photo/m_ratio_poster/public/p2545472803.webp",
        "large": "https://img3.doubanio.com/view/photo/l_ratio_poster/public/p2545472803.webp"
      },
      "alt": "https://movie.douban.com/subject/26266893/",
      "id": "26266893"
    },
    {
      "id": "30432991",
      "title": "瑞雪兆丰年",
      "year": 2019,
      "subtype": "movie",
      "images": {"small": ""},
      "has_video": true
    }
  ]
}
''';

const String _detailJson = r'''
{
  "id": "26266893",
  "title": "流浪地球",
  "original_title": "The Wandering Earth",
  "year": "2019",
  "subtype": "movie",
  "alt": "https://movie.douban.com/subject/26266893/",
  "images": {
    "small": "https://img3.doubanio.com/view/photo/s_ratio_poster/public/p2545472803.webp",
    "medium": "https://img3.doubanio.com/view/photo/m_ratio_poster/public/p2545472803.webp",
    "large": "https://img3.doubanio.com/view/photo/l_ratio_poster/public/p2545472803.webp"
  },
  "rating": {"max": 10, "average": 7.9, "stars": "40", "min": 0,
    "details": {"1": 1956.0, "2": 3862.0, "3": 18408.0, "4": 32828.0, "5": 25995.0}},
  "genres": ["科幻", "灾难"],
  "casts": [{"id": "1359081", "name": "屈楚萧", "name_en": "Chuxiao Qu", "avatars": {}}],
  "directors": [{"id": "1276086", "name": "郭帆", "name_en": "Frant Gwo", "avatars": {}}],
  "writers": [{"id": "1276086", "name": "龚格尔", "name_en": "Gong Geer", "avatars": {}}],
  "collect_count": 942930,
  "pubdates": ["2019-02-05(中国大陆)"],
  "durations": ["125分钟"],
  "mainland_pubdate": "2019-02-05",
  "has_video": false,
  "summary": "近未来，科学家们发现太阳急速衰老膨胀，短时间内包括地球在内的整个太阳系都将被太阳所吞没。",
  "tags": ["科幻", "灾难", "中国大陆"],
  "countries": ["中国大陆"],
  "languages": ["汉语普通话"],
  "wish_count": 312456,
  "reviews_count": 15869,
  "photos_count": 1118,
  "pubdate": "2019-02-05",
  "has_ticket": true,
  "website": "",
  "douban_site": "",
  "mobile_url": "https://m.douban.com/movie/subject/26266893/mobile",
  "share_url": "https://m.douban.com/movie/subject/26266893",
  "schedule_url": "https://m.douban.com/movie/subject/26266893/cinema/",
  "seasons_count": null,
  "episodes_count": null,
  "trailers": [{
    "id": "242330", "subject_id": "26266893",
    "title": "预告片：终极版 (中文字幕)",
    "alt": "https://movie.douban.com/trailer/242330/",
    "small": "https://img3.doubanio.com/img/trailer/small/2546089641.jpg",
    "medium": "https://img3.doubanio.com/img/trailer/medium/2546089641.jpg",
    "resource_url": "http://vt1.doubanio.com/201902141333/x/view/movie/M/302420330.mp4"
  }],
  "bloopers": [],
  "videos": [{
    "id": "242331", "subject_id": "26266893", "title": "幕后花絮",
    "small": "https://img3.doubanio.com/img/trailer/small/2546089642.jpg",
    "medium": "https://img3.doubanio.com/img/trailer/medium/2546089642.jpg",
    "resource_url": "http://vt1.doubanio.com/201902141333/y/view/movie/M/302420331.mp4"
  }],
  "popular_comments": [{
    "rating": {"max": 5, "value": 1.0, "min": 0},
    "useful_count": 8818,
    "author": {"uid": "63469119", "avatar": "https://img1.doubanio.com/icon/u63469119-1.jpg",
      "signature": "", "alt": "https://www.douban.com/people/63469119/",
      "id": "63469119", "name": "迷眼看青山"},
    "subject_id": "26266893",
    "content": "希望，是这个时代像钻石一样珍贵的东西。",
    "created_at": "2019-02-05 10:24:19",
    "id": "1655736091"
  }]
}
''';

const String _celebrityJson = r'''
{
  "id": "1000525",
  "name": "吴京",
  "name_en": "Jing Wu",
  "gender": "男",
  "birthday": "1974-04-03",
  "born_place": "中国,北京",
  "constellation": "白羊座",
  "aka": [""],
  "aka_en": ["Jacky Wu"],
  "professions": ["", "", "导演", "制片人", "编剧"],
  "summary": "吴京，1974年4月3日出生于北京，中国内地男演员、导演。",
  "website": "",
  "mobile_url": "https://movie.douban.com/celebrity/1000525/mobile",
  "alt": "https://movie.douban.com/celebrity/1000525/",
  "avatars": {
    "small": "https://img1.doubanio.com/view/celebrity/s_ratio_celebrity/public/p1501738155.24.webp",
    "medium": "https://img1.doubanio.com/view/celebrity/m/public/p1501738155.24.webp",
    "large": "https://img1.doubanio.com/view/celebrity/l/public/p1501738155.24.webp"
  },
  "photos": [{
    "thumb": "https://img3.doubanio.com/view/photo/thumb/public/p2159793864.webp",
    "image": "https://img3.doubanio.com/view/photo/l/public/p2159793864.webp",
    "cover": "https://img3.doubanio.com/view/photo/cover/public/p2159793864.webp",
    "alt": "https://movie.douban.com/celebrity/1000525/photo/2159793864/",
    "id": "2159793864",
    "icon": "https://img3.doubanio.com/view/photo/icon/public/p2159793864.webp"
  }],
  "works": [{
    "roles": ["演员"],
    "subject": {
      "id": "26654167", "title": "局面", "year": "2017", "subtype": "movie",
      "images": {"small": "https://img9.doubanio.com/view/photo/s_ratio_poster/public/p2515216033.webp"},
      "rating": {"max": 10, "average": 6.4, "stars": "35", "min": 0}
    }
  }]
}
''';

const String _worksJson = r'''
{
  "count": 20,
  "start": 0,
  "total": 56,
  "celebrity": {
    "avatars": {"small": "https://img1.doubanio.com/view/celebrity/s_ratio_celebrity/public/p1501738155.24.webp"},
    "name_en": "Jing Wu", "name": "吴京",
    "alt": "https://movie.douban.com/celebrity/1000525/", "id": "1000525"
  },
  "works": [
    {
      "roles": ["演员"],
      "subject": {
        "id": "27125418", "title": "杀破狼3", "year": "2018", "subtype": "movie",
        "images": {"small": "https://img3.doubanio.com/view/photo/s_ratio_poster/public/p2522753082.webp"},
        "rating": {"max": 10, "average": 5.0, "stars": "25", "min": 0},
        "casts": [{"name": "吴京", "avatars": null, "id": null, "alt": null}]
      }
    },
    {
      "roles": ["导演"],
      "subject": {
        "id": "26266893", "title": "流浪地球", "year": "2019", "subtype": "movie",
        "images": {}, "rating": {"max": 10, "average": 7.9, "stars": "40", "min": 0}
      }
    }
  ]
}
''';

const String _reviewPageJson = r'''
{
  "count": 1,
  "start": 0,
  "total": 20208,
  "next_start": 20,
  "subject": {"id": "26266893", "title": "流浪地球", "year": "2019"},
  "reviews": [
    {
      "rating": {"max": 5, "value": 1.0, "min": 0},
      "useful_count": 42735,
      "author": {"uid": "2129082", "id": "2129082", "name": "左丘失明",
        "signature": "红猪是我的自传体电影",
        "avatar": "https://img1.doubanio.com/icon/u2129082-9.jpg",
        "alt": "https://www.douban.com/people/2129082/"},
      "created_at": "2019-02-06 23:46:08",
      "title": "流浪地球，不及格。",
      "updated_at": "2019-02-26 11:49:40",
      "share_url": "https://m.douban.com/movie/review/9936402",
      "summary": "给《流浪地球》挑毛病是一件很累的事情。",
      "content": "给《流浪地球》挑毛病是一件很累的事情。\n以下是正文。",
      "useless_count": 3117,
      "comments_count": 1566,
      "alt": "https://movie.douban.com/review/9936402/",
      "id": "9936402",
      "subject_id": "26266893"
    },
    {
      "id": "9936403",
      "title": "没有摘要的影评",
      "content": "第一行正文\n第二行正文",
      "useful_count": 120,
      "rating": {"max": 5, "value": 4.0, "min": 0},
      "author": {"id": "1", "name": "无名氏"}
    }
  ]
}
''';

const String _commentPageJson = r'''
{
  "count": 1,
  "start": 0,
  "total": 394410,
  "next_start": 20,
  "subject": {"id": "26266893", "title": "流浪地球", "year": "2019"},
  "comments": [{
    "rating": {"max": 5, "value": 1.0, "min": 0},
    "useful_count": 57058,
    "author": {"uid": "duduxiongzhifu", "id": "2201715", "name": "嘟嘟熊之父",
      "signature": "爱看电影", "avatar": "https://img1.doubanio.com/icon/u2201715-7.jpg",
      "alt": "https://www.douban.com/people/2201715/"},
    "subject_id": "26266893",
    "content": "流浪地球的设定是好的，可惜执行太差。",
    "created_at": "2019-01-28 22:06:27",
    "id": "1646653503"
  }]
}
''';

const String _weeklyJson = r'''
{
  "title": "豆瓣电影本周口碑榜",
  "subjects": [
    {"rank": 1, "delta": 10, "subject": {"id": "27119586", "title": "谁先爱上他的", "year": "2018"}},
    {"rank": 2, "delta": -3, "subject": {"id": "1292052", "title": "肖申克的救赎", "year": "1994"}},
    {"rank": 3, "delta": 0, "subject": {"id": "1", "title": "持平", "year": "2000"}}
  ]
}
''';

const String _usBoxJson = r'''
{
  "date": "10月17日",
  "subjects": [{
    "box": 12345678,
    "rank": 1,
    "subject": {"id": "30170448", "title": "小丑", "year": "2019",
      "rating": {"max": 10, "average": 8.8, "stars": "45", "min": 0}}
  }]
}
''';

void main() {
  group('subject mapping (real douban JSON)', () {
    final list = FlutterDouBanSubjectList.fromJson(
      jsonDecode(_subjectListJson) as Map<String, dynamic>,
    );

    test('list envelope maps title/start/count/total', () {
      expect(list.title, '正在上映的电影-北京');
      expect(list.start, 0);
      expect(list.count, 2);
      expect(list.total, 42);
      expect(list.subjects.length, 2);
      expect(list.isEmpty, isFalse);
      expect(list.hasMore, isTrue, reason: '0 + 2 < 42');
    });

    test('subject summary keeps the real douban field names', () {
      final subject = list.subjects[0];
      expect(subject.id, '26266893');
      expect(subject.title, '流浪地球');
      expect(subject.originalTitle, 'The Wandering Earth');
      expect(subject.year, '2019');
      expect(subject.subtype, 'movie');
      expect(subject.alt, 'https://movie.douban.com/subject/26266893/');
      expect(subject.collectCount, 942919);
      expect(subject.mainlandPubdate, '2019-02-05');
      expect(subject.hasVideo, isFalse);
      expect(subject.genres, <String>['科幻', '灾难']);
      expect(subject.pubdates, <String>['2019-02-05(中国大陆)']);
      expect(subject.durations, <String>['125分钟']);
    });

    test('rating average/stars/details map from rating.average etc.', () {
      final rating = list.subjects[0].rating;
      expect(rating.average, 7.9);
      expect(rating.stars, '40');
      expect(rating.max, 10);
      expect(rating.min, 0);
      expect(rating.details[1], 1956.0);
      expect(rating.details[3], 18408.0);
      expect(rating.details[5], 25995.0);
      expect(rating.ratingCount, 83049);
      expect(rating.isRated(5), isTrue);
      expect(rating.isEmpty, isFalse);
    });

    test('casts/directors are douban celebrity summaries', () {
      final subject = list.subjects[0];
      expect(subject.casts.length, 1);
      expect(subject.casts.first.id, '1359081');
      expect(subject.casts.first.name, '屈楚萧');
      expect(subject.casts.first.nameEn, 'Chuxiao Qu');
      expect(subject.directors.length, 1);
      expect(subject.directors.first.name, '郭帆');
      expect(subject.directorsText, '郭帆');
    });

    test('display helpers match the source search/home rows', () {
      final subject = list.subjects[0];
      expect(subject.displayTitle, '流浪地球 (2019)');
      expect(subject.typeLabel, '电影');
      expect(subject.isMovie, isTrue);
      expect(subject.genresText, '科幻 / 灾难');
      expect(subject.ratingText, '豆瓣 7.9 分');
      expect(
        subject.posterUrl,
        'https://img3.doubanio.com/view/photo/l_ratio_poster/public/p2545472803.webp',
      );
    });

    test('a terse subject (missing lists, numeric year) must not crash', () {
      final subject = list.subjects[1];
      expect(subject.id, '30432991');
      expect(subject.year, '2019', reason: 'JSON number coerced to string');
      expect(subject.genres, isEmpty);
      expect(subject.casts, isEmpty);
      expect(subject.directors, isEmpty);
      expect(subject.pubdates, isEmpty);
      expect(subject.durations, isEmpty);
      expect(subject.pubdates, isEmpty);
      expect(subject.collectCount, 0);
      expect(subject.rating.isEmpty, isTrue);
      expect(subject.ratingText, '');
      expect(subject.posterUrl, isNull, reason: 'images.small was ""');
      expect(subject.hasVideo, isTrue);
      expect(subject.isMovie, isTrue, reason: 'subtype movie');
    });
  });

  group('subject detail mapping', () {
    final detail = FlutterDouBanSubjectDetail.fromJson(
      jsonDecode(_detailJson) as Map<String, dynamic>,
    );

    test('detail envelope joins subject + detail-only fields', () {
      expect(detail.id, '26266893');
      expect(detail.title, '流浪地球');
      expect(detail.displayTitle, '流浪地球 (2019)');
      expect(detail.rating.average, 7.9);
      expect(detail.castMembers.length, 1);
      expect(detail.directors.length, 1);
      expect(detail.collectCount, 942930);
      expect(detail.hasVideo, isFalse);
    });

    test('summary/tags/countries/languages/pubdate map', () {
      expect(detail.hasSummary, isTrue);
      expect(detail.summary, contains('太阳急速衰老膨胀'));
      expect(detail.tags.first, '科幻');
      expect(detail.countries, <String>['中国大陆']);
      expect(detail.languages.first, '汉语普通话');
      expect(detail.pubdate, '2019-02-05');
      expect(detail.pubdatesText, '2019-02-05(中国大陆)');
      expect(detail.durationsText, '125分钟');
      expect(detail.wishCount, 312456);
      expect(detail.reviewsCount, 15869);
      expect(detail.photosCount, 1118);
      expect(detail.mobileUrl, 'https://m.douban.com/movie/subject/26266893/mobile');
      expect(detail.shareUrl, 'https://m.douban.com/movie/subject/26266893');
      expect(detail.hasTicket, isTrue);
      expect(detail.seasonsCount, isNull);
      expect(detail.episodesCount, isNull);
      expect(detail.writers.first.name, '龚格尔');
    });

    test('casts take only the names; trailers/videos feed allClips', () {
      expect(detail.casts, <String>['屈楚萧']);
      expect(detail.trailers.length, 1);
      expect(detail.trailers.first.id, '242330');
      expect(detail.trailers.first.title, '预告片：终极版 (中文字幕)');
      expect(
        detail.trailers.first.resourceUrl,
        'http://vt1.doubanio.com/201902141333/x/view/movie/M/302420330.mp4',
      );
      expect(detail.bloopers, isEmpty);
      expect(detail.videos.length, 1);
      expect(detail.allClips.length, 2, reason: 'trailers then bloopers then videos');
      expect(detail.popularComments.length, 1);
      expect(detail.popularComments.first.content, contains('像钻石一样珍贵'));
      expect(detail.popularComments.first.usefulCount, 8818);
      expect(detail.popularComments.first.author.name, '迷眼看青山');
      expect(detail.popularComments.first.rating.value, 1.0);
      expect(detail.popularComments.first.createdAt, '2019-02-05 10:24:19');
    });

    test('credits are read from the subject payload (no v2 credits endpoint)', () {
      final credits = FlutterDouBanCredits.fromJson(
        jsonDecode(_detailJson) as Map<String, dynamic>,
      );
      expect(credits.isEmpty, isFalse);
      expect(credits.casts.first.name, '屈楚萧');
      expect(credits.directors.first.name, '郭帆');
      expect(credits.all.length, 2);
    });
  });

  group('celebrity mapping', () {
    final celebrity = FlutterDouBanCelebrity.fromJson(
      jsonDecode(_celebrityJson) as Map<String, dynamic>,
    );

    test('profile fields map with real douban key names', () {
      expect(celebrity.id, '1000525');
      expect(celebrity.name, '吴京');
      expect(celebrity.nameEn, 'Jing Wu');
      expect(celebrity.gender, '男');
      expect(celebrity.birthday, '1974-04-03');
      expect(celebrity.bornPlace, '中国,北京');
      expect(celebrity.constellation, '白羊座');
      expect(celebrity.hasSummary, isTrue);
      expect(
        celebrity.profileLine,
        '男 · 1974-04-03 · 中国,北京 · 白羊座',
      );
      expect(
        celebrity.avatarUrl,
        'https://img1.doubanio.com/view/celebrity/l/public/p1501738155.24.webp',
      );
    });

    test('blank professions/aka entries are filtered, not shown', () {
      expect(celebrity.professions, <String>['', '', '导演', '制片人', '编剧']);
      expect(celebrity.realProfessions, <String>['导演', '制片人', '编剧']);
      expect(celebrity.professionsText, '导演 / 制片人 / 编剧');
      expect(celebrity.akaAll, <String>['Jacky Wu']);
    });

    test('photos and works map', () {
      expect(celebrity.photos.length, 1);
      expect(
        celebrity.photos.first.url,
        'https://img3.doubanio.com/view/photo/l/public/p2159793864.webp',
      );
      expect(celebrity.works.length, 1);
      expect(celebrity.works.first.rolesText, '演员');
      expect(celebrity.works.first.subject?.title, '局面');
      expect(celebrity.works.first.subject?.rating.average, 6.4);
    });
  });

  group('review and comment mapping', () {
    final reviewPage = FlutterDouBanReviewPage.fromJson(
      jsonDecode(_reviewPageJson) as Map<String, dynamic>,
    );

    test('review page envelope + next_start paging', () {
      expect(reviewPage.total, 20208);
      expect(reviewPage.nextStart, 20);
      expect(reviewPage.reviews.length, 2);
      expect(reviewPage.isEmpty, isFalse);
      expect(reviewPage.hasMore, isTrue, reason: 'next_start 20 > start 0');
      expect(reviewPage.subject?.title, '流浪地球');
    });

    test('review fields use subject_id/useful_count/created_at etc.', () {
      final review = reviewPage.reviews.first;
      expect(review.id, '9936402');
      expect(review.subjectId, '26266893');
      expect(review.title, '流浪地球，不及格。');
      expect(review.usefulCount, 42735);
      expect(review.uselessCount, 3117);
      expect(review.commentsCount, 1566);
      expect(review.usefulText, '42.7k');
      expect(review.rating.value, 1.0);
      expect(review.rating.max, 5);
      expect(review.author.id, '2129082');
      expect(review.author.name, '左丘失明');
      expect(review.author.signature, '红猪是我的自传体电影');
      expect(review.author.avatarUrl, isNotNull);
      expect(review.createdAt, '2019-02-06 23:46:08');
      expect(review.updatedAt, '2019-02-26 11:49:40');
      expect(review.shareUrl, 'https://m.douban.com/movie/review/9936402');
      expect(review.alt, 'https://movie.douban.com/review/9936402/');
      expect(review.displaySummary, contains('挑毛病'));
    });

    test('displaySummary falls back to the first content line', () {
      final review = reviewPage.reviews[1];
      expect(review.summary, isEmpty);
      expect(review.displaySummary, '第一行正文');
      expect(review.usefulText, '120', reason: 'under 1000 stays exact');
    });

    test('comment page fields + usefulText formatting', () {
      final page = FlutterDouBanCommentPage.fromJson(
        jsonDecode(_commentPageJson) as Map<String, dynamic>,
      );
      expect(page.total, 394410);
      expect(page.nextStart, 20);
      expect(page.hasMore, isTrue);
      expect(page.comments.length, 1);
      final comment = page.comments.first;
      expect(comment.id, '1646653503');
      expect(comment.subjectId, '26266893');
      expect(comment.content, '流浪地球的设定是好的，可惜执行太差。');
      expect(comment.usefulCount, 57058);
      expect(comment.usefulText, '57.1k');
      expect(comment.author.uid, 'duduxiongzhifu');
      expect(comment.author.name, '嘟嘟熊之父');
      expect(comment.createdAt, '2019-01-28 22:06:27');
      expect(comment.rating.value, 1.0);
    });
  });

  group('weekly / us_box / search mapping', () {
    test('weekly entries carry rank and delta, rendered as arrows', () {
      final weekly = FlutterDouBanWeeklyResult.fromJson(
        jsonDecode(_weeklyJson) as Map<String, dynamic>,
      );
      expect(weekly.title, '豆瓣电影本周口碑榜');
      expect(weekly.subjects.length, 3);
      expect(weekly.subjects[0].rank, 1);
      expect(weekly.subjects[0].delta, 10);
      expect(weekly.subjects[0].deltaText, '↑10');
      expect(weekly.subjects[0].subject.title, '谁先爱上他的');
      expect(weekly.subjects[1].deltaText, '↓3');
      expect(weekly.subjects[2].deltaText, '—');
    });

    test('us_box entries map rank + box gross', () {
      final usBox = FlutterDouBanUsBoxResult.fromJson(
        jsonDecode(_usBoxJson) as Map<String, dynamic>,
      );
      expect(usBox.date, '10月17日');
      expect(usBox.subjects.length, 1);
      expect(usBox.subjects.first.rank, 1);
      expect(usBox.subjects.first.box, 12345678);
      expect(usBox.subjects.first.boxText, r'$12,345,678');
      expect(usBox.subjects.first.subject.title, '小丑');
      expect(usBox.subjects.first.subject.rating.average, 8.8);
    });

    test('search result sorts newest-first like the source page', () {
      final result = FlutterDouBanSearchResult.fromJson(<String, dynamic>{
        'query': '流浪地球',
        'start': 0,
        'count': 2,
        'total': 40,
        'subjects': [
          (jsonDecode(_subjectListJson) as Map<String, dynamic>)['subjects'][0],
          {'id': '9', 'title': '旧片', 'year': '1994'},
        ],
      });
      expect(result.query, '流浪地球');
      expect(result.total, 40);
      expect(result.hasMore, isTrue);
      expect(result.sortedByYear.first.title, '流浪地球');
      expect(result.sortedByYear.last.title, '旧片');
    });
  });

  group('api request building', () {
    test('paged category list builds start/count/apikey on the real path', () async {
      RequestOptions? seen;
      final api = FlutterDouBanApi(
        dio: _fakeDio((options) {
          seen = options;
          return _ok(jsonDecode(_subjectListJson), options);
        }),
      );
      addTearDown(api.dispose);

      final result = await api.inTheaters(start: 40, count: 20);

      expect(seen!.baseUrl, 'https://api.douban.com');
      expect(seen!.path, '/v2/movie/in_theaters');
      expect(seen!.method, 'GET');
      expect(seen!.queryParameters['apikey'], '0b2bdeda43b5688921839c8ecb20399b');
      expect(seen!.queryParameters['start'], 40);
      expect(seen!.queryParameters['count'], 20);
      expect(result.title, '正在上映的电影-北京');
      expect(result.total, 42);
      expect(result.subjects.first.title, '流浪地球');
    });

    test('every category endpoint keeps its real douban path', () async {
      final paths = <String, Future<void> Function(FlutterDouBanApi)>{
        '/v2/movie/coming_soon': (api) => api.comingSoon(count: 5),
        '/v2/movie/top250': (api) => api.top250(start: 20, count: 10),
        '/v2/movie/weekly': (api) async => api.weekly(),
        '/v2/movie/us_box': (api) async => api.usBox(),
      };
      for (final entry in paths.entries) {
        RequestOptions? seen;
        final api = FlutterDouBanApi(
          dio: _fakeDio((options) {
            seen = options;
            return _ok(<String, dynamic>{}, options);
          }),
        );
        await entry.value(api);
        expect(seen!.path, entry.key);
        api.dispose();
      }
    });

    test('weekly takes no paging parameters (source sent none)', () async {
      RequestOptions? seen;
      final api = FlutterDouBanApi(
        dio: _fakeDio((options) {
          seen = options;
          return _ok(jsonDecode(_weeklyJson), options);
        }),
      );
      addTearDown(api.dispose);

      final weekly = await api.weekly();
      expect(seen!.path, '/v2/movie/weekly');
      expect(seen!.queryParameters.containsKey('start'), isFalse);
      expect(seen!.queryParameters.containsKey('count'), isFalse);
      expect(seen!.queryParameters['apikey'], FlutterDouBanEndpoint.apiKey);
      expect(weekly.title, '豆瓣电影本周口碑榜');
    });

    test('search sends q + paging and trims the keyword', () async {
      RequestOptions? seen;
      final api = FlutterDouBanApi(
        dio: _fakeDio((options) {
          seen = options;
          return _ok(jsonDecode(_subjectListJson), options);
        }),
      );
      addTearDown(api.dispose);

      await api.search('  流浪地球  ', start: 20, count: 20);

      expect(seen!.path, '/v2/movie/search');
      expect(seen!.queryParameters['q'], '流浪地球');
      expect(seen!.queryParameters['start'], 20);
      expect(seen!.queryParameters['count'], 20);
      expect(seen!.queryParameters['apikey'], FlutterDouBanEndpoint.apiKey);
    });

    test('blank search never issues a request', () {
      var called = false;
      final api = FlutterDouBanApi(
        dio: _fakeDio((options) {
          called = true;
          return _ok(<String, dynamic>{}, options);
        }),
      );
      addTearDown(api.dispose);
      expect(() => api.search('   '), throwsArgumentError);
      expect(called, isFalse);
    });

    test('subject/comments/reviews/celebrity/works build the real paths', () async {
      final calls = <String, Future<void> Function(FlutterDouBanApi)>{
        'subject': (api) async => api.subject('1292052'),
        'creditsOf': (api) async => api.creditsOf('1292052'),
        'subjectComments': (api) async => api.subjectComments('1292052', start: 20),
        'subjectReviews': (api) async => api.subjectReviews('1292052', start: 20),
        'celebrity': (api) async => api.celebrity('1000525'),
        'celebrityWorks': (api) async => api.celebrityWorks('1000525', start: 20),
      };
      final expected = <String, String>{
        'subject': '/v2/movie/subject/1292052',
        'creditsOf': '/v2/movie/subject/1292052',
        'subjectComments': '/v2/movie/subject/1292052/comments',
        'subjectReviews': '/v2/movie/subject/1292052/reviews',
        'celebrity': '/v2/movie/celebrity/1000525',
        'celebrityWorks': '/v2/movie/celebrity/1000525/works',
      };
      for (final entry in calls.entries) {
        RequestOptions? seen;
        final api = FlutterDouBanApi(
          dio: _fakeDio((options) {
            seen = options;
            return _ok(<String, dynamic>{}, options);
          }),
        );
        await entry.value(api);
        expect(seen!.path, expected[entry.key], reason: entry.key);
        expect(seen!.queryParameters['apikey'], FlutterDouBanEndpoint.apiKey);
        api.dispose();
      }
    });

    test('works paging carries start/count; detail does not', () async {
      RequestOptions? workOptions;
      final workApi = FlutterDouBanApi(
        dio: _fakeDio((options) {
          workOptions = options;
          return _ok(jsonDecode(_worksJson), options);
        }),
      );
      addTearDown(workApi.dispose);
      final works = await workApi.celebrityWorks('1000525', start: 20, count: 20);
      expect(workOptions!.queryParameters['start'], 20);
      expect(workOptions!.queryParameters['count'], 20);
      expect(works.total, 56);

      RequestOptions? detailOptions;
      final detailApi = FlutterDouBanApi(
        dio: _fakeDio((options) {
          detailOptions = options;
          return _ok(jsonDecode(_detailJson), options);
        }),
      );
      addTearDown(detailApi.dispose);
      await detailApi.subject('26266893');
      expect(detailOptions!.path, '/v2/movie/subject/26266893');
      expect(detailOptions!.queryParameters.containsKey('start'), isFalse);
      expect(detailOptions!.queryParameters.containsKey('count'), isFalse);
    });

    test('the source key/URL constants are preserved verbatim', () {
      expect(FlutterDouBanEndpoint.baseUrl, 'https://api.douban.com');
      expect(FlutterDouBanEndpoint.apiKey, '0b2bdeda43b5688921839c8ecb20399b');
      expect(
        FlutterDouBanEndpoint.legacyReviews,
        '/v2/movie/subject/26266893/reviews',
      );
      expect(FlutterDouBanApi.defaultCount, 20);
      expect(
        FlutterDouBanEndpoint.celebrityWorks('1000525'),
        '/v2/movie/celebrity/1000525/works',
      );
    });
  });

  group('api errors and empty payloads', () {
    test('badResponse surfaces status code and Chinese message', () async {
      final api = FlutterDouBanApi(
        dio: _rejectingDio(
          (options) => DioException(
            requestOptions: options,
            type: DioExceptionType.badResponse,
            response: _status(404, <String, dynamic>{}, options),
          ),
        ),
      );
      addTearDown(api.dispose);

      await expectLater(
        api.inTheaters(),
        throwsA(
          isA<FlutterDouBanException>()
              .having((error) => error.message, 'message', '请求失败：HTTP 404')
              .having((error) => error.statusCode, 'statusCode', 404)
              .having((error) => error.toString(), 'toString', '请求失败：HTTP 404'),
        ),
      );
    });

    test('connection errors map to the retry message', () async {
      final api = FlutterDouBanApi(
        dio: _rejectingDio(
          (options) => DioException(
            requestOptions: options,
            type: DioExceptionType.connectionError,
          ),
        ),
      );
      addTearDown(api.dispose);

      await expectLater(
        api.top250(),
        throwsA(
          isA<FlutterDouBanException>().having(
            (error) => error.message,
            'message',
            '网络连接失败，请检查网络后重试',
          ),
        ),
      );
    });

    test('a non-2xx response body that is not thrown still fails', () async {
      final api = FlutterDouBanApi(
        dio: _fakeDio((options) => _status(500, 'boom', options)),
      );
      addTearDown(api.dispose);

      await expectLater(
        api.comingSoon(),
        throwsA(
          isA<FlutterDouBanException>()
              .having((error) => error.message, 'message', '请求失败：HTTP 500')
              .having((error) => error.statusCode, 'statusCode', 500),
        ),
      );
    });

    test('a non-map payload is rejected instead of half-parsed', () async {
      final api = FlutterDouBanApi(
        dio: _fakeDio((options) => _ok(<dynamic>[1, 2, 3], options)),
      );
      addTearDown(api.dispose);

      await expectLater(
        api.subject('26266893'),
        throwsA(
          isA<FlutterDouBanException>().having(
            (error) => error.message,
            'message',
            '豆瓣返回的数据格式无法解析',
          ),
        ),
      );
    });

    test('empty payloads report empty without throwing', () {
      final list = FlutterDouBanSubjectList.fromJson(<String, dynamic>{
        'count': 0,
        'start': 0,
        'total': 0,
        'subjects': <dynamic>[],
      });
      expect(list.isEmpty, isTrue);
      expect(list.hasMore, isFalse);

      final search = FlutterDouBanSearchResult.fromJson(<String, dynamic>{
        'total': 0,
        'subjects': <dynamic>[],
      });
      expect(search.isEmpty, isTrue);
      expect(search.hasMore, isFalse);

      final reviews = FlutterDouBanReviewPage.fromJson(<String, dynamic>{
        'total': 0,
        'reviews': <dynamic>[],
      });
      expect(reviews.isEmpty, isTrue);
      expect(reviews.hasMore, isFalse);
      expect(reviews.nextStart, isNull);

      final comments = FlutterDouBanCommentPage.fromJson(<String, dynamic>{
        'total': 0,
        'comments': <dynamic>[],
      });
      expect(comments.isEmpty, isTrue);
      expect(comments.hasMore, isFalse);

      final details = FlutterDouBanSubjectDetail.fromJson(<String, dynamic>{});
      expect(details.hasSummary, isFalse);
      expect(details.summary, '');
      expect(details.genres, isEmpty);
      expect(details.rating.average, 0);
      expect(details.allClips, isEmpty);
    });
  });

  group('image URL building + placeholder handling', () {
    test('resolve keeps absolute http(s) douban URLs', () {
      const url =
          'https://img3.doubanio.com/view/photo/l_ratio_poster/public/p2545472803.webp';
      expect(FlutterDouBanImage.resolve(url), url);
      expect(FlutterDouBanImage.resolve('  $url  '), url);
      expect(FlutterDouBanImage.resolve('http://img1.doubanio.com/a.jpg'), isNotNull);
    });

    test('resolve rejects blanks, relative paths and non-http schemes', () {
      expect(FlutterDouBanImage.resolve(null), isNull);
      expect(FlutterDouBanImage.resolve(''), isNull);
      expect(FlutterDouBanImage.resolve('   '), isNull);
      expect(FlutterDouBanImage.resolve('/view/photo/s_ratio_poster/x.webp'), isNull);
      expect(FlutterDouBanImage.resolve('ftp://img1.doubanio.com/a.jpg'), isNull);
      expect(FlutterDouBanImage.resolve('data:image/png;base64,AAAA'), isNull);
    });

    test('the source placeholder asset path is not treated as an image', () {
      expect(
        FlutterDouBanImage.placeholderAssetPath,
        'assets/images/ic_default_img_subject_movie.9.png',
      );
      expect(
        FlutterDouBanImage.resolve(FlutterDouBanImage.placeholderAssetPath),
        isNull,
      );
      expect(
        FlutterDouBanImage.needsPlaceholder(FlutterDouBanImage.placeholderAssetPath),
        isTrue,
      );
      expect(FlutterDouBanImage.needsPlaceholder(''), isTrue);
      expect(
        FlutterDouBanImage.needsPlaceholder('https://img1.doubanio.com/a.jpg'),
        isFalse,
      );
    });

    test('images prefer large, then medium, then small', () {
      final full = FlutterDouBanImages.fromJson(<String, dynamic>{
        'small': 'https://img1.doubanio.com/s.webp',
        'medium': 'https://img1.doubanio.com/m.webp',
        'large': 'https://img1.doubanio.com/l.webp',
      });
      expect(full.preferred, 'https://img1.doubanio.com/l.webp');
      expect(full.preferredUrl, 'https://img1.doubanio.com/l.webp');
      expect(full.isEmpty, isFalse);

      final partial = FlutterDouBanImages.fromJson(<String, dynamic>{
        'small': 'https://img1.doubanio.com/s.webp',
        'large': '',
      });
      expect(partial.preferred, 'https://img1.doubanio.com/s.webp');

      final none = FlutterDouBanImages.fromJson(<String, dynamic>{
        'small': '',
        'medium': '',
        'large': '',
      });
      expect(none.isEmpty, isTrue);
      expect(none.preferred, '');
      expect(none.preferredUrl, isNull);
    });

    test('subject.posterUrl and cast avatarUrl go through the resolver', () {
      final list = FlutterDouBanSubjectList.fromJson(
        jsonDecode(_subjectListJson) as Map<String, dynamic>,
      );
      final subject = list.subjects[0];
      expect(subject.posterUrl, contains('/l_ratio_poster/'));
      expect(subject.casts.first.avatarUrl, contains('/l/public/'));
      expect(subject.directors.first.avatarUrl, isNull, reason: 'avatars was {}');
    });
  });

  group('mock fixture path (real files on disk)', () {
    final source = FlutterDouBanMockSource(loader: _diskLoader);

    test('all nine ported fixtures exist; us_box was never ported', () {
      const names = <String>[
        'in_theaters',
        'coming_soon',
        'top250',
        'weekly',
        'subject_26266893',
        'comments',
        'reviews',
        'celebrity',
        'works',
      ];
      for (final name in names) {
        final file = File('$_fixtureRoot$name.json');
        expect(file.existsSync(), isTrue, reason: '$name.json must be ported');
        expect(file.lengthSync(), greaterThan(500));
      }
      expect(File('${_fixtureRoot}us_box.json').existsSync(), isFalse);
    });

    test('the source action→fixture map is preserved verbatim', () {
      expect(
        FlutterDouBanMockRequest.map[FlutterDouBanEndpoint.inTheaters],
        'in_theaters',
      );
      expect(
        FlutterDouBanMockRequest.map[FlutterDouBanEndpoint.comingSoon],
        'coming_soon',
      );
      expect(FlutterDouBanMockRequest.map[FlutterDouBanEndpoint.top250], 'top250');
      expect(FlutterDouBanMockRequest.map[FlutterDouBanEndpoint.weekly], 'weekly');
      expect(
        FlutterDouBanMockRequest.map[FlutterDouBanEndpoint.legacyReviews],
        'reviews',
      );
      expect(FlutterDouBanMockRequest.jsonName('/v2/movie/top250'), 'top250');
      expect(
        FlutterDouBanMockRequest.jsonName('/v2/movie/unknown'),
        '/v2/movie/unknown',
      );
      expect(
        FlutterDouBanMockRequest.assetPathFor('top250'),
        'lib/features/movie/flutterdouban/mock/top250.json',
      );
    });

    test('in_theaters fixture parses with its real totals and provenance', () async {
      final data = await source.inTheaters();
      expect(data.kind, FlutterDouBanSourceKind.mock);
      expect(data.mocked, isTrue);
      expect(data.origin, 'mock/in_theaters.json');
      expect(
        data.assetPath,
        'lib/features/movie/flutterdouban/mock/in_theaters.json',
      );
      expect(data.label, '本地 Mock · mock/in_theaters.json');
      expect(data.value.title, '正在上映的电影-北京');
      expect(data.value.total, 22);
      expect(data.value.subjects.length, 20);
      expect(data.value.subjects.first.id, '26266893');
      expect(data.value.subjects.first.title, '流浪地球');
      expect(data.value.subjects.first.rating.average, 7.9);
      expect(data.value.subjects.first.rating.details[5], 25995.0);
      expect(data.value.hasMore, isTrue);
    });

    test('mock paging slices the fixture (deviation: source ignored start/count)', () async {
      final first = await source.inTheaters(start: 0, count: 5);
      expect(first.value.subjects.length, 5);
      expect(first.value.start, 0);
      expect(first.value.count, 5);
      expect(first.value.total, 22);
      expect(first.value.hasMore, isTrue);

      final last = await source.inTheaters(start: 18, count: 20);
      expect(last.value.subjects.length, 2);
      expect(last.value.subjects.first.title, '死侍2：我爱我家');
      expect(last.value.subjects.last.title, '相亲时代');
      expect(
        last.value.hasMore,
        isTrue,
        reason: 'the fixture holds 20 rows but reports total 22',
      );

      final exhausted = await source.inTheaters(start: 20, count: 20);
      expect(exhausted.value.subjects, isEmpty);
      expect(exhausted.value.hasMore, isFalse);

      final past = await source.inTheaters(start: 999, count: 20);
      expect(past.value.subjects, isEmpty);
    });

    test('top250 fixture has no rating.details and must stay empty', () async {
      final data = await source.top250();
      expect(data.value.title, '豆瓣电影Top250');
      expect(data.value.total, 250);
      expect(data.value.subjects.first.id, '1292052');
      expect(data.value.subjects.first.title, '肖申克的救赎');
      expect(data.value.subjects.first.year, '1994');
      expect(data.value.subjects.first.rating.average, 9.6);
      expect(data.value.subjects.first.rating.details, isEmpty);
      expect(data.value.subjects.first.rating.ratingCount, 0);
    });

    test('weekly fixture keeps rank/delta and the mock origin', () async {
      final data = await source.weekly();
      expect(data.value.title, '豆瓣电影本周口碑榜');
      expect(data.value.subjects.length, 10);
      expect(data.value.subjects.first.rank, 1);
      expect(data.value.subjects.first.delta, 10);
      expect(data.value.subjects.first.deltaText, '↑10');
      expect(data.value.subjects.first.subject.title, '谁先爱上他的');
      expect(data.origin, 'mock/weekly.json');
    });

    test('subject/comments/reviews keep the source hard-coded fixtures', () async {
      final detail = await source.subject('any-id-at-all');
      expect(detail.origin, 'mock/subject_26266893.json');
      expect(detail.value.id, '26266893', reason: 'source ignored the requested id');
      expect(detail.value.title, '流浪地球');
      expect(detail.value.hasSummary, isTrue);
      expect(detail.value.summary.length, 351);
      expect(detail.value.castMembers.length, 4);
      expect(detail.value.directors.length, 1);
      expect(detail.value.wishCount, 312456);
      expect(detail.value.reviewsCount, 15869);
      expect(detail.value.tags.length, 10);
      expect(detail.value.trailers.length, 4);
      expect(detail.value.popularComments.length, 4);

      final credits = await source.credits('any-id');
      expect(credits.value.casts.length, 4);
      expect(credits.value.directors.length, 1);
      expect(credits.value.all.length, 5);

      final comments = await source.subjectComments('any-id');
      expect(comments.origin, 'mock/comments.json');
      expect(comments.value.total, 394410);
      expect(comments.value.comments.length, 20);
      expect(comments.value.comments.first.id, '1646653503');
      expect(comments.value.comments.first.author.name, '嘟嘟熊之父');
      expect(comments.value.comments.first.usefulCount, 57058);
      expect(comments.value.hasMore, isTrue);

      final commentsSecond = await source.subjectComments('any-id', start: 10);
      expect(commentsSecond.value.comments.length, 10);
      expect(commentsSecond.value.start, 10);

      final commentsTail = await source.subjectComments('any-id', start: 20);
      expect(commentsTail.value.comments, isEmpty);
      expect(commentsTail.value.nextStart, isNull);
      expect(commentsTail.value.hasMore, isFalse);

      final reviews = await source.subjectReviews('any-id');
      expect(reviews.origin, 'mock/reviews.json');
      expect(reviews.value.total, 20208);
      expect(reviews.value.reviews.length, 20);
      expect(reviews.value.reviews.first.title, '流浪地球，不及格。');
      expect(reviews.value.reviews.first.usefulCount, 42735);
      expect(reviews.value.reviews.first.author.name, '左丘失明');
      expect(reviews.value.hasMore, isTrue);
    });

    test('celebrity/works fixtures parse (host additions, source had none)', () async {
      final celebrity = await source.celebrity('1000525');
      expect(celebrity.origin, 'mock/celebrity.json');
      expect(celebrity.value.id, '1000525');
      expect(celebrity.value.name, '吴京');
      expect(
        celebrity.value.professions,
        <String>['', '', '导演', '制片人', '编剧'],
      );
      expect(celebrity.value.professionsText, '导演 / 制片人 / 编剧');
      expect(celebrity.value.photos.length, 10);
      expect(celebrity.value.works.length, 5);
      expect(celebrity.value.works.first.rolesText, '演员');
      expect(celebrity.value.works.first.subject?.title, '局面');

      final works = await source.celebrityWorks('1000525', start: 0, count: 5);
      expect(works.origin, 'mock/works.json');
      expect(works.value.total, 56);
      expect(works.value.works.length, 5);
      expect(works.value.works.first.subject?.title, '杀破狼3');
      expect(works.value.works.first.subject?.id, '27125418');
      expect(works.value.celebrity?.name, '吴京');
      expect(works.value.hasMore, isTrue);

      final tail = await source.celebrityWorks('1000525', start: 19, count: 20);
      expect(tail.value.works.length, 1);
      expect(
        tail.value.hasMore,
        isTrue,
        reason: 'the fixture holds 20 rows but reports total 56',
      );

      final exhausted = await source.celebrityWorks('1000525', start: 20);
      expect(exhausted.value.works, isEmpty);
      expect(exhausted.value.hasMore, isFalse);
    });

    test('category() wraps fixtures into rank-aware rows', () async {
      final rows = await source.category(FlutterDouBanCategory.inTheaters);
      expect(rows.value.length, 20);
      expect(rows.value.first.subject.title, '流浪地球');
      expect(rows.value.first.rank, isNull);
      expect(rows.kind, FlutterDouBanSourceKind.mock);

      final weeklyRows = await source.category(FlutterDouBanCategory.weekly);
      expect(weeklyRows.value.first.rank, 1);
      expect(weeklyRows.value.first.rankDelta, '↑10');
      expect(weeklyRows.value.first.subject.title, '谁先爱上他的');
    });

    test('mock us_box fails loudly instead of inventing data', () async {
      await expectLater(
        source.usBox(),
        throwsA(
          isA<FlutterDouBanException>().having(
            (error) => error.message,
            'message',
            contains('北美票房榜'),
          ),
        ),
      );
      await expectLater(
        source.category(FlutterDouBanCategory.usBox),
        throwsA(isA<FlutterDouBanException>()),
      );
    });

    test('mock search filters the two ported list fixtures', () async {
      final hit = await source.search('流浪');
      expect(hit.value.query, '流浪');
      expect(hit.value.subjects.first.title, '流浪地球');
      expect(hit.value.total, greaterThanOrEqualTo(1));
      expect(hit.origin, contains('mock/'));
      expect(hit.mocked, isTrue);

      final byOriginal = await source.search('shawshank');
      expect(byOriginal.value.subjects.first.title, '肖申克的救赎');

      final miss = await source.search('不存在的片子xyz');
      expect(miss.value.isEmpty, isTrue);
      expect(miss.value.total, 0);

      await expectLater(source.search('  '), throwsArgumentError);
    });

    test('a missing fixture becomes a readable error', () async {
      final broken = FlutterDouBanMockSource(loader: _diskLoader);
      await expectLater(
        broken.subjectReviews('x'),
        completes,
        reason: 'reviews.json is ported',
      );
      final noFixture = FlutterDouBanMockSource(
        loader: (path) => throw const FileSystemException('missing'),
      );
      await expectLater(
        noFixture.inTheaters(),
        throwsA(
          isA<FlutterDouBanException>().having(
            (error) => error.message,
            'message',
            contains('Mock 数据缺失'),
          ),
        ),
      );
    });
  });

  group('source switch (useNetData) + network provenance', () {
    test('network source is the host default and reports provenance', () async {
      RequestOptions? seen;
      final source = FlutterDouBanNetworkSource(
        api: FlutterDouBanApi(
          dio: _fakeDio((options) {
            seen = options;
            return _ok(jsonDecode(_subjectListJson), options);
          }),
        ),
      );
      addTearDown(source.dispose);

      final data = await source.inTheaters(start: 0, count: 20);
      expect(seen!.path, '/v2/movie/in_theaters');
      expect(data.kind, FlutterDouBanSourceKind.network);
      expect(data.mocked, isFalse);
      expect(data.origin, 'api.douban.com');
      expect(data.assetPath, isNull);
      expect(data.label, '网络 · api.douban.com');
      expect(data.value.total, 42);
    });

    test('factory resolves the source useNetData switch into the two sources', () {
      final networked = createFlutterDouBanSource(useNetData: true);
      expect(networked, isA<FlutterDouBanNetworkSource>());
      networked.dispose();

      final mocked = createFlutterDouBanSource(
        useNetData: false,
        assetLoader: _diskLoader,
      );
      expect(mocked, isA<FlutterDouBanMockSource>());
      expect(
        FlutterDouBanSettingsStore.defaultUseNetData,
        isTrue,
        reason: 'host flips the source default (source defaulted to mock)',
      );
      expect(FlutterDouBanSettingsStore.useNetDataKey, 'USE_NET_DATA');
    });

    test('category() on the network source wraps the same payload', () async {
      final source = FlutterDouBanNetworkSource(
        api: FlutterDouBanApi(
          dio: _fakeDio(
            (options) => _ok(
              options.path.contains('weekly')
                  ? jsonDecode(_weeklyJson)
                  : jsonDecode(_subjectListJson),
              options,
            ),
          ),
        ),
      );
      addTearDown(source.dispose);

      final rows = await source.category(FlutterDouBanCategory.inTheaters);
      expect(rows.value.length, 2);
      expect(rows.value.first.subject.title, '流浪地球');
      expect(rows.kind, FlutterDouBanSourceKind.network);

      final weekly = await source.category(FlutterDouBanCategory.weekly);
      expect(weekly.value.first.rank, 1);
      expect(weekly.value.first.rankDelta, '↑10');
    });

    test('search/celebrity/works responses parse through the real client', () async {
      final source = FlutterDouBanNetworkSource(
        api: FlutterDouBanApi(
          dio: _fakeDio((options) {
            if (options.path.contains('/search')) {
              return _ok(<String, dynamic>{
                'q': '流浪地球',
                'total': 1,
                'subjects': [
                  (jsonDecode(_subjectListJson) as Map<String, dynamic>)['subjects'][0],
                ],
              }, options);
            }
            if (options.path.endsWith('/works')) {
              return _ok(jsonDecode(_worksJson), options);
            }
            return _ok(jsonDecode(_celebrityJson), options);
          }),
        ),
      );
      addTearDown(source.dispose);

      final search = await source.search('流浪地球');
      expect(search.value.query, '流浪地球');
      expect(search.value.subjects.first.title, '流浪地球');

      final celebrity = await source.celebrity('1000525');
      expect(celebrity.value.name, '吴京');

      final works = await source.celebrityWorks('1000525');
      expect(works.value.works.first.subject?.title, '杀破狼3');
    });
  });
}
