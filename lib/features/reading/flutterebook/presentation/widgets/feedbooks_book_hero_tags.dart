/// 卡片 / 详情页之间共享的 Hero tag 组。
///
/// 源工程用 `Uuid().v4()` 给每张卡片生成三个 tag（封面 / 标题 / 作者），
/// 点击时把同一组 tag 传给详情页，Hero 动画才能接上。宿主 pubspec 没有
/// `uuid`，这里用自增计数器生成同样唯一的字符串。
class FeedbooksBookHeroTags {
  const FeedbooksBookHeroTags({
    required this.imgTag,
    required this.titleTag,
    required this.authorTag,
  });

  /// 每个 widget 实例调用一次，得到该实例专属的一组 tag。
  factory FeedbooksBookHeroTags.unique() {
    final int id = ++_counter;
    return FeedbooksBookHeroTags(
      imgTag: 'flutterebook-cover-$id',
      titleTag: 'flutterebook-title-$id',
      authorTag: 'flutterebook-author-$id',
    );
  }

  static int _counter = 0;

  final String imgTag;
  final String titleTag;
  final String authorTag;

  @override
  String toString() => 'FeedbooksBookHeroTags($imgTag, $titleTag, $authorTag)';
}
