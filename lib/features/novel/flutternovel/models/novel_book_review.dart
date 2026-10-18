import 'package:dashboard/features/novel/flutternovel/models/json_read.dart';
import 'package:dashboard/features/novel/flutternovel/models/novel_review.dart';

/// Ported from `NovelBookReview` in entity_novel_book_review.dart.
class NovelBookReview {
  NovelBookReview({
    this.total,
    this.today,
    this.reviews = const <NovelReview>[],
    this.ok,
  });

  int? total;
  int? today;
  List<NovelReview> reviews;
  bool? ok;

  bool get isEmpty => reviews.isEmpty;

  factory NovelBookReview.fromJson(Map<String, dynamic> json) =>
      NovelBookReview(
        total: readInt(json, 'total'),
        today: readInt(json, 'today'),
        reviews: readMapList(json, 'reviews').map(NovelReview.fromJson).toList(),
        ok: readBool(json, 'ok'),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'total': total,
    'today': today,
    'reviews': reviews.map((review) => review.toJson()).toList(),
    'ok': ok,
  };
}
