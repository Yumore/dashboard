import 'package:dashboard/features/movie/dytt/dytt_signature.dart';
import 'package:dashboard/features/movie/dytt/dytt_signature_unavailable.dart';
import 'package:flutter/services.dart';

/// 照搬源工程 `lib/keyutil.dart` 的签名器。
///
/// 通道名、方法名和参数都与源站一致：`com.bzh.dytt/key_utils` /
/// `getHeaderKey` / 秒级时间戳。宿主没有注册这个通道，也没有打包
/// `libkey-lib.so`，所以它只适用于「以后把原生库补进宿主」的场景；
/// `DyttApi` 的默认签名器仍是 [DyttUnsupportedSignature]。
///
/// 原生库缺失时统一转成 [DyttSignatureUnavailable]，页面会显示
/// 「签名不可用」，而不是拿空签名去请求。
class DyttChannelSignature extends DyttSignature {
  const DyttChannelSignature();

  static const MethodChannel channel = MethodChannel('com.bzh.dytt/key_utils');

  static const String method = 'getHeaderKey';

  @override
  Future<String> sign(int timestampSeconds) async {
    try {
      final key = await channel.invokeMethod<String>(method, timestampSeconds);
      if (key == null || key.isEmpty) {
        throw const DyttSignatureUnavailable(
          '原生 getHeaderKey 返回了空值，无法作为 x-header-request-key。',
        );
      }
      return key;
    } on MissingPluginException {
      throw const DyttSignatureUnavailable(
        '宿主没有注册 com.bzh.dytt/key_utils 通道，也没有 libkey-lib.so。',
      );
    } on PlatformException catch (error) {
      throw DyttSignatureUnavailable(
        '原生 getHeaderKey 调用失败：${error.message ?? error.code}',
      );
    }
  }
}
