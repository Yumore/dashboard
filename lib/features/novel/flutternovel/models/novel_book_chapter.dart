import 'package:dashboard/features/novel/flutternovel/models/json_read.dart';
import 'package:dashboard/features/novel/flutternovel/models/novel_chapter.dart';

/// Ported from `NovelBookChapter` in entity_novel_book_chapter.dart — the whole
/// `atoc/{sourceid}?view=chapters` catalog for one book source.
class NovelBookChapter {
  NovelBookChapter({
    this.id,
    this.name,
    this.source,
    this.book,
    this.link,
    this.chapters = const <NovelChapter>[],
    this.updated,
    this.host,
  });

  String? id;
  String? name;
  String? source;
  String? book;
  String? link;
  List<NovelChapter> chapters;
  String? updated;
  String? host;

  int get chapterCount => chapters.length;

  factory NovelBookChapter.fromJson(Map<String, dynamic> json) =>
      NovelBookChapter(
        id: readString(json, '_id'),
        name: readString(json, 'name'),
        source: readString(json, 'source'),
        book: readString(json, 'book'),
        link: readString(json, 'link'),
        chapters: readMapList(json, 'chapters')
            .map(NovelChapter.fromJson)
            .toList(),
        updated: readString(json, 'updated'),
        host: readString(json, 'host'),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    '_id': id,
    'name': name,
    'source': source,
    'book': book,
    'link': link,
    'chapters': chapters.map((chapter) => chapter.toJson()).toList(),
    'updated': updated,
    'host': host,
  };

  /// The reader stamps every chapter with the catalog's book id (the source did
  /// this with a cascade when requesting chapter content).
  NovelBookChapter withBookIdOnChapters() {
    for (var index = 0; index < chapters.length; index++) {
      chapters[index] = chapters[index].withNovelId(book);
    }
    return this;
  }
}
