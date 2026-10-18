/// The outcome of evaluating one [RuleEndpoint].
///
/// Scalar fields land in [values]; list rules land in [lists] as one map per
/// matched item. Keeping both halves separate mirrors EasyMyGo's
/// `<Entity>Resp` payloads, which always paired detail fields with a list.
class RuleResult {
  const RuleResult({
    this.values = const <String, String>{},
    this.lists = const <String, List<Map<String, String>>>{},
  });

  final Map<String, String> values;
  final Map<String, List<Map<String, String>>> lists;

  String value(String name) => values[name] ?? '';

  String? optional(String name) {
    final found = values[name];
    if (found == null || found.isEmpty) return null;
    return found;
  }

  List<Map<String, String>> list(String name) =>
      lists[name] ?? const <Map<String, String>>[];

  Map<String, String?> first(String name) {
    final rows = list(name);
    if (rows.isEmpty) return const <String, String?>{};
    return rows.first;
  }

  bool get isEmpty =>
      values.values.every((e) => e.isEmpty) &&
      lists.values.every((e) => e.isEmpty);

  @override
  String toString() => 'RuleResult(values: $values, lists: $lists)';
}
