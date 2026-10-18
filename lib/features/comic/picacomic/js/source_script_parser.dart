import 'package:dashboard/features/comic/picacomic/js/comic_source_parse_exception.dart';
import 'package:dashboard/features/comic/picacomic/js/js_rule_entry.dart';
import 'package:dashboard/features/comic/picacomic/js/js_rule_kind.dart';
import 'package:dashboard/features/comic/picacomic/js/source_script_descriptor.dart';

/// Ports the static part of PicaComic's `ComicSourceParser`.
///
/// PicaComic validated the script header and then ran the whole class in
/// QuickJS. This port performs exactly the same header validation and key
/// validation, and statically recovers literal metadata plus the declared rule
/// methods; it never executes script bodies.
class SourceScriptParser {
  const SourceScriptParser();

  /// Header line required by PicaComic: `class X extends ComicSource`.
  static const String requiredHeader = 'class ';
  static const String requiredExtends = 'extends ComicSource';

  SourceScriptDescriptor parse(String js, {String filePath = ''}) {
    final normalized = js.replaceAll('\r\n', '\n');
    final headerLine = normalized
        .split('\n')
        .map((line) => line.trim())
        .firstWhere((line) => line.isNotEmpty, orElse: () => '');
    if (!headerLine.startsWith(requiredHeader) ||
        !headerLine.contains(requiredExtends)) {
      throw ComicSourceParseException('Invalid Content');
    }
    final className = headerLine
        .split(requiredHeader)[1]
        .split(requiredExtends)
        .first
        .trim();
    if (className.isEmpty) {
      throw ComicSourceParseException('Invalid Content');
    }

    final stripped = _stripComments(normalized);
    return SourceScriptDescriptor(
      className: className,
      filePath: filePath,
      script: js,
      name: _literal(stripped, 'name'),
      key: _literal(stripped, 'key'),
      version: _literal(stripped, 'version'),
      url: _literal(stripped, 'url'),
      minAppVersion: _literal(stripped, 'minAppVersion'),
      matchBriefIdRegex: _literal(stripped, 'matchBriefIdRegex'),
      rules: _discoverRules(stripped),
    );
  }

  /// Removes `//` line comments and `/* */` block comments, preserving lines.
  static String _stripComments(String source) {
    final withoutBlock = source.replaceAllMapped(
      RegExp(r'/\*.*?\*/', dotAll: true),
      (match) => '\n' * '\n'.allMatches(match.group(0)!).length,
    );
    return withoutBlock
        .split('\n')
        .map((line) {
          final index = line.indexOf('//');
          return index == -1 ? line : line.substring(0, index);
        })
        .join('\n');
  }

  /// Recovers a literal (single-quoted, double-quoted or backtick) assignment
  /// such as `key = "my_source"` or `this.key = 'my_source'`.
  static String? _literal(String source, String property) {
    final pattern = RegExp(
      '(?:^|[\\s;{,])'
      '(?:this\\.)?'
      '${RegExp.escape(property)}'
      r'\s*[:=]\s*'
      r'''(?:"([^"\n]*)"|'([^'\n]*)'|`([^`\n]*)`)''',
      multiLine: true,
    );
    final match = pattern.firstMatch(source);
    if (match == null) return null;
    return match.group(1) ?? match.group(2) ?? match.group(3);
  }

  /// Finds declared rule methods and rule data objects, in source order.
  static List<JsRuleEntry> _discoverRules(String source) {
    final entries = <JsRuleEntry>[];
    final seen = <String>{};
    final lines = source.split('\n');
    for (var index = 0; index < lines.length; index++) {
      final line = lines[index];
      final method = RegExp(
        r'^\s*(?:async\s+)?(?:static\s+)?([A-Za-z_$][\w$]*)\s*\(',
      ).firstMatch(line);
      final data = RegExp(
        r'^\s*(?:this\.)?([A-Za-z_$][\w$]*)\s*[:=]\s*[{\[]',
      ).firstMatch(line);
      final name = method?.group(1) ?? data?.group(1);
      if (name == null) continue;
      final kind = _kindFor(name);
      if (kind == null || !seen.add(name)) continue;
      entries.add(
        JsRuleEntry(kind: kind, declaredName: name, line: index + 1),
      );
    }
    return entries;
  }

  static JsRuleKind? _kindFor(String name) {
    for (final kind in JsRuleKind.values) {
      if (kind.scriptName == name) return kind;
    }
    return null;
  }
}
