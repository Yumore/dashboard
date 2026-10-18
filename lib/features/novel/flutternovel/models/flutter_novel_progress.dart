import 'package:dashboard/features/novel/flutternovel/models/json_read.dart';

/// Where the reader left a book.
///
/// The source persisted this through `helper_db.dart` (a `ChapterReadProgress`
/// row keyed by book id). The port keeps the source's chapter-position model
/// (`chapterIndex` into the catalog's flat chapter list) and adds the page
/// index inside that chapter so the reader can restore the exact page.
class FlutterNovelProgress {
  FlutterNovelProgress({
    this.bookId = '',
    this.chapterIndex = 0,
    this.pageIndex = 0,
    this.chapterId = '',
    this.chapterTitle = '',
    this.updatedAt,
  });

  /// The zhuishushenqi book id (`_id`).
  String bookId;

  /// Index into [NovelBookChapter.chapters] (the source's `chapterIndex`).
  int chapterIndex;

  /// Page index inside the paginated chapter.
  int pageIndex;

  /// The `atoc` chapter id at that position (cheap staleness check).
  String chapterId;

  /// Chapter title, so the shelf can show "读到 X 章" without fetching.
  String chapterTitle;

  /// Last write time.
  DateTime? updatedAt;

  factory FlutterNovelProgress.fromJson(Map<String, dynamic> json) =>
      FlutterNovelProgress(
        bookId: readString(json, 'bookId') ?? '',
        chapterIndex: readInt(json, 'chapterIndex') ?? 0,
        pageIndex: readInt(json, 'pageIndex') ?? 0,
        chapterId: readString(json, 'chapterId') ?? '',
        chapterTitle: readString(json, 'chapterTitle') ?? '',
        updatedAt: DateTime.tryParse(readString(json, 'updatedAt') ?? ''),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'bookId': bookId,
    'chapterIndex': chapterIndex,
    'pageIndex': pageIndex,
    'chapterId': chapterId,
    'chapterTitle': chapterTitle,
    'updatedAt': updatedAt?.toIso8601String(),
  };

  Map<String, dynamic> toMap() => <String, dynamic>{
    'book_id': bookId,
    'chapter_index': chapterIndex,
    'page_index': pageIndex,
    'chapter_id': chapterId,
    'chapter_title': chapterTitle,
    'updated_at': updatedAt?.millisecondsSinceEpoch,
  };

  factory FlutterNovelProgress.fromMap(Map<String, dynamic> map) {
    final updated = map['updated_at'];
    return FlutterNovelProgress(
      bookId: '${map['book_id'] ?? ''}',
      chapterIndex: readInt(map, 'chapter_index') ?? 0,
      pageIndex: readInt(map, 'page_index') ?? 0,
      chapterId: '${map['chapter_id'] ?? ''}',
      chapterTitle: '${map['chapter_title'] ?? ''}',
      updatedAt: updated is int
          ? DateTime.fromMillisecondsSinceEpoch(updated)
          : DateTime.tryParse('$updated'),
    );
  }

  FlutterNovelProgress copyWith({
    String? bookId,
    int? chapterIndex,
    int? pageIndex,
    String? chapterId,
    String? chapterTitle,
    DateTime? updatedAt,
  }) => FlutterNovelProgress(
    bookId: bookId ?? this.bookId,
    chapterIndex: chapterIndex ?? this.chapterIndex,
    pageIndex: pageIndex ?? this.pageIndex,
    chapterId: chapterId ?? this.chapterId,
    chapterTitle: chapterTitle ?? this.chapterTitle,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FlutterNovelProgress &&
          bookId == other.bookId &&
          chapterIndex == other.chapterIndex &&
          pageIndex == other.pageIndex;

  @override
  int get hashCode => Object.hash(bookId, chapterIndex, pageIndex);

  @override
  String toString() =>
      'FlutterNovelProgress($bookId, chapter: $chapterIndex, page: $pageIndex)';
}
