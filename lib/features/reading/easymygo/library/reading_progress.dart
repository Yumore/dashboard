/// Reading progress for one book.
///
/// Ported from the `last_read_*` / `last_history_time` columns of the EasyMyGo
/// drift tables (`MangaInfo` / `NovelInfo`, `lib/entity/*/*_info.dart`). The
/// manga columns are `last_read_chapter_id`, `last_read_chapter_label`,
/// `last_read_chapter_count`, `last_read_page_index`, `last_read_chapter_page_count`;
/// the novel table adds `last_read_volume_id`, `last_read_volume_label`,
/// `last_read_volume_index` and `last_read_volume_process`.
class ReadingProgress {
  const ReadingProgress({
    required this.chapterId,
    required this.chapterLabel,
    this.chapterIndex = 0,
    this.pageIndex = 0,
    this.pageCount = 0,
    this.volumeId = '',
    this.volumeLabel = '',
    this.volumeIndex = 0,
    this.updatedAt = 0,
  });

  final String chapterId;
  final String chapterLabel;
  final int chapterIndex;
  final int pageIndex;
  final int pageCount;
  final String volumeId;
  final String volumeLabel;
  final int volumeIndex;
  final int updatedAt;

  /// 0.0 – 1.0 progress inside the current chapter.
  double get chapterProcess =>
      pageCount <= 0 ? 0 : ((pageIndex + 1) / pageCount).clamp(0.0, 1.0);

  /// 0.0 – 1.0 progress inside the current volume (novel only).
  double get volumeProcess =>
      chapterIndex <= 0 ? 0 : 1 / (chapterIndex + 1);

  ReadingProgress copyWith({
    String? chapterId,
    String? chapterLabel,
    int? chapterIndex,
    int? pageIndex,
    int? pageCount,
    String? volumeId,
    String? volumeLabel,
    int? volumeIndex,
    int? updatedAt,
  }) => ReadingProgress(
    chapterId: chapterId ?? this.chapterId,
    chapterLabel: chapterLabel ?? this.chapterLabel,
    chapterIndex: chapterIndex ?? this.chapterIndex,
    pageIndex: pageIndex ?? this.pageIndex,
    pageCount: pageCount ?? this.pageCount,
    volumeId: volumeId ?? this.volumeId,
    volumeLabel: volumeLabel ?? this.volumeLabel,
    volumeIndex: volumeIndex ?? this.volumeIndex,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  Map<String, Object?> toJson() => <String, Object?>{
    'chapter_id': chapterId,
    'chapter_label': chapterLabel,
    'chapter_index': chapterIndex,
    'page_index': pageIndex,
    'page_count': pageCount,
    'volume_id': volumeId,
    'volume_label': volumeLabel,
    'volume_index': volumeIndex,
    'updated_at': updatedAt,
  };

  factory ReadingProgress.fromJson(Map<String, Object?> json) =>
      ReadingProgress(
        chapterId: '${json['chapter_id'] ?? ''}',
        chapterLabel: '${json['chapter_label'] ?? ''}',
        chapterIndex: (json['chapter_index'] as num?)?.toInt() ?? 0,
        pageIndex: (json['page_index'] as num?)?.toInt() ?? 0,
        pageCount: (json['page_count'] as num?)?.toInt() ?? 0,
        volumeId: '${json['volume_id'] ?? ''}',
        volumeLabel: '${json['volume_label'] ?? ''}',
        volumeIndex: (json['volume_index'] as num?)?.toInt() ?? 0,
        updatedAt: (json['updated_at'] as num?)?.toInt() ?? 0,
      );

  @override
  String toString() =>
      'ReadingProgress($chapterLabel:$pageIndex/$pageCount)';
}
