import 'package:dashboard/features/comic/manhuatai/manhuatai_book.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_book_section.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_comic.dart';

/// Merges the extra `recommend` page into the legacy `getBookByType` sections.
///
/// The source rendered one section per book title and appended the newer
/// `comic_info` entries to the section with the same title (and skipped
/// duplicate comics), which is what this helper reproduces.
class ManhuataiBookSectionMerge {
  const ManhuataiBookSectionMerge._();

  static ManhuataiBookSection merge(
    ManhuataiBookSection first,
    ManhuataiBookSection second,
  ) {
    final result = <ManhuataiBook>[...first.book];
    for (final incoming in second.book) {
      final existing = result.indexWhere((book) => book.title == incoming.title);
      if (existing == -1) {
        result.add(incoming);
        continue;
      }
      final current = result[existing];
      result[existing] = ManhuataiBook(
        bookId: current.bookId,
        siteid: current.siteid,
        modularType: current.modularType,
        unionType: current.unionType,
        unionId: current.unionId,
        istop: current.istop,
        topNum: current.topNum,
        ordernum: current.ordernum,
        versionFilter: current.versionFilter,
        versionNum: current.versionNum,
        title: current.title,
        config: current.config,
        bookcomicOrder: current.bookcomicOrder,
        bookcomicImgstyle: current.bookcomicImgstyle,
        advertiseLocation: current.advertiseLocation,
        advertiseSdktype: current.advertiseSdktype,
        bookDatasource: current.bookDatasource,
        bookIntellrecommend: current.bookIntellrecommend,
        comicInfo: <ManhuataiComic>[
          ...current.comicInfo,
          ...incoming.comicInfo.where(
            (comic) => !current.comicInfo
                .any((item) => item.comicId == comic.comicId),
          ),
        ],
      );
    }
    return ManhuataiBookSection(book: result, name: first.name);
  }
}
