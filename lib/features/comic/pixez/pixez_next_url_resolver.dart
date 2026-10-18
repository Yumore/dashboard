/// Rewrites `next_url` values the way pixez `ApiClient.getNext` does.
///
/// pixiv always returns absolute `https://app-api.pixiv.net/...` URLs. The
/// source replaces that host with its configured base URL so paging keeps
/// using the same DNS-bypass endpoint as the first request.
class PixezNextUrlResolver {
  const PixezNextUrlResolver({required this.baseUrl});

  static const String pixivApiHost = 'app-api.pixiv.net';

  final String baseUrl;

  /// Returns [nextUrl] with the pixiv app-api host replaced, or `null` when
  /// the URL is absent/blank.
  String? resolve(String? nextUrl) {
    final raw = nextUrl?.trim();
    if (raw == null || raw.isEmpty) return null;
    final uri = Uri.tryParse(raw);
    if (uri == null) return null;
    if (uri.host != pixivApiHost) return raw;
    final base = Uri.parse(baseUrl);
    return Uri(
      scheme: base.scheme.isEmpty ? 'https' : base.scheme,
      host: base.host,
      port: base.hasPort ? base.port : null,
      path: uri.path,
      query: uri.hasQuery ? uri.query : null,
    ).toString();
  }
}
