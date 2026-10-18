# 内容工程源码迁移与依赖统一方案（2026-10-18 完结，含代码级盘点与 51 项回收）

> 2026-10-18 最终状态：110 个相关来源中 **51 个已迁入并回收**、42 个私有后端服务跳过（源目录保留）、7 个无真实业务保留、5 个原生阻塞保留（业务在 Rust/Go 侧，仓库内只有通道客户端）、4 个播放器/信令插件保留、1 个私有依赖阻塞保留 —— 无待迁入、无部分迁入。逐条证据在 `document/loggers/content-migration-triage.json`，执行日志在 `document/loggers/2026-10-17-content-migration-triage-and-wave1.log.md`，回收凭证在 `document/loggers/content-migration-retirements.json`（51 条，含归档 SHA-256 与条目数），库存报告在 `document/loggers/content-migration-inventory.json`。
>
> 宿主校验（2026-10-18，全部集成与回收之后）：`flutter test --no-pub` **1661 项全部通过**；`dart analyze` **0 ERROR / 9 WARNING / 1121 INFO**（与迁移前基线完全一致，无新增告警）。51 个已回收来源的可恢复快照在 `document/migration_backups/`。未迁入的来源目录一律保留、不删除。

> 2026-10-17 早先状态（历史）：110 个相关来源中 11 个已回收、3 个迁入待回收、4 个部分迁入、42 个私有服务跳过、10 个重复来源、6 个待迁入静态演示、5 个原生阻塞保留、4 个插件保留、7 个无业务保留、26 个待迁入。

> 2026-10-16 状态（历史）：110 个相关来源；5 个已回收、5 个部分迁入、26 个因私有服务跳过、1 个缺少私有引擎、73 个尚未开始。`zhihu-flutter` 静态阅读演示已按本地实际源码完整迁入并回收；`flutter_tiktok1` 仍仅部分迁入，源目录保留。

## 2026-10-16 `zhihu-flutter` 静态阅读工程迁入与回收

来源 Git HEAD `c1aaaac4c8e65001af15f3dd44ca21ec958ca31f`，工作区干净；README 明确为黑色主题 UI 高仿。全部 18 个应用 Dart 文件无登录、搜索请求、发布接口、私有服务或自定义原生业务；原 `pubspec.yaml` 除 Flutter 和旧版 `cupertino_icons` 外无业务依赖。宿主阅读入口新增“比乎阅读演示”，沿用根工程的 `cached_network_image`，没有添加上级目录路径依赖或旧包。原代码空回调保留为展示态，不能解释为已具备真实搜索、提问、关注或收藏服务。

| 原源码 | 宿主实际业务映射 |
| --- | --- |
| `main.dart`、`global_config.dart`、`index/index.dart`、`index/navigation_icon_view.dart` | `zhihu_demo_page.dart` 与独立状态类：五栏导航、局部深浅主题和“我的”页切换；宿主统一管理应用入口，不嵌套旧 `MaterialApp`。 |
| `home/home_page.dart`、`follow.dart`、`recommend.dart`、`hot.dart`、`article.dart`、`question.dart` | `zhihu_home_page.dart`、信息流/热榜页、文章与问题模型：关注四条、推荐两条、热榜五条原始样例和关注页广告，保留标题、摘要、统计及远程图片地址。 |
| `home/reply_page.dart`、`question_page.dart`、`search_page.dart`、`ask_page.dart` | 静态回答/问题相互可达；搜索热词与历史展示；提问标题输入及原来未实现的“下一步”禁用。无真实网络查询或发布。 |
| `my/my_page.dart`、`idea/idea_page.dart`、`market/market_page.dart`、`notice/notice_page.dart` | “我的”原有数字、菜单、视频封面、想法卡片与本地日夜主题开关；后三个主栏在源代码只有标题和空白，宿主如实留空。 |
| `test/widget_test.dart`、Android/iOS 模板、`image/1.png`～`5.png`、`lib.zip` | 原测试为旧计数器模板，用 `test/zhihu_demo_test.dart` 覆盖样例数量、阅读入口、问答路由、搜索/提问和主题切换；平台工程无定制逻辑，复用宿主。截图不参与运行；`lib.zip` 经检查是较早的同名 `lib/` 快照（例如其中“我的”页仅 569 字节），不是当前应用加载的另一套业务，均留在完整恢复快照。 |

本轮定向 `dart analyze` **无问题**，全量 `flutter test --no-pub` **49 项通过**。未主动构建 APK；设备端视觉效果、原有远程图片可达性未验证，需用户自行编译安装最新包检查。来源全部 **166 条目**（含 `.git`、截图和压缩包）归档为 `document/migration_backups/zhihu-flutter-c1aaaac4c8e6.tar.gz`，SHA-256 `8aef3dd03141435eafd5dba479b7190b758f40f6f8c2a9fc63cdb6d1af56920c`；移动前后全目录逐项校验一致。源路径已移入 `/Users/nathaniel/.Trash/dashboard-migration-20261016/zhihu-flutter`，未永久清除，可从废纸篓或快照恢复。其余未完成和私有服务来源均未删除。

