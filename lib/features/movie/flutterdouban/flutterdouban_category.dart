/// The browse tabs the source home screen exposed.
///
/// The source had `影院热映` + `即将上映` (`API.getHotComingSoon`), the random
/// `豆瓣榜单` slice of top250, `一周口碑电影榜` (`API.WEEKLY`) and Top250
/// itself. `usBox` is the real douban north-american box office endpoint and
/// has no mock fixture — its tab reports a mock-mode error honestly.
enum FlutterDouBanCategory {
  inTheaters('正在热映'),
  comingSoon('即将上映'),
  top250('豆瓣 Top250'),
  weekly('一周口碑榜'),
  usBox('北美票房榜');

  const FlutterDouBanCategory(this.label);

  final String label;
}
