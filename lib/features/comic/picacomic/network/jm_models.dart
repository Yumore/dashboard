import 'package:dashboard/features/comic/picacomic/core/base_comic.dart';
import 'package:dashboard/features/comic/picacomic/network/jm_image_urls.dart';

/// 禁漫天堂 API DTOs, ported from
/// PicaComic lib/network/jm_network/jm_models.dart.
///
/// The DTOs of one source are kept in a single file (PicaComic grouped them the
/// same way); every screen/controller still gets its own file.
class JmComicBrief extends BaseComic {
  JmComicBrief(
    this.id,
    this.author,
    this.name,
    this.description,
    this.categories,
  );

  @override
  final String id;

  /// Author display name; may be empty.
  final String author;

  /// Comic title (`name` on the wire).
  final String name;

  @override
  final String description;

  final List<ComicCategoryInfo> categories;

  @override
  List<String> get tags => categories.map((e) => e.name).toList();

  @override
  String get cover => JmImageUrls.cover(id);

  @override
  String get subTitle => author;

  @override
  String get title => name;
}

/// A `category` / `category_sub` pair entry.
class ComicCategoryInfo {
  const ComicCategoryInfo(this.id, this.name);

  final String id;
  final String name;
}

/// `/promote` response: the home page rows.
class HomePageData {
  HomePageData(this.items);

  final List<HomePageItem> items;
}

/// One home page row; [category] is `item['type'] != 'promote'`.
class HomePageItem {
  HomePageItem(this.name, this.id, this.comics, this.category);

  final String name;
  final String id;
  final List<JmComicBrief> comics;
  final bool category;
}

/// A paged `promote_list` result.
class PromoteList {
  PromoteList(this.id, this.comics);

  final String id;
  final List<JmComicBrief> comics;
  int loaded = 0;
  int total = 1;
  int page = 0;
}

/// One entry of `/categories`; an empty slug becomes `"0"`.
class JmCategory {
  JmCategory(this.name, String slug, this.subCategories) : slug = slug == '' ? '0' : slug;

  final String name;
  final String slug;
  final List<JmSubCategory> subCategories;
}

class JmSubCategory {
  const JmSubCategory(this.cid, this.name, this.slug);

  final String cid;
  final String name;
  final String slug;
}

/// `/album` response.
class JmComicInfo {
  JmComicInfo(
    this.name,
    this.id,
    this.author,
    this.description,
    this.likes,
    this.views,
    this.series,
    this.tags,
    this.relatedComics,
    this.liked,
    this.favorite,
    this.comments,
    this.epNames,
  );

  final String name;
  final String id;
  final List<String> author;
  final String description;
  final int likes;
  final int views;
  final int comments;

  /// Chapter ordinal (1 based) -> chapter id.
  final Map<int, String> series;
  final List<String> tags;
  final List<JmComicBrief> relatedComics;
  final bool liked;
  final bool favorite;
  final List<String> epNames;

  String get firstAuthor => author.isEmpty ? '' : author.first;

  JmComicBrief toBrief() =>
      JmComicBrief(id, firstAuthor, name, description, const []);
}
