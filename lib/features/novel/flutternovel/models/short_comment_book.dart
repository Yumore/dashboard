import 'package:dashboard/features/novel/flutternovel/models/json_read.dart';

/// Ported from `Book` in entity_novel_short_comment.dart — the book a short
/// comment was posted on.
class ShortCommentBook {
  ShortCommentBook({this.id, this.title, this.cover});

  String? id;
  String? title;
  String? cover;

  factory ShortCommentBook.fromJson(Map<String, dynamic> json) =>
      ShortCommentBook(
        id: readString(json, '_id'),
        title: readString(json, 'title'),
        cover: readString(json, 'cover'),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    '_id': id,
    'title': title,
    'cover': cover,
  };
}
