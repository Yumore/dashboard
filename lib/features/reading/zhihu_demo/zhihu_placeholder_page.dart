import 'package:flutter/material.dart';

class ZhihuPlaceholderPage extends StatelessWidget {
  const ZhihuPlaceholderPage({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: const SizedBox.expand(),
  );
}
