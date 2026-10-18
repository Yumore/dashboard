import 'dart:math';

/// 源工程 `lib/src/common/constants/utils.dart` 的 `formatBytes`。
///
/// 下载对话框用它显示体积：1024 进制、`decimals` 位小数、单位表到 YB；
/// 注意 `bytes == 0` 时源工程直接返回 `'0.0'`（**没有单位**），移植版保留
/// 这个细节。
class FeedbooksFormat {
  const FeedbooksFormat._();

  /// 单位表，顺序照抄源工程。
  static const List<String> sizes = <String>[
    'Bytes',
    'KB',
    'MB',
    'GB',
    'TB',
    'PB',
    'EB',
    'ZB',
    'YB',
  ];

  static String formatBytes(int bytes, int decimals) {
    if (bytes == 0) return '0.0';
    const int k = 1024;
    final int dm = decimals <= 0 ? 0 : decimals;
    final int i = (log(bytes) / log(k)).floor();
    return '${(bytes / pow(k, i)).toStringAsFixed(dm)} ${sizes[i]}';
  }
}
