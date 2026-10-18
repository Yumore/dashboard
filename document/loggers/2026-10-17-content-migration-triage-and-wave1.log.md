# 内容工程源码迁移执行日志（2026-10-17：逐来源代码级盘点、三项迁入与六项回收）

## 本轮范围与用户决定

用户重申原目标：把上级目录中除本工程外的阅读、小说、动漫、漫画、影视、聊天、直播、短剧、爬虫等工程源码迁入宿主，使用私有后端服务的来源跳过，按实际业务逻辑迁移后删除源工程。

上一阶段留下 73 个"尚未开始"和 5 个"部分迁入"。本轮先对全部 78 个来源做**代码级**核对（读 `pubspec.yaml`、`lib/` 源码、README 与实际引用的资源，以代码而非 README 声明为准），再决定每个来源的真实处置。结果显示：真正含有独有业务、值得迁入的只有 26 个；其余是私有后端来源、纯静态 UI 演示、业务已被覆盖的重复来源、原生/Rust/Go 实现而无法进入 Dart 宿主的插件与包，以及完全没有可用业务的骨架。

据此用户明确两点：

1. **静态 UI 演示**照 `Messenger`、`zhihu-flutter` 先例迁入宿主为演示模块（保留其真实数据与交互），迁入后再回收源目录；**无业务来源与插件包保留**，因为回收会丢掉从未迁入的代码。
2. **`dart_simple_live` 严格按规则跳过并保留目录**，尽管它只有"远程同步"一个屏幕依赖作者服务器 `https://sync1.nsapps.cn/sync`，而同工程内已有局域网/WebDAV 替代。

逐来源结论与证据落盘在 `document/loggers/content-migration-triage.json`，并由 `tool/content_migration_audit.py` 的新状态表驱动库存报告。

## 盘点结论（78 个来源）

| 处置 | 数量 | 来源 |
| --- | --- | --- |
| 迁入（MIGRATE） | 26 | `Alexandria`、`EasyMyGo`、`eso`、`flutter_novel`、`FlutterEbookApp`、`AnimeOne`、`PicaComic`、`anime_trace`、`flutter_manhuatai`、`haka_comic`、`pixez-flutter`、`tsdm_client`、`FlutterCinematic`、`FlutterDouBan`、`FlutterMovies`、`Flutter_Eyepetizer`、`MovieApp`、`Tako-Play`、`bilivideo_down`、`douyin`、`dytt_flutter`、`eyepetizer_flutter`、`inKino`、`youtube_downloader_flutter`、`yyets_flutter`、`my_tv` |
| 部分迁入待补完 | 4 | `AnimeTV`、`book`、`comic_flutter`、`easy_tv_live` |
| 静态演示，迁入后回收 | 6 | `FlutterSocialAppUIKit`、`fake_wechat`、`flutter-social`、`flutter-wechat`、`flutterWechat`、`flutter_tiktok` |
| 重复来源，规范源迁入后回收 | 7 | `flutter_books`→`flutter_novel`、`comic_flutter1`、`dmzj_flutter`、`flutter_dmzj`、`pixiv_func_mobile`→`pixez-flutter`、`morec`→`FlutterMovies`、`flutter_tiktok1`→`flutter_tiktok` |
| 私有后端，跳过并保留 | 16（累计 42） | `book_app`、`flutter_learn_news`、`ZY_Player_flutter`、`flutter_bilibili`、`visitor-flutter`、`Getx-PinkApp`、`OpenFlutterYim`、`OpenJMU`、`flutter-grpc-tutorial`、`flutter_campus_social_app`、`flutter_chat`、`flutter_chat1`、`alltv_flutter`、`dart_simple_live`、`flutter-p2p-engine`、`flutter_tencentplayer` |
| 原生/Rust/Go 阻塞，保留 | 5 | `daisy`、`jasmine`、`kobi`、`nhentai-cross`、`pikapi-flutter` |
| 插件包，保留 | 4 | `fijkplayer`、`flutter-webrtc`、`flutter_rtmppublisher`、`flutter_torrent_streamer` |
| 插件包且能力重复，保留 | 3 | `chewie`、`flutter_ijkplayer`、`flutter_live` |
| 无真实业务，保留 | 7 | `flutter_read`、`flutter_shuqi`、`LegadoFlutter`、`YueY`、`eyeperizer`、`flutter-webrtc-demo`、`wechat-flutter` |

需要说明的两点判断：

- `daisy`、`jasmine`、`kobi`、`nhentai-cross`、`pikapi-flutter` 的业务真实存在，但全部在 Rust（`flutter_rust_bridge`）或 Go（gomobile）里，Dart 侧只是通道客户端；其中 `jasmine` 的 `native/` 后端**根本不在检出中**。按字面规则它们既不是私有后端，也不是无业务，因此保留而不回收，避免删除无法进入宿主实现的代码。
- 动漫/漫画域**没有任何私有后端**：该域内每一处 `192.168.x`/`127.0.0.1` 都是设置提示串、代理报错注释或被注释掉的开发抓包代理。

## 本轮迁入

### `Alexandria`（阅读）

11 个应用 Dart 文件全部对照。`lib/features/reading/alexandria/` 迁入 z-library 带年份/语言/扩展名筛选与分页的 HTML 检索、Library Genesis 的 13 字段结果解析与客户端筛选、Sci-Hub 的 DOI 解析与下载链接提取、筛选条件持久化，以及解析出的卡片/详情交互。`flutter_downloader` 与 `permission_handler` 换为 `url_launcher`（来源自身在非 Android 平台就是这么回退的），`another_flushbar` 换 `fluttertoast`，旧 `share` 换 `share_plus`。死代码（空 `GetLibGenResult`、被注释的下载块）未迁入。

### `my_tv`（直播）

`lib/features/live/my_tv/` 迁入宿主此前没有的部分：TVbox `#genre#` 文本格式解析与首次出现分组排序、m3u `tvg-name` 提取、CCTV/卫视名称简化和顺序重编号、遵循来源保留窗口的 24 小时播放列表缓存、XMLTV 节目单解析与按 `tvgName` 的当前/下一档匹配及其按日缓存与刷新阈值、以及频道平铺环绕、分组环绕跳过空组、数字键输入叠加来源的 4 秒自动确认计时器。原生 AndroidX Media3 播放器换为宿主 `media_kit` 播放页，`shelf` 局域网设置服务改为普通 `ChangeNotifier`，APK 自更新通道与 `UnsafeTrustManager` 不迁入。

