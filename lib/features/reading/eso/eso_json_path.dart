/// 宿主没有 `json_path` 依赖，这里实现书源规则实际用到的 JSONPath 子集：
///
/// * `$` 根、`$.a.b` 逐级取键、`$.a['b c']` 引号键
/// * `$.a[*]`、`$.a.*` 通配
/// * `$.a[0]`、`$.a[-1]` 下标
/// * `$..name` 递归下降
class EsoJsonPath {
  EsoJsonPath(this.path);

  final String path;

  static final RegExp _namePattern = RegExp(r"^[^.\[\]]+");

  /// 对应 `JsonPath(rule).readValues(ctx)`。
  List<dynamic> readValues(dynamic context) {
    final steps = _parse();
    if (steps == null) return <dynamic>[];
    var current = <dynamic>[context];
    for (final step in steps) {
      final next = <dynamic>[];
      for (final node in current) {
        step.collect(node, next);
      }
      current = next;
    }
    return current;
  }

  List<_EsoJsonPathStep>? _parse() {
    var value = path.trim();
    if (value.isEmpty) return null;
    if (!value.startsWith(r'$')) return null;
    value = value.substring(1);
    final steps = <_EsoJsonPathStep>[];
    var pos = 0;
    while (pos < value.length) {
      if (value.startsWith('..', pos)) {
        pos += 2;
        final match = _namePattern.firstMatch(value.substring(pos));
        if (match == null) return null;
        steps.add(_EsoJsonPathStep.descendant(match.group(0)!));
        pos += match.end;
        continue;
      }
      if (value[pos] == '.') {
        pos++;
        if (pos < value.length && value[pos] == '*') {
          steps.add(const _EsoJsonPathStep.wildcard());
          pos++;
          continue;
        }
        final match = _namePattern.firstMatch(value.substring(pos));
        if (match == null) return null;
        steps.add(_EsoJsonPathStep.key(match.group(0)!));
        pos += match.end;
        continue;
      }
      if (value[pos] == '[') {
        final end = value.indexOf(']', pos);
        if (end < 0) return null;
        final inner = value.substring(pos + 1, end).trim();
        pos = end + 1;
        if (inner == '*') {
          steps.add(const _EsoJsonPathStep.wildcard());
        } else if (inner.length >= 2 &&
            ((inner.startsWith("'") && inner.endsWith("'")) ||
                (inner.startsWith('"') && inner.endsWith('"')))) {
          steps.add(_EsoJsonPathStep.key(inner.substring(1, inner.length - 1)));
        } else {
          final index = int.tryParse(inner);
          if (index == null) return null;
          steps.add(_EsoJsonPathStep.index(index));
        }
        continue;
      }
      return null;
    }
    return steps;
  }
}

class _EsoJsonPathStep {
  _EsoJsonPathStep.key(this.key)
      : index = null,
        descendant = false,
        wildcard = false;
  _EsoJsonPathStep.index(this.index)
      : key = null,
        descendant = false,
        wildcard = false;
  const _EsoJsonPathStep.wildcard()
      : key = null,
        index = null,
        descendant = false,
        wildcard = true;
  _EsoJsonPathStep.descendant(this.key)
      : index = null,
        descendant = true,
        wildcard = false;

  final String? key;
  final int? index;
  final bool descendant;
  final bool wildcard;

  void collect(dynamic node, List<dynamic> out) {
    if (descendant) {
      _collectDescendant(node, out);
      return;
    }
    if (wildcard) {
      if (node is Map) {
        out.addAll(node.values);
      } else if (node is List) {
        out.addAll(node);
      }
      return;
    }
    if (index != null) {
      if (node is List) {
        var i = index!;
        if (i < 0) i += node.length;
        if (i >= 0 && i < node.length) out.add(node[i]);
      }
      return;
    }
    if (node is Map && node.containsKey(key)) out.add(node[key]);
  }

  void _collectDescendant(dynamic node, List<dynamic> out) {
    if (node is Map) {
      if (node.containsKey(key)) out.add(node[key]);
      for (final value in node.values) {
        _collectDescendant(value, out);
      }
    } else if (node is List) {
      for (final value in node) {
        _collectDescendant(value, out);
      }
    }
  }
}
