import 'package:dashboard/features/novel/flutternovel/models/json_read.dart';

/// Ported from `Helpful` in entity_novel_book_review.dart.
class ReviewHelpful {
  ReviewHelpful({this.total, this.yes, this.no});

  int? total;
  int? yes;
  int? no;

  factory ReviewHelpful.fromJson(Map<String, dynamic> json) => ReviewHelpful(
    total: readInt(json, 'total'),
    yes: readInt(json, 'yes'),
    no: readInt(json, 'no'),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'total': total,
    'yes': yes,
    'no': no,
  };
}