## 2026-10-16 `Messenger` 源码迁移与回收

`Messenger` Git HEAD 为 `025b9933291bf905d041e10a880c7b45c51dbcb3`，工作区干净。本地源码是 WhatsApp 风格的**静态界面演示**，并非可收发消息的通讯工程；除 Unsplash 样例图片外无业务 API、私有后端、Firebase 或 IM 依赖。`pubspec.yaml` 声明的旧 `camera`、`video_player` 和 `path_provider` 没有被其 `lib/` 代码调用；Camera 页只有标题占位，因此不引入这些旧依赖。宿主从聊天模块工具栏打开独立演示页，复用根工程现有 `cached_network_image` 缓存远程样例图片。

同日还补齐了**仍保留源目录**的 `flutter_tiktok1` 音乐标题滚动：原布局/视频页每隔 3 秒在 200 像素视窗内将长标题横向滚到尾部，再以 1.5 秒返回。宿主新增 `ShortVideoMusicTitle` 与独立状态类，供布局和播放页复用，退出时释放计时器及滚动控制器。该改动只补足部分迁入的一项真实交互；原生解码、资产及逐文件覆盖尚未验收，因此不回收 `flutter_tiktok1`。

| 原文件 | 宿主落点及真实业务映射 |
| --- | --- |
| `lib/main.dart` | `messenger_demo_page.dart`、`messenger_demo_page_state.dart`：Home、Calls、Camera、Stories、Contacts 五栏与 `PageView` 滑动/底部切换；宿主继续管理应用入口和主题。 |
| `lib/model/chat_model.dart` | `messenger_chat_model.dart`：21 条原始会话预览数据和头像 URL 保留；Home 列表由 `messenger_demo_home_page.dart` 渲染。原工程点击列表无后续消息页，不伪造真实通信。 |
| `lib/model/calls_model.dart` | `messenger_call_model.dart`：9 条原始呼叫记录及语音/视频图标分支；`messenger_demo_calls_page.dart` 展示。没有发起呼叫逻辑。 |
| `lib/model/stories_model.dart` | `messenger_story_model.dart`：15 条原始横向动态预览、头像和已看边框；Home 负责展示。Stories 主栏在原工程只有占位。 |
| `lib/screens/home.dart`、`calls.dart` | 对应 `messenger_demo_home_page.dart` 与 `messenger_demo_calls_page.dart`，保留可滚动布局、远程图片和样例文本；原来未实现的搜索/更多按钮不制造空操作入口。 |
| `lib/screens/camera.dart`、`Stories.dart`、`Contacts.dart` | 三页原本只显示传入标题，统一由一个 `MessengerDemoPlaceholderPage` 按不同标题展示；不声称拍照、上传动态或通讯录已存在。 |
| `test/widget_test.dart` | 原文件仍是 Flutter 默认计数器测试，与此工程页面不符；由 `test/messenger_demo_test.dart` 覆盖数据数量、五栏切换及聊天入口。 |
| Android/iOS 模板及 `LICENSE` | 无自定义原生业务逻辑；使用宿主平台工程，原 MIT 文本原样保留在 `document/licenses/Messenger.LICENSE`。 |

Messenger 接入时组件回归 **45 项通过**；随后新增短视频滚动测试，最终全量 46 项通过，定向滚动标题 5 项通过，本轮新增文件定向 `dart analyze` 无问题；头像 URL 与许可文件已逐项比对。未主动构建 APK，真实设备 UI 和外部 Unsplash 图片可用性尚未验收。完整源目录（含 Git）共 139 条目，快照 `document/migration_backups/Messenger-025b9933291b.tar.gz` 的 SHA-256 为 `c268d563007d752e04e23fbc85f81e5c371e23e8c999415554afdfb05eaab7df`；移入 `/Users/nathaniel/.Trash/dashboard-migration-20261016/Messenger` 前后两次全量校验一致，可恢复。其他未完成来源未移动。

> 2026-10-15 复核：2026-10-13 的工作只完成导航入口、页面骨架及宿主依赖升级，不构成源工程业务源码迁移。本轮按用户确认的“所有相关工程（含本地改动）”扩大范围。只有业务能力在宿主运行且源码、资源、本地改动均核对完成后，才能回收对应源目录；现已完成 Billd 本地源码的业务迁入与验收并回收其目录，其他 107 个来源尚未完成。

## 本轮范围与验收口径

用户最新要求：将短剧、爬虫纳入上级目录源码迁移范围；包含私有后端服务的来源跳过，不再等待其服务配置，也不删除其目录。已存在的宿主适配代码保留，不回退其他工作。此前 108 个来源、1 个回收、7 个业务切片的数量属于上一阶段；本轮补入 `flutter_spider_fx` 与 `MagicMagnet`，最新数量以库存报告为准，不能视作全量迁移完成。

### 私有依赖及新增来源复核

