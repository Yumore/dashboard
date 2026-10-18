import 'package:dashboard/features/reading/easymygo/rule/rule_expr.dart';
import 'package:dashboard/features/reading/easymygo/rule/rule_scope.dart';

/// One named value a parse rule pulls out of a response.
class RuleField {
  const RuleField({required this.name, required this.expr});

  final String name;
  final RuleExpr expr;

  String evaluate(RuleScope scope) => expr.evaluate(scope);

  Map<String, Object?> toJson() => <String, Object?>{
    'name': name,
    'expr': expr.toJson(),
  };

  factory RuleField.fromJson(Map<String, Object?> json) {
    final name = '${json['name'] ?? ''}'.trim();
    return RuleField(name: name, expr: RuleExpr.fromJson(json['expr']));
  }
}
