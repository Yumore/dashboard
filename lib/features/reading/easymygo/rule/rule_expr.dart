import 'package:dashboard/features/reading/easymygo/rule/rule_exception.dart';
import 'package:dashboard/features/reading/easymygo/rule/rule_scope.dart';
import 'package:dashboard/features/reading/easymygo/rule/source_action.dart';

/// A rule expression — the Dart port of one EasyMyGo JS expression.
///
/// EasyMyGo sources were JS functions; every parse rule was an expression tree
/// built from literals, the `Buffer`, source variables and action calls such as
/// `HtmlQuerySelector(html, '.title').text()`. That tree is modelled here so a
/// rule source stays declarative after the JS runtime is removed.
sealed class RuleExpr {
  const RuleExpr();

  String evaluate(RuleScope scope);

  Map<String, Object?> toJson();

  /// Parses the three JSON forms a rule source may use:
  ///
  /// ```json
  /// "plain literal"
  /// {"var": "keyword"}
  /// {"action": "HtmlQuerySelector", "func": "text",
  ///  "constructor": [{"var": "body"}, ".title"], "args": []}
  /// ```
  static RuleExpr fromJson(Object? json) {
    if (json is String) return RuleLiteral(json);
    if (json is num || json is bool) return RuleLiteral('$json');
    if (json is Map) {
      final map = <String, Object?>{
        for (final entry in json.entries) '${entry.key}': entry.value,
      };
      if (map.containsKey('literal')) return RuleLiteral('${map['literal']}');
      if (map.containsKey('var')) return RuleVariable('${map['var']}');
      final clazz = map['action'] ?? map['clazz'];
      if (clazz != null) {
        final action = SourceAction.of('$clazz');
        final constructorArgs = _list(map['constructor']);
        final args = _list(map['args']);
        if (constructorArgs.length != action.constructorArgsCount) {
          throw RuleException(
            '${action.clazz} 构造参数应为 ${action.constructorArgsCount} 个，'
            '实际 ${constructorArgs.length} 个',
          );
        }
        final funcName = '${map['func'] ?? ''}';
        if (!action.funcNames.contains(funcName)) {
          throw RuleException('${action.clazz} 不支持 $funcName');
        }
        return RuleActionCall(
          action: action,
          funcName: funcName,
          constructorArgs: constructorArgs,
          args: args,
        );
      }
    }
    throw RuleException('无法解析规则表达式: $json');
  }

  static List<RuleExpr> _list(Object? json) {
    if (json == null) return const <RuleExpr>[];
    if (json is! List) throw const RuleException('规则参数必须是数组');
    return json.map(RuleExpr.fromJson).toList();
  }
}

/// A constant string baked into the rule.
class RuleLiteral extends RuleExpr {
  const RuleLiteral(this.value);

  final String value;

  @override
  String evaluate(RuleScope scope) => value;

  @override
  Map<String, Object?> toJson() => <String, Object?>{'literal': value};
}

/// Reads `scope.variables[name]` — the port of a JS free variable lookup.
class RuleVariable extends RuleExpr {
  const RuleVariable(this.name);

  final String name;

  @override
  String evaluate(RuleScope scope) => scope.get(name) ?? '';

  @override
  Map<String, Object?> toJson() => <String, Object?>{'var': name};
}

/// Calls one [SourceAction] method — the port of `Clazz(ctor...).func(args...)`.
class RuleActionCall extends RuleExpr {
  const RuleActionCall({
    required this.action,
    required this.funcName,
    this.constructorArgs = const <RuleExpr>[],
    this.args = const <RuleExpr>[],
  });

  final SourceAction action;
  final String funcName;
  final List<RuleExpr> constructorArgs;
  final List<RuleExpr> args;

  @override
  String evaluate(RuleScope scope) {
    final constructorValues = constructorArgs
        .map((e) => e.evaluate(scope))
        .toList();
    final argValues = args.map((e) => e.evaluate(scope)).toList();
    return action.execute(scope, funcName, constructorValues, argValues);
  }

  @override
  Map<String, Object?> toJson() => <String, Object?>{
    'action': action.clazz,
    'func': funcName,
    'constructor': constructorArgs.map((e) => e.toJson()).toList(),
    'args': args.map((e) => e.toJson()).toList(),
  };
}
