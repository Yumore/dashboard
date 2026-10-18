import 'package:dashboard/features/reading/easymygo/rule/rule_field.dart';
import 'package:dashboard/features/reading/easymygo/rule/rule_list_spec.dart';
import 'package:dashboard/features/reading/easymygo/rule/rule_request.dart';

/// One business of a source: how to ask for it and how to read the answer.
///
/// This is the port's replacement for a single EasyMyGo JS component function
/// (e.g. `manga_search_search`): the request half replaces the `Http.*` call and
/// the [fields] / [lists] halves replace the JS parse body.
class RuleEndpoint {
  const RuleEndpoint({
    required this.request,
    this.fields = const <RuleField>[],
    this.lists = const <RuleListSpec>[],
    this.initialKey = '',
    this.business = '',
  });

  final RuleRequest request;
  final List<RuleField> fields;
  final List<RuleListSpec> lists;

  /// Seed paging key (`MangaGetInitKeyResp.initKey` in the original).
  final String initialKey;

  /// Business name (`home_tab`, `search`, ...) used in error messages.
  final String business;

  RuleListSpec? listSpec(String name) {
    for (final spec in lists) {
      if (spec.name == name) return spec;
    }
    return null;
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'business': business,
    'request': request.toJson(),
    'fields': fields.map((e) => e.toJson()).toList(),
    'lists': lists.map((e) => e.toJson()).toList(),
    'initial_key': initialKey,
  };

  factory RuleEndpoint.fromJson(Map<String, Object?> json) => RuleEndpoint(
    request: RuleRequest.fromJson(_asMap(json['request'])),
    fields: (json['fields'] as List<Object?>? ?? const <Object?>[])
        .map((e) => RuleField.fromJson(_asMap(e)))
        .toList(),
    lists: (json['lists'] as List<Object?>? ?? const <Object?>[])
        .map((e) => RuleListSpec.fromJson(_asMap(e)))
        .toList(),
    initialKey: '${json['initial_key'] ?? ''}',
    business: '${json['business'] ?? ''}',
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
