/// Shelf storage names.
///
/// The host keeps its SQLite names as top-level constants in `lib/sql/*.dart`
/// (e.g. `comicHistoryTable`); the port follows that convention but owns its own
/// database, because `lib/main.dart`'s `initDatabase()` is outside this
/// migration's write scope and its `onCreate` only builds the comic tables.
/// `databaseProvider` in [SqfliteNovelShelfStore] reads these.
library;

const String novelShelfTable = 'flutternovel_shelf';
const String novelShelfColumnId = '_id';
const String novelShelfColumnBookId = 'bookId';
const String novelShelfColumnTitle = 'title';
const String novelShelfColumnImage = 'image';
const String novelShelfColumnChapterIndex = 'chaptersIndex';
const String novelShelfColumnVolumeIndex = 'volumeIndex';
const String novelShelfColumnPageIndex = 'pageIndex';

/// One book on the shelf, including the reader's saved position.
///
/// Ported from `NovelBookInfo` in entity_novel_info.dart; the source's
/// `DBHelper` column constants now live beside this class.
class NovelBookInfo {
  NovelBookInfo({
    required this.bookId,
    required this.title,
    this.cover = '',
    this.currentPageIndex = 0,
    this.currentChapterIndex = 0,
    this.currentVolumeIndex = 0,
  });

  String bookId;
  String cover;
  String title;

  int currentPageIndex;
  int currentChapterIndex;
  int currentVolumeIndex;

  Map<String, dynamic> toMap() => <String, dynamic>{
    novelShelfColumnBookId: bookId,
    novelShelfColumnTitle: title,
    novelShelfColumnImage: cover,
    novelShelfColumnChapterIndex: currentChapterIndex,
    novelShelfColumnVolumeIndex: currentVolumeIndex,
    novelShelfColumnPageIndex: currentPageIndex,
  };

  factory NovelBookInfo.fromMap(Map<String, dynamic> map) => NovelBookInfo(
    bookId: '${map[novelShelfColumnBookId] ?? ''}',
    title: '${map[novelShelfColumnTitle] ?? ''}',
    cover: '${map[novelShelfColumnImage] ?? ''}',
    currentChapterIndex: _asInt(map[novelShelfColumnChapterIndex]),
    currentVolumeIndex: _asInt(map[novelShelfColumnVolumeIndex]),
    currentPageIndex: _asInt(map[novelShelfColumnPageIndex]),
  );

  NovelBookInfo copyWith({
    String? bookId,
    String? cover,
    String? title,
    int? currentPageIndex,
    int? currentChapterIndex,
    int? currentVolumeIndex,
  }) => NovelBookInfo(
    bookId: bookId ?? this.bookId,
    cover: cover ?? this.cover,
    title: title ?? this.title,
    currentPageIndex: currentPageIndex ?? this.currentPageIndex,
    currentChapterIndex: currentChapterIndex ?? this.currentChapterIndex,
    currentVolumeIndex: currentVolumeIndex ?? this.currentVolumeIndex,
  );

  static int _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is NovelBookInfo && bookId == other.bookId;

  @override
  int get hashCode => bookId.hashCode;

  @override
  String toString() =>
      'NovelBookInfo($bookId, $title, chapter $currentChapterIndex, '
      'page $currentPageIndex)';
}
