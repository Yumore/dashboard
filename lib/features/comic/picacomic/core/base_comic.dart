/// Ports PicaComic's `lib/network/base_comic.dart`.
abstract class BaseComic {
  String get title;

  String get subTitle;

  String get cover;

  String get id;

  List<String> get tags;

  String get description;

  bool get enableTagsTranslation => false;

  const BaseComic();
}
