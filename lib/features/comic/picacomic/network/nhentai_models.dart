import 'package:dashboard/features/comic/picacomic/core/base_comic.dart';
import 'package:dashboard/features/comic/picacomic/core/history_mixin.dart';
import 'package:dashboard/features/comic/picacomic/core/history_type.dart';

/// Ports PicaComic lib/network/nhentai_network/models.dart.

class NhentaiComicBrief extends BaseComic {
  const NhentaiComicBrief(this.title, this.cover, this.id, this.lang, this.tags);

  @override
  final String title;
  @override
  final String cover;
  @override
  final String id;
  final String lang;
  @override
  final List<String> tags;

  @override
  String get description => lang;

  @override
  String get subTitle => id;

  @override
  bool get enableTagsTranslation => true;
}

class NhentaiHomePageData {
  NhentaiHomePageData(this.popular, this.latest);

  final List<NhentaiComicBrief> popular;
  List<NhentaiComicBrief> latest;
  int page = 1;
}

class NhentaiComic with HistoryMixin {
  NhentaiComic(
    this.id,
    this.title,
    this.subTitle,
    this.cover,
    this.tags,
    this.favorite,
    this.thumbnails,
    this.recommendations,
    this.token,
  );

  NhentaiComic.fromMap(Map<String, dynamic> map)
      : id = map['id'] as String,
        title = map['title'] as String,
        subTitle = map['subTitle'] as String,
        cover = map['cover'] as String,
        tags = {},
        favorite = false,
        thumbnails = [],
        recommendations = [],
        token = '';

  String id;
  @override
  String title;
  @override
  String subTitle;
  @override
  String cover;
  Map<String, List<String>> tags;
  bool favorite;
  List<String> thumbnails;
  List<NhentaiComicBrief> recommendations;
  String token;

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'subTitle': subTitle,
    'cover': cover,
  };

  @override
  HistoryType get historyType => HistoryType.nhentai;

  @override
  String get target => id;
}

class NhentaiComment {
  NhentaiComment(this.userName, this.avatar, this.content, this.date);

  String userName;
  String avatar;
  String content;
  int date;
}

/// nhentai_main_network.dart:485-512 — the `&sort=` suffix used in search and
/// category urls.
enum NhentaiSort {
  recent(''),
  popularToday('&sort=popular-today'),
  popularWeek('&sort=popular-week'),
  popularMonth('&sort=popular-month'),
  popularAll('&sort=popular');

  const NhentaiSort(this.value);

  final String value;

  static NhentaiSort fromValue(String value) {
    switch (value) {
      case '':
        return NhentaiSort.recent;
      case '&sort=popular-today':
        return NhentaiSort.popularToday;
      case '&sort=popular-week':
        return NhentaiSort.popularWeek;
      case '&sort=popular-month':
        return NhentaiSort.popularMonth;
      case '&sort=popular':
        return NhentaiSort.popularAll;
      default:
        return NhentaiSort.recent;
    }
  }
}
