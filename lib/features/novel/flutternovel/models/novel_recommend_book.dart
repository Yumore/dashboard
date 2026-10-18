import 'package:dashboard/features/novel/flutternovel/models/json_read.dart';

/// Ported from `Books` in entity_novel_book_recommend.dart — one entry of the
/// `book/{id}/recommend` response.
class NovelRecommendBook {
  NovelRecommendBook({
    this.id,
    this.title,
    this.author,
    this.site,
    this.cover,
    this.shortIntro,
    this.lastChapter,
    this.retentionRatio,
    this.latelyFollower,
    this.majorCate,
    this.minorCate,
    this.allowMonthly,
    this.isSerial,
    this.contentType,
    this.allowFree,
    this.otherReadRatio,
  });

  String? id;
  String? title;
  String? author;
  String? site;
  String? cover;
  String? shortIntro;
  String? lastChapter;
  double? retentionRatio;
  int? latelyFollower;
  String? majorCate;
  String? minorCate;
  bool? allowMonthly;
  bool? isSerial;
  String? contentType;
  bool? allowFree;
  double? otherReadRatio;

  factory NovelRecommendBook.fromJson(Map<String, dynamic> json) =>
      NovelRecommendBook(
        id: readString(json, '_id'),
        title: readString(json, 'title'),
        author: readString(json, 'author'),
        site: readString(json, 'site'),
        cover: readString(json, 'cover'),
        shortIntro: readString(json, 'shortIntro'),
        lastChapter: readString(json, 'lastChapter'),
        retentionRatio: readDouble(json, 'retentionRatio'),
        latelyFollower: readInt(json, 'latelyFollower'),
        majorCate: readString(json, 'majorCate'),
        minorCate: readString(json, 'minorCate'),
        allowMonthly: readBool(json, 'allowMonthly'),
        isSerial: readBool(json, 'isSerial'),
        contentType: readString(json, 'contentType'),
        allowFree: readBool(json, 'allowFree'),
        otherReadRatio: readDouble(json, 'otherReadRatio'),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    '_id': id,
    'title': title,
    'author': author,
    'site': site,
    'cover': cover,
    'shortIntro': shortIntro,
    'lastChapter': lastChapter,
    'retentionRatio': retentionRatio,
    'latelyFollower': latelyFollower,
    'majorCate': majorCate,
    'minorCate': minorCate,
    'allowMonthly': allowMonthly,
    'isSerial': isSerial,
    'contentType': contentType,
    'allowFree': allowFree,
    'otherReadRatio': otherReadRatio,
  };
}
