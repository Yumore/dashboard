import 'package:flutter/material.dart';

/// Port of the source `TimeMarker` widget
/// (`lib/page/wechat/chat_detail_page.dart`).
class FakeWechatTimeMarker extends StatelessWidget {
  const FakeWechatTimeMarker({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        color: const Color(0x22AAAAAA),
        padding: const EdgeInsets.all(10),
        child: Text(text, style: const TextStyle(fontSize: 10)),
      ),
    );
  }
}
