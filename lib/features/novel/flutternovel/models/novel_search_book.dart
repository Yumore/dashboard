import 'package:dashboard/features/novel/flutternovel/models/json_read.dart';
import 'package:dashboard/features/novel/flutternovel/models/novel_highlight.dart';

/// Ported from `Books` in entity_novel_book_key_word_search.dart — one hit of
/// the `book/fuzzy-search` response.
class NovelSearchBook {
  NovelSearchBook({
    this.id,
    this.hasCp,
    this.title,
    this.aliases,
    this.cat,
    this.author,
    this.site,
    this.cover,
    this.shortIntro,
    this.lastChapter,
    this.retentionRatio,
    this.banned,
    this.allowMonthly,
    this.latelyFollower,
    this.wordCount,
    this.contentType,
    this.superscript,
    this.sizetype,
    this.highlight,
  });

  String? id;
  bool? hasCp;
  String? title;
  String? aliases;
  String? cat;
  String? author;
  String? site;
  String? cover;
  String? shortIntro;
  String? lastChapter;
  double? retentionRatio;
  int? banned;
  bool? allowMonthly;
  int? latelyFollower;
  int? wordCount;
  String? contentType;
  String? superscript;
  int? sizetype;
  NovelHighlight? highlight;

  factory NovelSearchBook.fromJson(Map<String, dynamic> json) =>
      NovelSearchBook(
        id: readString(json, '_id'),
        hasCp: readBool(json, 'hasCp'),
        title: readString(json, 'title'),
        aliases: readString(json, 'aliases'),
        cat: readString(json, 'cat'),
        author: readString(json, 'author'),
        site: readString(json, 'site'),
        cover: readString(json, 'cover'),
        shortIntro: readString(json, 'shortIntro'),
        lastChapter: readString(json, 'lastChapter'),
        retentionRatio: readDouble(json, 'retentionRatio'),
        banned: readInt(json, 'banned'),
        allowMonthly: readBool(json, 'allowMonthly'),
        latelyFollower: readInt(json, 'latelyFollower'),
        wordCount: readInt(json, 'wordCount'),
        contentType: readString(json, 'contentType'),
        superscript: readString(json, 'superscript'),
        sizetype: readInt(json, 'sizetype'),
        highlight: json['highlight'] is Map
            ? NovelHighlight.fromJson(
                (json['highlight'] as Map).cast<String, dynamic>(),
              )
            : null,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    '_id': id,
    'hasCp': hasCp,
    'title': title,
    'aliases': aliases,
    'cat': cat,
    'author': author,
    'site': site,
    'cover': cover,
    'shortIntro': shortIntro,
    'lastChapter': lastChapter,
    'retentionRatio': retentionRatio,
    'banned': banned,
    'allowMonthly': allowMonthly,
    'latelyFollower': latelyFollower,
    'wordCount': wordCount,
    'contentType': contentType,
    'superscript': superscript,
    'sizetype': sizetype,
    'highlight': highlight?.toJson(),
  };
}
