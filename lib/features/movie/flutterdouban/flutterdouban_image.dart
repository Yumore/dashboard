/// Image handling for douban payloads.
///
/// Douban returns `{small, medium, large}` objects whose values are already
/// absolute `img*.doubanio.com` URLs, but entries can be empty strings or null
/// (real douban list payloads do this for minor cast members).
///
/// Placeholder handling ported from the source:
/// `lib/widgets/subject_mark_image_widget.dart:56` used
/// `Image.asset('assets/images/ic_default_img_subject_movie.9.png')` as the
/// `CachedNetworkImage.placeholder` for every poster. That bitmap is part of
/// the source app's `assets/images/` tree and is NOT part of this host's asset
/// registry, so [placeholderAssetPath] keeps the source path for reference and
/// [FlutterDouBanPoster] falls back to a Material icon instead of shipping an
/// unregistered asset.
class FlutterDouBanImage {
  const FlutterDouBanImage._();

  static const String placeholderAssetPath =
      'assets/images/ic_default_img_subject_movie.9.png';

  /// Returns a usable http(s) URL or null when there is nothing to load.
  ///
  /// Trimmed, and rejects non-network values (the source's own asset
  /// placeholder path, data URIs, blanks).
  static String? resolve(Object? raw) {
    final value = raw?.toString().trim() ?? '';
    if (value.isEmpty) return null;
    if (!isNetworkUrl(value)) return null;
    return value;
  }

  static bool isNetworkUrl(String value) {
    final uri = Uri.tryParse(value);
    return uri != null &&
        uri.hasScheme &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  /// True when the caller should draw the placeholder instead of an image.
  static bool needsPlaceholder(Object? raw) => resolve(raw) == null;
}
