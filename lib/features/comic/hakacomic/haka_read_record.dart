/// Last-read position of one comic.
///
/// Mirrors the upstream read-record columns
/// (`haka_comic/lib/database/read_record_helper.dart:20-40`).
class HakaReadRecord {
  const HakaReadRecord({
    required this.comicId,
    required this.chapterId,
    required this.chapterOrder,
    required this.chapterTitle,
    required this.pageNo,
    this.finished = false,
  });

  final String comicId;

  /// `_id` of the chapter.
  final String chapterId;

  /// 1-based `order` used by the chapter-images endpoint.
  final int chapterOrder;

  final String chapterTitle;

  /// 1-based page inside the chapter.
  final int pageNo;

  final bool finished;

  HakaReadRecord copyWith({
    String? chapterId,
    int? chapterOrder,
    String? chapterTitle,
    int? pageNo,
    bool? finished,
  }) {
    return HakaReadRecord(
      comicId: comicId,
      chapterId: chapterId ?? this.chapterId,
      chapterOrder: chapterOrder ?? this.chapterOrder,
      chapterTitle: chapterTitle ?? this.chapterTitle,
      pageNo: pageNo ?? this.pageNo,
      finished: finished ?? this.finished,
    );
  }

  Map<String, dynamic> toJson() => {
    'comic_id': comicId,
    'chapter_id': chapterId,
    'chapter_order': chapterOrder,
    'chapter_title': chapterTitle,
    'page_no': pageNo,
    'finished': finished,
  };

  factory HakaReadRecord.fromJson(Map<String, dynamic> json) {
    return HakaReadRecord(
      comicId: json['comic_id'] as String,
      chapterId: json['chapter_id'] as String? ?? '',
      chapterOrder: (json['chapter_order'] as num?)?.toInt() ?? 1,
      chapterTitle: json['chapter_title'] as String? ?? '',
      pageNo: (json['page_no'] as num?)?.toInt() ?? 1,
      finished: json['finished'] as bool? ?? false,
    );
  }
}
