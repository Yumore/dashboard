import 'package:dashboard/features/comic/manhuatai/manhuatai_book_info.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_book_list.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_chapter.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_client.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_comment_count.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_detail.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_endpoints.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_hot_search.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_influence.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_json.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_rank_detail.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_rank_list.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_rank_types.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_search_comic.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_sort_list.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_update_list.dart';

/// The 321mh / yyhao / zymk comic API client.
///
/// Ported from `lib/api/api.dart` (1375 lines, static methods on `Api`). Every
/// endpoint, parameter name and "empty payload" rule is preserved; login-bound
/// endpoints (SMS, binding, levels, tasks, comments, satellites) are not part
/// of this migration.
///
/// All methods are network calls: never invoke them from `build()`.
class ManhuataiSource {
  ManhuataiSource({ManhuataiClient? client})
      : _client = client ?? ManhuataiClient(),
        _ownsClient = client == null;

  final ManhuataiClient _client;
  final bool _ownsClient;

  /// Identity used by the anonymous (device) record/collect endpoints.
  ///
  /// The source read these from `UserInfoModel`; the migrated screens keep
  /// favourites locally, so they stay empty unless a caller supplies them.
  String openid = '';
  String deviceid = '';
  String userauth = '';
  String myuid = '';
  String authorization = '';

  void dispose() {
    if (_ownsClient) {
      _client.close();
    }
  }

  // --------------------------------------------------------------- home feed

  /// Legacy first-page feed (`getBookByType`, 20 per page).
  Future<ManhuataiBookList> legacyRecommend() async {
    final response = await _client.get(
      ManhuataiEndpoints.legacyRecommend,
      params: <String, dynamic>{
        'page': 1,
        'pagesize': ManhuataiEndpoints.legacyRecommendPageSize,
        'pytype': '',
        'booktype': ManhuataiEndpoints.bookType,
        'platform': ManhuataiEndpoints.platform,
        'platformname': ManhuataiEndpoints.platformName,
        'productname': ManhuataiEndpoints.productName,
      },
    );
    return ManhuataiBookList.fromJson(ManhuataiJson.map(response));
  }

  /// Paged recommendation feed. `status != 0` yields an empty list, exactly as
  /// the source did.
  Future<ManhuataiBookList> recommend({
    String userId = '',
    int page = 1,
  }) async {
    final response = await _client.get(
      ManhuataiEndpoints.recommend,
      params: <String, dynamic>{
        'user_id': userId,
        'page': page,
        'pagesize': ManhuataiEndpoints.recommendPageSize,
        'pytype': '',
        'booktype': ManhuataiEndpoints.bookType,
        'platform': ManhuataiEndpoints.platform,
        'platformname': ManhuataiEndpoints.platformName,
        'productname': ManhuataiEndpoints.productName,
      },
    );
    final map = ManhuataiJson.map(response);
    if (ManhuataiJson.asInt(map['status']) != 0) {
      return ManhuataiBookList.empty;
    }
    return ManhuataiBookList.fromJson(map);
  }

  /// Personalised "streaming" feed used when the paged feed runs dry.
  Future<ManhuataiBookList> recommendStreaming({String userId = ''}) async {
    final response = await _client.get(
      ManhuataiEndpoints.recommendStreaming,
      params: <String, dynamic>{
        'user_id': userId,
        'pytype': '',
        'booktype': ManhuataiEndpoints.bookType,
        'platform': ManhuataiEndpoints.platform,
        'platformname': ManhuataiEndpoints.platformName,
        'productname': ManhuataiEndpoints.productName,
      },
    );
    final map = ManhuataiJson.map(response);
    if (ManhuataiJson.asInt(map['status']) != 0) {
      return ManhuataiBookList.empty;
    }
    return ManhuataiBookList.fromJson(map);
  }

  /// Album shelf shown at a CMS position (home banner uses position 7).
  Future<ManhuataiBookList> bookByPosition({
    int positionId = ManhuataiEndpoints.homePositionId,
  }) async {
    final response = await _client.get(
      ManhuataiEndpoints.bookByPosition,
      params: <String, dynamic>{
        'position_id': positionId,
        'page': 1,
        'pagesize': ManhuataiEndpoints.bookPositionPageSize,
        'platformname': ManhuataiEndpoints.platformName,
        'productname': ManhuataiEndpoints.productName,
      },
    );
    return ManhuataiBookList.fromJson(ManhuataiJson.map(response));
  }

  // ----------------------------------------------------------------- ranking

  Future<ManhuataiRankList> rankIndex() async {
    final response = await _client.get(
      ManhuataiEndpoints.rankIndex,
      params: <String, dynamic>{
        'platformname': ManhuataiEndpoints.platformName,
        'productname': ManhuataiEndpoints.productName,
      },
    );
    return ManhuataiRankList.fromJson(ManhuataiJson.map(response));
  }

