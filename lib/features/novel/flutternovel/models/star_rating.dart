import 'package:dashboard/features/novel/flutternovel/models/json_read.dart';

/// Ported from `StarRatings` in entity_novel_detail.dart (keys: count, star).
class StarRating {
  StarRating({this.count, this.star});

  int? count;
  int? star;

  factory StarRating.fromJson(Map<String, dynamic> json) =>
      StarRating(count: readInt(json, 'count'), star: readInt(json, 'star'));

  Map<String, dynamic> toJson() => <String, dynamic>{
    'count': count,
    'star': star,
  };
}
