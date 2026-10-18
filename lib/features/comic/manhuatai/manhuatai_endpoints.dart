/// Marketing/API hosts and paths for the 321mh (manhuatai) comic network.
///
/// The network is spread across three domains that still share one product
/// identity (`platformname=android`, `productname=mht`):
///  * `*.321mh.com`     — comic content, CMS book lists, book shelf record;
///  * `*.yyhao.com`     — configuration/global search endpoints;
///  * `mkxq.zymk.cn`    — account endpoints (login/bind), not ported here.
///
/// Everything is a plain GET/POST with query or form parameters — there is no
/// request signing and no HTML scraping in this source.
class ManhuataiEndpoints {
  const ManhuataiEndpoints._();

  // ---------------------------------------------------------------- home feed
  /// Legacy first-page feed (`Api.getRecommentList`).
  static const String legacyRecommend =
      'https://cms-booklist.321mh.com/api/v1/bookList/getBookByType';

  /// Paged recommendation feed (`Api.getRecommenNewList`).
  static const String recommend =
      'http://recommend.321mh.com/api/v2/booklist/getbookbytype';

  /// Personalised "streaming" feed used once the paged feed runs dry.
  static const String recommendStreaming =
      'http://recommend.321mh.com/api/v2/booklist/recommendstreamlist';

  // ------------------------------------------------------------------- ranking
  static const String rankIndex =
      'https://rankdata-globalapi.321mh.com/app_api/v1/comic/getIndexRankData/';
  static const String rankTypes =
      'https://rankdata-globalapi.321mh.com/app_api/v1/comic/getRankTypes/';
  static const String rankDetail =
      'https://rankdata-globalapi.321mh.com/app_api/v1/comic/getRankDataDetials/';

  // -------------------------------------------------------------- comic detail
  static const String comicInfoBody =
      'https://comic.321mh.com/app_api/v5/getcomicinfo_body/';
  static const String comicInfoInfluence =
      'http://comic.321mh.com/app_api/v5/getcomicinfo_influence/';
  static const String comicInfoRole =
      'http://kanmanapi-main.321mh.com/app_api/v5/getcomicinfo_role/';
  static const String comicCommentCount =
      'http://community-hots.321mh.com/comment/count/';
  static const String comicChapterInfo =
      'http://kanmanapi-main.321mh.com/v1/comic/getchapterinfobychapterid';

  // ----------------------------------------------------------- book (album) db
  static const String bookByComicId =
      'http://cms-booklist.321mh.com/api/v1/bookList/getBookByComicidNew';
  static const String bookByPosition =
      'https://cms-booklist.321mh.com/api/v1/bookList/getBookByPosition';
  static const String bookInfoById =
      'http://cms-booklist.321mh.com/api/v1/bookList/getbookinfo_sys';

  // ----------------------------------------------------------------- discovery
  static const String updateList =
      'https://comic.321mh.com/app_api/v5/updatelist/';
  static const String hotSearch =
      'https://getconfig-globalapi.yyhao.com/app_api/v5/gettopsearch/';
  static const String searchComic =
      'https://getconfig-globalapi.yyhao.com/app_api/v5/serachcomic/';
  static const String sortList =
      'https://getconfig-globalapi.yyhao.com/app_api/v5/getsortlist/';
  static const String searchUser =
      'https://community-new.321mh.com/v1/user/searchuser';

  // ------------------------------------------------------------- user record
  static const String userRecord =
      'https://kanmanapi-main.321mh.com/app_api/v5/getuserrecord/';
  static const String userCollect =
      'https://kanmanapi-main.321mh.com/app_api/v5/setusercollect/';
  static const String userReadAdd =
      'https://adduserread.321mh.com/app_api/v5/adduserread/';
  static const String userReadDelete =
      'https://kanmanapi-main.321mh.com/app_api/v5/deluserread/';

  // --------------------------------------------------- shared request values
  static const String platformName = 'android';
  static const String productName = 'mht';

  /// `platform` is a numeric extra used by the CMS book-list endpoints only.
  static const int platform = 8;

  /// `booktype=132` selects comic albums on the recommendation endpoints.
  static const int bookType = 132;

  static const int recommendPageSize = 10;
  static const int legacyRecommendPageSize = 20;
  static const int bookPositionPageSize = 20;
  static const int defaultSortPageSize = 7;
  static const String defaultSortOrder = 'click';

  static const int rankProductId = 2;
  static const String defaultRankType = 'heat';
  static const String defaultTimeType = 'week';

  /// Default anonymous user type for the record/collect endpoints.
  static const String defaultUserType = 'device';

  /// Default album position used by the home "book shelf" banner (/comic/detail).
  static const int homePositionId = 7;
}
