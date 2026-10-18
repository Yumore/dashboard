import 'package:dashboard/features/short_video/douyin/douyin_signature_provider.dart';

/// 源工程硬编码的签名。
///
/// 出处：`flutter_app/lib/config/api.dart` 的
/// `_signature=pKb.ogAgEB9ImoSQahoqJKSm.rAAPox`。
/// 该值在源工程提交时就已过期，源工程自己的 live 请求同样会 403；
/// 默认提供者保留它，是为了让失败模式保持与源工程一致、并能在错误信息里
/// 明确指出“签名过期”，而不是悄悄请求失败。
class DouyinStaleSignature implements DouyinSignatureProvider {
  const DouyinStaleSignature();

  static const String staleSignature = 'pKb.ogAgEB9ImoSQahoqJKSm.rAAPox';

  @override
  bool get isSupported => true;

  @override
  Future<String> signature() async => staleSignature;
}
