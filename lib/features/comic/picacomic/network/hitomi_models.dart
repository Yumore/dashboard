import 'package:dashboard/features/comic/picacomic/core/base_comic.dart';
import 'package:dashboard/features/comic/picacomic/core/history_mixin.dart';
import 'package:dashboard/features/comic/picacomic/core/history_type.dart';

/// Ports PicaComic lib/network/hitomi_network/hitomi_models.dart.

class Tag {
  Tag(this.name, this.link);

  String name;
  String link;
}

class HitomiComicBrief extends BaseComic {
  HitomiComicBrief(
    this.name,
    this.type,
    this.lang,
    this.tagList,
    this.time,
    this.artist,
    this.link,
    this.cover,
  );

  String name;
  String type;
  String lang;
  List<Tag> tagList;
  String time;
  String artist;
  String link;

  @override
  String cover;

  @override
  String get description => lang;

  @override
  String get id => link;

  @override
  String get subTitle => artist;

  @override
  List<String> get tags => tagList.map((e) => e.name).toList();

  @override
  String get title => name;

  @override
  bool get enableTagsTranslation => true;
}

/// A paginated window into a `.nozomi` id list
/// (hitomi_main_network.dart:52-66).
class ComicList {
  ComicList(this.url);

  /// Data source url.
  String url;

  /// Byte offset to resume from.
  int toLoad = 0;

  /// Total bytes, learned from the `Content-Range` header.
  int total = 100;

  List<int> comicIds = [];
}

class HitomiFile {
  HitomiFile(
    this.name,
    this.hash,
    this.hasWebp,
    this.hasAvif,
    this.height,
    this.width,
    this.galleryId,
  );

  HitomiFile.fromMap(Map<String, dynamic> map)
      : name = map['name'] as String,
        hash = map['hash'] as String,
        hasWebp = map['hasWebp'] as bool,
        hasAvif = map['hasAvif'] as bool,
        height = map['height'] as int,
        width = map['width'] as int,
        galleryId = map['galleryId'] as String;

  String name;
  String hash;
  bool hasWebp;
  bool hasAvif;
  int height;
  int width;
  String galleryId;

  Map<String, dynamic> toMap() => {
    'name': name,
    'hash': hash,
    'hasWebp': hasWebp,
    'hasAvif': hasAvif,
    'height': height,
    'width': width,
    'galleryId': galleryId,
  };
}

class HitomiComic with HistoryMixin {
  HitomiComic(
    this.id,
    this.name,
    this.related,
    this.type,
    this.artists,
    this.lang,
    this.tags,
    this.time,
    this.files,
    this.group,
    this.cover,
  ) {
    // hitomi_models.dart:124-130.
    if (group.isEmpty) {
      group.add('N/A');
    }
    if (artists == null || artists!.isEmpty) {
      artists = ['N/A'];
    }
  }

  HitomiComic.fromMap(Map<String, dynamic> map)
      : id = map['id'] as String,
        name = map['name'] as String,
        type = map['type'] as String,
        artists = List<String>.from(map['artists'] as List),
        lang = map['lang'] as String,
        time = map['time'] as String,
        tags = [],
        related = [],
        group = [],
        cover = '',
        files = List.generate(
          (map['files'] as List).length,
          (index) => HitomiFile.fromMap(
            (map['files'] as List)[index] as Map<String, dynamic>,
          ),
        );

  String id;
  String name;
  List<int> related;
  String type;
  List<String>? artists;
  String lang;
  List<Tag> tags;
  String time;
  List<HitomiFile> files;
  List<String> group;

  @override
  final String cover;

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'type': type,
    'artists': artists,
    'lang': lang,
    'time': time,
    'files': List<Map<String, dynamic>>.generate(
      files.length,
      (index) => files[index].toMap(),
    ),
  };

  HitomiComicBrief toBrief(String link, String cover) => HitomiComicBrief(
    name,
    type,
    lang,
    tags,
    time,
    (artists ?? ['未知']).isEmpty ? '未知' : (artists ?? ['未知'])[0],
    link,
    cover,
  );

  @override
  HistoryType get historyType => HistoryType.hitomi;

  @override
  String get subTitle => (artists == null || artists!.isEmpty)
      ? ''
      : artists!.first;

  @override
  String get target => id;

  @override
  String get title => name;
}

/// Home/popular `.nozomi` endpoints
/// (hitomi_main_network.dart:184-204).
class HitomiDataUrls {
  static const String homePageAll = 'https://ltn.hitomi.la/index-all.nozomi';
  static const String homePageCn = 'https://ltn.hitomi.la/index-chinese.nozomi';
  static const String homePageJp = 'https://ltn.hitomi.la/index-japanese.nozomi';
  static const String homePageEn = 'https://ltn.hitomi.la/index-english.nozomi';
  static const String todayPopular =
      'https://ltn.hitomi.la/popular/today-all.nozomi';
  static const String weekPopular =
      'https://ltn.hitomi.la/popular/week-all.nozomi';
  static const String monthPopular =
      'https://ltn.hitomi.la/popular/month-all.nozomi';
  static const String yearPopular =
      'https://ltn.hitomi.la/popular/year-all.nozomi';
}
