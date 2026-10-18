import 'package:dashboard/features/reading/easymygo/component/component.dart';
import 'package:dashboard/features/reading/easymygo/entity/book_cover.dart';
import 'package:dashboard/features/reading/easymygo/entity/component_payload.dart';

/// Ported from `MangaSearchComponent` / `NovelSearchComponent` (merged).
abstract class SearchComponent extends Component {
  const SearchComponent(super.sourceInfo);

  /// Ported from `getInitKey` — the first paging key for [keyword].
  String getInitKey(String keyword);

  Future<(ComponentPayload, List<BookCover>, String?)> search(
    String key,
    String keyword,
  );
}
