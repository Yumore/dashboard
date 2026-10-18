import 'package:dashboard/features/reading/easymygo/component/component.dart';
import 'package:dashboard/features/reading/easymygo/entity/book_detailed.dart';
import 'package:dashboard/features/reading/easymygo/entity/book_summary.dart';
import 'package:dashboard/features/reading/easymygo/entity/component_payload.dart';
import 'package:dashboard/features/reading/easymygo/entity/manga_chapter.dart';
import 'package:dashboard/features/reading/easymygo/entity/manga_picture.dart';

/// Ported from `MangaDetailedComponent` + `MangaReadComponent`.
abstract class MangaComponent extends Component {
  const MangaComponent(super.sourceInfo);

  Future<(ComponentPayload, BookDetailed?, List<MangaChapter>?)>
  getMangaDetailed(BookSummary summary);

  Future<(ComponentPayload, List<MangaPicture>?)> getMangaPictures(
    MangaChapter chapter,
    BookSummary summary,
  );
}
