import 'package:dashboard/features/reading/easymygo/rule/rule_field.dart';

/// How a list rule locates its items.
enum RuleListMode {
  /// [RuleListSpec.itemSelector] is a CSS selector over the HTML body.
  html,

  /// [RuleListSpec.itemSelector] is a JSONPath over the decoded JSON body.
  json;

  static RuleListMode fromName(String? name) {
    for (final value in RuleListMode.values) {
      if (value.name == name) return value;
    }
    return RuleListMode.html;
  }
}

/// The list form of a parse rule — covers, chapters, volumes and pictures.
///
/// For every matched item the engine puts the item source under the `item`
/// variable and evaluates [fields] against it, so a field selector stays
/// relative to the item instead of the whole page.
class RuleListSpec {
  const RuleListSpec({
    required this.name,
    required this.itemSelector,
    this.mode = RuleListMode.html,
    this.fields = const <RuleField>[],
  });

  final String name;
  final String itemSelector;
  final RuleListMode mode;
  final List<RuleField> fields;

  Map<String, Object?> toJson() => <String, Object?>{
    'name': name,
    'item_selector': itemSelector,
    'mode': mode.name,
    'fields': fields.map((e) => e.toJson()).toList(),
  };

  factory RuleListSpec.fromJson(Map<String, Object?> json) => RuleListSpec(
    name: '${json['name'] ?? ''}'.trim(),
    itemSelector: '${json['item_selector'] ?? json['selector'] ?? ''}',
    mode: RuleListMode.fromName(json['mode'] as String?),
    fields: (json['fields'] as List<Object?>? ?? const <Object?>[])
        .map((e) => RuleField.fromJson(_asMap(e)))
        .toList(),
  );
}

Map<String, Object?> _asMap(Object? value) {
  if (value is Map) {
    return <String, Object?>{
      for (final entry in value.entries) '${entry.key}': entry.value,
    };
  }
  return const <String, Object?>{};
}
