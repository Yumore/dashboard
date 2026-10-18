/// 单源开关 / 排序配置，对应 EasyMyGo `SourceConfigController` 存储的 `SourceConfig`。
class SourceConfigItem {
  const SourceConfigItem({
    required this.key,
    required this.fromPackage,
    this.enabled = true,
    this.order = 999,
  });

  final String key;
  final String fromPackage;
  final bool enabled;
  final int order;

  String get identify => '$fromPackage-|-$key';

  SourceConfigItem copyWith({bool? enabled, int? order}) => SourceConfigItem(
    key: key,
    fromPackage: fromPackage,
    enabled: enabled ?? this.enabled,
    order: order ?? this.order,
  );

  Map<String, Object?> toJson() => <String, Object?>{
    'key': key,
    'from_package': fromPackage,
    'enabled': enabled,
    'order': order,
  };

  factory SourceConfigItem.fromJson(Map<String, Object?> json) => SourceConfigItem(
    key: '${json['key'] ?? ''}',
    fromPackage: '${json['from_package'] ?? ''}',
    enabled: json['enabled'] as bool? ?? true,
    order: (json['order'] as num?)?.toInt() ?? 999,
  );
}