- `flutter-movie-app-ui`：`lib/common/constant.dart` 写死私网影视后端，标记 `skipped_private_service`。
- `flutter-chat-demo`：`lib/main.dart` 初始化 Firebase，认证、FireStore 与 Storage 是业务必需服务，标记 `skipped_private_service`。
- `flutter-im`：README 明确要求另行部署 webchat 并配置地址，当前没有部署，标记 `skipped_private_service`。之前已迁入的局域网协议代码保留，不再以其本机协议测试作为源工程删除依据。
- `chat_app`、`flutter-chat-app`、`Flutter-Movie`、`newsbuzz`：业务代码直接使用 Firebase Auth、Firestore、Realtime Database 或 Storage，标记 `skipped_private_service`。
- `wechat_flutter`：会话和好友业务直接调用腾讯云 `V2TIMManager`；`FEhViewer`：全局业务创建 Firestore 客户端。两者同样跳过并保留目录。
- `dy_flutter`：原 API 固定为来源作者局域网 `192.168.97.142:1236`；`VideoCall-App-Flutter` 使用 Agora App ID/令牌；`zego-express-example-screen-capture-flutter` 使用 ZEGO App ID/签名；`FlutterTencentImPlugin` 的业务 API 依赖腾讯云 IM 登录。四者均跳过并保留目录。
- 进一步定位来源作者或用户自有服务：`bika_comics_client` 默认走作者服务器，`Book-Flutter` 启动时请求本机配置服务，`Flutter-MediaLibrary`、`flutter_hrlweibo` 使用工程专属 IP 后端，`flutter_readhub` 的 Web 分支走局域网代理，`FlutterTianYue`、`YeRead` 的 HTTP 分支指向局域网，`vvibe` 开发 API 指向局域网，`flutter_portal` 包含本机开发 API，`Ghosten-Player` 账户流程包含用户私有 WebDAV 服务。按“包含私有后端服务则跳过”统一保留这些源目录；源码中的公开接口或本地演示不因此视作已完成迁移。
- `MagicMagnet`：实际爬虫引擎为未提供源码的私有 Git 依赖，不等同于私有后端服务，单独标记 `blocked_private_dependency`，保留源目录，不迁一个空壳后删除。
- `Flutter-Project` 的动态发布、评论、时间线调用来源作者 `api.cleven1.com` 后端；`flutter_news` 的资讯从工程专属 IP 后端读取。按用户条件加入私有服务跳过清单，两个原目录均保留。
- `flutter_WeChat` 启动时即连接写死的来源作者 WebSocket `111.231.225.178:3001`，消息业务依赖它，按同一规则跳过；含本地未跟踪生成文件的源目录原样保留。
- `flutter_spider_fx`：本地任务框架及公开网页选择器，无私有服务依赖。补齐宿主爬虫入口、任务详情、配置保存、开始/暂停/继续/停止、日志清理、链接结果和 JSON 文件导出；验证与删除结论见下文最新日志。
- 短剧：扫描兄弟目录的 README、pubspec 与 Dart 源码，目前仅在 `flutter_gromore_ads` / `flutter_qq_ads` README 中命中外部 `flutter_adcontent_pro` 推荐，未找到本地短剧业务实现；不将广告插件或链接当作已迁入的短剧模块，不据此删除这些目录。

2026-10-15 扩展盘点已枚举宿主以外 359 个目录，将其中 108 个内容应用及专用媒体插件纳入迁移清单，共 10,550 个非缓存 Dart 文件；33 个来源存在本地改动或 Git 状态异常。逐文件 SHA-256、Git HEAD、工作区状态、子包与目录分类保存在 `document/loggers/content-migration-inventory.json`，可用 `python3 tool/content_migration_audit.py` 重建。该报告是盘点依据，不能作为自动删除授权；它明确排除生成缓存，删除时的恢复快照仍须包含完整原目录。另有 `flutter_wechat_camera_picker` 作为配套插件等待依赖图确认。

上级目录中首先识别出以下 39 个名称明确相关、且包含 Dart 源码的工程，合计 4156 个 Dart 文件。进一步筛查又发现 `dmzj_flutter`、`flutter_dmzj`、`flutter_shuqi`、`LegadoFlutter`、`YueY`、`yyets_flutter`、`ZY_Player_flutter`、`Tako-Play`、`Ghosten-Player`、`FlutterDouBan`、`FlutterTianYue`、`OpenJMU`、`EasyMyGo`、`pikapi-flutter`、`flutter_tiktok`、`flutter_live`、`flutter_rtmppublisher`、`flutter-im`、`flutter-webrtc-demo`、`flutter_campus_social_app`、`Messenger` 等可能相关工程，仍须按 `pubspec.yaml`、README 与业务代码逐一判定。补充枚举还发现 `eso`、`FEhViewer`、`nhentai-cross`、`AnimeOne/animeone`、`dart_simple_live` 多包工程、`douyin` 多包工程等明显可能相关来源，因此最初的 39 个远非完整范围。没有根目录 `lib/` 的目录也可能是多包工程，不能仅凭目录名或文件数量决定删除。

