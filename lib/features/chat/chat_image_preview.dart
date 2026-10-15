import 'dart:typed_data';

import 'package:flutter/material.dart';

class ChatImagePreview extends StatelessWidget {
  const ChatImagePreview({required this.bytes, super.key});

  final Uint8List bytes;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('本机图片预览')),
    body: Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(12),
          child: Text('图片未发送：当前聊天服务仅支持文字消息。'),
        ),
        Expanded(
          child: InteractiveViewer(
            child: Center(
              child: Image.memory(
                bytes,
                errorBuilder: (_, _, _) => const Text('无法显示此图片'),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
