# 内容模块逻辑拆分与 UI 统一（2026-10-18）

## 背景

迁移战役结束后，`lib/features/` 下的 8 个内容模块页统一呈现为「9 行 StatefulWidget 外壳 +
`*_module_page_state.dart`」。这些 state 文件同时承担了四类职责：数据访问（`AnimeSource`、
`MovieSource`、`LivePlaylistRepository`、`CrawlConfigStore`、`ChatLocalStore`）、本地持久化、
导航与对话框流程、以及页面渲染。直接后果：

- 影视页 AppBar 有 15 个 `IconButton`（开眼、B站下载、豆瓣、inKino、电影天堂……），动漫页 5 个、
  聊天页 7 个，小屏上标题被挤没，入口与「页面自身功能」混在同一层。
- 同一套模式被复制 8 次：居中 loading、`Text('加载失败：…')`、空列表文案、`ListTile` +
  `Image.network(errorBuilder:)` 封面、per-module `SnackBar`。
- 逻辑与界面耦合，无法在不改 UI 的情况下复用/测试数据层。

需求（m03294）：「按照实际业务逻辑将模块内的逻辑进行拆分归并并统一 UI 样式」。

## 方案

按「声明 → 状态 → 渲染 → 装配」四层拆分，并抽出共享 UI kit：

| 层 | 职责 | 位置 |
| --- | --- | --- |
| 声明层 | 每个模块有哪些入口（图标、副标题、tooltip、目标页面），与渲染无关 | `lib/features/<module>/<module>_entry_catalog.dart`、`lib/features/content_hub/content_module_catalog.dart` |
| 状态层 | 持有数据源、持久化 store、异步 Future、筛选/搜索/收藏状态，`extends ChangeNotifier` | `*_hub_controller.dart` |
| 渲染层 | 只读 controller，渲染列表/状态/网格；可独立 widget 测试 | `*_hub_body.dart`、`*_tab.dart` |
| 装配层 | 9 行外壳 → 真实页面：创建/释放 controller、AppBar、TabBar | `<module>_module_page.dart` |
| 共享 UI | token、入口卡/网格/分组、内容行/封面、状态占位、页面骨架 | `lib/features/shared/ui/` |

### 共享 UI kit

- `content_spacing.dart` / `content_radius.dart` / `content_accents.dart`：一个文件一个 token 类
  （`ContentSpacing` 4/8/12/16/24、`ContentRadius` 卡片 14 / 图标 12 / 封面 8、`ContentAccents`
  每个模块一个主题色：阅读 teal、小说 indigo、动漫 deepPurple、漫画 pink、影视 orange、
  聊天 green、直播 red、爬虫 blueGrey）；`content_tokens.dart` 仅作为 barrel 统一 re-export。
- `content_entry.dart`：`ContentEntry`（id/title/icon/subtitle/accent/tooltip + `builder` 或
  `onTap(BuildContext)`）、`ContentEntrySection`（title/description/entries）。
- `content_entry_card.dart`：`ContentEntryCard`（统一入口卡，保留 tooltip 以便测试与无障碍）、
  `ContentSectionHeader`（统一分组标题）、`ContentEntrySectionView`、`openContentEntry`、
  `showContentEntrySheet`。
- `content_entry_grid.dart`：宽度驱动列数（<360 1 列，360–619 2 列，620–899 3 列，否则 4 列；
  无界宽度回退 600）。
- `content_row.dart`：`ContentRow`（统一 Card+ListTile 行，含 cover/leadingIcon/trailing）与
  `ContentCover`（统一封面回退：无 scheme 或加载失败都用 icon）。
- `content_status.dart`：`ContentStatusView` 与 `AsyncContentView`（loading/error/empty/idle 四态
  一处实现，error 统一带重试按钮）。
- `module_page_scaffold.dart`：统一 Scaffold/AppBar/底部 TabBar 与页面 padding；并在模块页范围内
  用 `Theme` 覆盖 `cardTheme`（radius 14、elevation 0、antiAlias）与 `inputDecorationTheme`
  （isDense + OutlineInputBorder 12），不污染旧版 `views/` 页面。
- `content_navigation.dart`：`openContentPage`（一处路由封装）。

### 模块拆分结果

- 阅读：纯声明页，三段入口（书源与书库 / 找书与检索 / 社区与偏好）。
- 小说、漫画：同上，页面只剩「catalog → ListView」。
- 动漫：`AnimeHubController` + `anime_entry_tab` / `anime_recent_tab` / `anime_catalogue_tab` /
  `anime_search_tab` / `anime_favorites_tab` + `anime_show_list`（目录与搜索共用列表）+
  `anime_detail_launcher`（播放/详情导航 + 历史刷新）；页面变为 5 tab（入口/最近更新/目录/搜索/收藏），
  原「最近更新/目录/搜索/收藏」4 tab 的功能全部保留，「继续观看」AppBar 动作保留。
- 影视：`MovieHubController` + `movie_entry_tab` / `movie_discover_tab` / `movie_watchlist_tab`，
  页面 3 tab（入口/发现/片单）；原 15 个图标全部进入「入口」网格，endpoint/搜索/收藏逻辑不变。
