import '../pixez_json.dart';
import 'pixez_image_urls.dart';
import 'pixez_novel_series.dart';
import 'pixez_novel_tag.dart';
import 'pixez_user.dart';

/// A novel work from `/v1/novel/recommended`, `/v2/novel/detail`, etc.
class PixezNovel {
  const PixezNovel({
    required this.id,
    required this.title,
    required this.caption,
    required this.restrict,
    required this.xRestrict,
    required this.isOriginal,
    required this.imageUrls,
    required this.createDate,
    required this.tags,
    required this.pageCount,
    required this.textLength,
    required this.user,
    required this.series,
    required this.isBookmarked,
    required this.totalBookmarks,
    required this.totalView,
    required this.visible,
    required this.totalComments,
    required this.isMuted,
    required this.isMypixivOnly,
    required this.isXRestricted,
    required this.novelAiType,
  });

  final int id;
  final String title;
  final String caption;
  final int restrict;
  final int xRestrict;
  final bool isOriginal;
  final PixezImageUrls imageUrls;
  final DateTime createDate;
  final List<PixezNovelTag> tags;
  final int pageCount;
  final int textLength;
  final PixezUser user;
  final PixezNovelSeries? series;
  final bool isBookmarked;
  final int totalBookmarks;
  final int totalView;
  final bool visible;
  final int totalComments;
  final bool isMuted;
  final bool isMypixivOnly;
  final bool isXRestricted;
  final int novelAiType;

  factory PixezNovel.fromJson(Map<String, dynamic> json) {
    return PixezNovel(
      id: pixezInt(json['id']),
      title: pixezString(json['title']),
      caption: pixezString(json['caption']),
      restrict: pixezInt(json['restrict']),
      xRestrict: pixezInt(json['x_restrict']),
      isOriginal: pixezBool(json['is_original']),
      imageUrls: PixezImageUrls.fromJson(pixezMap(json['image_urls'])),
      createDate:
          pixezDateTime(json['create_date']) ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      tags: [
        for (final tag in pixezMapList(json['tags']))
          PixezNovelTag.fromJson(tag),
      ],
      pageCount: pixezInt(json['page_count']),
      textLength: pixezInt(json['text_length']),
      user: PixezUser.fromJson(pixezMap(json['user'])),
      series: json['series'] is Map
          ? PixezNovelSeries.fromJson(pixezMap(json['series']))
          : null,
      isBookmarked: pixezBool(json['is_bookmarked']),
      totalBookmarks: pixezInt(json['total_bookmarks']),
      totalView: pixezInt(json['total_view']),
      visible: pixezBool(json['visible'], fallback: true),
      totalComments: pixezInt(json['total_comments']),
      isMuted: pixezBool(json['is_muted']),
      isMypixivOnly: pixezBool(json['is_mypixiv_only']),
      isXRestricted: pixezBool(json['is_x_restricted']),
      novelAiType: pixezInt(json['novel_ai_type']),
    );
  }
}
