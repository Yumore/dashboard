import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatefulWidget {
  final String url;

  const WebViewPage(this.url, {Key? key}) : super(key: key);

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController _controller;
  String _title = "网页加载中...";

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent("")
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) async {
            final title = await _controller.getTitle();
            if (!mounted) {
              return;
            }
            setState(() => _title = title ?? widget.url);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () async {
              Share.share(
                "${await _controller.getTitle()}\r\n${await _controller.currentUrl()}",
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            onPressed: () async {
              launchUrl(
                Uri.parse(await _controller.currentUrl() ?? widget.url),
              );
            },
          ),
        ],
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
