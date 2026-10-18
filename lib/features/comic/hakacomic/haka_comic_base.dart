import 'package:dashboard/features/comic/hakacomic/haka_image_detail.dart';

/// Common surface of comic list documents
/// (`haka_comic/lib/network/models.dart:1534-1545`).
abstract class HakaComicBase {
  const HakaComicBase();

  String get uid;

  String get title;

  String get author;

  List<String> get categories;

  List<String> get tags;

  HakaImageDetail get thumb;

  bool get finished;

  int? get totalViews;

  int? get totalLikes;

  int get likesCount;
}
