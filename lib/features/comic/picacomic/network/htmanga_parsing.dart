/// Pure helpers extracted from PicaComic's 紳士漫畫 scraper
/// (lib/network/htmanga_network/htmanga_main_network.dart) so the HTML rules can
/// be unit tested without a network round trip.
class HtmangaParsing {
  HtmangaParsing._();

  /// `-aid-<digits>` out of a gallery link
  /// (htmanga_main_network.dart:131, :189, :419).
  static final RegExp aidPattern = RegExp(r'-aid-([0-9]+)');

  /// `del-id-<digits>` out of a favourite delete `onclick`
  /// (htmanga_main_network.dart:426).
  static final RegExp favoriteIdPattern = RegExp(r'del-id-([0-9]+)');

  static String? aidFromLink(String link) =>
      aidPattern.firstMatch(link)?.group(1);

  static String? favoriteIdFromOnclick(String onclick) =>
      favoriteIdPattern.firstMatch(onclick)?.group(1);

  /// Every digit of [text] concatenated (`"頁數：12 P"` -> `"12"`).
  static String digitsOnly(String text) =>
      text.split('').where((c) => int.tryParse(c) != null).join();

  static int? pagesFromText(String text) => int.tryParse(digitsOnly(text));

  /// Image sources are protocol relative (`//cdn...`).
  static String absoluteImage(String src) =>
      src.startsWith('//') ? 'https:$src' : src;

  /// Cover path of the detail page.
  ///
  /// PicaComic built `"https:$src"` and then ran `replaceRange(6, 8, "")`,
  /// which drops the `//` of the scheme and leaves an unusable URL
  /// (htmanga_main_network.dart:269). This port keeps the intent (an absolute
  /// https URL) instead of reproducing the broken splice.
  static String normalizeCoverPath(String src) =>
      src.startsWith('http') ? src : 'https:$src';

  /// Paginated list URL for [page] > 1
  /// (htmanga_main_network.dart:164-176).
  ///
  /// Search URLs get `&p=<page>`; album URLs are rewritten to
  /// `<prefix>albums-index-page-<page><rest>`.
  static String pageUrl(String url, int page) {
    if (page == 1) return url;
    if (url.contains('search')) {
      return '$url&p=$page';
    }
    var result = url;
    if (!result.contains('-')) {
      result = result.replaceAll('.html', '-.html');
    }
    result = result.replaceAll('index', '');
    final parts = result.split('albums-');
    parts[1] = 'index-page-$page${parts[1]}';
    return '${parts[0]}albums-${parts[1]}';
  }
}
