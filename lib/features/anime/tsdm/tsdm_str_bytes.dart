import 'dart:io';
import 'dart:typed_data';

/// Decode a zlib/deflate payload. The forum serves `deflate` when gzip is
/// disabled for a request; `package:http` only auto decodes gzip.
Uint8List zlibDecodeBytes(List<int> bytes) {
  try {
    return Uint8List.fromList(zlib.decode(bytes));
  } catch (_) {
    // Raw deflate stream without the zlib wrapper.
    try {
      return Uint8List.fromList(ZLibDecoder(raw: true).convert(bytes));
    } catch (_) {
      // Web 没有 dart:io 的 zlib，原样返回让上层按解析失败处理而不是崩溃。
      return Uint8List.fromList(bytes);
    }
  }
}

/// Parse an integer, returns null instead of throwing.
extension TsdmSafeIntParse on String {
  /// Try to parse this string as an int.
  int? parseToIntSafe() => int.tryParse(trim());
}