| 内容域 | 初始候选目录 |
| --- | --- |
| 阅读/小说 | `book`、`book_app`、`Book-Flutter`、`flutter_books`、`FlutterEbookApp`、`YeRead`、`flutter_novel`、`flutter_read`、`flutter_readhub` |
| 动漫 | `AnimeTV`、`anime_trace` |
| 漫画 | `comic_flutter`、`comic_flutter1`、`bika_comics_client`、`haka_comic`、`PicaComic`、`flutter_manhuatai` |
| 影视/视频 | `FlutterMovies`、`Flutter-Movie`、`MovieApp`、`flutter-movie-app-ui`、`dytt_flutter`、`eyepetizer_flutter`、`flutter_bilibili` |
| 聊天/通话 | `wechat_flutter`、`flutterWechat`、`flutter_WeChat`、`flutter-wechat`、`fake_wechat`、`chat_app`、`flutter-chat-app`、`flutter-chat-demo`、`flutter_chat1`、`VideoCall-App-Flutter` |
| 直播/IPTV | `easy_tv_live`、`my_tv`、`billd-live-flutter`、`alltv_flutter`、`dy_flutter` |

每个源工程单独建立业务映射：功能入口、数据模型、网络/存储/解析服务、界面流程、资产、平台权限、测试或手工验收。不是直接复制应用入口或添加 `../` 路径依赖。根 `pubspec.yaml` 是唯一的宿主依赖入口；无法统一的私有服务、密钥和平台插件须先明确适配与验证方案，不能静默丢弃。源工程中的未提交改动按用户数据保留并比对。

删除门槛：该目录的所有业务能力完成迁移并在宿主验证；迁移清单和差异核对无遗漏；保留可恢复快照；再针对明确目录移入系统废纸篓，并在日志中列明。目录中 Git 元数据、未跟踪文件和资源在删除前也必须纳入核对。

## 背景

`dashboard` 已包含漫画、新闻和轻小说的历史实现。上级目录另有多个独立 Flutter 应用，分别覆盖阅读、小说、动漫、漫画、影视、聊天和直播。它们的 Dart SDK 范围跨越 Dart 2 与 Dart 3，且各自带有独立的应用入口、Android/iOS 配置和依赖版本，不能直接把整套工程复制到宿主项目。

本次迁移以 `dashboard` 为唯一应用宿主：功能在宿主内以独立页面和服务边界呈现，依赖仅由根 `pubspec.yaml` 管理。

## 2026-10-13 的有限来源选择（已被本轮范围取代）

| 内容域 | 已选来源/现有能力 | 迁移方式 |
| --- | --- | --- |
| 阅读 | `YeRead`、现有 `views/reader` | 复用现有阅读器并在模块中心提供统一入口 |
| 小说 | `flutter_novel`、现有 `views/novel` | 复用已在宿主内的小说首页和阅读器 |
| 动漫 | `AnimeTV` | 迁移其“最近更新、目录、搜索、收藏”信息架构，保留网络数据源适配边界 |
| 漫画 | `haka_comic`、`flutter_manhuatai`、现有 `views/comic` | 以现有漫画模块为宿主入口，避免迁入 Rust、原生下载和窗口管理插件 |
| 影视 | `FlutterMovies`、`flutter-movie-app-ui` | 迁移影视浏览的信息层级，使用宿主的统一网络与图片能力 |
| 聊天 | `wechat_flutter`、`flutter-chat-demo` | 迁移会话列表/消息展示交互；云 IM 与 Firebase 配置留在可替换的适配边界，避免把外部账号配置写入工程 |
| 直播 | `billd-live-flutter` | 迁移首页、分区、排行、我的四栏结构；通过统一服务接口加载列表 |

## 依赖统一原则

1. 根工程升级为 Dart 3 约束，移除指向上级目录的 `common_utils` 和 `flutter_easyrefresh` 路径依赖。
2. 统一使用发布版的跨平台依赖：`dio`、`provider`、`shared_preferences`、`cached_network_image`、`flutter_easyrefresh`、`webview_flutter`、`sqflite` 等。
3. 将已废弃依赖替换为其维护中的同源包：`share` → `share_plus`、`connectivity` → `connectivity_plus`、`wakelock` → `wakelock_plus`、`package_info` → `package_info_plus`、`battery` → `battery_plus`。
4. 对需要云端密钥、Firebase 配置、私有插件、特定桌面运行时或 Git 依赖的工程，单独设计可配置适配器并验证平台构建；不能以依赖困难为由把对应业务直接排除在用户确认的范围之外，也不能复制生产凭据。

## 验收标准

1. 对全部确认相关的源工程逐项建立源码、资源、本地改动、功能及平台配置映射，不只覆盖七类导航入口。
2. 每项原业务流程在宿主运行，且根 `pubspec.yaml` 统一管理可解析依赖；不能依赖原目录路径或仅做链接。
3. 执行静态分析、自动化测试及需要真实服务的验收；按用户最新规则不主动构建 APK，涉及真机 UI 或新原生能力的验收由用户编译安装最新包后进行。私有服务来源跳过，不得宣称完成；未验证平台需明确列出。
4. 逐工程比对迁移前后能力与数据，保留可恢复快照，最后才移除原目录。

