import 'package:dashboard/features/comic/picacomic/core/comic_source.dart';

/// Contract for supplying user-authored comic sources to the registry.
///
/// PicaComic scanned `${dataPath}/comic_source/*.js` and executed them in a
/// QuickJS engine. The host has no JS runtime, so the concrete implementation
/// (`js/source_script_loader.dart`) parses the declarative metadata block in
/// Dart and reports the executable rule bodies as unsupported.
abstract class ComicSourceLoader {
  Future<List<ComicSource>> load();
}
