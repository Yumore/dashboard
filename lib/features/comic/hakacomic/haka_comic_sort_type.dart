/// Sort values accepted by `comics` and `comics/advanced-search`
/// (`haka_comic/lib/network/models.dart:156-166`).
enum HakaComicSortType {
  dd('新到旧'),
  da('旧到新'),
  ld('最多喜欢'),
  vd('最多观看');

  const HakaComicSortType(this.title);

  final String title;
}
