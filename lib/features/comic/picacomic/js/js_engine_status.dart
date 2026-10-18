/// Reports the porting status of PicaComic's user-JS extension engine.
///
/// Evidence: PicaComic's `lib/comic_source/parser.dart:50-55` builds
/// `new <className>()` and runs it through `JsEngine().runCode(...)`
/// (`lib/foundation/js_engine.dart`), backed by the `flutter_qjs` QuickJS
/// binding. The host pubspec has no JS runtime, so script bodies cannot run.
class JsEngineStatus {
  const JsEngineStatus._();

  /// `none` in this port.
  static const String runtime = 'none';

  /// Whether JS source bodies can be executed.
  static const bool jsExecutionSupported = false;

  /// What the port does instead.
  static const String portedBehaviour =
      'User .js sources are discovered, header-validated, key-validated and '
      'registered with their literal metadata and declared rule names.';

  static const String reason =
      'The host has no JavaScript runtime; PicaComic used flutter_qjs '
      '(package flutter_qjs, git ref ade0b9d) invoked from '
      'lib/foundation/js_engine.dart.';

  /// Machine-readable list of what is missing, for the module UI.
  static const List<String> notPorted = [
    'ComicSourceParser rule bodies (search/category/explore/favorites)',
    'loadComic / loadComicPages script bodies',
    'getImageLoadingConfig / getThumbnailLoadingConfig script bodies',
    'comments loader and sender script bodies',
    'Convert helpers (md5/sha1/sha256/base64) and Network.* script bindings',
  ];
}
