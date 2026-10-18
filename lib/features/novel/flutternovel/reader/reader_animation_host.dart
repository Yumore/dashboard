import 'dart:ui';

import 'package:dashboard/features/novel/flutternovel/reader/reader_canvas_page.dart';

/// The slice of the reader view model that the three page-turn animations need.
///
/// The source animations reached straight into `NovelReaderViewModel`. The port
/// goes through this interface instead so the animation layer can be exercised
/// with a fake host and stays independent of storage and networking.
abstract class ReaderAnimationHost {
  /// Whether another page/chapter exists after the current one.
  bool isCanGoNext();

  /// Whether another page/chapter exists before the current one.
  bool isCanGoPre();

  /// Advances one page (rolling into the next chapter when needed).
  void nextPage();

  /// Rewinds one page (rolling into the previous chapter when needed).
  void prePage();

  /// The page currently shown, or null while it is still being rendered.
  ReaderCanvasPage? getCurrentPage();

  /// The following page, or null when there is none / it is not rendered yet.
  ReaderCanvasPage? getNextPage();

  /// The preceding page, or null when there is none / it is not rendered yet.
  ReaderCanvasPage? getPrePage();

  /// Page background paint (paper colour, configurable from the settings menu).
  Paint get bgPaint;
}
