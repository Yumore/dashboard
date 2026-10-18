import 'package:dashboard/features/novel/flutternovel/models/json_read.dart';

/// Ported from `NovelBookSource` in entity_novel_book_source.dart.
///
/// One interchangeable book source for a zhuishushenqi book (`btoc` response).
class NovelBookSource {
  NovelBookSource({
    this.id,
    this.isCharge,
    this.name,
    this.lastChapter,
    this.updated,
    this.source,
    this.link,
    this.starting,
    this.chaptersCount,
    this.host,
  });

  String? id;
  bool? isCharge;
  String? name;
  String? lastChapter;
  String? updated;
  String? source;
  String? link;
  bool? starting;
  int? chaptersCount;
  String? host;

  factory NovelBookSource.fromJson(Map<String, dynamic> json) =>
      NovelBookSource(
        id: readString(json, '_id'),
        isCharge: readBool(json, 'isCharge'),
        name: readString(json, 'name'),
        lastChapter: readString(json, 'lastChapter'),
        updated: readString(json, 'updated'),
        source: readString(json, 'source'),
        link: readString(json, 'link'),
        starting: readBool(json, 'starting'),
        chaptersCount: readInt(json, 'chaptersCount'),
        host: readString(json, 'host'),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    '_id': id,
    'isCharge': isCharge,
    'name': name,
    'lastChapter': lastChapter,
    'updated': updated,
    'source': source,
    'link': link,
    'starting': starting,
    'chaptersCount': chaptersCount,
    'host': host,
  };
}
