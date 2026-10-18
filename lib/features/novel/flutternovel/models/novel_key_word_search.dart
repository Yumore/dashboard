import 'package:dashboard/features/novel/flutternovel/models/json_read.dart';
import 'package:dashboard/features/novel/flutternovel/models/novel_search_book.dart';

/// Ported from `NovelKeyWordSearch` in entity_novel_book_key_word_search.dart —
/// the `book/fuzzy-search` envelope.
class NovelKeyWordSearch {
  NovelKeyWordSearch({
    this.books = const <NovelSearchBook>[],
    this.total,
    this.ok,
  });

  List<NovelSearchBook> books;
  int? total;
  bool? ok;

  bool get isEmpty => books.isEmpty;

  factory NovelKeyWordSearch.fromJson(Map<String, dynamic> json) =>
      NovelKeyWordSearch(
        books: readMapList(json, 'books').map(NovelSearchBook.fromJson).toList(),
        total: readInt(json, 'total'),
        ok: readBool(json, 'ok'),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'books': books.map((book) => book.toJson()).toList(),
    'total': total,
    'ok': ok,
  };
}
