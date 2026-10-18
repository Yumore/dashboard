/// Ported from `lib/plugin/component/api/payload/component_payload.dart`.
///
/// Every component call carries one of these so failures stay explicit.
class ComponentPayload {
  const ComponentPayload({this.code = 0, this.msg = '', this.raw});

  const ComponentPayload.ok() : this();

  /// Runtime / plugin crash.
  static const int codeCallError = -10086;

  /// The response could not be parsed into the expected entity.
  static const int codeParseResultError = -10085;

  /// The source itself reported a business failure.
  static const int codeBusinessError = -10084;

  final int code;
  final String msg;

  /// The unparsed source data, kept for diagnostics.
  final Object? raw;

  bool get isError => code != 0;

  /// Ported from `ComponentPayloadExt.errorMsg` — including the original's
  /// trailing space and its prefixing rules.
  String get errorMsg => switch (code) {
    codeCallError => '调用错误 $msg',
    codeParseResultError => '解析错误 $msg',
    codeBusinessError => msg,
    _ => '未知错误 $code $msg',
  };

  @override
  String toString() => 'ComponentPayload($code, $msg)';
}
