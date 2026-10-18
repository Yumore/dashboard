import 'package:dashboard/features/reading/flutterebook/feedbooks_api.dart';
import 'package:dio/dio.dart';

/// 源工程 `AppDio` 的 `BaseOptions`（`lib/src/common/data/remote/app_dio.dart`）：
/// `baseUrl` 指向 Feedbooks 站点，`contentType` 是 application/json，
/// 连接 / 发送 / 接收三个超时都是 30 秒。
///
/// 源工程是全局单例 + 平台适配器（`getAdapter()`，按 mobile/web 分支）+
/// `LogmanDioInterceptor`；移植版改成每个页面自己造一个可注入的 Dio，
/// 拦截器与平台适配器都不需要（Dio 默认适配器已经覆盖移动端 / 桌面 / Web）。
Dio createFeedbooksDio() {
  return Dio(
    BaseOptions(
      baseUrl: FeedbooksApi.baseUrl,
      contentType: 'application/json',
      connectTimeout: const Duration(milliseconds: 30000),
      sendTimeout: const Duration(milliseconds: 30000),
      receiveTimeout: const Duration(milliseconds: 30000),
    ),
  );
}
