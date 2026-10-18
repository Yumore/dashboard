/// Feedbooks 公共书库（catalog.feedbooks.com）的浏览端点。
///
/// 照抄源工程 `lib/src/common/constants/api.dart`，逐字节一致：
/// 站点根、公共领域浏览前缀，以及源工程里预置的 8 个书单/分类地址。
/// 分类地址就是 `top.atom` 加 `?cat=<BISAC 主题码>`，首页与分类页实际用的
/// 还是 feed 里返回的 `link`（见 [FeedbooksApi.publicDomainUrl] 这一族常量
/// 只被源工程的书单入口引用）。
class FeedbooksApi {
  const FeedbooksApi._();

  /// 源 `lib/src/common/constants/strings.dart` 的 `appName`：
  /// 首页标题与下载子目录名都用它。
  static const String appName = 'OpenLeaf';

  /// 源 `baseURL`。
  static const String baseUrl = 'https://catalog.feedbooks.com';

  /// 源 `publicDomainURL`。
  static const String publicDomainUrl = '/publicdomain/browse';

  /// 源 `popular`：最受欢迎的公共领域作品。
  static const String popular = '$publicDomainUrl/top.atom';

  /// 源 `recent`：最新入库。
  static const String recent = '$publicDomainUrl/recent.atom';

  /// 源 `awards`。
  static const String awards = '$publicDomainUrl/awards.atom';

  /// 源 `noteworthy`：编辑精选。
  static const String noteworthy = '$publicDomainUrl/homepage_selection.atom';

  /// 源 `shortStory`：短篇。
  static const String shortStory = '$publicDomainUrl/top.atom?cat=FBFIC029000';

  /// 源 `sciFi`：科幻。
  static const String sciFi = '$publicDomainUrl/top.atom?cat=FBFIC028000';

  /// 源 `actionAdventure`：动作冒险。
  static const String actionAdventure =
      '$publicDomainUrl/top.atom?cat=FBFIC002000';

  /// 源 `mystery`：推理。
  static const String mystery = '$publicDomainUrl/top.atom?cat=FBFIC022000';

  /// 源 `romance`：言情。
  static const String romance = '$publicDomainUrl/top.atom?cat=FBFIC027000';

  /// 源 `horror`：恐怖。
  static const String horror = '$publicDomainUrl/top.atom?cat=FBFIC015000';
}
