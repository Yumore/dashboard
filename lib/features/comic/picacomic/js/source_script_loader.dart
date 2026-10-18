import 'package:dashboard/features/comic/picacomic/core/comic_source.dart';
import 'package:dashboard/features/comic/picacomic/core/comic_source_loader.dart';
import 'package:dashboard/features/comic/picacomic/js/comic_source_parse_exception.dart';
import 'package:dashboard/features/comic/picacomic/js/source_script_descriptor.dart';
import 'package:dashboard/features/comic/picacomic/js/source_script_parser.dart';

/// One `.js` file offered to the loader.
///
/// PicaComic read `${dataPath}/comic_source/*.js` from disk; the host takes the
/// file contents as data so the loader stays testable without a filesystem.
class SourceScriptEntry {
  final String filePath;
  final String content;

  const SourceScriptEntry({required this.filePath, required this.content});
}

/// Ports PicaComic's user-source half of `ComicSource.init()`.
///
/// Sources whose header or key is invalid are rejected exactly like the
/// original (header check, `^[a-zA-Z0-9_]+$` key check, duplicate-key check)
/// and reported through [errors]; their rule bodies are not executed.
class SourceScriptLoader implements ComicSourceLoader {
  SourceScriptLoader({required this.entries, this.existingKeys = const {}});

  final List<SourceScriptEntry> entries;

  /// Keys already registered by built-in sources, checked for duplicates.
  final Set<String> existingKeys;

  final List<ComicSourceParseException> errors = [];

  /// Descriptors that passed validation, in input order.
  final List<ComicSourceScriptRegistration> registrations = [];

  @override
  Future<List<ComicSource>> load() async {
    final sources = <ComicSource>[];
    final seen = <String>{...existingKeys};
    for (final entry in entries) {
      if (!entry.filePath.endsWith('.js')) continue;
      try {
        final descriptor = const SourceScriptParser().parse(
          entry.content,
          filePath: entry.filePath,
        );
        final key = descriptor.key;
        if (key == null) {
          throw ComicSourceParseException('key is required');
        }
        if (!descriptor.hasValidKey) {
          throw ComicSourceParseException('key $key is invalid');
        }
        if (descriptor.name == null) {
          throw ComicSourceParseException('name is required');
        }
        if (!seen.add(key)) {
          throw ComicSourceParseException('key($key) already exists');
        }
        final source = ComicSource(
          name: descriptor.name!,
          key: key,
          filePath: entry.filePath,
          url: descriptor.url ?? '',
          version: descriptor.version ?? '1.0.0',
          matchBriefIdReg: descriptor.matchBriefIdRegex,
          data: <String, dynamic>{
            'jsExecutionSupported': false,
            'unsupportedRules': descriptor.rules
                .map((rule) => rule.kind.scriptName)
                .toList(),
          },
        );
        sources.add(source);
        registrations.add(
          ComicSourceScriptRegistration(descriptor, source),
        );
      } on ComicSourceParseException catch (error) {
        errors.add(error);
      }
    }
    return sources;
  }
}

/// Pairs a parsed script with the registered [ComicSource].
class ComicSourceScriptRegistration {
  final SourceScriptDescriptor descriptor;
  final ComicSource source;

  const ComicSourceScriptRegistration(this.descriptor, this.source);
}
