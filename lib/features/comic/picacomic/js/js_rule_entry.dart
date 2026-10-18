import 'package:dashboard/features/comic/picacomic/js/js_rule_kind.dart';

/// One rule method discovered in a user JS source, with its 1-based line.
class JsRuleEntry {
  final JsRuleKind kind;

  /// Name as declared in the script (e.g. `loadComic` or `"loadComic"`).
  final String declaredName;

  final int line;

  const JsRuleEntry({
    required this.kind,
    required this.declaredName,
    required this.line,
  });

  @override
  String toString() => '${kind.scriptName}@$line';
}
