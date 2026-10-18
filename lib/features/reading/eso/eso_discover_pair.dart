/// 一本书（一个源）里的一对「分类名 → 规则」（移植 eso `api.dart` 的 `DiscoverPair`）。
class EsoDiscoverPair {
  const EsoDiscoverPair(this.name, this.value);

  final String name;
  final String value;

  @override
  bool operator ==(Object other) =>
      other is EsoDiscoverPair && other.name == name && other.value == value;

  @override
  int get hashCode => Object.hash(name, value);
}
