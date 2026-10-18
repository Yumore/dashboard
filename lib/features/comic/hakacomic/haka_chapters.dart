import 'package:dashboard/features/comic/hakacomic/haka_chapter.dart';

/// Chapter paging envelope (`haka_comic/lib/network/models.dart:465-489`).
class HakaChapters {
  const HakaChapters({
    required this.docs,
    required this.total,
    required this.limit,
    required this.page,
    required this.pages,
  });

  final List<HakaChapter> docs;

  final int total;

  final int limit;

  final int page;

  /// Page count used by `fetchChapters` to fan out `page=2..pages`.
  final int pages;

  factory HakaChapters.fromJson(Map<String, dynamic> json) {
    return HakaChapters(
      docs: (json['docs'] as List<dynamic>)
          .map((item) => HakaChapter.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      limit: json['limit'] as int,
      page: json['page'] as int,
      pages: json['pages'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'docs': docs.map((chapter) => chapter.toJson()).toList(),
    'total': total,
    'limit': limit,
    'page': page,
    'pages': pages,
  };
}
