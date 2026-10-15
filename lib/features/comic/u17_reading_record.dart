import 'package:dashboard/features/comic/u17_chapter.dart';
import 'package:dashboard/features/comic/u17_comic.dart';

class U17ReadingRecord {
  const U17ReadingRecord({
    required this.comic,
    required this.chapter,
    required this.readAt,
  });

  final U17Comic comic;
  final U17Chapter chapter;
  final DateTime readAt;

  factory U17ReadingRecord.fromJson(Map<String, dynamic> json) =>
      U17ReadingRecord(
        comic: U17Comic.fromJson(
          Map<String, dynamic>.from(json['comic'] as Map),
        ),
        chapter: U17Chapter.fromJson(
          Map<String, dynamic>.from(json['chapter'] as Map),
        ),
        readAt: DateTime.parse(json['readAt'] as String),
      );

  Map<String, Object?> toJson() => {
    'comic': comic.toJson(),
    'chapter': chapter.toJson(),
    'readAt': readAt.toIso8601String(),
  };
}
