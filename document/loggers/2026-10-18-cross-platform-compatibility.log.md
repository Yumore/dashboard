# 2026-10-18 跨平台兼容改造日志

## 触发

用户需求（m03810，原文）："兼容 web/WIndows/MacOS/Linux/鸿蒙 平台"。

## 关键节点

1. **基线**：`android/ ios/ linux/ macos/ web/ windows/` 存在，无 `ohos/`；Flutter 3.47.7 / Dart 3.13.5。首次 `flutter build web` 失败（`dart:io` 顶层导入 + 无 databaseFactory）。
2. **发现**：Dart 3.13 的 `dart compile js` 接受 `import 'dart:io'` 并注入运行时报错桩——Web 编译不再需要条件导入，只需保证运行期不触碰 io API。据此采用"能力层 + 运行期守卫"而非大规模条件导入。
3. **平台层**：新增 `lib/app/platform/`（kind/traits/detect/capability/db factory/directories/toast/messenger/local image/file writer/web view/bootstrap），`AppPlatform` 支持测试注入。
4. **启动**：`main.dart` 重写为无 `dart:io`；数据库初始化失败可降级启动。
5. **调用点迁移**：channel 参数、Platform.isX 分支、89 处 Fluttertoast 调用（29 文件改 `AppToast.show`，保留 Toast 常量类型导入）、media_kit 播放页（io/stub 条件导入）、WebView 两页改 `AppWebView`。
6. **入口过滤**：`ContentEntry.requires` + `AppCapability`，Web 隐藏文件系统/视频类入口。
7. **运行时守卫**：图片保存、本地图片、爬虫导出、局域网聊天、系统亮度、Reader DB 路径、EasyTV 本地订阅、ESO 压缩书源、TSDM deflate。
8. **SQLite 构建材料**：GitHub 预编译库下载被网络中断；`pubspec.yaml` 增加镜像 `url_pattern` 后 hooks 成功；`sqflite_common_ffi_web:setup` 用镜像 wasm 地址生成 `web/sqflite_sw.js`、`web/sqlite3.wasm`。
9. **macOS 权限**：两个 entitlements 补 `network.client`。
10. **验证**：Web 构建成功；`flutter test --platform chrome` 9/9；全量 `flutter test` 与 `dart analyze` 见下方结果。

## 验证结果

- `flutter build web --no-wasm-dry-run`：成功（`✓ Built build/web`，76.4s）。
- `flutter test --platform chrome`：平台层 9/9、内容中心/UI 套件 4/4 通过（真实 Chrome）。
- 全量回归：`flutter test --no-pub` 1677 通过（exit 0）；`dart analyze lib test` 0 error / 9 warning / 1118 info（基线持平）。
- macOS：本机缺 CocoaPods；开启 Swift Package Manager 后 media_kit 插件无 SPM 支持仍回退 CocoaPods；`gem install --user-install cocoapods` 因 ruby-china 镜像 SSL 证书错误失败 → 本机无法完成 macOS 构建验证。
- Windows/Linux：本机 macOS 无法交叉构建，未验证构建产物。
- 鸿蒙：`/opt/harmonyos` Dart 2.19.6 < 工程要求 3.8，未编译。

## 遗留

- 未做浏览器/桌面人工 UI 走查。
- 旧版历史/下载页面依赖 SQLite；Web SQLite 不可用时这些页面会抛空值错误（内容中心与模块页不受影响）。
- Web 端本地文件、WebView、内嵌视频、局域网聊天、系统亮度、自更新均按"隐藏或提示"降级，属于已知产品限制。

## 独立审查

- 两个只读审查者对平台层/启动链路/入口过滤/SQLite 资产/macOS 配置/文档做独立核查。
- 修复：亮度两处守卫、bootstrap try/catch、开眼上传与图片保存能力判定、traits 收紧（unknown/OHOS）、还原 macOS 生成文件、文档 6 处不准确表述。
- 复核：analyze 0 error / 9 warning / 1118 info；全量测试 1677 通过；Web 重新构建通过。

## 构建产物（2026-10-18 12:31）

- Web：`flutter build web --release --no-wasm-dry-run` → `build/web/`（72 MB，含 canvaskit、main.dart.js、sqlite3.wasm、sqflite_sw.js）；备用压缩包 `build/dashboard-web.zip`。
- Android：`GRADLE_OPTS="-Dorg.gradle.workers.max=4 -Dorg.gradle.parallel=false" flutter build apk --release` → `build/app/outputs/flutter-apk/app-release.apk`（147 MB，release 证书签名；首次构建因 Gradle 下载网络中断自动重试后成功）。
- APK SHA-256：`e3e9bcc792c531a82105a4c0a00f85aba38a48ce24f40ec2748c8845956f9e90`