- 聊天：`ChatHubController` + `chat_hub_body`；本地会话列表 + 「新建会话」对话框（含局域网聊天入口）
  保留，「微信本地界面演示」等入口进入网格。
- 直播：`LiveHubController` + `live_hub_body`；订阅地址校验、保存、分组列表、播放跳转不变。
- 爬虫：`CrawlerHubController` + `crawler_hub_body`；任务列表与 `CrawlTaskPage` 跳转不变。
- 内容中心：`contentModuleCatalog` 声明 8 个模块卡片，`ContentHubPage` 只负责渲染；删除旧
  `lib/features/shared/content_module_card.dart`。

## 验证

- `dart analyze lib test`：0 error / 9 warning / 1121 info（warning 与 info 均回到改动前基线；
  重构期间新增的 25 条 unused import 已清理）。
- `flutter test --no-pub`：1668 全通过（基线 1661 + `test/content_ui_kit_test.dart` 3 条
  + `test/content_module_refactor_test.dart` 4 条）。
- 新增测试覆盖：网格列数规则（359→1、360→2、420/619→2、620→3、900→4）；内容中心 8 卡与跳转阅读；
  影视页三个 tab + 入口 tooltip 仍可达；**持久化的非法影视地址会弹出统一错误提示**；
  **聊天「新建会话」对话框打开/取消**；**直播非法订阅地址被拒**；**动漫最近更新用 trailing
  图标标记已看/未看**。
- 既有测试未改动（仅迁移期已有的 messenger/short_video 入口测试），全部通过，说明入口与导航未被破坏。

## 独立审查与修复

由独立子代理完成一次回归审查（聚焦遗漏场景、潜在回归与修复完整性），共 13 项发现，
处理后逐项状态：

| # | 发现 | 处理 |
| --- | --- | --- |
| 1 | 动漫「已看」标记丢失（`leading` 与 `leadingIcon` 同传时后者被丢弃） | `anime_recent_tab.dart` 改用 `trailing`：已看 `check_circle_outline`、未看 `play_arrow`；`ContentRow` 文档同步更正 |
| 2 | 聊天「新建会话」对话框 `TextEditingController` 泄漏 | 提升为 `ChatModulePageState._conversationNameInput` 字段，打开前 `clear()`、`dispose()` 随 State 释放（直接在 `showDialog` 后 dispose 会在退场动画期间触发 "used after being disposed"，故用字段方案） |
| 3 | 直播 `http.Client` 从未关闭 | `LiveHubController.dispose()` 调用 `_repository.dispose()` |
| 4 | 启动自动重连失败时无提示 | `MovieHubController.load()` 返回错误文案，装配页 `showContentError` 弹出（新增测试覆盖） |
| 5 | 统一状态组件只落地一半 | 爬虫错误、动漫收藏空态、动漫搜索空态改用 `ContentStatusView`；影视片单空态文案恢复为 `暂无影视内容`；连接错误统一 `showContentError` |
| 6 | 「一个文件一个类」被破坏 | `content_tokens.dart` 拆为 `content_spacing/content_radius/content_accents` 三文件 + barrel；5 个模块页的 State 类重新拆回独立 `*_module_page_state.dart`；删除无引用的 `content_page_intro.dart` |
| 7 | `showContentEntrySheet` 仍用裸 `ListTile`；`showContentError` 无调用方 | 弹层行改用统一 `ContentRow`；`showContentError` 已用于影视连接与动漫详情错误路径 |
| 8 | 网格在 360dp 只有一列 | 阈值改为 `>=360` 两列，并对无界宽度回退 600.0 |
| 9 | `ContentRow` 文档与 API 不符 | 文档改为「`leading` 为空时才使用 `leadingIcon`」 |
| 10 | 影视入口 tab 硬编码 `12` 间距 | 改用 `ContentSpacing.md` |
| 11 | 内容中心分组间无间距 | 与各模块入口 tab 一致，补 `ContentSpacing.md` |
| 12 | 自动重连时 source 可能先建后弃 | `connect()` 先 `save` 端点，再判 `_disposed`，最后才创建/替换 source |
| 13 | 影视旧注释指向已删除文件 | 改为 `movie_entry_catalog.dart` |

审查中确认无需修改的一点：直播订阅错误仍以「输入框下方红字」就地展示，而不是居中
`ContentStatusView` —— 这是表单校验的就地反馈，属于不同场景，不强行套用占位组件。

修复后再次全量验证：`dart analyze` 0 error / 9 warning / 1121 info；`flutter test --no-pub` 1668 通过。

## 已知遗留

- `views/`（漫画首页、新闻、个人页）等旧页面未纳入本次统一，仍使用各自的 Scaffold/列表样式；
  它们不在 8 个内容模块页范围内，改动会波及未迁移逻辑。
- 模块内部二级页面（如 anime1、TakoPlay、Pixiv 等）保留各自页面骨架，仅在入口层统一。
- 尚未做设备/真机渲染确认：入口卡 padding 16→12、分组字号、48×48 封面裁切等视觉结果为
  组件层推断，建议安装最新包后人工过一遍 8 个模块（需用户自行编译安装，本次不主动构建 APK）。
- 网络行为未在测试中连真实服务验证（沿用迁移战役的既有结论）。
