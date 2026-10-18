import 'package:dashboard/features/movie/dytt/dytt_signature.dart';
import 'package:dashboard/features/movie/dytt/dytt_signature_unavailable.dart';

/// 默认签名器：明确表示宿主无法生成源站要求的签名。
///
/// 它不会返回空串、时间戳或任何「看起来像签名」的值——调用即抛出
/// [DyttSignatureUnavailable]。`DyttApi` 默认使用它，页面在
/// [isSupported] 为 `false` 时直接展示说明并停止请求。
class DyttUnsupportedSignature implements DyttSignature {
  const DyttUnsupportedSignature();

  @override
  bool get isSupported => false;

  @override
  Future<String> sign(int timestampSeconds) async {
    throw const DyttSignatureUnavailable();
  }
}
