/// 阅读位置：章索引 + 章内进度（移植 eso 的 `durChapterIndex` / `durContentIndex`）。
class EsoReadingPosition {
  const EsoReadingPosition({
    required this.durChapterIndex,
    required this.durContentIndex,
  });

  final int durChapterIndex;
  final int durContentIndex;

  @override
  bool operator ==(Object other) =>
      other is EsoReadingPosition &&
      other.durChapterIndex == durChapterIndex &&
      other.durContentIndex == durContentIndex;

  @override
  int get hashCode => Object.hash(durChapterIndex, durContentIndex);

  @override
  String toString() => 'EsoReadingPosition($durChapterIndex, $durContentIndex)';
}
