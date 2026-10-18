import 'package:dashboard/features/novel/flutternovel/models/dmzj_novel_brief.dart';
import 'package:dashboard/features/novel/flutternovel/models/json_read.dart';

/// One titled block of the dmzj v3 `novel/recommend.json` feed.
///
/// The feed nests each section's books under `data` with the section `title`
/// beside them; `books` is accepted as a fallback key so a caller can seed the
/// parser from a hand-built map.
class DmzjRecommendSection {
  DmzjRecommendSection({
    this.title,
    this.books = const <DmzjNovelBrief>[],
  });

  String? title;
  List<DmzjNovelBrief> books;

  bool get isEmpty => books.isEmpty;

  factory DmzjRecommendSection.fromJson(Map<String, dynamic> json) {
    final items = readMapList(json, 'data').isEmpty
        ? readMapList(json, 'books')
        : readMapList(json, 'data');
    return DmzjRecommendSection(
      title: readString(json, 'title'),
      books: items.map(DmzjNovelBrief.fromJson).toList(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'title': title,
    'data': books.map((book) => book.toJson()).toList(),
  };
}
