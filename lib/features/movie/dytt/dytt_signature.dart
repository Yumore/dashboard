/// 电影天堂请求签名器。
///
/// 源站要求每个请求带上 `x-header-request-key`，该值由 Android 原生库
/// `com.bzh.dytt/key_utils.getHeaderKey(long timestamp)` 生成。宿主没有
/// 内置对应的 `libkey-lib.so`，Dart 侧也没有可复现的算法，所以签名必须
/// 从外部注入。
///
/// 约定：传入的 [timestampSeconds] 与 `x-header-request-timestamp` 头
/// **必须是同一个值**，即 `(DateTime.now().millisecondsSinceEpoch / 1000).ceil()`。
/// 实现方不得自行取当前时间，否则服务端的时效校验会失败。
abstract class DyttSignature {
  const DyttSignature();

  /// 默认实现声称自己可用；无法签名时返回 `false`，页面据此停发请求。
  bool get isSupported => true;

  /// 返回写入 `x-header-request-key` 的签名串。
  Future<String> sign(int timestampSeconds);
}
