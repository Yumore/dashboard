import 'package:flutter/material.dart';

class ZhihuAskPage extends StatelessWidget {
  const ZhihuAskPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('提问'),
      actions: const [TextButton(onPressed: null, child: Text('下一步'))],
    ),
    body: const Padding(
      padding: EdgeInsets.all(16),
      child: TextField(decoration: InputDecoration(hintText: '请输入标题')),
    ),
  );
}
