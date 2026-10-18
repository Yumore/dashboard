import 'package:dashboard/features/movie/dytt/dytt_signature.dart';

/// 构造源站要求的三个请求头。
///
/// 与 `lib/networkapi.dart` 的 `getHeader()` 逐项对应：
/// 时间戳取毫秒数除以 1000 后向上取整，签名与时间戳来自同一次计算，
/// IMEI 固定为空串。
class DyttHeaders {
  DyttHeaders({required this.signature, DateTime Function()? now})
    : _now = now ?? DateTime.now;

  static const String timestampHeader = 'x-header-request-timestamp';
  static const String keyHeader = 'x-header-request-key';
  static const String imeiHeader = 'x-header-request-imei';

  final DyttSignature signature;
  final DateTime Function() _now;

  /// 与源站一致：`(millisecondsSinceEpoch / 1000).ceil()`。
  static int timestampSeconds(DateTime time) =>
      (time.millisecondsSinceEpoch / 1000).ceil();

  Future<Map<String, String>> build() async {
    final seconds = timestampSeconds(_now());
    final key = await signature.sign(seconds);
    return <String, String>{
      timestampHeader: '$seconds',
      keyHeader: key,
      imeiHeader: '',
    };
  }
}