  Future<ManhuataiRankTypes> rankTypes() async {
    final response = await _client.get(
      ManhuataiEndpoints.rankTypes,
      params: <String, dynamic>{
        'platformname': ManhuataiEndpoints.platformName,
        'productname': ManhuataiEndpoints.productName,
      },
    );
    return ManhuataiRankTypes.fromJson(ManhuataiJson.map(response));
  }

  /// Ranked list for one rank type. [now] only exists so tests can pin the
  /// `query_time` value; production passes `DateTime.now()`.
  Future<ManhuataiRankDetail> rankDetail({
    required String sortType,
    String rankType = ManhuataiEndpoints.defaultRankType,
    String timeType = ManhuataiEndpoints.defaultTimeType,
    DateTime? now,
  }) async {
    final response = await _client.get(
      ManhuataiEndpoints.rankDetail,
      params: <String, dynamic>{
        'sort_type': sortType,
        'rank_type': rankType,
        'time_type': timeType,
        'query_time': formatQueryDate(now ?? DateTime.now()),
        'product_id': ManhuataiEndpoints.rankProductId,
        'platformname': ManhuataiEndpoints.platformName,
        'productname': ManhuataiEndpoints.productName,
      },
    );
    return ManhuataiRankDetail.fromJson(ManhuataiJson.map(response));
  }

  /// `yyyy-MM-dd`, as the source formatted `getRankDataDetials.query_time`.
  static String formatQueryDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  // ------------------------------------------------------------ comic detail

  Future<ManhuataiDetail> detail({
    required int comicId,
    String fromPage = '',
  }) async {
    final response = await _client.get(
      ManhuataiEndpoints.comicInfoBody,
      params: <String, dynamic>{
        'comic_id': comicId,
        'from_page': fromPage,
        'platformname': ManhuataiEndpoints.platformName,
        'productname': ManhuataiEndpoints.productName,
      },
    );
    return ManhuataiDetail.fromJson(ManhuataiJson.map(response));
  }

  Future<ManhuataiInfluence> influence({required int comicId}) async {
    final response = await _client.get(
      ManhuataiEndpoints.comicInfoInfluence,
      params: <String, dynamic>{
        'comic_id': comicId,
        'rank_type': 'all',
        'platformname': ManhuataiEndpoints.platformName,
        'productname': ManhuataiEndpoints.productName,
      },
    );
    return ManhuataiInfluence.fromJson(ManhuataiJson.map(response));
  }

  Future<ManhuataiCommentCount> commentCount({required int comicId}) async {
    final response = await _client.get(
      ManhuataiEndpoints.comicCommentCount,
      params: <String, dynamic>{
        'appId': 2,
        'commentType': 2,
        'ssid': comicId,
        'ssidType': 0,
      },
    );
    return ManhuataiCommentCount.fromJson(ManhuataiJson.map(response));
  }

  /// Chapter metadata for reader bookkeeping.
  ///
  /// The endpoint needs a *repeated* `chapterid` query key. The source built it
  /// manually because Dio would have encoded `chapterid[]`; this port passes a
  /// List through [ManhuataiClient.buildUri], which produces the same URL.
  Future<List<ManhuataiChapter>> chapterInfo({
    required List<int> chapterIds,
  }) async {
    final response = await _client.get(
      ManhuataiEndpoints.comicChapterInfo,
      params: <String, dynamic>{
        'chapterid': chapterIds,
        'platformname': ManhuataiEndpoints.platformName,
        'productname': ManhuataiEndpoints.productName,
      },
    );
    final map = ManhuataiJson.map(response);
    if (ManhuataiJson.asInt(map['status']) != 0) {
      return <ManhuataiChapter>[];
    }
    return ManhuataiJson.maps(map['data'])
        .map(ManhuataiChapter.fromJson)
        .toList();
  }

  // ------------------------------------------------------------- discovery

  Future<ManhuataiUpdateList> updateList() async {
    final response = await _client.get(
      ManhuataiEndpoints.updateList,
      params: <String, dynamic>{
        'platformname': ManhuataiEndpoints.platformName,
        'productname': ManhuataiEndpoints.productName,
      },
    );
    return ManhuataiUpdateList.fromJson(ManhuataiJson.map(response));
  }

  /// Top searches. The endpoint returns a bare array.
  Future<List<ManhuataiHotSearch>> hotSearch() async {
    final response = await _client.get(
      ManhuataiEndpoints.hotSearch,
      params: <String, dynamic>{
        'platformname': ManhuataiEndpoints.platformName,
        'productname': ManhuataiEndpoints.productName,
      },
    );
    if (response is! List) {
      return <ManhuataiHotSearch>[];
    }
    return response
        .whereType<Map<dynamic, dynamic>>()
        .map(
          (Map<dynamic, dynamic> item) =>
              ManhuataiHotSearch.fromJson(ManhuataiJson.map(item)),
        )
        .toList();
  }

