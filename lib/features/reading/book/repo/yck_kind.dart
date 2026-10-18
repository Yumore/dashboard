
/// Kind of yckceo catalog entry.
enum YckKind {
  /// Legado book source (`/yuedu/shuyuan/`).
  source,

  /// Book-source collection (`/yuedu/shuyuans/`).
  collection,

  /// Legado RSS subscription source (`/yuedu/rss/`).
  rss,
}

/// 源仓库 (yckceo) 列表项。
///
/// 站点页面：
/// - 订阅源：`/yuedu/rss/index.html`
/// - 书源：`/yuedu/shuyuan/index.html`
/// - 书源合集：`/yuedu/shuyuans/index.html`
///
/// JSON 直链：
/// - 订阅源：`/yuedu/rss/json/id/{id}.json`（Legado RSS 对象数组）
/// - 书源：`/yuedu/shuyuan/json/id/{id}.json`
/// - 合集：`/yuedu/shuyuans/json/id/{id}.json`
