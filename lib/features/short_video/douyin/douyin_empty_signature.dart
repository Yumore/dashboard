import 'package:dashboard/features/short_video/douyin/douyin_signature_provider.dart';

/// 明确表示“没有签名”的提供者：客户端不会发送 share 请求。
class DouyinEmptySignature implements DouyinSignatureProvider {
  const DouyinEmptySignature();

  @override
  bool get isSupported => false;

  @override
  Future<String> signature() async => '';
}
