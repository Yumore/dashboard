import 'package:dashboard/features/novel/flutternovel/models/json_read.dart';

/// Ported from `Highlight` in entity_novel_book_key_word_search.dart.
class NovelHighlight {
  NovelHighlight({this.title = const <String>[]});

  List<String> title;

  factory NovelHighlight.fromJson(Map<String, dynamic> json) =>
      NovelHighlight(title: readStringList(json, 'title'));

  Map<String, dynamic> toJson() => <String, dynamic>{'title': title};
}
