/// 目标平台种类。
///
/// `ohos` 为鸿蒙（OpenHarmony/HarmonyOS）Flutter 分支的 `Platform.operatingSystem`
/// 取值；`unknown` 用于识别失败的兜底。
enum AppPlatformKind { android, ios, macos, windows, linux, web, ohos, unknown }
