import 'package:dashboard/features/comic/hakacomic/haka_comic_sort_type.dart';

/// Body of `POST comics/advanced-search` (`haka_comic/lib/network/models.dart:760-781`).
///
/// `categories` is only serialized when non-empty; `sort` is sent as the enum
/// *name*.
class HakaSearchPayload {
  const HakaSearchPayload({
    required this.keyword,
    required this.page,
    required this.sort,
    this.categories = const {},
  });

  final String keyword;

  final int page;

  final HakaComicSortType sort;

  final Set<String> categories;

  Map<String, dynamic> toJson() => {
    'keyword': keyword,
    'sort': sort.name,
    if (categories.isNotEmpty) 'categories': categories.toList(),
  };
}
