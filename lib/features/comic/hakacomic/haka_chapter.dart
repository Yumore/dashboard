/// One chapter of a comic (`haka_comic/lib/network/models.dart:438-463`).
class HakaChapter {  const HakaChapter({
    required this.uid,
    required this.title,
    required this.order,
    required this.updatedAt,
    required this.id,
  });

  final String uid;

  final String title;

  /// `order` is what the image endpoint is keyed by.
  final int order;

  final String updatedAt;

  final String id;

  factory HakaChapter.fromJson(Map<String, dynamic> json) {
    return HakaChapter(
      uid: json['_id'] as String,
      title: json['title'] as String,
      order: (json['order'] as num).toInt(),
      updatedAt: json['updated_at'] as String,
      id: json['id'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': uid,
    'title': title,
    'order': order,
    'updated_at': updatedAt,
    'id': id,
  };
}
