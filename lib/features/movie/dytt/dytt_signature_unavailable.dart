/// 电影天堂签名不可用。
///
/// 这是迁移记录里的真实缺口：源工程的 `KeyUtils` 通过
/// `MethodChannel('com.bzh.dytt/key_utils')` 调用原生 `getHeaderKey`，
/// 真正的算法在 `libkey-lib.so` 中，Dart/Java 源码都推导不出来。
class DyttSignatureUnavailable implements Exception {
  const DyttSignatureUnavailable([this.reason = defaultReason]);

  static const String defaultReason =
      '源站的 x-header-request-key 由原生库 '
      'com.bzh.dytt/key_utils.getHeaderKey() 生成，宿主未内置该 .so，'
      'Dart 侧无法推导。';

  /// 具体原因，便于页面展示或测试断言。
  final String reason;

  String get message => '签名不可用：$reason';

  @override
  String toString() => message;
}
