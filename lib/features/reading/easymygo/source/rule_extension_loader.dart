import 'dart:convert';

import 'package:dashboard/features/reading/easymygo/entity/extension_data.dart';
import 'package:dashboard/features/reading/easymygo/entity/extension_info.dart';
import 'package:dashboard/features/reading/easymygo/entity/source_data.dart';
import 'package:dashboard/features/reading/easymygo/entity/source_type.dart';
import 'package:dashboard/features/reading/easymygo/rule/rule_exception.dart';
import 'package:dashboard/features/reading/easymygo/source/extension_loader.dart';
import 'package:dashboard/features/reading/easymygo/source/rule_source_loader.dart';

/// The port's replacement for EasyMyGo's JS extension package.
///
/// EasyMyGo's `js` extension loader was an unimplemented stub: JS plugins really
/// arrived as `.mygopack` archives (a zip with a `manifest.json` and one folder
/// per source loader type). The host has no unzip dependency, so the port keeps
/// the same manifest contract as plain JSON:
///
/// ```json
/// {
///   "package": "com.example.rules",
///   "label": "示例规则包",
///   "version_name": "1.0",
///   "version_code": 1,
///   "lib_version": 1,
///   "sources": [ { ...a rule source descriptor... } ]
/// }
/// ```
///
/// The version gate (`libVersionMin` / `libVersionMax` → '插件版本过旧！' /
/// '纯纯 Mygo 版本过旧，请升级版本！') is ported verbatim from
/// `MygopackExtensionLoader.load`.
class RuleExtensionLoader extends ExtensionLoader {
  RuleExtensionLoader({RuleSourceLoader? sourceLoader})
    : sourceLoader = sourceLoader ?? RuleSourceLoader.instance;

  final RuleSourceLoader sourceLoader;
  final Map<String, ExtensionInfo> _infos = <String, ExtensionInfo>{};
  final Map<String, List<Object?>> _rawSources = <String, List<Object?>>{};

  @override
  ExtensionLoaderType get type => ExtensionLoaderType.js;

  @override
  ExtensionInfo? parse(String raw) {
    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException catch (error) {
      throw RuleException('扩展包 JSON 解析失败: ${error.message}');
    }
    final map = _asMap(decoded);
    final package = '${map['package'] ?? map['from_package'] ?? ''}'.trim();
    if (package.isEmpty) {
      throw const RuleException('扩展包缺少 package');
    }
    final rawSources = map['sources'] as List<Object?>? ?? const <Object?>[];
    final info = ExtensionInfo(
      fromPackage: package,
      label: '${map['label'] ?? map['name'] ?? package}',
      versionName: '${map['version_name'] ?? '1.0'}',
      versionCode: (map['version_code'] as num?)?.toInt() ?? 1,
      libVersion:
          (map['lib_version'] as num?)?.toInt() ?? ExtensionLoader.libVersionMax,
      loadType: ExtensionLoaderType.js,
      readme: '${map['readme'] ?? ''}',
      sources: <SourceType>[
        for (final source in rawSources)
          SourceType.fromName('${_asMap(source)['type'] ?? 'manga'}'),
      ],
    );
    _infos[package] = info;
    _rawSources[package] = rawSources;
    return info;
  }

  @override
  ExtensionData load(ExtensionInfo info) {
    if (info.libVersion < ExtensionLoader.libVersionMin) {
      return ExtensionData(
        info: info,
        state: ExtensionLoadState.error,
        errorMsg: '插件版本过旧！',
      );
    }
    if (info.libVersion > ExtensionLoader.libVersionMax) {
      return ExtensionData(
        info: info,
        state: ExtensionLoadState.error,
        errorMsg: '纯纯 Mygo 版本过旧，请升级版本！',
      );
    }
    final sources = <SourceData>[];
    for (final raw in _rawSources[info.fromPackage] ?? const <Object?>[]) {
      try {
        final sourceInfo = sourceLoader.parseDefinition(info.fromPackage, raw);
        sources.add(sourceLoader.load(sourceInfo));
      } catch (error) {
        continue;
      }
    }
    return ExtensionData(info: info, sources: sources);
  }
}

Map<String, Object?> _asMap(Object? value) {
  if (value is Map) {
    return <String, Object?>{
      for (final entry in value.entries) '${entry.key}': entry.value,
    };
  }
  return const <String, Object?>{};
}
