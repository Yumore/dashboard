/// 站点条目的最小信息：名称与链接。
abstract class AnimeOneBasic {
  AnimeOneBasic({this.name, this.link});

  String? name;
  String? link;

  /// 名称是否包含关键字（忽略大小写）。
  bool contains(String text) {
    final value = name;
    if (value == null) return false;
    return value.toLowerCase().contains(text.toLowerCase());
  }

  /// 名称是否已成功解析。
  bool valid() => (name ?? '').trim().isNotEmpty;

  /// 把剧集编号从名称尾部移到最前，例如 "鬼滅之刃 [12]" -> "[12] 鬼滅之刃"。
  String? formattedName() {
    final value = name;
    if (value == null) return null;
    if (!value.endsWith(']')) return value;
    final parts = value.split(' ');
    if (parts.length < 2) return value;
    final tag = parts.removeLast();
    final moved = '$tag ${parts.join(' ')}';
    return moved.startsWith('[') ? moved : value;
  }
}
