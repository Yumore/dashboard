import 'dart:ui';

/// The last size the reader laid itself out with.
///
/// The source read `ScreenUtils.getScreenWidth()/getScreenHeight()` (screenutil)
/// from static context. The host does not use screenutil, so the reader page
/// records its paint size here and the page-turn animations fall back to it
/// while no explicit size has been pushed through [ReaderPageManager].
class ReaderScreenMetrics {
  ReaderScreenMetrics._();

  static double width = 0;
  static double height = 0;

  static void update(Size size) {
    width = size.width;
    height = size.height;
  }

  static Size get size => Size(width, height);
}
