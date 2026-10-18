import 'package:dashboard/features/novel/flutternovel/models/json_read.dart';
import 'package:dashboard/features/novel/flutternovel/models/novel_recommend_book.dart';

/// Ported from `NovelBookRecommend` in entity_novel_book_recommend.dart.
class NovelBookRecommend {
  NovelBookRecommend({this.books = const <NovelRecommendBook>[], this.ok});

  List<NovelRecommendBook> books;
  bool? ok;

  bool get isEmpty => books.isEmpty;

  factory NovelBookRecommend.fromJson(Map<String, dynamic> json) =>
      NovelBookRecommend(
        books: readMapList(json, 'books')
            .map(NovelRecommendBook.fromJson)
            .toList(),
        ok: readBool(json, 'ok'),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'books': books.map((book) => book.toJson()).toList(),
    'ok': ok,
  };
}
