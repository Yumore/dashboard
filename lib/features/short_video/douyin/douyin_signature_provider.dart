/// `/share/item/list` 的 `_signature` 来源。
///
/// 源工程 `flutter_app/lib/config/api.dart` 把一个过期签名写死在 URL 与请求
/// 头里，没有生成算法。宿主只把这枚字符串抽象成可注入的提供者：
/// * 默认 [DouyinStaleSignature] 返回源码里的那个值，原样请求会 403；
/// * 真正能签的调用方实现本接口注入自己的算法（宿主不伪造签名）。
abstract class DouyinSignatureProvider {
  const DouyinSignatureProvider();

  /// 是否具备可发送的签名值。为 false 时客户端直接抛
  /// `DouyinSignatureRejected`，不会发出没有签名的请求。
  bool get isSupported => true;

  /// 返回要放进 `_signature` 参数/请求头的签名串。
  Future<String> signature();
}
