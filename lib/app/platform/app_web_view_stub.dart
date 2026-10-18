import 'package:flutter/widgets.dart';

import 'app_web_view.dart';
import 'app_web_view_fallback.dart';

/// Web 没有 WebView 插件：直接降级为浏览器打开卡片。
Widget buildPlatformWebView(
  BuildContext context, {
  required String url,
  String? title,
  AppWebNavigationDecision Function(String url)? onNavigationRequest,
  void Function(String? title, String? url)? onPageFinished,
}) => AppWebViewFallback(url: url, title: title);
