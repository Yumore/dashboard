/// 源工程的 10 个首页标签及其分类 ID。
///
/// 顺序与 `lib/main.dart` 的 `TabBar` 一致，ID 与
/// `lib/listpage.dart` 的 `getCategoryIdByTab()` 一一对应。
enum DyttCategory {
  latest(9, '最新电影'),
  general(10, '综合电影'),
  chineseMovie(1, '华语电影'),
  westernMovie(2, '欧美电影'),
  asianMovie(3, '日韩电影'),
  chineseTv(4, '华语电视'),
  westernTv(5, '欧美电视'),
  asianTv(6, '日韩电视'),
  variety(7, '综艺'),
  anime(8, '动漫');

  const DyttCategory(this.categoryId, this.label);

  /// 请求体里的 `categoryId`。
  final int categoryId;

  /// 源工程 `Strings.tab1` … `Strings.tab10`。
  final String label;
}
