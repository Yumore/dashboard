import 'package:dashboard/features/novel/flutternovel/models/json_read.dart';

/// The `chapterup.zhuishushenqi.com/chapter/{link}` payload.
///
/// The source never modelled this (it piped the raw JSON into
/// `json.decode(...)["chapter"]["cpContent"]` inside the reader view model), so
/// this is the hand-written equivalent of that access path: the response wraps
/// the chapter under a `chapter` key.
class NovelChapterContent {
  NovelChapterContent({this.title, this.cpContent, this.link});

  String? title;
  String? cpContent;
  String? link;

  bool get isEmpty => (cpContent ?? '').isEmpty;

  factory NovelChapterContent.fromJson(Map<String, dynamic> json) {
    final chapter = json['chapter'];
    final map = chapter is Map ? chapter.cast<String, dynamic>() : json;
    return NovelChapterContent(
      title: readString(map, 'title'),
      cpContent: readString(map, 'cpContent'),
      link: readString(map, 'link'),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'chapter': <String, dynamic>{
      'title': title,
      'cpContent': cpContent,
      'link': link,
    },
  };
}
