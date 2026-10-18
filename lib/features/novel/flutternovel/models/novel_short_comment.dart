import 'package:dashboard/features/novel/flutternovel/models/json_read.dart';
import 'package:dashboard/features/novel/flutternovel/models/novel_short_comment_doc.dart';

/// Ported from `NovelShortComment` in entity_novel_short_comment.dart.
class NovelShortComment {
  NovelShortComment({
    this.today,
    this.docs = const <NovelShortCommentDoc>[],
    this.ok,
  });

  int? today;
  List<NovelShortCommentDoc> docs;
  bool? ok;

  bool get isEmpty => docs.isEmpty;

  factory NovelShortComment.fromJson(Map<String, dynamic> json) =>
      NovelShortComment(
        today: readInt(json, 'today'),
        docs: readMapList(json, 'docs')
            .map(NovelShortCommentDoc.fromJson)
            .toList(),
        ok: readBool(json, 'ok'),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'today': today,
    'docs': docs.map((doc) => doc.toJson()).toList(),
    'ok': ok,
  };
}
