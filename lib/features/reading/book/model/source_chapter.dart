/// Engine-level search hit from a book source.
class SourceChapter {
  String name;
  String url;
  bool isVolume;
  int index;

  SourceChapter({
    this.name = '',
    this.url = '',
    this.isVolume = false,
    this.index = 0,
  });
}
