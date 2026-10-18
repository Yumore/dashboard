/// 书源类型，对应 EasyMyGo `entity/source/source_info/source_info.dart` 的 `SourceType`。
enum SourceType {
  manga,
  novel;

  String get label => switch (this) {
    SourceType.manga => '漫画',
    SourceType.novel => '小说',
  };

  static SourceType fromName(String? name) {
    for (final value in SourceType.values) {
      if (value.name == name) return value;
    }
    return SourceType.manga;
  }
}
