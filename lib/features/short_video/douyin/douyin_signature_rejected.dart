import 'package:dashboard/features/short_video/douyin/douyin_stale_signature.dart';

/// `/share/item/list` 拒绝签名（HTTP 403）或根本没有可用签名。
///
/// 这是迁移文档里记录的源站失败模式：源工程硬编码的 `_signature` 已过期，
/// 原样请求必然 403。宿主把它显式化，UI 才能解释“为什么用户作品列表为空”。
class DouyinSignatureRejected implements Exception {
  const DouyinSignatureRejected({
    this.statusCode = 403,
    this.signature = DouyinStaleSignature.staleSignature,
    this.reason = '',
  });

  static const String defaultMessage =
      '抖音公开接口拒绝了 _signature（HTTP 403）。源工程 '
      'flutter_app/lib/config/api.dart 硬编码了过期签名，按源工程设计 live 请求就会 403；'
      '注入可用的 DouyinSignatureProvider 后才能恢复该接口。';

  final int statusCode;
  final String signature;
  final String reason;

  String get message =>
      reason.isEmpty ? defaultMessage : '$defaultMessage（$reason）';

  @override
  String toString() => message;
}
