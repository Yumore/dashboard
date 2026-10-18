import 'dart:convert';

import 'package:dashboard/features/reading/easymygo/entity/source_info.dart';
import 'package:dashboard/features/reading/easymygo/entity/source_type.dart';
import 'package:dashboard/features/reading/easymygo/rule/rule_endpoint.dart';
import 'package:dashboard/features/reading/easymygo/rule/rule_exception.dart';
import 'package:dashboard/features/reading/easymygo/rule/rule_source_definition.dart';

/// Hand-written parser for a rule-source descriptor.
///
/// EasyMyGo loaded these from `.mygopack` archives (`MygopackManifest`) and from
/// plain JS files; the host has neither a zip nor a JS dependency, so the same
/// descriptor is accepted here as JSON and turned into a [RuleSourceDefinition].
///
/// Shape:
///
/// ```json
/// {
///   "key": "example", "label": "Example", "type": "manga",
///   "from_package": "com.example.rules", "base_url": "https://example.com",
///   "version_name": "1.0", "version_code": 1,
///   "endpoints": {
///     "search": {
///       "initial_key": "1",
///       "request": {"url": "${baseUrl}/search?q=${keyword}&p=${key}"},
///       "lists": [{"name": "covers", "item_selector": ".item",
///                  "fields": [{"name": "id", "expr":
///                    {"action": "HtmlQuerySelector", "func": "attr",
///                     "constructor": [{"var": "item"}, "a"], "args": ["href"]}}]}]
///     }
///   }
/// }
/// ```
class RuleDefinitionParser {
  const RuleDefinitionParser();

  RuleSourceDefinition parseString(String source) {
    final Object? decoded;
    try {
      decoded = jsonDecode(source);
    } on FormatException catch (e) {
      throw RuleException('书源 JSON 解析失败: ${e.message}');
    }
    return parse(decoded);
  }

  RuleSourceDefinition parse(Object? json) {
    final map = _asMap(json);
    final key = '${map['key'] ?? ''}'.trim();
    if (key.isEmpty) throw const RuleException('书源缺少 key');
    final label = '${map['label'] ?? map['name'] ?? ''}'.trim();
    if (label.isEmpty) throw const RuleException('书源缺少 label');
    final endpoints = map['endpoints'] is Map
        ? _asMap(map['endpoints'])
        : map;
    final info = SourceInfo(
      key: key,
      fromPackage: '${map['from_package'] ?? 'rule'}',
      label: label,
      type: SourceType.fromName('${map['type'] ?? 'manga'}'),
      versionName: '${map['version_name'] ?? '1.0'}',
      versionCode: (map['version_code'] as num?)?.toInt() ?? 1,
      loaderType: SourceLoaderType.rule,
      description: '${map['description'] ?? ''}',
    );
    RuleEndpoint? endpoint(String business) {
      final raw = endpoints[business];
      if (raw == null) return null;
      final parsed = RuleEndpoint.fromJson(_asMap(raw));
      return RuleEndpoint(
        request: parsed.request,
        fields: parsed.fields,
        lists: parsed.lists,
        initialKey: parsed.initialKey,
        business: business,
      );
    }

    return RuleSourceDefinition(
      info: info,
      baseUrl: '${map['base_url'] ?? map['baseUrl'] ?? ''}',
      homeTab: endpoint('home_tab'),
      secondTab: endpoint('second_tab'),
      homePage: endpoint('home_page'),
      homeCovers: endpoint('home_covers'),
      search: endpoint('search'),
      detail: endpoint('detail'),
      chapters: endpoint('chapters'),
      read: endpoint('read'),
      volumes: endpoint('volumes'),
    );
  }
}

Map<String, Object?> _asMap(Object? value) {
  if (value is Map) {
    return <String, Object?>{
      for (final entry in value.entries) '${entry.key}': entry.value,
    };
  }
  throw RuleException('期望 JSON 对象，实际是 ${value.runtimeType}');
}
