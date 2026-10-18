/// Ports `EhentaiRequests` (URL construction) from
/// PicaComic lib/network/eh_network/eh_main_network.dart.
class EhentaiRequests {
  const EhentaiRequests._();

  static const String ehentaiBaseUrl = 'https://e-hentai.org';
  static const String exhentaiBaseUrl = 'https://exhentai.org';
  static const String ehentaiApiUrl = 'https://api.e-hentai.org/api.php';
  static const String exhentaiApiUrl = 'https://exhentai.org/api.php';

  /// Home page: the original called `getGalleries(ehBaseUrl)` with no path.
  static const String homePath = '';

  /// `Eh热门` explore page.
  static const String popularPath = '/popular';

  /// The four search option slots, in order, as the original `_SearchOptions`
  /// widget emitted them (`f_cats`, `f_spf`, `f_spt`, `f_srdd`).
  static const List<String> searchOptionQueryKeys = [
    'f_cats',
    'f_spf',
    'f_spt',
    'f_srdd',
  ];

  /// `favorites.php` for all folders, `favorites.php?favcat=<id>` otherwise.
  static String favoritesUrl(String folderId) => folderId == '-1'
      ? '$ehentaiBaseUrl/favorites.php'
      : '$ehentaiBaseUrl/favorites.php?favcat=$folderId';

  /// Leaderboard page; `tl` is the [EhLeaderboardType] value and `p` is 1
  /// based in the original (`getLeaderBoardByPage`).
  static String leaderboardUrl(int type, int page) =>
      '$ehentaiBaseUrl/toplist.php?tl=$type&p=$page';

  /// `toplist.php?tl=<type>` without a page, used by `getLeaderboard`.
  static String leaderboardFirstPageUrl(int type) =>
      '$ehentaiBaseUrl/toplist.php?tl=$type';

  /// Image page URL: `/s/<imgKey>/<gid>-<page>?nl=<nl>`.
  static String imagePageUrl(
    String baseUrl,
    String gid,
    String imgKey,
    int page, {
    String nl = '',
  }) =>
      '$baseUrl/s/$imgKey/$gid-$page?nl=$nl';

  /// Comment listing URL: `<link>?hc=1`.
  static String commentsUrl(String link) => '$link?hc=1';

  /// Reader page URL: page 1 is the plain link, later pages use `p=` (0 based).
  static String readerPageUrl(String link, int page) {
    if (page == 1) return link;
    return link.contains('?') ? '$link&p=${page - 1}' : '$link?p=${page - 1}';
  }
}
