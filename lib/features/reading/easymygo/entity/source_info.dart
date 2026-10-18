import 'package:dashboard/features/reading/easymygo/entity/source_type.dart';

/// 书源加载方式。源工程为 `js` / `inner`；本移植把 `js` 替换为 Dart 规则源（`rule`）。
enum SourceLoaderType {
  rule,
  inner;

  static SourceLoaderType fromName(String? name) {
    for (final value in SourceLoaderType.values) {
      if (value.name == name) return value;
    }
    return SourceLoaderType.rule;
  }
}

/// 一个已注册书源的元数据，对应 EasyMyGo `SourceInfo`。
class SourceInfo {
  const SourceInfo({
    required this.key,
    required this.fromPackage,
    required this.label,
    required this.type,
    this.versionName = '1.0',
    this.versionCode = 1,
    this.path = '',
    this.loaderType = SourceLoaderType.rule,
    this.description = '',
  });

  final String key;
  final String fromPackage;
  final String label;
  final SourceType type;
  final String versionName;
  final int versionCode;
  final String path;
  final SourceLoaderType loaderType;
  final String description;

  /// 源工程标识：`"$fromPackage-|-$key"`。
  String get identify => '$fromPackage-|-$key';

  SourceInfo copyWith({
    String? key,
    String? fromPackage,
    String? label,
    SourceType? type,
    String? versionName,
    int? versionCode,
    String? path,
    SourceLoaderType? loaderType,
    String? description,
  }) {
    return SourceInfo(
      key: key ?? this.key,
      fromPackage: fromPackage ?? this.fromPackage,
      label: label ?? this.label,
      type: type ?? this.type,
      versionName: versionName ?? this.versionName,
      versionCode: versionCode ?? this.versionCode,
      path: path ?? this.path,
      loaderType: loaderType ?? this.loaderType,
      description: description ?? this.description,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'key': key,
    'from_package': fromPackage,
    'label': label,
    'type': type.name,
    'version_name': versionName,
    'version_code': versionCode,
    'path': path,
    'loader_type': loaderType.name,
    'description': description,
  };

  factory SourceInfo.fromJson(Map<String, Object?> json) => SourceInfo(
    key: '${json['key'] ?? ''}',
    fromPackage: '${json['from_package'] ?? ''}',
    label: '${json['label'] ?? ''}',
    type: SourceType.fromName(json['type'] as String?),
    versionName: '${json['version_name'] ?? '1.0'}',
    versionCode: (json['version_code'] as num?)?.toInt() ?? 1,
    path: '${json['path'] ?? ''}',
    loaderType: SourceLoaderType.fromName(json['loader_type'] as String?),
    description: '${json['description'] ?? ''}',
  );

  @override
  String toString() => 'SourceInfo($identify, $label, ${type.name})';

  @override
  bool operator ==(Object other) =>
      other is SourceInfo &&
      other.key == key &&
      other.fromPackage == fromPackage &&
      other.label == label &&
      other.type == type &&
      other.versionName == versionName &&
      other.versionCode == versionCode &&
      other.path == path &&
      other.loaderType == loaderType &&
      other.description == description;

  @override
  int get hashCode => Object.hash(
    key,
    fromPackage,
    label,
    type,
    versionName,
    versionCode,
    path,
    loaderType,
    description,
  );
}
