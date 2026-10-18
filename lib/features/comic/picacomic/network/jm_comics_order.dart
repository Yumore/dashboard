/// 禁漫天堂 sort modes; the wire value is what the API expects in `o=`.
///
/// Ports `ComicsOrder` from
/// PicaComic lib/network/jm_network/jm_network.dart:875.
enum JmComicsOrder {
  /// 最新
  latest('mr'),

  /// 总排行
  totalRanking('mv'),

  /// 月排行
  monthRanking('mv_m'),

  /// 周排行
  weekRanking('mv_w'),

  /// 日排行
  dayRanking('mv_t'),

  /// 最多图片
  maxPictures('mp'),

  /// 最多喜欢
  maxLikes('tf'),

  /// 最新更新 (收藏夹)
  update('mp');

  const JmComicsOrder(this.value);

  final String value;

  static JmComicsOrder fromValue(String value) {
    for (final order in JmComicsOrder.values) {
      if (order.value == value) return order;
    }
    throw UnimplementedError('Unknown JmComicsOrder: $value');
  }

  @override
  String toString() => value;
}
