import 'package:dashboard/features/reading/easymygo/entity/source_type.dart';

/// 扩展包加载方式，对应 EasyMyGo `ExtensionLoaderType`。
enum ExtensionLoaderType {
  js,
  mygopack,
  inner;

  static ExtensionLoaderType fromName(String? name) {
    for (final value in ExtensionLoaderType.values) {
      if (value.name == name) return value;
    }
    return ExtensionLoaderType.mygopack;
  }
}

/// 扩展包元数据，对应 EasyMyGo `ExtensionInfo`（含注入源描述）。
class ExtensionInfo {
  const ExtensionInfo({
    required this.fromPackage,
    this.label = '',
    this.versionName = '1.0',
    this.versionCode = 1,
    this.libVersion = 1,
    this.loadType = ExtensionLoaderType.mygopack,
    this.readme = '',
    this.sources = const <SourceType>[],
  });

  final String fromPackage;
  final String label;
  final String versionName;
  final int versionCode;
  final int libVersion;
  final ExtensionLoaderType loadType;
  final String readme;
  final List<SourceType> sources;

  Map<String, Object?> toJson() => <String, Object?>{
    'from_package': fromPackage,
    'label': label,
    'version_name': versionName,
    'version_code': versionCode,
    'lib_version': libVersion,
    'load_type': loadType.name,
    'readme': readme,
    'sources': sources.map((e) => e.name).toList(),
  };

  factory ExtensionInfo.fromJson(Map<String, Object?> json) => ExtensionInfo(
    fromPackage: '${json['from_package'] ?? ''}',
    label: '${json['label'] ?? ''}',
    versionName: '${json['version_name'] ?? '1.0'}',
    versionCode: (json['version_code'] as num?)?.toInt() ?? 1,
    libVersion: (json['lib_version'] as num?)?.toInt() ?? 1,
    loadType: ExtensionLoaderType.fromName(json['load_type'] as String?),
    readme: '${json['readme'] ?? ''}',
    sources: (json['sources'] as List<Object?>? ?? const <Object?>[])
        .map((e) => SourceType.fromName(e as String?))
        .toList(),
  );
}
