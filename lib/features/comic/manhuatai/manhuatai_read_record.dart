import 'package:dashboard/features/comic/manhuatai/manhuatai_chapter.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_json.dart';

/// A locally persisted reading record ("阅读历史").
///
/// Mirrors the fields the source wrote through `adduserread`
/// (`comic_id`, `chapter_id`, `chapter_name`, `chapter_page`).
class ManhuataiReadRecord {
  const ManhuataiReadRecord({
    required this.comicId,
    required this.comicName,
    required this.chapterTopicId,
    required this.chapterName,
    required this.chapterPage,
    required this.readAt,
    this.imgUrl = '',
  });

  final int comicId;
  final String comicName;
  final int chapterTopicId;
  final String chapterName;
  final int chapterPage;
  final int readAt;
  final String imgUrl;

  ManhuataiReadRecord copyWith({
    int? comicId,
    String? comicName,
    int? chapterTopicId,
    String? chapterName,
    int? chapterPage,
    int? readAt,
    String? imgUrl,
  }) {
    return ManhuataiReadRecord(
      comicId: comicId ?? this.comicId,
      comicName: comicName ?? this.comicName,
      chapterTopicId: chapterTopicId ?? this.chapterTopicId,
      chapterName: chapterName ?? this.chapterName,
      chapterPage: chapterPage ?? this.chapterPage,
      readAt: readAt ?? this.readAt,
      imgUrl: imgUrl ?? this.imgUrl,
    );
  }

  factory ManhuataiReadRecord.fromChapter({
    required int comicId,
    required String comicName,
    required ManhuataiChapter chapter,
    required int chapterPage,
    String imgUrl = '',
  }) {
    return ManhuataiReadRecord(
      comicId: comicId,
      comicName: comicName,
      chapterTopicId: chapter.chapterTopicId,
      chapterName: chapter.chapterName,
      chapterPage: chapterPage,
      readAt: DateTime.now().millisecondsSinceEpoch,
      imgUrl: imgUrl,
    );
  }

  factory ManhuataiReadRecord.fromJson(Map<String, dynamic> json) {
    final source = ManhuataiJson.map(json);
    return ManhuataiReadRecord(
      comicId: ManhuataiJson.asInt(source['comic_id']),
      comicName: ManhuataiJson.asString(source['comic_name']),
      chapterTopicId: ManhuataiJson.asInt(source['chapter_topic_id']),
      chapterName: ManhuataiJson.asString(source['chapter_name']),
      chapterPage: ManhuataiJson.asInt(source['chapter_page']),
      readAt: ManhuataiJson.asInt(source['read_at']),
      imgUrl: ManhuataiJson.asString(source['img_url']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'comic_id': comicId,
        'comic_name': comicName,
        'chapter_topic_id': chapterTopicId,
        'chapter_name': chapterName,
        'chapter_page': chapterPage,
        'read_at': readAt,
        'img_url': imgUrl,
      };
}