  Future<ManhuataiSearchComic> searchComic(
    String searchKey, {
    int? topNumber,
  }) async {
    final response = await _client.get(
      ManhuataiEndpoints.searchComic,
      params: <String, dynamic>{
        'serachKey': searchKey,
        'platformname': ManhuataiEndpoints.platformName,
        'productname': ManhuataiEndpoints.productName,
        'topNumber': ?topNumber,
      },
    );
    return ManhuataiSearchComic.fromJson(ManhuataiJson.map(response));
  }

  Future<ManhuataiSortList> sortList({
    int page = 1,
    int size = ManhuataiEndpoints.defaultSortPageSize,
    String orderby = ManhuataiEndpoints.defaultSortOrder,
    String searchKey = '',
  }) async {
    final response = await _client.get(
      ManhuataiEndpoints.sortList,
      params: <String, dynamic>{
        'page': page,
        'size': size,
        'orderby': orderby,
        'search_key': searchKey,
        'platformname': ManhuataiEndpoints.platformName,
        'productname': ManhuataiEndpoints.productName,
      },
    );
    return ManhuataiSortList.fromJson(ManhuataiJson.map(response));
  }

  /// Album (book) payload of `getbookinfo_sys`.
  Future<ManhuataiBookInfo> bookInfoById({required int bookId}) async {
    final response = await _client.get(
      ManhuataiEndpoints.bookInfoById,
      params: <String, dynamic>{
        'book_id': bookId,
        'platformname': ManhuataiEndpoints.platformName,
        'productname': ManhuataiEndpoints.productName,
      },
    );
    return ManhuataiBookInfo.fromJson(ManhuataiJson.map(response));
  }

  // ---------------------------------------------------------- user records

  /// Server-side "my comics" write (`setusercollect`).
  ///
  /// `action == 'dels'` needs the id list with the source's trailing comma.
  Future<bool> setUserCollect({
    required String action,
    int? comicId,
    List<int> comicIdList = const <int>[],
  }) async {
    final data = <String, dynamic>{
      'openid': openid,
      'type': ManhuataiEndpoints.defaultUserType,
      'deviceid': deviceid,
      'myuid': myuid,
      'autologo': 1,
    };
    if (action == 'add') {
      if (comicId == null) {
        throw ArgumentError('comicId is required when action is "add"');
      }
      data['comic_id'] = comicId;
    } else {
      if (comicIdList.isEmpty) {
        throw ArgumentError('comicIdList is required when action is "dels"');
      }
      final buffer = StringBuffer();
      for (final id in comicIdList) {
        buffer.write('$id,');
      }
      data['comic_id_list'] = buffer.toString();
    }
    final response = await _client.post(
      ManhuataiEndpoints.userCollect,
      data: data,
    );
    return ManhuataiJson.asInt(ManhuataiJson.map(response)['status']) == 0;
  }

  /// Records the reading position (`adduserread`); `status == 0` means success.
  Future<bool> addUserRead({
    required int comicId,
    required int chapterId,
    required String chapterName,
    required int chapterPage,
  }) async {
    final response = await _client.post(
      ManhuataiEndpoints.userReadAdd,
      data: <String, dynamic>{
        'openid': openid,
        'type': ManhuataiEndpoints.defaultUserType,
        'deviceid': deviceid,
        'myuid': myuid,
        'userauth': userauth,
        'comic_id': comicId,
        'chapter_id': chapterId,
        'chapter_name': chapterName,
        'chapter_page': chapterPage,
        'localtime': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'platformname': ManhuataiEndpoints.platformName,
        'productname': ManhuataiEndpoints.productName,
      },
    );
    return ManhuataiJson.asInt(ManhuataiJson.map(response)['status']) == 0;
  }

  /// Removes one read record (`deluserread`).
  Future<bool> delUserRead({
    required int comicId,
    required int chapterId,
  }) async {
    final response = await _client.post(
      ManhuataiEndpoints.userReadDelete,
      data: <String, dynamic>{
        'openid': openid,
        'type': ManhuataiEndpoints.defaultUserType,
        'deviceid': deviceid,
        'myuid': myuid,
        'comic_id': comicId,
        'chapter_id': chapterId,
        'platformname': ManhuataiEndpoints.platformName,
        'productname': ManhuataiEndpoints.productName,
      },
    );
    return ManhuataiJson.asInt(ManhuataiJson.map(response)['status']) == 0;
  }
}