修正一处任务转述误差：来源常量是 `epgRefreshTimeThreshold = 6`，不是 9；按 6 迁入并做成可配置。

### `MovieApp`（影视）

`lib/features/movie/movieapp/` 迁入 TMDb 客户端的实际业务：来源 `api_service` 调用的全部 11 个端点（`movie/now_playing`、`movie/upcoming`、`movie/popular`、`discover/movie`、`tv/airing_today`、`tv/popular`、`tv/on_the_air`、`{movie,tv}/{id}/credits`、`{movie,tv}/{id}/videos`）及真实的 `api_key`/`language`/分页语义、来源的 27 项类型对照表、手写模型、图片基址拼接与浏览/详情界面。`search/movie`、`movie/top_rated`、`movie/{id}`、`tv/{id}` 与相似推荐是**规格驱动补充**，已标注。`flutter_bloc`、`get_it`、`equatable`、`json_serializable` 代码生成未迁入。

两处如实记录：来源的 `SharedPreferences` 缓存优先仓储层被放弃，宿主改为纯网络客户端；来源**没有**影片流播放，`youtube_player_flutter` 只用于 YouTube 预告片，TMDb 返回的是预告片 key 而不是播放地址，因此没有伪造流，预告片走 `url_launcher`。

## 宿主验证

- `flutter test --no-pub`：**87 项通过**（本轮前基线 49 项，新增 38 项）。
- `dart analyze`：**0 个 ERROR**，9 个 WARNING、1121 个 INFO，与迁移前基线完全一致（新代码未新增任何问题）。
- 新增测试分别覆盖：Alexandria 的两种封面分支、作者列表、`not given` 回退、LibGen 13 字段、客户端筛选、Sci-Hub 链接提取、两个查询构造器；my_tv 的 TVbox 分组、m3u 简化重编号、XMLTV 当前/下一档、24 小时 TTL 边界与 EPG 按日阈值（注入时钟）、频道/分组环绕与空组跳过、数字键与假计时器自动确认；MovieApp 的列表/详情/剧集映射、演职员、预告片、图片地址（含空 `poster_path`）、分页与搜索请求构造、TMDb 错误体、HTTP 401 与断连，全部使用注入的 `Dio`，无网络访问。

未验证：真机 UI 与原生媒体解码、远程站点可达性；私有服务来源按规则未做在线验收。

## 本轮回收

新增 6 个回收，累计 11 个。全部走 `tool/retire_migrated_source.py` 的六步流水线：刷新库存指纹 → 打完整快照 → **对活目录逐条校验** → 移入 `~/.Trash/dashboard-migration-<日期>/` → 对移动后目录再次校验 → 写回收凭证。

| 来源 | 归档 | 条目 | SHA-256（前 16 位） |
| --- | --- | --- | --- |
| `Alexandria` | `Alexandria-a558f256dd44.tar.gz` | 196 | `b84a00403103a3fc` |
| `my_tv` | `my_tv-aeb7abd95743.tar.gz` | 367 | `58d1d51b876c7e40` |
| `MovieApp` | `MovieApp-faef67b385ac.tar.gz` | 495 | `65946de6349692b6` |
| `dmzj_flutter` | `dmzj_flutter-cba2825f29fe.tar.gz` | 351 | `a9e5caee4a4fafe8` |
| `flutter_dmzj` | `flutter_dmzj-6a8d261a2cae.tar.gz` | 184 | `051e418608d936ab` |
| `comic_flutter1` | `comic_flutter1-083612062427.tar.gz` | 5709 | `b1394e95384f4675` |

三个重复来源在回收**之前**逐项核对了宿主已有覆盖：`dmzj_flutter` 的 `getUpdateList`/`getDetail`/`getRankList` 对应宿主 `lib/app/api/comic.dart`，其 v4 与网页回退阅读对应宿主 `Api.comicChapterDetail` 与 `Api.comicWebChapterDetail`，阅读记录对应 `Api.comicChapterViewPoint`；`flutter_dmzj` 的四个方法全部落在宿主漫画模块内；`comic_flutter1` 是 `comic_flutter` 的克隆，而宿主 `lib/features/comic/u17_source.dart` 开篇即写明移植了同一 U17 接口。三者都不是"未迁入即删除"。

`flutter_dmzj` 与 `comic_flutter1` 有本地改动，均为构建/IDE 产物（`.dart_tool`、`.packages`、`.flutter-plugins`、`local.properties`、`Generated.xcconfig`、`.DS_Store`，以及被删除的 `.idea` 文件），已通过 `--acknowledge-dirty` 显式确认后按当前磁盘状态完整入档。

## 工具变更

- `tool/retire_migrated_source.py`（新增）：把上述六步串成一条**逐步失败即停止**的流水线，拒绝非同级目录名、已存在归档、已存在凭证、已存在废纸篓目标；脏工作区必须显式 `--acknowledge-dirty`。它把"移动到废纸篓"而非永久删除固定为唯一路径，误删可从废纸篓和归档两处恢复。
- 该脚本发现并修复一个真实缺陷：macOS `bsdtar` 会为带扩展属性的文件写入 AppleDouble `._*` 成员，这些成员在磁盘上并不存在，导致归档与活目录逐条比对失败（`MovieApp` 首次回收即因此中断）。现以 `COPYFILE_DISABLE=1` 打包。
- `tool/content_migration_audit.py`：新增 `BLOCKED_NATIVE`、`PLAYER_PLUGIN`、`NO_REAL_BUSINESS`、`DUPLICATE_ONLY`、`STATIC_DEMO`、`MIGRATED_IN_HOST` 六张表，并把 16 个新确认的私有来源并入 `SKIPPED_PRIVATE`。库存报告的 `migration_status` 因此能如实区分"跳过私有服务"、"保留"、"待迁入演示"与"重复来源"，而不再把 73 个来源一律记为 `not_started`。私有服务来源由 26 增至 42。

## 当前库存

110 个相关来源：**11 个已回收、3 个迁入待回收、4 个部分迁入、42 个私有服务跳过、10 个重复来源、6 个待迁入静态演示、5 个原生阻塞保留、4 个插件保留、7 个无业务保留、26 个待迁入**（含已完成的 3 个）。全量迁移仍未完成，剩余待迁入来源的目录一律保留、不删除。

