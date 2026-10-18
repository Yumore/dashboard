/// Port of the app-wide constants of the flutter-social static UI demo
/// (source `lib/utils/utils.dart:3-10`, `AppConfig`).
///
/// The source project has no networking at all: its single URL is the
/// random-name-generator comment in `lib/models/user.dart:15`. Every image it
/// references is a bundled asset under `assets/images/`, so there is no remote
/// sample image URL to carry over. The list below is intentionally empty and is
/// asserted by `test/fluttersocial_demo_test.dart` so the port can be checked
/// against the source instead of assumed.
const List<String> flutterSocialDemoRemoteSampleImageUrls = <String>[];

class FlutterSocialDemoConfig {
  const FlutterSocialDemoConfig._();

  static const String appName = 'Heart String';
  static const String appTagline = 'Find your perfect match';

  /// Source `AvailableFonts.primaryFont`. The host keeps its own typography, so
  /// this value is recorded but not applied to any widget.
  static const String sourceFontFamily = 'Quicksand';
}