## 风险与处理

- 历史漫画/小说代码正处于本地未提交的空安全改造中。本次不回退或覆盖这些文件，只在其外围接入。
- 原始第三方接口可能失效或受服务端限制。模块页面必须提供加载失败态，且不把网络调用写进 `build`。
- 视频播放、云 IM、直播推流涉及平台权限、播放器和服务端鉴权；先保留适配边界并列明待接入项，不伪造可用的生产凭据，也不把未接入项计作已完成。

## 2026-10-15 实际迁移进度

| 来源与内容域 | 已纳入宿主的业务切片 | 仍未完成的部分 |
| --- | --- | --- |
| `book`，阅读 | HTML 章节清理与 Legado 风格替换规则；网页章节读取界面 | 书源引擎、书架、分页、下载、资源和原工程其余能力 |
| `AnimeTV`，动漫 | 最近更新、五类目录与筛选、电影/OVA 直接播放、搜索、详情、收藏元数据、剧集倒序与已看标识；视频解析、内置播放器、相邻剧集、最近观看与进度恢复 | 原站点跳转后返回 Cloudflare 403，未通过真实原生播放验收；资源及逐文件完整覆盖仍须核对，源目录保留 |
| `comic_flutter`，漫画 | U17 分页/搜索/完整详情、原始 `location` 图片字段、关注、阅读历史、继续阅读与上下章；锁定章节不开放读取 | 真实 API、平台运行、原工程资源与逐文件覆盖核对，以及其他漫画工程 |
| `flutter-movie-app-ui`，影视 | 推荐、搜索、详情、后端 URL 配置、按后端隔离片单；用选中影片主键获取分组剧集、统一内置播放与上下集 | 原后端仅有私网地址；真实服务、评论、账户与逐文件映射、更多影视工程 |
| `flutter-chat-demo`，聊天 | 消息模型改造与本地会话持久化 | Firebase/腾讯云 IM、联系人、群聊、音视频和其他聊天工程 |
| `flutter-im`，聊天 | `/echo` WebSocket、设备标识、在线用户、文字双向收发、未读数、重连和断开、每会话 100 条缓存与清理；本机相机/相册预览与配置帮助 | 真实部署服务、原生拍照和选图验收未完成；来源没有图片发送协议，因此选图明确标为仅本机预览，源目录保留 |
| `easy_tv_live`，直播 | M3U/TXT 分组解析、多线路去重、订阅保存；频道接入统一内置播放器并可切换全部线路 | 原生播放验收、EPG、遥控器、设备同步、其他直播工程 |
| `billd-live-flutter`，直播 | 6 个 Dart 文件的四栏导航及 `/live/list` 适配、8 张图标；真实接口、组件测试和 Android 构建通过，已移入废纸篓且保留全目录快照 | 来源 README 的推流/支付/PK 属于其他仓库，并非该 Flutter 目录已有功能；本轮未新增这些业务 |

除 Billd 已按本地实际源码完成映射与回收外，其他条目仍是业务切片，不能计作整个来源迁移完成。其余未列出来源尚未开始；未完成的源目录不删除。

## 删除前的特殊风险

- `flutter_read` 的 `.git/index` 报 `bad signature`，因此普通 Git 状态检查不能用于判断其文件是否已完整迁移。
- `anime_trace` 的 Git 状态显示 9 个 `.gradle` 跟踪文件删除；`comic_flutter` 存在未跟踪 `ios/Podfile`。其他候选也有本地改动，必须逐项保存与核对。
- `flutter-movie-app-ui` 的原后端写死为 `http://169.254.32.117:5001`，这是私网地址，宿主虽已改为可配置，但不能在无服务的情况下声称线上功能已验收。
- 原站点 API 可能停用或限制访问；测试使用本地模拟响应，只证明协议解析与流程，不证明真实站点可用。
- `billd-live-flutter` 原代码调用 `/live/list` 时未带 `nowPage`、`pageSize`，2026-10-15 实测返回 HTTP 400；补上参数后返回 HTTP 200、空房间列表。没有伪造在线房间或其详情路由。
- `flutter_live` 并非仅有一个业务页面，而是含 Android/iOS 原生实现、WebRTC/RTMP 资源与示例应用的 Flutter 插件；迁移其直播播放/推流能力时必须核对插件原生接口和平台权限，不能按根 `lib/` 中的 Dart 文件数判定为已完成。
- `flutter-im` 的文字通讯已迁入，但只使用本机 WebSocket 测试服务验证协议，未连接用户的真实聊天部署。未引入旧 `device_info` 的硬件标识收集，改为用户指定设备别名。

## 2026-10-13 阶段性结果（不代表源码迁移完成）

