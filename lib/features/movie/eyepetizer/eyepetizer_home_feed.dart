import 'package:dashboard/features/movie/eyepetizer/eyepetizer_item.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_issue_entity.dart';

/// The home feed's real list-shaping rules, extracted from
/// `module_home/lib/viewmodel/home_page_model.dart` so they can be asserted
/// without a widget.
///
/// The source did three non-obvious things on the first page:
/// 1. `doLoadMoreDataProcess` stripped every `banner2` row out of the issue;
/// 2. it put those rows into the carousel *instead of* the list;
/// 3. it seeded the list with an empty placeholder item so the carousel could
///    be the `ListView`'s first child.
///
/// Consequence (kept deliberately): the first page's ordinary videos appear in
/// the carousel only; the list starts at the second page.
class EyepetizerHomeFeed {
  const EyepetizerHomeFeed({
    this.banner = const <EyepetizerItem>[],
    this.items = const <EyepetizerItem>[],
    this.nextPageUrl,
  });

  /// Rows shown by the banner carousel.
  final List<EyepetizerItem> banner;

  /// Rows shown by the list, index 0 being the placeholder.
  final List<EyepetizerItem> items;

  final String? nextPageUrl;

  /// `banner2` rows are carousel material, never list rows.
  static List<EyepetizerItem> visibleItems(List<EyepetizerItem> source) =>
      source.where((item) => !item.isBanner).toList(growable: false);

  /// First page: carousel from the first issue, list seeded with a placeholder.
  factory EyepetizerHomeFeed.firstPage(EyepetizerIssueEntity entity) {
    final rows = visibleItems(entity.itemList);
    return EyepetizerHomeFeed(
      banner: rows,
      items: <EyepetizerItem>[const EyepetizerItem.placeholder()],
      nextPageUrl: entity.nextPageUrl,
    );
  }

  /// Load-more page: append the next issue's non-banner rows.
  EyepetizerHomeFeed appendPage(EyepetizerIssueEntity entity) =>
      EyepetizerHomeFeed(
        banner: banner,
        items: <EyepetizerItem>[...items, ...visibleItems(entity.itemList)],
        nextPageUrl: entity.nextPageUrl,
      );
}
