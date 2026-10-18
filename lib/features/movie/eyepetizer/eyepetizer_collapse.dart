/// The category detail app-bar collapse rule.
///
/// Port of `module_discover/lib/page/category_detail_page.dart`:
/// ```dart
/// void changeExpendStatusByOffset(int statusBarHeight, int offset) {
///   if (offset > statusBarHeight && offset < 250) {
///     if (!expend) { expend = true; setState(() {}); }
///   } else {
///     if (expend) { expend = false; setState(() {}); }
///   }
/// }
/// ```
/// The source called it *during build* with the `SliverAppBar`'s live height,
/// which is why the title flips between white and black as the header
/// collapses. The port keeps the arithmetic and turns the mutation into a pure
/// query, so no `setState` happens inside `build`.
class EyepetizerCollapse {
  const EyepetizerCollapse._();

  /// The upper bound the source hard-coded (`offset < 250`).
  static const double maxExpandedHeight = 250;

  /// The toolbar height the source added to the status bar
  /// (`MediaQuery.of(context).padding.top + 56`).
  static const double toolbarHeight = 56;

  /// True while the header is still tall enough to need a light title.
  static bool showsLightTitle({
    required double height,
    required double collapseThreshold,
  }) => height > collapseThreshold && height < maxExpandedHeight;

  /// The `collapseThreshold` the source passed: status bar + toolbar.
  static double collapseThresholdFor(double statusBarHeight) =>
      statusBarHeight + toolbarHeight;
}