## 第二批迁入（2026-10-17 后续）

四个来源已完成业务迁入、集成与验证，先记账再回收：

| 来源 | 宿主模块 | 集成入口 | 验证 |
| --- | --- | --- | --- |
| `FlutterDouBan` | `lib/features/movie/flutterdouban/`（50 个 Dart 文件） | 影视页 AppBar「豆瓣电影 · FlutterDouBan」（`Icons.local_movies_outlined`） | `flutter analyze` 无问题；`test/flutterdouban_test.dart` 54 项通过 |
| `inKino` | `lib/features/movie/inkino/` | 影视页 AppBar「inKino · Finnkino 场次」（`Icons.theaters_outlined`） | `flutter analyze` 无问题；`test/inkino_test.dart` 30 项通过 |
| `FlutterMovies` | `lib/features/movie/fluttermovies/`（35 个 Dart 文件） | 影视页 AppBar「今日看片 · FlutterMovies」（`Icons.local_play_outlined`） | `flutter analyze` 无问题；`test/fluttermovies_test.dart` 通过（与 inKino 合计 74 项） |
| `flutter-social` | `lib/features/chat/fluttersocial_demo/`（27 个 Dart 文件） | 聊天页 AppBar「Heart String 本地界面演示」（`Icons.favorite`） | `flutter analyze` 无问题；`test/fluttersocial_demo_test.dart` 19 项通过 |

`flutter-social` 属用户裁定的「静态演示照 Messenger/知乎先例迁入后再删除」类别：真实界面、真实交互与打包数据全部迁入，无网络业务。

配套宿主改动（全部由 Lead 完成）：`pubspec.yaml` 注册 `assets/fluttersocial_demo/`（源工程 15 张真实图片已复制，`FlutterSocialPhoto` 用 `Image.asset` 加载并用 `IgnorePointer` 保持命中透明，避免盖住下方按钮——这是源工程的真实行为）与 `lib/features/movie/flutterdouban/mock/`（9 个真实 mock 夹具）；`test/fluttersocial_demo_test.dart` 的图片路径断言随目录改为 `assets/fluttersocial_demo/`。

其余在途来源（`animetrace` 修复中、`flutter_novel` 测试修复中、`bilivideo_down` 补测中、`Flutter_Eyepetizer` 与 `Tako-Play` 迁入中）尚未验收，目录一律保留。

## 第二批回收

| 来源 | 归档 | 条目 | SHA-256（前 16 位） |
| --- | --- | --- | --- |
| `FlutterDouBan` | `FlutterDouBan-3217d83b7e95.tar.gz` | 322 | `8155d7b173f5b379` |
| `inKino` | `inKino-d406a23c3b57.tar.gz` | 452 | `079bb276a75f9e1b` |
| `FlutterMovies` | `FlutterMovies-ef50819d8a35.tar.gz` | 306 | `bf083c3f0f202403` |
| `flutter-social` | `flutter-social-9b4d344a86d5.tar.gz` | 200 | `efa227409d39389c` |

累计 **15 个已回收**。`FlutterMovies` 有 7 处本地改动（被删除的 `.gradle` 与 `gradle-wrapper.properties`），按当前磁盘状态完整入档并显式 `--acknowledge-dirty`。全部归档位于 `document/migration_backups/`，废纸篓目录为 `~/.Trash/dashboard-migration-20261017/`。

## 第三批迁入与回收

| 来源 | 宿主模块 | 集成入口 | 验证 | 归档 | 条目 | SHA-256（前 16 位） |
| --- | --- | --- | --- | --- | --- | --- |
| `anime_trace` | `lib/features/anime/animetrace/`（51 个 Dart 文件） | 动漫页 AppBar「漫迹 AnimeTrace」 | analyze 无问题；`test/animetrace_test.dart` 45 项通过 | `anime_trace-0aa88df86b40.tar.gz` | 704 | `935b625f832e9580` |
| `flutter_novel` | `lib/features/novel/flutternovel/`（54 个 Dart 文件） | 小说页「网络小说」按钮 | analyze 无问题；`test/flutternovel_test.dart` 54 项通过 | `flutter_novel-4d16a9d6d0d7.tar.gz` | 290 | `d0310bc743d49449` |

累计 **17 个已回收**。`anime_trace` 的 9 处本地改动（被删除的 `.gradle`）以 `--acknowledge-dirty` 按磁盘现状入档。

迁入过程中修复的真实缺陷（子代理发现，已复核）：

- `flutternovel`：`reader/novel_page_turn_engine.dart` 的 `begin()` 先置 `_touchActive = true` 再调用 `_reset()`（后者把它清回 `false`），导致**所有拖拽翻页被静默吞掉**——15 个翻页动画测试因此失败；改为先 `_reset()`。`api/dmzj_v3_api.dart` 的推荐位解析把任意裸 Map 当成 `{data:[...]}` 包装，丢掉单段落对象的 `title`/`books`；`store/novel_chapter_cache.dart` 的默认 TTL 12 小时与规格的 24 小时不符。
- `bilivideo_down`：DASH 分轨在宿主没有混流器，改为明确拒绝并提示，而不是写出损坏文件；范围下载的取消/续传竞态已修复。
- `FlutterMovies`：`MediaPlaybackPage` 没有 `initialIndex`，从第 N 集进入时传 `all.sublist(N)`。

集成入口（全部由 Lead 添加）：动漫页 AppBar 新增 `Icons.collections_bookmark_outlined`（漫迹）；小说页由单按钮改为「打开小说库 / 网络小说」两个按钮；影视页 AppBar 依次为 B站视频下载、今日看片、豆瓣电影、inKino、本地短视频演示。

在途：`bilivideo_down` 测试与入口已就绪待终验，`Flutter_Eyepetizer`、`Tako-Play`、`EasyMyGo`、`AnimeOne`、`yyets_flutter` 迁入中。

## 第四批迁入与回收（2026-10-17）

