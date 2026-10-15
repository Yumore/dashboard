import 'package:flutter/material.dart';

class MessengerDemoPlaceholderPage extends StatelessWidget {
  const MessengerDemoPlaceholderPage({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: Center(child: Text(title)),
  );
}
