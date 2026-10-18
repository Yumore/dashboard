/// anime1.me 站点地址工具。
class AnimeOneUrl {
  const AnimeOneUrl._();

  /// 站点主域名。
  static const String domain = 'https://anime1.me/';

  /// 站点基础 Uri。
  static final Uri base = Uri.parse(domain);

  /// 把站内相对链接补全为绝对链接。
  static String absolute(String? href, {String? from}) {
    final value = href?.trim() ?? '';
    if (value.isEmpty) return '';
    if (value.startsWith('http')) return value;
    return Uri.parse(from ?? domain).resolve(value).toString();
  }

  /// 动画目录里的分类入口：https://anime1.me/?cat=ID
  static String category(int id) => '$domain?cat=$id';

  /// 分类分页链接，第 1 页沿用原链接。
  static String paged(String link, int page) {
    if (page <= 1) return link;
    final trimmed = link.endsWith('/')
        ? link.substring(0, link.length - 1)
        : link;
    return '$trimmed/page/$page';
  }
}
