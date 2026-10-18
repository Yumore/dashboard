import 'package:dashboard/features/novel/flutternovel/models/json_read.dart';

/// The review/comment author.
///
/// The source had two byte-identical `Author` classes, one in
/// entity_novel_book_review.dart and one in entity_novel_short_comment.dart.
/// They map to the same JSON, so the port keeps a single `ReviewAuthor` used by
/// both [NovelReview] and [NovelShortCommentDoc].
class ReviewAuthor {
  ReviewAuthor({
    this.id,
    this.avatar,
    this.nickname,
    this.activityAvatar,
    this.type,
    this.lv,
    this.gender,
  });

  String? id;
  String? avatar;
  String? nickname;
  String? activityAvatar;
  String? type;
  int? lv;
  String? gender;

  factory ReviewAuthor.fromJson(Map<String, dynamic> json) => ReviewAuthor(
    id: readString(json, '_id'),
    avatar: readString(json, 'avatar'),
    nickname: readString(json, 'nickname'),
    activityAvatar: readString(json, 'activityAvatar'),
    type: readString(json, 'type'),
    lv: readInt(json, 'lv'),
    gender: readString(json, 'gender'),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    '_id': id,
    'avatar': avatar,
    'nickname': nickname,
    'activityAvatar': activityAvatar,
    'type': type,
    'lv': lv,
    'gender': gender,
  };
}
