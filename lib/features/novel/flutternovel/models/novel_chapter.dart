import 'package:dashboard/features/novel/flutternovel/models/json_read.dart';

/// Ported from `Chapters` in entity_novel_book_chapter.dart — one entry of the
/// `atoc/{sourceid}?view=chapters` catalog.
///
/// The source renamed the class to `NovelChapter` to avoid colliding with the
/// host's own chapter models. `novelId` is deliberately NOT read from the map:
/// the source assigned it after parsing (from the catalog's `book`), and it is
/// what the reader keys its content cache on.
class NovelChapter {
  NovelChapter({
    this.bookId,
    this.title,
    this.link,
    this.id,
    this.time,
    this.chapterCover,
    this.totalpage,
    this.partsize,
    this.order,
    this.currency,
    this.unreadble,
    this.isVip,
    this.novelId,
  });

  String? bookId;
  String? title;
  String? link;
  String? id;
  int? time;
  String? chapterCover;
  int? totalpage;
  int? partsize;
  int? order;
  int? currency;
  bool? unreadble;
  bool? isVip;
  String? novelId;

  factory NovelChapter.fromJson(Map<String, dynamic> json) => NovelChapter(
    bookId: readString(json, '_id'),
    title: readString(json, 'title'),
    link: readString(json, 'link'),
    id: readString(json, 'id'),
    time: readInt(json, 'time'),
    chapterCover: readString(json, 'chapterCover'),
    totalpage: readInt(json, 'totalpage'),
    partsize: readInt(json, 'partsize'),
    order: readInt(json, 'order'),
    currency: readInt(json, 'currency'),
    unreadble: readBool(json, 'unreadble'),
    isVip: readBool(json, 'isVip'),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    '_id': bookId,
    'title': title,
    'link': link,
    'id': id,
    'time': time,
    'chapterCover': chapterCover,
    'totalpage': totalpage,
    'partsize': partsize,
    'order': order,
    'currency': currency,
    'unreadble': unreadble,
    'isVip': isVip,
  };

  /// A copy carrying the book id the reader needs for progress + content cache.
  NovelChapter withNovelId(String? value) =>
      NovelChapter(
          bookId: bookId,
          title: title,
          link: link,
          id: id,
          time: time,
          chapterCover: chapterCover,
          totalpage: totalpage,
          partsize: partsize,
          order: order,
          currency: currency,
          unreadble: unreadble,
          isVip: isVip,
        )
        ..novelId = value;
}
