import 'package:dashboard/features/comic/hakacomic/haka_doc.dart';

/// Paging envelope of a comic list
/// (`haka_comic/lib/network/models.dart:269-280`).
class HakaComics {
  const HakaComics({
    required this.docs,
    required this.limit,
    required this.page,
    required this.pages,
    required this.total,
  });

  final List<HakaDoc> docs;

  final int limit;

  final int page;

  /// Total number of pages — drives `loadMore` cut-off.
  final int pages;

  final int total;

  factory HakaComics.fromJson(Map<String, dynamic> json) {
    return HakaComics(
      docs: (json['docs'] as List<dynamic>)
          .map((item) => HakaDoc.fromJson(item as Map<String, dynamic>))
          .toList(),
      limit: json['limit'] as int,
      page: json['page'] as int,
      pages: json['pages'] as int,
      total: json['total'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'docs': docs.map((doc) => doc.toJson()).toList(),
    'limit': limit,
    'page': page,
    'pages': pages,
    'total': total,
  };
}
