/// The three page-turn animations the source reader shipped.
///
/// Values match the source's `ReaderPageManager.TYPE_ANIMATION_*` constants and
/// are what the reader persists as the user's chosen animation mode.
class ReaderAnimationType {
  ReaderAnimationType._();

  /// 仿真翻页 — the curl simulation (`SimulationTurnPageAnimation`, source 621 lines).
  static const int simulationTurn = 1;

  /// 覆盖翻页 — the cover slide (`CoverPageAnimation`, source 280 lines).
  static const int coverTurn = 2;

  /// 滑动翻页 — the vertical scroll (`SlidePageAnimation`, source 208 lines).
  static const int slideTurn = 3;

  static const List<int> all = <int>[simulationTurn, coverTurn, slideTurn];

  static String label(int mode) => switch (mode) {
    coverTurn => '覆盖',
    slideTurn => '滑动',
    _ => '仿真',
  };
}
