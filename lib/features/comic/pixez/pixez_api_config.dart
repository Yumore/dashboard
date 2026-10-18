/// Endpoints of the pixiv app-api / OAuth API.
///
/// The source app defaults to the hard-coded DNS-bypass addresses
/// `210.140.131.199` (app-api) and `210.140.131.219` (oauth) and sends the
/// canonical pixiv host in the `Host` header. This port keeps that behaviour
/// available as [PixezApiConfig.dnsBypass] but defaults to the canonical
/// hostnames, because those bypass IPs rotate and a TLS certificate cannot be
/// validated against a bare IP without the source's `badCertificateCallback`.
class PixezApiConfig {
  const PixezApiConfig({
    this.baseUrl = 'https://app-api.pixiv.net',
    this.oauthBaseUrl = 'https://oauth.secure.pixiv.net',
  });

  /// Base URL of the app-api, e.g. `https://app-api.pixiv.net`.
  final String baseUrl;

  /// Base URL of the OAuth token endpoint.
  final String oauthBaseUrl;

  /// The source's DNS-bypass endpoints. Set this only when a custom
  /// [HttpClientAdapter] disables certificate host validation.
  static const PixezApiConfig dnsBypass = PixezApiConfig(
    baseUrl: 'https://210.140.131.199',
    oauthBaseUrl: 'https://210.140.131.219',
  );
}
