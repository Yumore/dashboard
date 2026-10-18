import 'package:dashboard/features/novel/flutternovel/models/json_read.dart';

/// Ported from `Rating` in entity_novel_detail.dart (keys: score, count, tip, isEffect).
class NovelRating {
  NovelRating({this.score, this.count, this.tip, this.isEffect});

  double? score;
  int? count;
  String? tip;
  bool? isEffect;

  factory NovelRating.fromJson(Map<String, dynamic> json) => NovelRating(
    score: readDouble(json, 'score'),
    count: readInt(json, 'count'),
    tip: readString(json, 'tip'),
    isEffect: readBool(json, 'isEffect'),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'score': score,
    'count': count,
    'tip': tip,
    'isEffect': isEffect,
  };
}
