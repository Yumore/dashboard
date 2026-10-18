import 'package:dashboard/features/reading/eso/eso_discover_pair.dart';

/// 发现页的一个 tab 及其分类（移植 eso `api.dart` 的 `DiscoverMap`）。
class EsoDiscoverMap {
  const EsoDiscoverMap(this.name, this.pairs);

  final String name;
  final List<EsoDiscoverPair> pairs;
}
