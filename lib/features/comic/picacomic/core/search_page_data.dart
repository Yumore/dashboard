import 'package:dashboard/features/comic/picacomic/core/comic_source_typedefs.dart';
import 'package:dashboard/features/comic/picacomic/core/search_options.dart';

/// Ports PicaComic's `SearchPageData` (UI builder hooks dropped, see report).
class SearchPageData {
  /// When not `null`, the first entry of each option group is the default.
  final List<SearchOptions>? searchOptions;

  final SearchFunction? loadPage;

  final bool enableLanguageFilter;

  final bool enableTagsSuggestions;

  const SearchPageData({
    this.searchOptions,
    this.loadPage,
    this.enableLanguageFilter = false,
    this.enableTagsSuggestions = false,
  });
}
