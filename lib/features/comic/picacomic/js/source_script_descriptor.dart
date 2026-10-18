import 'package:dashboard/features/comic/picacomic/js/js_rule_entry.dart';
import 'package:dashboard/features/comic/picacomic/js/js_rule_kind.dart';

/// Statically extracted description of a user-authored JS comic source.
///
/// PicaComic executed the script in QuickJS and read `name`, `key`, `version`,
/// `url` and `comic.matchBriefIdRegex` off the instance. With no JS runtime in
/// the host only literal declarations can be recovered, so every field except
/// [className], [filePath] and [rules] is nullable.
class SourceScriptDescriptor {
  /// Class name taken from `class X extends ComicSource`.
  final String className;

  final String filePath;

  /// The raw script, kept so the original rule bodies remain available.
  final String script;

  final String? name;
  final String? key;
  final String? version;
  final String? url;
  final String? minAppVersion;
  final String? matchBriefIdRegex;

  /// Rule methods that were found in the class body, in source order.
  final List<JsRuleEntry> rules;

  const SourceScriptDescriptor({
    required this.className,
    required this.filePath,
    required this.script,
    required this.rules,
    this.name,
    this.key,
    this.version,
    this.url,
    this.minAppVersion,
    this.matchBriefIdRegex,
  });

  /// Whether the script declares a given rule method.
  bool implementsRule(JsRuleKind kind) =>
      rules.any((rule) => rule.kind == kind);

  /// Every declared rule method needs the absent JS runtime, so this port can
  /// register the source but not run it.
  bool get requiresJsRuntime => rules.isNotEmpty;

  /// `key` is required by PicaComic and must be alphanumeric/underscore.
  bool get hasValidKey => key != null && RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(key!);

  @override
  String toString() => 'SourceScriptDescriptor($className, key: $key)';
}
