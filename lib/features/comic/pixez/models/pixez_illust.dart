import '../pixez_json.dart';
import 'pixez_illust_meta_page.dart';
import 'pixez_illust_meta_single_page.dart';
import 'pixez_illust_tag.dart';
import 'pixez_image_urls.dart';
import 'pixez_user.dart';

/// An illust/manga work from `/v1/illust/*` and search responses.
class PixezIllust {
  const PixezIllust({
    required this.id,
    required this.title,
    required this.type,
    required this.imageUrls,
    required this.caption,
    required this.restrict,
    required this.user,
    required this.tags,
    required this.tools,
    required this.createDate,
    required this.pageCount,
    required this.width,
    required this.height,
    required this.sanityLevel,
    required this.xRestrict,
    required this.metaPages,
    required this.totalView,
    required this.totalBookmarks,
    required this.isBookmarked,
    required this.visible,
    required this.isMuted,
    required this.illustAiType,
    this.metaSinglePage,
  });

  final int id;
  final String title;
  final String type;
  final PixezImageUrls imageUrls;
  final String caption;
  final int restrict;
  final PixezUser user;
  final List<PixezIllustTag> tags;
  final List<String> tools;
  final String createDate;
  final int pageCount;
  final int width;
  final int height;
  final int sanityLevel;
  final int xRestrict;
  final PixezIllustMetaSinglePage? metaSinglePage;
  final List<PixezIllustMetaPage> metaPages;
  final int totalView;
  final int totalBookmarks;
  final bool isBookmarked;
  final bool visible;
  final bool isMuted;
  final int illustAiType;

  bool get isManga => type == 'manga';

  /// Original image when the work has a single page, otherwise the large
  /// thumbnail. Mirrors the source's detail-page fallback.
  String get displayImageUrl =>
      metaSinglePage?.originalImageUrl ?? imageUrls.large;

  factory PixezIllust.fromJson(Map<String, dynamic> json) {
    return PixezIllust(
      id: pixezInt(json['id']),
      title: pixezString(json['title']),
      type: pixezString(json['type']),
      imageUrls: PixezImageUrls.fromJson(pixezMap(json['image_urls'])),
      caption: pixezString(json['caption']),
      restrict: pixezInt(json['restrict']),
      user: PixezUser.fromJson(pixezMap(json['user'])),
      tags: [
        for (final tag in pixezMapList(json['tags']))
          PixezIllustTag.fromJson(tag),
      ],
      tools: pixezStringList(json['tools']),
      createDate: pixezString(json['create_date']),
      pageCount: pixezInt(json['page_count']),
      width: pixezInt(json['width']),
      height: pixezInt(json['height']),
      sanityLevel: pixezInt(json['sanity_level']),
      xRestrict: pixezInt(json['x_restrict']),
      metaSinglePage: json['meta_single_page'] == null
          ? null
          : PixezIllustMetaSinglePage.fromJson(
              pixezMap(json['meta_single_page']),
            ),
      metaPages: [
        for (final page in pixezMapList(json['meta_pages']))
          PixezIllustMetaPage.fromJson(page),
      ],
      totalView: pixezInt(json['total_view']),
      totalBookmarks: pixezInt(json['total_bookmarks']),
      isBookmarked: pixezBool(json['is_bookmarked']),
      visible: pixezBool(json['visible'], fallback: true),
      isMuted: pixezBool(json['is_muted']),
      illustAiType: pixezInt(json['illust_ai_type']),
    );
  }
}
