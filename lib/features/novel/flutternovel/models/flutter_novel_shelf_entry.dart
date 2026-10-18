import 'package:dashboard/features/novel/flutternovel/models/json_read.dart';
import 'package:dashboard/features/novel/flutternovel/models/novel_detail_info.dart';

/// A book the user put on the shelf (书架).
///
/// The host's own novel module keeps a `NovelBookInfo` per book
/// (lib/models/novel/novel_book_info.dart) and the legacy views carry a
/// `BookShelf` entity; neither is reachable from this feature folder without a
/// cross-module import, so this port keeps the shelf row flat: the book
/// identity plus the fields the shelf list actually renders.
class FlutterNovelShelfEntry {
  FlutterNovelShelfEntry({
    this.bookId = '',
    this.title = '',
    this.author = '',
    this.cover = '',
    this.sourceId = '',
    this.lastChapter = '',
    this.chaptersCount = 0,
    this.addedAt,
  });

  /// `_id` of the zhuishushenqi book, e.g. `51b1c1a5...`.
  String bookId;

  /// Book title (also the detail payload's `title`).
  String title;

  /// Author name.
  String author;

  /// Cover URL; the reader serves these through `statics.zhuishushenqi.com`.
  String cover;

  /// The `btoc` source id the chapter list was fetched from.
  String sourceId;

  /// The source's `lastChapter` string, shown as the "latest" line.
  String lastChapter;

  /// The source's `chaptersCount`.
  int chaptersCount;

  /// When the book was added (used to sort the shelf newest-first).
  DateTime? addedAt;

  /// The zhuishushenqi search/detail payload only carries `_id`.
  factory FlutterNovelShelfEntry.fromDetail(NovelDetailInfo detail) =>
      FlutterNovelShelfEntry(
        bookId: detail.id ?? '',
        title: detail.title ?? '',
        author: detail.author ?? '',
        cover: detail.cover ?? '',
        lastChapter: detail.lastChapter ?? '',
        chaptersCount: detail.chaptersCount ?? 0,
        addedAt: DateTime.now(),
      );

  /// `{"_id": ..., "title": ...}` — the source's `BookShelf` JSON keys.
  factory FlutterNovelShelfEntry.fromJson(Map<String, dynamic> json) =>
      FlutterNovelShelfEntry(
        bookId: readString(json, '_id') ?? readString(json, 'bookId') ?? '',
        title: readString(json, 'title') ?? '',
        author: readString(json, 'author') ?? '',
        cover: readString(json, 'cover') ?? '',
        sourceId: readString(json, 'sourceId') ?? '',
        lastChapter: readString(json, 'lastChapter') ?? '',
        chaptersCount: readInt(json, 'chaptersCount') ?? 0,
        addedAt: DateTime.tryParse(readString(json, 'addedAt') ?? ''),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    '_id': bookId,
    'title': title,
    'author': author,
    'cover': cover,
    'sourceId': sourceId,
    'lastChapter': lastChapter,
    'chaptersCount': chaptersCount,
    'addedAt': addedAt?.toIso8601String(),
  };

  /// Flat map for the sqflite row (one column per field).
  Map<String, dynamic> toMap() => <String, dynamic>{
    'book_id': bookId,
    'title': title,
    'author': author,
    'cover': cover,
    'source_id': sourceId,
    'last_chapter': lastChapter,
    'chapters_count': chaptersCount,
    'added_at': addedAt?.millisecondsSinceEpoch,
  };

  factory FlutterNovelShelfEntry.fromMap(Map<String, dynamic> map) {
    final added = map['added_at'];
    return FlutterNovelShelfEntry(
      bookId: '${map['book_id'] ?? ''}',
      title: '${map['title'] ?? ''}',
      author: '${map['author'] ?? ''}',
      cover: '${map['cover'] ?? ''}',
      sourceId: '${map['source_id'] ?? ''}',
      lastChapter: '${map['last_chapter'] ?? ''}',
      chaptersCount: readInt(map, 'chapters_count') ?? 0,
      addedAt: added is int
          ? DateTime.fromMillisecondsSinceEpoch(added)
          : DateTime.tryParse('$added'),
    );
  }

  FlutterNovelShelfEntry copyWith({
    String? bookId,
    String? title,
    String? author,
    String? cover,
    String? sourceId,
    String? lastChapter,
    int? chaptersCount,
    DateTime? addedAt,
  }) => FlutterNovelShelfEntry(
    bookId: bookId ?? this.bookId,
    title: title ?? this.title,
    author: author ?? this.author,
    cover: cover ?? this.cover,
    sourceId: sourceId ?? this.sourceId,
    lastChapter: lastChapter ?? this.lastChapter,
    chaptersCount: chaptersCount ?? this.chaptersCount,
    addedAt: addedAt ?? this.addedAt,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FlutterNovelShelfEntry &&
          bookId == other.bookId &&
          title == other.title &&
          author == other.author &&
          cover == other.cover;

  @override
  int get hashCode => Object.hash(bookId, title, author, cover);

  @override
  String toString() => 'FlutterNovelShelfEntry($bookId, $title)';
}
