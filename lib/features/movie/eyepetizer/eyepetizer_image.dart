/// Image handling for 开眼 payloads.
///
/// The source resolved every thumbnail through `ImgUtil.cacheImage`
/// (`component/lib_utils/lib/img_util.dart`), which fell back to
/// `Image.asset('images/ic_default_img.png')` whenever the URL was blank. That
/// bitmap lives in the source app's `assets/images/` tree and is NOT part of
/// this host's asset registry, so [placeholderAssetPath] keeps the source path
/// for reference and [EyepetizerThumbnail] draws a Material icon instead of
/// shipping an unregistered asset.
class EyepetizerImage {
  const EyepetizerImage._();

  static const String placeholderAssetPath = 'images/ic_default_img.png';

  /// Returns a usable http(s) URL or null when there is nothing to load.
  ///
  /// Trimmed, `//host/path` scheme-relative values are upgraded to `https:`,
  /// and non-network values (blanks, the source's own asset path, data URIs)
  /// are rejected.
  static String? resolve(Object? raw) {
    var value = raw?.toString().trim() ?? '';
    if (value.isEmpty) return null;
    if (value.startsWith('//')) value = 'https:$value';
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
