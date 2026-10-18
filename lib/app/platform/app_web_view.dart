import 'package:flutter/widgets.dart';

import 'app_web_view_stub.dart'
    if (dart.library.io) 'app_web_view_io.dart';

/// 页面内导航的决策结果，避免业务代码直接依赖 webview 插件类型。
enum AppWebNavigationDecision { navigate, prevent }

/// 内嵌网页容器。
///
/// Android/iOS/macOS 使用 WebView 插件；其余平台由平台实现降级为浏览器卡片，
/// 降级时 [onNavigationRequest] 与 [onPageFinished] 不会被调用。
class AppWebView extends StatelessWidget {
  const AppWebView({
    required this.url,
    this.title,
    this.onNavigationRequest,
    this.onPageFinished,
    super.key,
  });

  final String url;
  final String? title;

  /// 自定义 scheme 拦截（如 dmzjimage/dmzjandroid）。
  final AppWebNavigationDecision Function(String url)? onNavigationRequest;

  /// 页面加载完成回调，用于同步标题/当前地址。
  final void Function(String? title, String? url)? onPageFinished;

  @override
  Widget build(BuildContext context) => buildPlatformWebView(
    context,
    url: url,
    title: title,
    onNavigationRequest: onNavigationRequest,
    onPageFinished: onPageFinished,
  );
}
