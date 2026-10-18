import '../pixez_json.dart';

/// `GET /v2/illust/bookmark/detail` `bookmark_detail`.
class PixezBookmarkDetail {
  const PixezBookmarkDetail({
    required this.isBookmarked,
    required this.restrict,
    required this.tags,
  });

  final bool isBookmarked;
  final String restrict;
  final List<String> tags;

  factory PixezBookmarkDetail.fromJson(Map<String, dynamic> json) {
    return PixezBookmarkDetail(
      isBookmarked: pixezBool(json['is_bookmarked']),
      restrict: pixezString(json['restrict'], fallback: 'public'),
      tags: [
        for (final tag in pixezMapList(json['tags']))
          pixezString(tag['name']),
      ],
    );
  }
}
