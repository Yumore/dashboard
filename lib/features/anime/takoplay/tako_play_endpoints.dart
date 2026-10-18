/// URL and query construction for the Tako-Play (gogoanime.wiki) endpoints.
///
/// Ported 1:1 from the source's generated chopper service
/// (`request_service.chopper.dart`), which interpolated raw query strings:
/// `search.html?keyword=$name`, `$url?page=$index`,
/// `$hostencrypt-ajax.php?id=$encryptedId$encryptAjaxParams&alias=$id`.
class TakoPlayEndpoints {
  const TakoPlayEndpoints._();

  static final Uri base = Uri.parse('https://gogoanime.wiki/');

  static final Uri recentEndpoint = Uri.parse(
    'https://ajax.gogocdn.net/ajax/page-recent-release.html',
  );

  static final Uri episodeEndpoint = Uri.parse(
    'https://ajax.gogo-load.com/ajax/load-list-episode',
  );

  static const String userAgent =
      'Mozilla/5.0 (X11; Fedora; Linux x86_64) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/96.0.4664.93 Safari/537.36';

  static const String referer = 'https://gogoplay.io';

  /// Headers the source attached to its player (`constants.dart`) and to the
  /// `encrypt-ajax.php` XHR (the `X-Requested-With` entry).
  static const Map<String, String> browserHeaders = {
    'User-Agent': userAgent,
    'Referer': referer,
  };

  static const Map<String, String> ajaxHeaders = {
    'User-Agent': userAgent,
    'Referer': referer,
    'X-Requested-With': 'XMLHttpRequest',
  };

  /// `https://gogoanime.wiki/search.html?keyword=$query`.
  static Uri search(String query) =>
      Uri.parse('${base}search.html?keyword=$query');

  /// `popular.html`, `anime-movies.html` or a genre path.
  static Uri catalogue(String path) => base.resolve(path);

  /// Genre pagination: `$url?page=$index` (1-based, as the source sent it).
  static Uri genre(String path, int page) => Uri.parse('$path?page=$page');

  /// `https://ajax.gogo-load.com/ajax/load-list-episode?ep_start=0&ep_end=5000&id=$id`.
  static Uri episodes(String episodeId) => episodeEndpoint.replace(
    queryParameters: {'ep_start': '0', 'ep_end': '5000', 'id': episodeId},
  );

  /// The `download` mirror table of an embed URL.
  static Uri mirrors(Uri embedUrl) =>
      Uri.parse(embedUrl.toString().replaceFirst('streaming.php', 'download'));

  /// `https://$host/` for the anime cdn the embed page was served from.
  static Uri cdnRoot(String embedUrl) {
    final parts = embedUrl.split('https://');
    if (parts.length < 2) {
      throw FormatException('embed url is not https: $embedUrl');
    }
    return Uri.parse('https://${parts[1].split('/')[0]}/');
  }

  /// `${host}encrypt-ajax.php?id=$encryptedId$ajaxParams&alias=$animeId`.
  ///
  /// [ajaxParams] is the `&token=...&expires=...` remainder decrypted from the
  /// embed page, [animeId] the plain `value` of the page's hidden input.
  static Uri encryptedData({
    required Uri cdnRoot,
    required String encryptedId,
    required String ajaxParams,
    required String animeId,
  }) => Uri.parse(
    '${cdnRoot}encrypt-ajax.php?id=$encryptedId$ajaxParams&alias=$animeId',
  );
}