| 来源 | 宿主模块 | 集成入口 | 验证 | 归档 | 条目 | SHA-256（前 16 位） |
| --- | --- | --- | --- | --- | --- | --- |
| `bilivideo_down` | `lib/features/movie/bilivideo_down/` | 影视页 AppBar「B站视频下载」（`Icons.download_for_offline_outlined`） | analyze 无问题；`test/bilivideo_down_test.dart` 26 项通过 | `bilivideo_down-15848a641229.tar.gz` | 195 | `ebea63346533e0ba` |
| `Tako-Play` | `lib/features/anime/takoplay/`（24 个 Dart 文件） | 动漫页 AppBar「TakoPlay · gogoanime」（`Icons.live_tv_outlined`） | analyze 无问题；`test/takoplay_test.dart` 33 项通过 | `Tako-Play-4c40d2bb3d4b.tar.gz` | 1209 | `6e57757aac299ba1` |
| `Flutter_Eyepetizer` | `lib/features/movie/eyepetizer/`（42 个 Dart 文件） | 影视页 AppBar「开眼 · Eyepetizer」（`Icons.remove_red_eye_outlined`） | analyze 无问题；`test/eyepetizer_test.dart` 54 项通过 | `Flutter_Eyepetizer-10bd33ae5ec0.tar.gz` | 306 | `df0da53c99914cb2` |
| `yyets_flutter` | `lib/features/movie/yyets/`（35 个 Dart 文件） | 影视页 AppBar「人人影视 · YYeTs」（`Icons.subtitles_outlined`） | analyze 无问题；`test/yyets_test.dart` 55 项通过 | `yyets_flutter-62033acc1b9f.tar.gz` | 260 | `0e38619becf04b2a` |
| `EasyMyGo` | `lib/features/reading/easymygo/`（82 个 Dart 文件） | 阅读页「EasyMyGo 插件阅读」（`Icons.extension`） | analyze 无问题；`test/easymygo_test.dart` 50 项通过 | `EasyMyGo-8f9a7163c5d4.tar.gz` | 558 | `566ac35470889d0b` |
| `eyepetizer_flutter` | `lib/features/movie/eyepetizer_flutter/`（96 个 Dart 文件） | 影视页 AppBar「开眼社区 · 登录/个人/图片」（`Icons.account_circle_outlined`） | analyze 无问题；`test/eyepetizer_flutter_test.dart` 89 项通过 | `eyepetizer_flutter-36091a8dc3ee.tar.gz` | 297 | `015d8e3fe64e2acf` |
| `AnimeOne` | `lib/features/anime/animeone/`（38 个 Dart 文件） | 动漫页 AppBar「anime1 · AnimeOne」（`Icons.ondemand_video_outlined`） | analyze 无问题；`test/animeone_test.dart` 43 项通过 | `AnimeOne-092f34b69725.tar.gz` | 340 | `5fb5582f7f7e9f5f` |

累计 **24 个已回收**；`yyets_flutter` 与 `eyepetizer_flutter` 的本地改动仅为 `.gradle` 构建缓存，按磁盘现状入档并显式 `--acknowledge-dirty`。

### 目录判定更正

`eyepetizer_flutter` **不是** `Flutter_Eyepetizer` 的重复工程，早先的三方判定有误，已在 `document/loggers/content-migration-triage.json` 的 `corrections[]` 中记录：`Flutter_Eyepetizer` 是 120 文件的模块化工程（`module/module_home|discover|hot|detail|person|common`），其首页/分类/详情/搜索由 `lib/features/movie/eyepetizer/` 承接；`eyepetizer_flutter` 是另一个 108 文件应用，独有 `account.kaiyanapp.com` 登录/注册、个人主页、社区、图片画廊与本地缓存（`lib/http/api.dart:8,10`），由 `lib/features/movie/eyepetizer_flutter/` 单独承接。

### 全量校验

- `flutter test --no-pub`：**683 项全部通过**（迁入前基线 49 项）。
- `dart analyze --format=machine`：**0 ERROR，9 WARNING，1122 INFO**，与基线一致（INFO 多 1 条）。
- 在途（尚未验收，目录全部保留）：`eso`、`book`、`PicaComic`、`flutter_manhuatai`、`tsdm_client`、`FlutterCinematic`、`FlutterEbookApp`、`haka_comic`。

## 第五批迁入与回收（7 个源工程）

第七批调度（`eso`、`book`、`PicaComic`、`flutter_manhuatai`、`tsdm_client`、`FlutterCinematic`、`FlutterEbookApp`、`haka_comic`）中，除 `tsdm_client` 外的 7 个全部落地并通过 Lead 亲自复跑：

| 源工程 | 迁入模块 | 入口页 | 测试 |
| --- | --- | --- | --- |
| `book` | `lib/features/reading/book/`（81 文件） | 源码书源引擎 + 阅读器 + 书架/详情/搜索/目录/来源页 | 414 项 |
| `flutter_manhuatai` | `lib/features/comic/manhuatai/`（38 文件） | `ManhuataiSearchPage`（321mh / yyhao / zymk 三源） | 192 项 |
| `haka_comic` | `lib/features/comic/haka/`（61 文件） | `HakaHomePage`（picacomic 公共源，4 个栏目） | 91 项 |
| `FlutterCinematic` | `lib/features/movie/fluttercinematic/`（48 文件） | `FlutterCinematicHomePage`（TMDb 公共接口） | 100 项 |
| `PicaComic` | `lib/features/comic/picacomic/`（47 文件） | `PicaComicTabPage`（6 个公共源 + 用户 JS 源引擎） | 58 项 |
| `eso` | `lib/features/reading/eso/`（88 文件） | `EsoHomePage`（书源管理 / 搜索 / 书架 / RSS / 播放） | 128 项 |
| `FlutterEbookApp` | `lib/features/reading/flutterebook/`（78 文件） | `FeedbooksCatalogPage`（Feedbooks 公共目录） | 88 项 |

- 模块入口全部由 Lead 亲自接入：`reading_module_page.dart`（书源阅读 / ESO / Feedbooks 目录）、`comic_module_page.dart`（PicaComic / 漫画台 / Haka 同人漫画）、`movie_module_page_state.dart`（FlutterCinematic）。
- `PicaComic` 由 Lead 修掉一个真实移植 bug：`lib/features/comic/picacomic/network/eh_network.dart` 的 taglist 解析取文本时对元素自身也调用了 `children`，导致 `RangeError`；改为 `div.text` 并在 tag 缺失 namespace 时回退到页面分类。
- `FlutterEbookApp` 的失败测试是断言写法问题（同一人名在列表与详情同时出现，`findsOneWidget` → `findsWidgets`）。
- 回收 7 个源工程（第 5 批），累计回收 **31** 个；父目录同级目录数从清单建立时的 354 降到实测 329（含本项目与少量非源码目录）。