1. 已在 `lib/features/` 新增内容中心，并按阅读、小说、动漫、漫画、影视、聊天、直播划分为独立页面；这些多数仍是占位页面。阅读、小说和漫画入口复用宿主已有功能，不等同于上级目录工程源码已迁入。
2. 根导航新增“内容”页，原漫画、新闻、轻小说和我的入口继续保留。
3. `pubspec.yaml` 已升级到 Dart 3，并移除全部 `../` 路径依赖。已将 `share`、`battery`、`connectivity`、`wakelock`、`package_info` 分别迁移至维护中的 `*_plus` 包；WebView、Dio 和历史控件 API 也已适配当前 Flutter SDK。
4. Flutter 自动更新了受依赖变更影响的平台插件注册文件，以及 Android Gradle 的兼容配置；这些均是新插件版本所需的生成结果。
5. 修复启动时无更新信息仍弹窗并解包空 URL 的问题，更新检查现在仅在完整更新信息存在时发起外部跳转。

## 2026-10-13 验证记录（旧阶段）

| 命令 | 结果 |
| --- | --- |
| `flutter pub get` | 通过，锁定根工程统一依赖 |
| `dart analyze --format=machine` | 0 个 `ERROR`；遗留代码仍有 9 个 warning 与 1121 个 lint info，未阻断编译 |
| `flutter test` | 通过；覆盖内容中心的七模块入口和直播页面跳转 |
| `flutter build apk --debug` | 已启动并完成 Android 产物下载，但旧 Gradle 工程在当前环境中长时间无日志输出；为避免留下并发构建进程，已停止该验证，未将其记作构建通过 |

## 2026-10-15 验证记录

| 命令 | 结果 |
| --- | --- |
| `flutter pub get` | 通过；新增根依赖 `html`，不引用上级路径 |
| `flutter test` | 最新全量 25 个测试全部通过；新增收藏元数据/旧格式兼容、电影与 OVA 路由、已看/收藏/倒序交互，以及选图取消和本机图片读取测试。完整输出见 `document/loggers/content-migration-tests-20261015.log` |
| `dart analyze --format=machine` | 本轮新增代码 0 个 ERROR/WARNING；工程仍有 9 个历史 WARNING |
| Billd 真实 API | `/live/list?nowPage=1&pageSize=20` 返回 HTTP 200、空 `rows`；只验证了该请求，不代表直播观看可用 |
| Android 构建 | 最新包含动漫与选图改动的 `flutter build apk --debug --no-pub` 成功，产物 `build/app/outputs/flutter-apk/app-debug.apk`。Gradle 9.3.1 / AGP 9.1.1 / Kotlin 2.4.10 / NDK 28.2；详细输出在 `document/loggers/content-migration-android-20261015.log`。未安装到真机，原生媒体解码和拍照未验收；Kotlin 插件仍有未来兼容提醒 |

## 统一播放依赖

