/// 点赞/评论数的紧凑展示。
///
/// 源工程用 `flutter_money_formatter` 的 compact 模式；宿主没有该依赖，
/// 这里按中文习惯实现 `w`/`亿` 两级，保持展示语义一致。
class DouyinCountFormatter {
  DouyinCountFormatter._();

  static String compact(int value) {
    if (value <= 0) {
      return '0';
    }
    if (value < 10000) {
      return '$value';
    }
    if (value < 100000000) {
      return '${_trim(value / 10000)}w';
    }
    return '${_trim(value / 100000000)}亿';
  }

  static String _trim(double value) {
    if (value >= 10) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(1).replaceFirst(RegExp(r'\.0$'), '');
  }
}