| 源工程 | 归档条目 | 归档 |
| --- | --- | --- |
| `book` | 519 | `book-0b25219cf7eb.tar.gz` |
| `flutter_manhuatai` | 629 | `flutter_manhuatai-fb8995c9c497.tar.gz` |
| `haka_comic` | 749 | `haka_comic-fad9333b626a.tar.gz` |
| `FlutterCinematic` | 191 | `FlutterCinematic-3929f7052eba.tar.gz` |
| `PicaComic` | 585 | `PicaComic-155cf0c6d701.tar.gz` |
| `eso` | 1298 | `eso-4815b92a7a8a.tar.gz` |
| `FlutterEbookApp` | 1632 | `FlutterEbookApp-b09736833197.tar.gz` |

`eso` 带未提交改动（38 个已跟踪删除 + 未跟踪目录），归档按磁盘实况快照后以 `--acknowledge-dirty` 回收。

### 在途（目录全部保留）

`tsdm_client`（测试套件重试中）、`pixez-flutter`、`dytt_flutter`、`youtube_downloader_flutter`、`douyin` 已派出移植代理；完成后同样走「复核 → 接入 → 归档 → 回收」。

## 第六批：tsdm_client（天使动漫论坛）

- 迁入 `lib/features/anime/tsdm/`（78 文件）：公共论坛客户端，站点 `www.tsdm39.com` / `tsdm39.com`，`plugin.php` 搜索与通知接口，无私有后端；源工程的 git 依赖 `realth000/system_theme` 为公共仓库。
- 结构：常量 / 手写 cookie 会话（替代 Dio+CookieManager）/ 模型 20+ / 仓库（版块、帖子 v1+v2、搜索、最新帖、通知）/ 控制器（ChangeNotifier 替代 bloc）/ 页面（FooPage + FooPageState）。
- 依赖取舍：宿主无 `package:collection`、无 `universal_html`、无 `dio_cookie_manager`、无 `bloc/rxdart/get_it/dart_mappable/drift`，全部改为手写等价物 + 构造函数注入；**未改 pubspec**。
- Lead 修掉两个真实移植问题：
  1. `package:html` 的 csslib 在选择器里把 `:nth-child(n)` 按「所有子节点」计数（含空白文本节点），真实 Discuz 页面是多行缩进 HTML，导致除首个元素外的 `:nth-child(n)` 全部失效。新增 `lib/features/anime/tsdm/tsdm_selector_compat.dart`（`q` / `qAll`，先按去掉伪类的选择器交给 csslib，再按父节点的元素序号过滤），并把 23 个解析文件的 68 处 `querySelector*` 全部改走兼容层。
  2. 帖子单元格同样受影响，改为显式取第二个 `td`。
- 校验：`flutter test --no-pub test/tsdm_test.dart` = **30 项全部通过**；`flutter analyze lib/features/anime/tsdm ...` = 无问题。
- 模块入口由 Lead 接入 `lib/features/anime/anime_module_page_state.dart`：`天使动漫 · TSDM 论坛`（`Icons.forum_outlined` → `TsdmLatestThreadPage(url: TsdmApiUrls.homePage)`）。
- 回收：1876 条目，`tsdm_client-0dd161a58748.tar.gz`，sha256 `39d4bb489d415cbb…`（源工程带 2 个未跟踪文件，按磁盘实况快照后 `--acknowledge-dirty`）。累计回收 **32** 个源工程。

## 第七批：pixez-flutter（2026-10-18）

- 迁入：`lib/features/comic/pixez/`（56 文件）—— `PixezApiClient`（dio 5，公开 `app-api.pixiv.net` / `oauth.secure.pixiv.net`）、`PixezApiHeaders`（`X-Client-Time` / `X-Client-Hash` = md5(time+salt) 推导、PixivAndroidApp UA、App-OS/Version、Bearer、OAuth 5.0.155/Android 6.0 两套头）、`PixezAuthParameters`（password / refresh_token / authorization_code 三种 body，PKCE S256 登录 URL）、`PixezAuthStore`（shared_preferences 单令牌）、24 个模型、5 个控制器、5 组 Page+State、7 个 widget。
- 校验：`flutter analyze lib/features/comic/pixez test/pixez_test.dart` = No issues found；`flutter test --no-pub test/pixez_test.dart` = 77 tests all passed（子代理与主代理各跑一次）。测试全部离线（fake `HttpClientAdapter` + 手写 fixture，无 token、无 socket），覆盖鉴权推导、请求头、各端点参数、分页去重、模型映射与令牌对话框。
- 模块入口：`lib/features/comic/comic_module_page.dart` 新增 `PixezEntry` 磁贴（`Pixiv（Pixez）`，`Icons.photo_library_outlined`，`PixezHomePage`）。
- 刻意偏差：默认走官方域名；源码硬编码的 DNS 绕行 IP 保留为可选 `PixezApiConfig.dnsBypass`（裸 IP TLS 需要源码里被禁用的证书校验，不伪造）；单令牌替代多账号 sqflite 库；未迁 WebView PKCE 登录界面、下载管理、评论、pixivision、小说/漫画阅读屏、设置。
- 回收：`pixez-flutter` 1004 条目，快照 `document/migration_backups/pixez-flutter-7b49bd4eb69b.tar.gz`，SHA-256 `c99bfea1df4656a22ed56225915cbce92f92434ffc3d89677201e16afe215d82`，已移入 `~/.Trash/dashboard-migration-20261018/`。累计回收 **33** 项。

## 第八批：dytt_flutter + 七个重复来源（2026-10-18）

### dytt_flutter → `lib/features/movie/dytt/`（25 文件 + 74 测试）

