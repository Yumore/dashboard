import 'package:dashboard/features/reading/easymygo/component/component.dart';
import 'package:dashboard/features/reading/easymygo/entity/book_cover.dart';
import 'package:dashboard/features/reading/easymygo/entity/book_home_page.dart';
import 'package:dashboard/features/reading/easymygo/entity/book_home_tab.dart';
import 'package:dashboard/features/reading/easymygo/entity/book_second_tab.dart';
import 'package:dashboard/features/reading/easymygo/entity/component_payload.dart';

/// Ported from `MangaHomeComponent` / `NovelHomeComponent` (merged, like the
/// book entities). The four calls and the `(payload, data, nextKey)` tuple shape
/// are unchanged.
abstract class HomeComponent extends Component {
  const HomeComponent(super.sourceInfo);

  Future<(ComponentPayload, List<BookHomeTab>?)> getHomeTab();

  Future<(ComponentPayload, List<BookSecondTab>?)> getSecondTab(BookHomeTab tab);

  Future<(ComponentPayload, BookHomePage?)> getPageWithHomeTab(BookHomeTab tab);

  Future<(ComponentPayload, BookHomePage?)> getPageWithSecondTab(
    BookHomeTab tab,
    BookSecondTab secondTab,
  );

  Future<(ComponentPayload, List<BookCover>, String?)> loadPageData(
    BookHomePage page,
    String key,
  );
}
