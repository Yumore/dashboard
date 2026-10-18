import 'package:dashboard/features/novel/flutternovel/models/json_read.dart';
import 'package:dashboard/features/novel/flutternovel/models/review_author.dart';
import 'package:dashboard/features/novel/flutternovel/models/review_helpful.dart';

/// Ported from `Reviews` in entity_novel_book_review.dart — a long-form review
/// from `post/review/by-book`.
class NovelReview {
  NovelReview({
    this.id,
    this.rating,
    this.author,
    this.helpful,
    this.likeCount,
    this.state,
    this.updated,
    this.created,
    this.commentCount,
    this.content,
    this.title,
  });

  String? id;
  int? rating;
  ReviewAuthor? author;
  ReviewHelpful? helpful;
  int? likeCount;
  String? state;
  String? updated;
  String? created;
  int? commentCount;
  String? content;
  String? title;

  factory NovelReview.fromJson(Map<String, dynamic> json) => NovelReview(
    id: readString(json, '_id'),
    rating: readInt(json, 'rating'),
    author: json['author'] is Map
        ? ReviewAuthor.fromJson((json['author'] as Map).cast<String, dynamic>())
        : null,
    helpful: json['helpful'] is Map
        ? ReviewHelpful.fromJson(
            (json['helpful'] as Map).cast<String, dynamic>(),
          )
        : null,
    likeCount: readInt(json, 'likeCount'),
    state: readString(json, 'state'),
    updated: readString(json, 'updated'),
    created: readString(json, 'created'),
    commentCount: readInt(json, 'commentCount'),
    content: readString(json, 'content'),
    title: readString(json, 'title'),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    '_id': id,
    'rating': rating,
    'author': author?.toJson(),
    'helpful': helpful?.toJson(),
    'likeCount': likeCount,
    'state': state,
    'updated': updated,
    'created': created,
    'commentCount': commentCount,
    'content': content,
    'title': title,
  };
}
