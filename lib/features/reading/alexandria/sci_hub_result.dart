/// A Sci-Hub lookup result, ported from `SciHubArticleInfo`.
class SciHubResult {
  const SciHubResult({required this.shareUrl, required this.downloadUrl});

  /// `#link > a[href]`: the Sci-Hub article page.
  final String shareUrl;

  /// Scheme-less host path scraped from the `#buttons` `onclick` attribute.
  ///
  /// The source stripped `location.href='//` and the surrounding quotes but left
  /// the scheme off (for example `sci-hub.se/downloads/2020/xyz.pdf`), then
  /// always opened it as `https://<downloadUrl>`.
  final String downloadUrl;

  /// The download location as the source opened it.
  String get absoluteDownloadUrl =>
      downloadUrl.startsWith('http') ? downloadUrl : 'https://$downloadUrl';
}
