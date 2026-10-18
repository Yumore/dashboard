import 'package:dashboard/features/comic/manhuatai/manhuatai_json.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_sort_item.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_sort_page.dart';

/// Response of `getsortlist` — the category/sort browse endpoint.
///
/// Source: `lib/models/sort_list.dart` → `SortList`.
class ManhuataiSortList {
  const ManhuataiSortList({
    required this.page,
    required this.data,
  });

  final ManhuataiSortPage page;
  final List<ManhuataiSortItem> data;

  static const ManhuataiSortList empty = ManhuataiSortList(
    page: ManhuataiSortPage(
      currentPage: 0,
      totalPage: 0,
      orderby: '',
      count: 0,
      comicSort: '',
      searchKey: '',
      time: 0,
    ),
    data: <ManhuataiSortItem>[],
  );

  factory ManhuataiSortList.fromJson(Map<String, dynamic> json) {
    final source = ManhuataiJson.map(json);
    return ManhuataiSortList(
      page: ManhuataiSortPage.fromJson(ManhuataiJson.map(source['page'])),
      data: ManhuataiJson.maps(source['data'])
          .map(ManhuataiSortItem.fromJson)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'page': page.toJson(),
        'data': data.map((item) => item.toJson()).toList(),
      };
}
