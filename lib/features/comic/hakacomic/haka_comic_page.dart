import 'package:dashboard/features/comic/hakacomic/haka_comic_base.dart';

/// One fetched page of a comic list plus its paging metadata.
///
/// The picacomic list envelope always carries `page` and `pages`, which is what
/// the "load more" rule keys off
/// (`haka_comic/lib/views/categories/categories.dart`).
class HakaComicPage {
  const HakaComicPage({
    required this.docs,
    required this.page,
    required this.pages,
  });

  final List<HakaComicBase> docs;

  /// 1-based index of the page just returned.
  final int page;

  /// Total number of pages available.
  final int pages;
}