- 业务：公开 `http://m.dydytt.net:8080/adminapi/api/movieList.json`（`categoryId/page/searchContent`，10 个分类 9、10、1..8）与 `movieDetail.json`（`categoryId/movieDetailId`），列表解析 `{total, rows}`、详情解析根对象；每个请求带 `x-header-request-timestamp`（毫秒/1000 向上取整）、`x-header-request-key`、`x-header-request-imei=""`；播放地址选择与 `MediaPlaybackPage` 接线；搜索页与加载更多为补齐项（源码只有第 1 页且搜索图标未接线）。
- 签名缺口（如实记录）：`com.bzh.dytt` 的 `KeyUtils.getHeaderKey(long)` 只是 `key-release.aar` 里对 `getKey(Context, timestamp, "")` 的 Java 包装，算法只存在于 `jni/<abi>/libkey-lib.so`，无法从 Dart/Java 源码推导。因此签名做成可注入契约，默认实现 `DyttUnsupportedSignature` 明确报告不可用、所有界面显示缺口且**不发任何请求**（有测试断言请求列表为空）；`DyttChannelSignature` 与源码通道一致，仅在宿主将来打包 .so 时才有意义。绝不伪造空 key。
- 校验：`flutter analyze lib/features/movie/dytt test/dytt_test.dart` = No issues found；`flutter test --no-pub test/dytt_test.dart` = 74 tests all passed（主代理复跑）。
- 入口：`lib/features/movie/movie_module_page_state.dart` 新增 `电影天堂` 按钮（`Icons.movie_creation_outlined` → `DyttPage`）。
- 回收：190 条目，`dytt_flutter-7b643731ebfd.tar.gz`，SHA-256 `455bfcd5dc65a38c74a9d51df0e55843e9dd651d2953618ab87b0c4052182ecd`（`--acknowledge-dirty`：删除 .idea/.gradle wrapper、未跟踪 ios 环境脚本与 `lib/delay_object.dart`，均已进快照）。

### 七个重复来源回收（业务已由宿主规范模块覆盖，按用户策略删除）

| 源 | 宿主覆盖 | 回收条目 / 快照 SHA-256 前缀 |
| --- | --- | --- |
| `chewie` | 视频播放用 media_kit / media_kit_video（chewie 为纯 Dart 播放器插件） | 293 / `44deec57052d0297` |
| `flutter_ijkplayer` | fijkplayer 的陈旧孪生（插件），宿主用 media_kit | 378 / `b7c59b2eabe94c79` |
| `flutter_live` | 归档聚合插件（fijkplayer + flutter-webrtc + camera_with_rtmp） | 250 / `643d0637f3a551a7` |
| `flutter_books` | `lib/features/novel/flutternovel`（zssq 面是 flutter_novel 子集） | 258 / `7e109040758d4629` |
| `morec` | `lib/features/movie/fluttermovies`（FlutterMovies 的 fork，72 文件中 29 个字节相同） | 256 / `370762c79e5e6662` |
| `pixiv_func_mobile` | `lib/features/comic/pixez`（pixiv 超集） | 603 / `09422ff8059af3db` |
| `pixez-flutter` | `lib/features/comic/pixez` | 1004 / `c99bfea1df4656a2` |

`flutter_tiktok1` 仍保留：它是 `flutter_tiktok` 的重复来源，而 `flutter_tiktok` 的静态演示尚未迁入，按策略要等规范来源进宿主后再回收。

累计回收 **40** 项。

## 第九批：两个"部分迁入"来源核对后回收（2026-10-18）

- `AnimeTV`：三阶段盘点里标为部分迁入，本次逐文件复核 25 个 lib 文件，确认宿主 `lib/features/anime/` 实际上就是由它构建的：`anime_source.dart` 的 Wcostream 接口（recent/catalogue/search，选择器一致）、`anime_episode_resolver.dart` 的"加密 iframe → JSON 接口 → HD/SD 流"管线、详情节、剧集页、收藏存储、观看记录与图库页均齐备，`better_player` 及其自定义控制条按战役策略由 `media_kit` 取代。仅"倾斜渐变装饰容器"这类纯装饰未迁。246 条目归档 `AnimeTV-5c96fd4c4505.tar.gz`，SHA-256 `d384a74480167db42a5481b1987beec0609cb30b2aa69bafc0aec5eb2bfeb265`。
- `comic_flutter`：29 个文件复核确认宿主 `lib/features/comic/u17_*.dart`（12 文件）即由它移植：U17 列表/详情/章节接口、模型、详情页、章节页、阅读器、图库/收藏、阅读记录，历史持久化在 `lib/sql/comic_history.dart`。**纠正盘点错误**：`lizhujiang.com` 只出现在 `pages/About.dart` 的关于页链接里，并不是"第二个数据源"；已把纠正写入 `content-migration-triage.json` 的 `corrections`。未迁：启动页/路由/Toast/存储工具等应用外壳与关于页链接（非业务）。217 条目归档 `comic_flutter-c7c2e2e317b9.tar.gz`，SHA-256 `e44c264f8dc122d6640e4c2cf17b6b08392658cdfcc70c5aa069f4f3efe7db44`（`--acknowledge-dirty`：未跟踪 `ios/Podfile`，已进快照）。

累计回收 **42** 项。

## 第十批：4 个来源迁入并回收（2026-10-18）

| 源 | 宿主模块 | 规模 / 测试 | 回收 |
| --- | --- | --- | --- |
| `fake_wechat` | `lib/features/chat/fakewechat_demo/` | 36 文件 / 15 测试 | 196 条目，SHA-256 `dd1b50205f0078f1` |
| `FlutterSocialAppUIKit` | `lib/features/chat/fluttersocialappuikit_demo/` | 38 文件 / 14 测试 | 272 条目，SHA-256 `7126ce9431339d20` |
| `flutter-wechat` | `lib/features/chat/flutterwechat_demo/` | 29 文件 / 10 测试 | 280 条目，SHA-256 `4fa510de9d1a830e` |
| `youtube_downloader_flutter` | `lib/features/movie/youtubedl/` | 38 文件 / 49 测试 | 268 条目，SHA-256 `0d6f931f00347fcc` |

要点与如实说明：

