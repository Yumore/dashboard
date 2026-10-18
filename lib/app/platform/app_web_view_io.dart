import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'app_platform.dart';
import 'app_web_view.dart';
import 'app_web_view_fallback.dart';

/// io 平台：有 WebView 插件时真正内嵌，其余桌面平台降级。
Widget buildPlatformWebView(
  BuildContext context, {
  required String url,
  String? title,
  AppWebNavigationDecision Function(String url)? onNavigationRequest,
  void Function(String? title, String? url)? onPageFinished,
}) {
  if (!AppPlatform.supportsWebView) {
    return AppWebViewFallback(url: url, title: title);
  }
  return _PlatformWebView(
    url: url,
    onNavigationRequest: onNavigationRequest,
    onPageFinished: onPageFinished,
  );
}

class _PlatformWebView extends StatefulWidget {
  const _PlatformWebView({
    required this.url,
    this.onNavigationRequest,
    this.onPageFinished,
  });

  final String url;
  final AppWebNavigationDecision Function(String url)? onNavigationRequest;
  final void Function(String? title, String? url)? onPageFinished;

  @override
  State<_PlatformWebView> createState() => _PlatformWebViewState();
}

class _PlatformWebViewState extends State<_PlatformWebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            final handler = widget.onNavigationRequest;
            if (handler == null) {
              return NavigationDecision.navigate;
            }
            return handler(request.url) == AppWebNavigationDecision.prevent
                ? NavigationDecision.prevent
                : NavigationDecision.navigate;
          },
          onPageFinished: (url) async {
            final handler = widget.onPageFinished;
            if (handler == null) return;
            final title = await _controller.getTitle();
            handler(title, url);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) => WebViewWidget(controller: _controller);
}
