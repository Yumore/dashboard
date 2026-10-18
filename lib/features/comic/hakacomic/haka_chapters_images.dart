import 'package:dashboard/features/comic/hakacomic/haka_chapter_image.dart';

/// Page envelope of `comics/{id}/order/{order}/pages`
/// (`haka_comic/lib/network/models.dart:1028-1052`).
class HakaChaptersImages {
  const HakaChaptersImages({
    required this.docs,
    required this.total,
    required this.limit,
    required this.page,
    required this.pages,
  });

  final List<HakaChapterImage> docs;

  final int total;

  final int limit;

  final int page;

  /// Drives the `page=2..pages` fan-out in `fetchChapterImages`.
  final int pages;

  factory HakaChaptersImages.fromJson(Map<String, dynamic> json) {
    return HakaChaptersImages(
      docs: (json['docs'] as List<dynamic>)
          .map(
            (item) => HakaChapterImage.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      total: json['total'] as int,
      limit: json['limit'] as int,
      page: json['page'] as int,
      pages: json['pages'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'docs': docs.map((image) => image.toJson()).toList(),
    'total': total,
    'limit': limit,
    'page': page,
    'pages': pages,
  };
}
