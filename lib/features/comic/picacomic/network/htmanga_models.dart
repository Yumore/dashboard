import 'package:dashboard/features/comic/picacomic/core/base_comic.dart';

/// 紳士漫畫 (wnacg) DTOs, ported from
/// PicaComic lib/network/htmanga_network/models.dart.
class HtHomePageData {
  const HtHomePageData(this.comics, this.links);

  /// One comic list per home page block, in DOM order.
  final List<List<HtComicBrief>> comics;

  /// Section title -> absolute link, in DOM order.
  final Map<String, String> links;
}

class HtComicBrief extends BaseComic {
  const HtComicBrief(
    this.name,
    this.time,
    this.image,
    this.id,
    this.pages, {
    this.favoriteId,
  });

  final String name;

  /// Upload time string, as scraped (may keep surrounding whitespace).
  final String time;
  final String image;
  final int pages;

  @override
  final String id;

  /// Present only for entries coming from a favourite folder listing.
  final String? favoriteId;

  @override
  String get cover => image;

  @override
  String get description => time;

  @override
  String get subTitle => id;

  @override
  List<String> get tags => const [];

  @override
  String get title => name;
}

class HtComicInfo {
  const HtComicInfo(
    this.id,
    this.coverPath,
    this.name,
    this.category,
    this.pages,
    this.tags,
    this.description,
    this.uploader,
    this.avatar,
    this.uploadNum,
    this.thumbnails,
  );

  final String id;
  final String coverPath;
  final String name;
  final String category;
  final int pages;

  /// Tag label -> tag link.
  final Map<String, String> tags;
  final String description;
  final String uploader;
  final String avatar;
  final int uploadNum;
  final List<String> thumbnails;

  HtComicBrief toBrief() => HtComicBrief(name, '', coverPath, id, pages);

  Map<String, dynamic> toJson() => {
    'id': id,
    'coverPath': coverPath,
    'name': name,
    'category': category,
    'pages': pages,
    'tags': tags,
    'description': description,
    'uploader': uploader,
    'avatar': avatar,
    'uploadNum': uploadNum,
  };
}
