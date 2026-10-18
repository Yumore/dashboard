/// 规则解析异常：书源规则写错或依赖宿主未移植的能力时抛出。
class EsoRuleException implements Exception {
  const EsoRuleException(this.message, {this.rule});

  final String message;
  final String? rule;

  @override
  String toString() =>
      rule == null ? 'EsoRuleException: $message' : 'EsoRuleException: $message (规则: $rule)';
}
