/// A bilibili video reference, parsed from a pasted share link, a bare `BV…`
/// id, or an `av…` / `aid=` numeric id.
///
/// Ports the source app's `RegExp(r'BV[\w]+')` scan in
/// `BiliVideoSearchController.handleSearch`, tightened to the real 12-character
/// `BV` shape (`BV` + 10 alphanumerics) and extended with `av…`/`aid=` support
/// plus the `p` (page) query parameter.
class BiliVideoId {
  const BiliVideoId({this.bvid, this.aid, this.page = 1});

  /// `BV` identifier, e.g. `BV1xx411c7mD`, when the input carried one.
  final String? bvid;

  /// Numeric `aid`, when the input was an `av…` id or an `aid=`/`avid=` link.
  final int? aid;

  /// 1-based part index from `?p=`, matching bilibili's own `p` parameter.
  final int page;

  bool get hasBvid => bvid != null;

  /// Whether the parse produced something the API can be queried with.
  bool get isValid => bvid != null || aid != null;

  /// Human-readable form used for logging, labels and cache keys.
  String get label => bvid ?? 'av$aid';

  /// The source app's id shape, narrowed to real ids: `BV` + 10 alphanumerics.
  static final RegExp bvidPattern = RegExp(r'BV[0-9A-Za-z]{10}');

  /// `av123456`, case-insensitive like bilibili's own links.
  static final RegExp avidPattern = RegExp(r'av(\d+)', caseSensitive: false);

  /// Parses [input]; returns `null` when it carries no usable video id.
  ///
  /// Accepted shapes:
  /// * `https://www.bilibili.com/video/BV1xx411c7mD/?p=2&spm_id_from=…`
  /// * `https://www.bilibili.com/video/av170001`
  /// * `https://www.bilibili.com/video/BV1xx411c7mD?aid=170001`
  /// * a bare `BV1xx411c7mD` or `av170001`
  ///
  /// `b23.tv` short links are rejected: expanding them needs a network round
  /// trip, which the source app never performed either.
  static BiliVideoId? parse(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;

    var page = 1;
    var candidate = trimmed;
    final uri = Uri.tryParse(trimmed);
    if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
      final parsedPage = int.tryParse(uri.queryParameters['p'] ?? '');
      if (parsedPage != null && parsedPage > 0) page = parsedPage;
      final aidParam = int.tryParse(
        uri.queryParameters['aid'] ?? uri.queryParameters['avid'] ?? '',
      );
      if (aidParam != null && aidParam > 0) {
        return BiliVideoId(aid: aidParam, page: page);
      }
      // The id lives in the path for `/video/<id>/`.
      candidate = uri.path;
    }

    final bvid =
        bvidPattern.firstMatch(candidate) ?? bvidPattern.firstMatch(trimmed);
    if (bvid != null) {
      return BiliVideoId(bvid: bvid.group(0), page: page);
    }

    final avid =
        avidPattern.firstMatch(candidate) ?? avidPattern.firstMatch(trimmed);
    if (avid != null) {
      final aid = int.tryParse(avid.group(1)!);
      if (aid != null && aid > 0) {
        return BiliVideoId(aid: aid, page: page);
      }
    }
    return null;
  }

  @override
  String toString() => 'BiliVideoId($label, page: $page)';
}
