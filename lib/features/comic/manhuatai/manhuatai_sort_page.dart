import 'package:dashboard/features/comic/manhuatai/manhuatai_json.dart';

/// Paging block of `getsortlist`.
///
/// Source: `lib/models/sort_list.dart` → `Page`.
class ManhuataiSortPage {
  const ManhuataiSortPage({
    required this.currentPage,
    required this.totalPage,
    required this.orderby,
    required this.count,
    required this.comicSort,
    required this.searchKey,
    required this.time,
  });

  final int currentPage;
  final int totalPage;
  final String orderby;
  final int count;
  final String comicSort;
  final String searchKey;
  final int time;

  /// The next page to request, or `null` when the last page is reached.
  int? get nextPage => currentPage < totalPage ? currentPage + 1 : null;

  factory ManhuataiSortPage.fromJson(Map<String, dynamic> json) {
    final source = ManhuataiJson.map(json);
    return ManhuataiSortPage(
      currentPage: ManhuataiJson.asInt(source['current_page']),
      totalPage: ManhuataiJson.asInt(source['total_page']),
      orderby: ManhuataiJson.asString(source['orderby']),
      count: ManhuataiJson.asInt(source['count']),
      comicSort: ManhuataiJson.asString(source['comic_sort']),
      searchKey: ManhuataiJson.asString(source['search_key']),
      time: ManhuataiJson.asInt(source['time']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'current_page': currentPage,
        'total_page': totalPage,
        'orderby': orderby,
        'count': count,
        'comic_sort': comicSort,
        'search_key': searchKey,
        'time': time,
      };
}
