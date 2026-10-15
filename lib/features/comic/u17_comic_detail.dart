import 'package:dashboard/features/comic/u17_chapter.dart';
import 'package:dashboard/features/comic/u17_comic.dart';

class U17ComicDetail {
  const U17ComicDetail({required this.comic, required this.chapters});

  final U17Comic comic;
  final List<U17Chapter> chapters;
}
