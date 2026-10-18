import 'package:dashboard/features/novel/flutternovel/reader/content_state.dart';
import 'package:dashboard/features/novel/flutternovel/reader/reader_canvas_page.dart';
import 'package:dashboard/features/novel/flutternovel/reader/reader_page_content_config.dart';

/// The reader's working set for one chapter (current, previous or next).
///
/// Ported from the source's `ReaderContentDataValue`. [chapterCanvasDataMap] is
/// keyed by page index and holds the rendered pages; [chapterContentConfigs] is
/// the pagination result for the chapter.
class ReaderContentDataValue {
  List<ReaderPageContentConfig> chapterContentConfigs =
      <ReaderPageContentConfig>[];
  Map<int, ReaderCanvasPage> chapterCanvasDataMap = <int, ReaderCanvasPage>{};
  String? contentData;

  int chapterIndex = 0;
  String? novelId;
  String? title;

  int currentPageIndex = 0;

  ContentState contentState = ContentState.normal;

  /// The source compared chapter + book, ignoring the page index.
  bool isSameChapter(ReaderContentDataValue? target) =>
      target != null &&
      target.novelId == novelId &&
      target.chapterIndex == chapterIndex;

  void clearCalculateResult() {
    chapterContentConfigs.clear();
    chapterCanvasDataMap.clear();
  }

  void clear() {
    clearCalculateResult();
    contentData = null;
    chapterIndex = 0;
    title = null;
    currentPageIndex = 0;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReaderContentDataValue &&
          chapterIndex == other.chapterIndex &&
          novelId == other.novelId &&
          currentPageIndex == other.currentPageIndex;

  @override
  int get hashCode => Object.hash(chapterIndex, novelId, currentPageIndex);
}
