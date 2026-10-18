/// Port of the app-wide constants of the FlutterSocialAppUIKit static UI demo
/// (source `lib/util/const.dart:2`, `lib/util/animations.dart:2`).
///
/// The source has no networking at all: no http/dio client, no socket, no
/// sample image URL. Every picture is a bundled asset under the source's
/// `assets/images/`. The list below is intentionally empty and is asserted by
/// `test/fluttersocialappuikit_demo_test.dart`, so the port can be checked
/// against the source instead of assumed.
const List<String> flutterSocialAppUIKitRemoteSampleImageUrls = <String>[];

class FlutterSocialAppUIKitDemoConfig {
  const FlutterSocialAppUIKitDemoConfig._();

  static const String appName = 'Chat App';

  /// Source `GetSourceSansProTextTheme` in `lib/app.dart`: the app builds its
  /// typography with `google_fonts` (`SourceSansPro`). The host keeps its own
  /// typography and has no `google_fonts` dependency, so this value is recorded
  /// but not applied to any widget.
  static const String sourceFontFamily = 'SourceSansPro';

  /// Source login screen's Lottie animation. The host has no `lottie`
  /// dependency, so the JSON file is not bundled and the panel renders a
  /// static stand-in (see `FlutterSocialAppUIKitDemoPageState`).
  static const String sourceLottieAnimation =
      'assets/animations/chat-anim.json';

  /// Directory the source's ten `assets/images/cm0..cm9.jpeg` files were copied
  /// into. The line the Lead must add to `pubspec.yaml` is
  /// `- assets/fluttersocialappuikit_demo/`.
  static const String assetDirectory = 'assets/fluttersocialappuikit_demo/';
}
