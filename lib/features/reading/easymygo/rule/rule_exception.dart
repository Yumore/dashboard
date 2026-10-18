/// Raised by the rule engine and by rule actions.
///
/// The original threw from inside the JS runtime (`flutter_js`) and surfaced the
/// crash through `ComponentPayload.codeCallError`; the port keeps the same
/// failure channel with a typed Dart exception.
class RuleException implements Exception {
  const RuleException(this.message);

  final String message;

  @override
  String toString() => 'RuleException: $message';
}
