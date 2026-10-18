import 'package:dashboard/features/reading/easymygo/component/component.dart';
import 'package:dashboard/features/reading/easymygo/entity/book_detailed.dart';
import 'package:dashboard/features/reading/easymygo/entity/book_summary.dart';
import 'package:dashboard/features/reading/easymygo/entity/component_payload.dart';
import 'package:dashboard/features/reading/easymygo/entity/novel_chapter.dart';
import 'package:dashboard/features/reading/easymygo/entity/novel_volume.dart';

/// Ported from `NovelDetailedComponent` + `NovelReadComponent`.
abstract class NovelComponent extends Component {
  const NovelComponent(super.sourceInfo);

  Future<(ComponentPayload, BookDetailed?, List<NovelVolume>?)>
  getNovelDetailed(BookSummary summary);

  Future<(ComponentPayload, List<NovelChapter>?)> getNovelChapters(
    NovelVolume volume,
    BookSummary summary,
  );

  /// Ported from `loadChapter`; the returned string is the raw chapter body.
  Future<(ComponentPayload, String)> loadNovelChapter(
    NovelChapter chapter,
    BookSummary summary,
  );
}
