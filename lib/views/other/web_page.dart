import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dashboard/app/platform/app_web_view.dart';

class WebViewPage extends StatefulWidget {
  final String url;

  const WebViewPage(this.url, {Key? key}) : super(key: key);

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  String _title = "网页加载中...";
  String? _currentUrl;

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
              Share.share("$_title\r\n${_currentUrl ?? widget.url}");
            },
          ),
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            onPressed: () async {
              launchUrl(Uri.parse(_currentUrl ?? widget.url));
            },
          ),
        ],
      ),
      body: AppWebView(
        url: widget.url,
        title: _title,
        onPageFinished: (title, url) {
          if (!mounted) return;
          setState(() {
            _title = title ?? widget.url;
            _currentUrl = url;
          });
        },
      ),
    );
  }
}