根 `pubspec.yaml` 统一使用 `media_kit`、`media_kit_video`、`media_kit_libs_video`，不把各来源旧播放器版本同时带入宿主。`lib/features/media/` 负责播放、线路切换、原生资源释放、后台暂停与进度存储，动漫侧只负责来源协议和上一集/下一集。实现依据为 [media_kit 官方包文档](https://pub.dev/packages/media_kit)，原生平台运行仍需验收。新增文件遵守一个类一个文件。

## Billd 逐文件验收映射与恢复依据

本地 HEAD 为 `89f7bb9fac915f25971651be0db3bcb0eb361ac3`，工作区干净。README 是整个 Billd 生态的说明，列出的推流、支付、PK 等未出现在这个 Flutter 来源的源码中，不视作该目录已有能力，也不宣称本轮实现这些能力。

| 原文件/资产 | 宿主落点与处理 |
| --- | --- |
| `lib/main.dart` | `BilldLivePage` / `BilldLivePageState`，四栏导航进入内容中心直播模块；应用主题和启动统一由宿主管理 |
| `lib/api/request.dart` | `BilldLiveRepository` 使用根 Dio；迁入实际调用的 GET `/live/list`；无调用方的通用 POST 包装由 Dio 原生接口覆盖，不另建旧客户端 |
| `lib/views/home/home.dart` | 请求只在初始化和刷新时执行，不再在 `build` 内再次调用 `initState`；列表、空态、错误态由宿主展示 |
| `lib/views/rank/rank.dart`、`area/area.dart`、`user/user.dart` | 源代码均只有标题，没有排行、分类或登录业务；宿主保留同名栏位和空态，不伪造服务 |
| `assets/images/tabbar/` 8 张 PNG | `assets/billd_live/tabbar/` 原样迁入，逐文件比较相同，根 assets 注册 |
| Android MainActivity、Manifest、图标和 Gradle | 无自定义原生逻辑；复用宿主 FlutterActivity、网络权限、包名、启动图和统一构建。源模板仍完整保留在恢复快照 |

完整快照：`document/migration_backups/billd-live-flutter-89f7bb9fac91.tar.gz`。`tool/verify_migration_archive.py` 比对原目录所有 215 个文件/目录/链接，包括 `.git` 与被忽略文件；校验通过，SHA-256 为 `9cb5ae37210362af5d518e6e99e6f4407b3b83ff9dddd71d56f64766827ca8e2`。源目录已移入 `/Users/nathaniel/.Trash/dashboard-migration-20261015/billd-live-flutter`，移动前后两次全目录校验一致。回收凭证与原始盘点记录保存在 `document/loggers/content-migration-retirements.json`；库存报告保留已回收条目，避免后续刷新丢失迁移历史。

## 来源许可保留

已将本轮实际改编来源 `book`、`AnimeTV`、`comic_flutter`、`flutter-chat-demo`、`easy_tv_live`、`flutter-im` 的原许可证保留到 `document/licenses/`。未找到许可证文件的来源不臆造许可证；本任务只在当前工作区迁移，未执行发布或上传。toast 升级依据为 [上游 changelog](https://pub.dev/packages/fluttertoast/changelog)。

## 2026-10-15 爬虫来源逐文件业务映射

`flutter_spider_fx` 原 HEAD 为 `4c32b85d25fee0a5e88a1f605fed6720404a7a8c`，Git 工作区干净；15 个 lib Dart 文件与 1 个原模板测试已检查。迁入的是下列本地实际业务，不声称增加原工程没有的递归爬取、反爬绕过、登录或短剧服务。

| 来源 | 宿主处理 |
| --- | --- |
| `lib/main.dart`、`framework/common.dart`、`framework/index.dart`、`route/index.dart` | 不嵌套独立应用，接入现有内容中心与宿主初始化；根依赖管理 |
| `route/home.dart`、`route/task_details.dart` | `CrawlerModulePage` / `CrawlTaskPage` 及各自独立 State 文件，任务状态、日志、详情与控制；原“新任务”“启动全部”“暂停全部”仅提示/打印或空回调，不冒充已有批处理逻辑 |
| `framework/task.dart` | `CrawlTask`、`CrawlState`、`CrawlConfig`、`CrawlExporter`；真正取消、暂停结果提交、避免旧请求覆盖新运行；配置/日志导出改为应用文档目录 JSON 文件 |
| `framework/logging.dart` | `CrawlLog` 和任务日志队列，保留五级日志、时间、1024 条上限、清理和导出；页面使用可解绑监听，不保留已销毁页面回调 |
| `framework/network.dart` | `CrawlHttpClient` 统一 Dio + html + enough_convert，限时、2 MiB 响应、最多 3 次重定向；UTF-8/GB2312/GBK 解码，移除同步 sleep 与无限重试。未被业务调用的通用图片下载/请求头辅助不单独建立新下载业务，原实现保留于完整快照 |
| `framework/persistence.dart` | `CrawlConfigStore` 按任务命名空间保存配置，兼容损坏 JSON/值类型，使用根 SharedPreferences；导出使用现有 path_provider，不申请旧全盘存储权限 |
| `spider/ithome_spider.dart`、`cnradio_news_spider.dart` | 保留原选择器，同时适配当前公开页的 `#rank .order.sel a` 与 `.row1 .col-l .list-before a`；实际 GET 提取 12/15 个链接 |
| `spider/ligui_spider.dart` | 保留原网址及 `ul.img li` 的 `a.href` / `img.alt` 提取，用户手动启动；用本地 HTML 验证，没有自动访问相册网站。未被调用的 `Album` 序列化示例不作为额外业务，原文件保留于快照 |
| `spider/test_spider.dart` | 本地日志演示保留十轮五级日志，改为异步循环，可暂停/停止，不阻塞界面 |
| `temp/isolate_test.dart`、`test/widget_test.dart` | 独立 isolate 实验入口及 Flutter 计数器模板不是主程序业务；未接入宿主，完整快照保留。新增解析、HTTP、生命周期、存储/导出和 UI 流程测试替代不相关模板测试 |
| 资源、Android/iOS 模板、README、LICENSE | 原 `assets/mzitu/` 在磁盘不存在且无引用，不伪造资产；无自定义原生业务，复用宿主平台配置。截图、未使用 ARB、原启动图和 Git 全部纳入快照；许可证逐字节保留为 `document/licenses/flutter_spider_fx.LICENSE` |

验证：`flutter test --no-pub` 全量 **36 项通过**；本轮 Dart 文件定向分析 **No issues found**；真实 HTTP 测试包括取消在途响应、重定向、GB2312、拒绝响应、超大响应；组件测试覆盖入口、无自动抓取、暂停/继续、清理日志和页面退出。

独立审查以本轮前临时快照为基线，范围为爬虫接入与新增 UI/导出/测试、内容中心入口、库存跳过分类，不审查或覆盖其他既有用户改动。发现并修复：运行输入未固定、异步导出目录可能使用变化后的任务 ID、损坏偏好值类型未回退；追加回归测试后通过。此前测试发现的 Dio 取消 API 与 URL 空锚点问题也已修复。收益是把原来不完整的解析切片接成可操作且有限资源占用的采集流程。

未覆盖：本轮没有构建 APK、未安装真机；原生文件目录和设备 UI 仍需用户编译安装最新包确认，iOS 旧环境阻塞未解除。相册站只验解析，不宣称在线可用；公开新闻站结构变化仍可能使选择器失效，UI 已支持修改配置。完整快照 `document/migration_backups/flutter_spider_fx-4c32b85d25fe.tar.gz` 含 Git 和忽略文件，共 161 条目；SHA-256 `1bb9ffd526fc72dc8277db9cd3f5b984c4297ae1b9e27870eeed1eb3cc742e7e`。最终回收动作以回收凭证和执行日志为准。

## 2026-10-15 DoDu 源码与本地改动核对

源码共有 6 个应用 Dart 文件及 1 个默认模板测试。`main.dart` 的独立 MaterialApp 由宿主代管；`tabbar_controller.dart` 的三栏状态和切换迁入 `DoduPage` / `DoduPageState`，入口在阅读模块。`bookshelf_page.dart` 实际只有空 ListView 和立即完成的下拉刷新；宿主提供空态和相同的刷新动作。`bookstore_page.dart`、`me_page.dart` 均只显示标题；宿主保留对应栏位，不虚构书城数据或登录。`do_screen_adapter.dart` 是未被业务调用的屏幕尺寸包装，宿主采用现有自适应布局，不引入旧 ScreenUtil 版本。

来源 README 声称本地导书、搜索、在线阅读、书架管理、翻书效果已完成，但这些实现并不存在于本地 6 个应用 Dart 文件中，不能据此声明迁入这些能力。实际使用的三栏导航图标 6 张以及各自的 2x 版本逐字节迁入 `assets/dodu/`。来源 `assets/json/` 的图书/章节样例和其余 PNG 在代码中没有引用，完整恢复快照保留；不把样例数据接成伪造的线上书城。

原 Git HEAD 为 `8438f68834cd614f7815c5bb9c094b109a9c3a3c`，工作区有 9 个已删除 `.idea` 跟踪文件。回收快照按**当前磁盘状态**而非干净 HEAD 制作，含其余全部 Git 元数据、资源与忽略文件；`tool/verify_migration_archive.py` 在移动前后对比 395 条目一致，SHA-256 为 `a3cb6316dd7995d31ca29ece5aea78b5ee86edc5f230b479a10cfa1c5c736f4f`。开发者配置文件的删除状态可由快照里的 Git 恢复，不回填原目录。原目录已移入 `/Users/nathaniel/.Trash/dashboard-migration-20261015/DoDu`；回收凭证记录了原始文件指纹。全量 37 项测试通过，定向 Dart 分析无问题；未构建 APK，真机 UI 尚需用户编译安装最新包验收。

## 2026-10-15 短视频本地演示迁移（来源保留）

`flutter_tiktok1/flutter_tiktok` 是纯本地短视频交互演示，包含 13 个 Dart 文件、两段打包 MP4、演示图。三个主入口已适配到影视页：双击点赞、横向关注/推荐布局、竖向视频列表。视频切换时只实例化当前页播放器，使用根工程统一的 `media_kit` 与 `asset:///` 资源 URI，其他页面只显示封面；点击暂停/继续、单片循环、后台暂停和释放播放器均接入。演示的图片、两段 MP4 按源文件复制并逐字节比对，不引入原 `video_player`/`chewie`/`flukit` 版本。

原工程的点赞数、评论数和分享数是写死的展示数据，宿主明确标注“示例互动”，未接入虚构后端。基础布局和双击动画已覆盖组件测试；原生视频解码、各平台资产加载、部分字幕横向滚动及原项目所有源码/资源的完整核对仍待完成，所以 `flutter_tiktok1` **只计部分迁入，源目录保留，不生成回收凭证**。这不是短剧来源，也不能冒充短剧业务已迁入。

## iOS 配置迁移与当前阻塞

- 按本机 Flutter 3.47 SDK 的 Podfile 模板统一插件安装，移除旧 `.flutter-plugins` 解析和手工复制 Flutter.framework；最低 iOS 版本由 8 提升到 15，Swift 4 提升到 5，与当前工具链要求一致。
- 补充相机、照片库、局域网权限用途说明；拍照/选图只由用户点击发起，当前协议不上传图片。`image_picker` 根依赖锁定为 1.2.4，取消和本地字节读取测试通过。用法依据 [官方插件文档](https://pub.dev/packages/image_picker)。
- Flutter 构建自动迁移了 Xcode project、scheme、workspace、AppDelegate `@main` 与 Swift Package Manager 集成；保留这些工具链兼容变更。生成的 `ios/Flutter/ephemeral/` 不进入版本控制。
- `ruby -c ios/Podfile`、`plutil -lint` 均通过，但 `flutter build ios --simulator --no-codesign --no-pub` **未通过**。`xcodebuild -showdestinations` 明确报 `iOS 26.5 is not installed`；本机没有 simulator runtimes，也找不到 `pod` 命令，媒体插件 `media_kit_video` / `media_kit_libs_ios_video` 尚不支持 SPM，仍需 CocoaPods。
- 未安装 Xcode 平台组件或 CocoaPods，未将未验证的 iOS 配置记作构建成功；旧 `Podfile.lock` 待可用环境重新解析。构建日志保存于 `document/loggers/content-migration-ios-20261015.log`。
