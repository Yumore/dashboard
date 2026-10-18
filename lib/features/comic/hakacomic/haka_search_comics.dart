import 'package:dashboard/features/comic/hakacomic/haka_search_comic.dart';

/// Paging envelope of search hits (`haka_comic/lib/network/models.dart:863-875`).
class HakaSearchComics {
  const HakaSearchComics({
    required this.docs,
    required this.total,
    required this.limit,
    required this.page,
    required this.pages,
  });

  final List<HakaSearchComic> docs;

  final int total;

  final int limit;

  final int page;

  final int pages;

  factory HakaSearchComics.fromJson(Map<String, dynamic> json) {
    return HakaSearchComics(
      docs: (json['docs'] as List<dynamic>)
          .map(
            (item) => HakaSearchComic.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      total: json['total'] as int,
      limit: json['limit'] as int,
      page: json['page'] as int,
      pages: json['pages'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'docs': docs.map((doc) => doc.toJson()).toList(),
    'total': total,
    'limit': limit,
    'page': page,
    'pages': pages,
  };
}
