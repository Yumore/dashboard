/// Port of inKino's `image_url_rewriter`.
///
/// Finnkino serves its images from `media.finnkino.fi`; the original app piped
/// them through its own imgix CDN. This host has no imgix account, so the
/// rewrite is kept as a pure, testable function (host replacement is a no-op)
/// and the one real bug it existed to fix is preserved: Finnkino occasionally
/// returns the literal text "Not yet rated" where an image URL belongs.
class InKinoImageRewriter {
  const InKinoImageRewriter._();

  static final RegExp _finnkinoBaseUrl = RegExp(
    r'https?://media\.finnkino\.fi',
  );
  static final RegExp _notYetRated = RegExp(
    r'.*not.*yet.*rated.*',
    caseSensitive: false,
  );

  /// Href used by the real app for the "coming soon" rating badge.
  static const String notYetRatedImage =
      'https://media.finnkino.fi/images/rating_large_Tulossa.png';

  static String? rewrite(String? originalUrl) {
    if (originalUrl == null || originalUrl.isEmpty) return null;
    var url = originalUrl;
    if (_notYetRated.hasMatch(url)) {
      url = url.replaceFirst(_notYetRated, notYetRatedImage);
    }
    return url;
  }

  /// The URL shape the source's imgix account produced, kept so the rewrite can
  /// still be exercised without hard-wiring a CDN into the host.
  static String withImgixHost(
    String? originalUrl, {
    String imgixBaseUrl = 'https://inkino.imgix.net',
    String query = '?auto=format,compress',
  }) {
    final url = rewrite(originalUrl);
    if (url == null) return '';
    return '${url.replaceFirst(_finnkinoBaseUrl, imgixBaseUrl)}$query';
  }
}