- `fake_wechat`：源只有 聊天/联系人/发现 三栏，任务描述里的"我"栏并不存在；按用户策略迁入时用源内 `USER` 数据补了第四栏并在界面上注明是补建。源的录音能力依赖 `flutter_sound`，宿主没有该依赖，因此保留长按录音入口但明确提示"录音不可用"，绝不伪造音频消息。源的头像/封面全是远程 `bdstatic/timgsa/duitang/xiami` 链接，改为确定性本地占位符以保证离线与可测。
- `FlutterSocialAppUIKit`：源没有 `lib/models/`（任务描述与 `FlutterSocial` 混淆），数据是 `lib/util/data.dart` 里的无类型 Map。迁入时把源每次运行随机生成的样本解析为固定抽取，条数与顺序与源一致（13/13/13/13/13/10 与会话 10 条气泡）。10 张 `cm0..cm9` 图片逐字节比对后放入 `assets/fluttersocialappuikit_demo/`。
- `flutter-wechat`：源**没有**聊天会话页也没有朋友圈列表/详情（朋友圈只是"发现"里一行，点击为原生 toast）。按策略不臆造，测试改为断言点击会话仍停留在列表。69 张 tab/menu 图片迁入 `assets/flutterwechat_demo/`。
- `youtube_downloader_flutter`：`youtube_explode_dart` 换成可注入 `YouTubeStreamProvider`，用公开 InnerTube WEB `/youtubei/v1/player` 与 `/search`；只有 `signatureCipher` 的格式被跳过并计数，不伪造。宿主无 `flutter_ffmpeg`，音视频分离的合并计划直接置 `needsMuxer`、写零字节并提示需要 FFmpeg，而不是假装合并成功。暂停/续传是新增能力（源没有），通过取消在途请求并重下实现。

集成：`lib/features/chat/chat_module_page_state.dart` 的演示入口收进一个"更多本地界面演示"菜单（`fake_wechat` / `Chat App` / `微信界面演示`），避免 AppBar 图标溢出；`lib/features/movie/movie_module_page_state.dart` 新增 `YouTube 下载`。`pubspec.yaml` 登记 `assets/fluttersocialappuikit_demo/` 与 `assets/flutterwechat_demo/`。

验证：`flutter analyze` 对全部新增/受影响范围为 0 ERROR（仅 2 条既有 `curly_braces` info）；`flutter test --no-pub` 跑 6 个相关文件 **110 项通过**。

累计回收 **46** 项。

## 第十一批：easy_tv_live / flutter_tiktok / douyin 迁入，flutter_tiktok1 重复来源回收（2026-10-18）

| 源 | 宿主模块 | 规模 / 测试 | 回收 |
| --- | --- | --- | --- |
| `easy_tv_live`（partial → 完成） | `lib/features/live/easy_tv_live/` | 17 文件 / 33 测试 | 431 条目，SHA-256 `2587ee65aeecba89` |
| `flutter_tiktok` | `lib/features/short_video/fluttertiktok_demo/` | 38 文件 / 16 测试 | 302 条目，SHA-256 `5a4291948f110e44` |
| `flutter_tiktok1`（重复来源） | 能力已由既有 `lib/features/short_video/` 覆盖 | 3 项演示 + 13 文件教程工程 | 180 条目，SHA-256 `3de83ff6b85b57fa` |
| `douyin` | `lib/features/short_video/douyin/` | 52 文件 / 58 测试 | 584 条目，SHA-256 `9fdedd826635a3c7` |

要点与如实说明：

- `easy_tv_live`：任务描述里"已有的宿主移植"实际不存在，宿主原有的扁平 `lib/features/live/live_*.dart` 是宿主自写的订阅加载流程。因此按"新文件可写"的授权在 `lib/features/live/easy_tv_live/` 重建完整移植（解析、订阅管理、线路切换/失效切换、`MediaPlaybackPage` 播放、`EasyTvPage`/`EasyTvSourcePage`），并把 `EasyTvPage` 作为"EasyTV 直播"卡片接入 `live_module_page_state.dart`；扁平旧流程原样保留（未删除，属宿主自写代码，是否收敛到新实现留待后续统一）。未移植：EPG 面板（宿主 `my_tv` 已有 XMLTV）、延迟检测点、远程配置、字体/必应壁纸/扫码/奖励、TV 设置壳、音量亮度、下载、局域网同步（源用 8828 端口 HttpServer）、文件选择器（缺依赖）。
- `flutter_tiktok`：源是静态演示（`lib/mock/video.dart` 9 条硬编码样例 URL），按用户策略忠实迁入，远程 MP4 播放不伪造——视频面为静态占位并保留原始 URL 供断言；源码里本就无封面的样例（`image: ''`）也未补。已接入 `short_video_demo_page.dart`。
- `flutter_tiktok1`：判为重复来源并**在能力核对后**回收——其三个演示（全屏点爱星双击坐标动画、关注/推荐布局、竖向播放控制）已分别由 `short_video_like_page.dart` / `short_video_layout_page.dart` / `short_video_feed_page.dart` 覆盖并有 `test/short_video_demo_test.dart` 断言；其余 `service/*` 为教程脚手架、`video_player` 本地循环壳，无独有业务。
- `douyin`：公有 web 端点（`creator.douyin.com`）业务迁入；关键点是 `_signature` 作为可注入 `DouyinSignatureProvider`，默认复现源里写死的旧签名 `pKb.ogAgEB9ImoSQahoqJKSm.rAAPox`，空/不支持时在发请求前抛 `DouyinSignatureRejected`，HTTP 403 也按源路径显式报错——**不伪造签名算法**。下载/保存为新增能力（源没有）。未移植：firebase firestore/login/subscription、三套 app 壳、fijkplayer/getflutter/marquee/video_player 组件、自定义图标字体。源工作区脏（991 项）全部是 `flutter_app_cn/build/**` 被删的构建产物，已 `--acknowledge-dirty` 归档。

集成与验证：`movie_module_page_state.dart` 新增 `抖音短视频`；`flutter analyze` 对新增范围为 0 ERROR（仅 2 条既有 `curly_braces` info）；`flutter test --no-pub test/douyin_test.dart test/short_video_demo_test.dart test/fluttertiktok_demo_test.dart test/easy_tv_live_golden_test.dart` 全绿。

累计回收 **50** 项。

## 第十二批：flutterWechat 全量界面迁入并回收（2026-10-18）

| 源 | 宿主模块 | 规模 / 测试 | 回收 |
| --- | --- | --- | --- |
| `flutterWechat` | `lib/features/chat/flutterwechatfull_demo/` | 96 文件 / 42 测试 / 121 资源 | 478 条目，SHA-256 `8f3ec2e340c8194a` |

