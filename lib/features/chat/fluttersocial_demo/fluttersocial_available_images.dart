/// Port of the source `AvailableImages` map (source `lib/utils/utils.dart:12-77`).
///
/// Only the `assetPath` entries are kept: `AssetImage` handles cannot be shared
/// across packages. The 15 files were copied from the source's `assets/images/`
/// into the host's `assets/fluttersocial_demo/` (registered in pubspec.yaml), so
/// `FlutterSocialPhoto` renders them through `Image.asset`; only the leading
/// directory changed, the file names are exact.
class FlutterSocialAvailableImages {
  const FlutterSocialAvailableImages._();

  static const String man1 = 'assets/fluttersocial_demo/man1.jpg';
  static const String man2 = 'assets/fluttersocial_demo/man2.jpg';
  static const String man3 = 'assets/fluttersocial_demo/man3.jpg';
  static const String man4 = 'assets/fluttersocial_demo/man4.jpg';
  static const String man5 = 'assets/fluttersocial_demo/man5.jpg';

  static const String woman1 = 'assets/fluttersocial_demo/woman1.jpg';
  static const String woman2 = 'assets/fluttersocial_demo/woman2.jpg';
  static const String woman3 = 'assets/fluttersocial_demo/woman3.jpg';
  static const String woman4 = 'assets/fluttersocial_demo/woman4.jpg';
  static const String woman5 = 'assets/fluttersocial_demo/woman5.jpg';

  static const String postBanner = 'assets/fluttersocial_demo/post_banner.jpg';
  static const String emptyState = 'assets/fluttersocial_demo/empty.png';
  static const String homePage = 'assets/fluttersocial_demo/home_page.png';
  static const String appLogo = 'assets/fluttersocial_demo/logo.png';
}
