import 'package:dashboard/features/novel/flutternovel/models/json_read.dart';
import 'package:dashboard/features/novel/flutternovel/models/review_author.dart';
import 'package:dashboard/features/novel/flutternovel/models/short_comment_book.dart';

/// Ported from `Docs` in entity_novel_short_comment.dart — one short comment
/// (短评) from `post/short-review`.
class NovelShortCommentDoc {
  NovelShortCommentDoc({
    this.id,
    this.rating,
    this.type,
    this.author,
    this.book,
    this.likeCount,
    this.priority,
    this.block,
    this.state,
    this.updated,
    this.created,
    this.content,
  });

  String? id;
  int? rating;
  String? type;
  ReviewAuthor? author;
  ShortCommentBook? book;
  int? likeCount;
  double? priority;
  String? block;
  String? state;
  String? updated;
  String? created;
  String? content;

  factory NovelShortCommentDoc.fromJson(Map<String, dynamic> json) =>
      NovelShortCommentDoc(
        id: readString(json, '_id'),
        rating: readInt(json, 'rating'),
        type: readString(json, 'type'),
        author: json['author'] is Map
            ? ReviewAuthor.fromJson(
                (json['author'] as Map).cast<String, dynamic>(),
              )
            : null,
        book: json['book'] is Map
            ? ShortCommentBook.fromJson(
                (json['book'] as Map).cast<String, dynamic>(),
              )
            : null,
        likeCount: readInt(json, 'likeCount'),
        priority: readDouble(json, 'priority'),
        block: readString(json, 'block'),
        state: readString(json, 'state'),
        updated: readString(json, 'updated'),
        created: readString(json, 'created'),
        content: readString(json, 'content'),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    '_id': id,
    'rating': rating,
    'type': type,
    'author': author?.toJson(),
    'book': book?.toJson(),
    'likeCount': likeCount,
    'priority': priority,
    'block': block,
    'state': state,
    'updated': updated,
    'created': created,
    'content': content,
  };
}