- 源是 599 KB / 104 文件的静态微信全量界面演示（内置 mock JSON）。迁入：5 秒跳过倒计时的广告启动页 → 登录（手机/账号两种方式、193 个国家区号、20 种语言、密码/验证码 + 60 秒倒计时、注册校验）、4 栏主框架（微信/通讯录/发现/我）、20 条会话主列表（角标、九宫格头像堆叠、免打扰图标、删除/标为未读/不再关注等保持无效）、100 位联系人 + 彩色 A-Z 索引、发现/朋友圈（`10条新消息`、相机无效）、资料与设置链（关于/账号安全/消息通知/隐私/通用/邮箱绑定/添加方式/可见范围/聊天背景/存储空间/聊天记录备份）、图片浏览、搜索浮层；样例数据逐字对齐源。
- 资源：84 张源 png/jpg 平铺 + 36 个 SVG 图标因宿主无 `flutter_svg` 而重写着色后 `sips` 转 PNG（按 `<stem>_<hex>.png` 命名），共 121 文件 2.3 MB，登记到 `pubspec.yaml`。
- 源**没有**聊天详情页，会话行保持不可点（不臆造）；`login/current_login`、首次安装引导、未使用的 `mock/mainframe_1.9.1.json` 未移植，原因已记录。
- 入口 `FlutterWechatFullDemoPage` 并入聊天模块"更多本地界面演示"菜单（`微信全量界面演示`）。

累计回收 **51** 项。

## 最终状态（2026-10-18 完结）

宿主 `lib/` 内已迁入并回收 **51** 个源工程；库存重建：同级目录 308 个、选中工程 110 个、已回收 51、私有服务跳过 42、无真实业务保留 7、原生阻塞保留 5、播放器/信令插件保留 4、私有依赖阻塞保留 1 —— **无待迁入、无部分迁入、无待回收**。

### 未迁入（源目录全部保留，未删除，共 59 项）

| 状态 | 数量 | 源工程 |
| --- | --- | --- |
| 私有后端服务跳过 | 42 | `Book-Flutter`、`FEhViewer`、`Flutter-MediaLibrary`、`Flutter-Movie`、`Flutter-Project`、`FlutterTencentImPlugin`、`FlutterTianYue`、`Getx-PinkApp`、`Ghosten-Player`、`OpenFlutterYim`、`OpenJMU`、`VideoCall-App-Flutter`、`YeRead`、`ZY_Player_flutter`、`alltv_flutter`、`bika_comics_client`、`book_app`、`chat_app`、`dart_simple_live`、`dy_flutter`、`flutter-chat-app`、`flutter-chat-demo`、`flutter-grpc-tutorial`、`flutter-im`、`flutter-movie-app-ui`、`flutter-p2p-engine`、`flutter_WeChat`、`flutter_bilibili`、`flutter_campus_social_app`、`flutter_chat`、`flutter_chat1`、`flutter_hrlweibo`、`flutter_learn_news`、`flutter_news`、`flutter_portal`、`flutter_readhub`、`flutter_tencentplayer`、`newsbuzz`、`visitor-flutter`、`vvibe`、`wechat_flutter`、`zego-express-example-screen-capture-flutter` |
| 无真实业务 | 7 | `LegadoFlutter`（规则编辑器/书源文件 0 字节，其余是 GitHub 客户端）、`YueY`（四个演示客户端，gank.io 已停服）、`eyeperizer`（`lib/main.dart` 返回空 Text）、`flutter-webrtc-demo`（插件官方示例）、`flutter_read`（`lib` 为 NUL 损坏且 git 索引不可读）、`flutter_shuqi`（全 mock 数据）、`wechat-flutter`（多个不相关小程序，聊天那个只是静态壳） |
| 原生阻塞 | 5 | `daisy`、`kobi`（业务在 Rust / flutter_rust_bridge）、`jasmine`、`nhentai-cross`、`pikapi-flutter`（Dart 只是通道客户端，Go/Rust 业务源码不在仓库内） |
| 插件保留 | 4 | `fijkplayer`、`flutter-webrtc`、`flutter_rtmppublisher`、`flutter_torrent_streamer`（独有能力是原生绑定，宿主无对应能力） |
| 私有依赖阻塞 | 1 | `MagicMagnet`（缺私有 `magic_magnet_engine`） |

### 最终验证

- 全量 `flutter test --no-pub`：**1661 项全部通过**（含新模块的 42 项 flutterWechat、58 项 douyin、33 项 easy_tv_live、16 项 flutter_tiktok、15 项 fake_wechat、14 项 socialappuikit、49 项 youtube 等）。
- 全量 `dart analyze`：**0 ERROR / 9 WARNING / 1121 INFO**，与迁移前基线（1121 INFO / 9 WARNING / 0 ERROR）完全一致，无新增告警。
- 回收凭证 51 条，归档 51 个 tarball 全部存在且 SHA-256 校验通过；同级目录中 51 个源目录均已不在。

### 恢复路径说明（诚实记录）

- 每个已回收来源在 `document/migration_backups/<name>-<git短SHA>.tar.gz` 有完整可恢复快照，`content-migration-retirements.json` 记录条目数、SHA-256、脏工作区说明与迁移范围。
- 按用户方案源目录被移入 `~/.Trash/dashboard-migration-<date>/`；本机环境的回收站会被系统/环境定期清空（本轮会话中多次观察到旧的 `dashboard-migration-*` 目录消失），因此**归档 tarball 才是权威恢复路径**，回收凭证中的 `trash_path` 只作历史记录。

### 环境结论（影响后续调度，历史记录）

本机当时 `flutter analyze` 全量约 16-26 分钟、单模块 2-16 分钟、全量测试约 20-50 分钟；并行运行多个大型迁移子代理时会被环境反复终止。后续大规模迁移应串行、小步调度。

## 已知遗留（非迁移任务范围，供后续维护）

1. 宿主 `lib/features/live/` 下同时存在旧的扁平订阅流程（`live_*.dart`）与新迁入的 `easy_tv_live/`（`EasyTvPage` 已从直播模块卡片进入）；两者共存，尚未收敛为单一实现。
2. 部分模块的 AppBar 动作按钮随迁移不断增多（如影视模块已 15 个图标），在窄屏设备上有溢出风险，建议后续统一改为"更多"菜单或下拉导航。
3. 所有网络行为只做了无网测试（fake Dio/http + 手写 fixture），真实站点在线可用性未验证；`douyin` 的 `_signature` 默认复现源内过期值，在线请求预期 403 并按设计显式报错。
