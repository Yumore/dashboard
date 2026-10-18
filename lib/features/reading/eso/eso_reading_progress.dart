import 'package:dashboard/features/reading/eso/eso_reading_position.dart';

/// 阅读进度换算（逐字移植 eso `lib/page/novel_page_refactor.dart` 的
/// `NovelContentTotal` + `percent` + `onSave`）。
///
/// eso 把「章索引 + 章内页码」压成一个全局百分比：整本书 = 1.0，
/// 分子是 `durContentIndex / 100000000`（一万章 × 一万页），分母按章节数换算。
class EsoReadingProgress {
  /// eso `const NovelContentTotal = 100000000; // 10000 * 10000 <==> 一万章节 * 一万页`
  static const int contentTotal = 100000000;

  /// eso `const TextConfigKey = "TextCompositionConfig";`
  static const String textConfigKey = 'TextCompositionConfig';

  /// 退位修正：避免 floor 把位置算到下一章/下一页。
  static const double epsilon = 0.0000001;

  /// 阅读位置 → 全局百分比（复原 eso 的 `percent` 闭包）。
  static double percentOf({
    required int durContentIndex,
    required int durChapterIndex,
    required int chaptersLength,
  }) {
    final p = durContentIndex / contentTotal;
    if (chaptersLength <= 0) return p;
    final ch = (p * chaptersLength).floor();
    if (ch == durChapterIndex) return p;
    return durChapterIndex / chaptersLength;
  }

  /// 全局百分比 → 阅读位置（复原 eso 的 `onSave`）。
  static EsoReadingPosition positionOf(double percent, int chaptersLength) {
    var value = percent;
    if (value > epsilon) {
      value -= epsilon;
    }
    return EsoReadingPosition(
      durContentIndex: (value * contentTotal).floor(),
      durChapterIndex:
          chaptersLength <= 0 ? 0 : (value * chaptersLength).floor(),
    );
  }
}
