import 'package:dashboard/features/chat/flutterwechat_demo/flutterwechat_widget_entries.dart';
import 'package:dashboard/features/chat/flutterwechat_demo/flutterwechat_palette.dart';
import 'package:flutter/material.dart';

/// Port of the source 基础组件 grid (source `lib/widgets/BasicsWeigets.dart`).
class FlutterWechatBasicsPage extends StatelessWidget {
  const FlutterWechatBasicsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterWechatPalette.scaffold,
      appBar: AppBar(
        elevation: 0.0,
        centerTitle: true,
        backgroundColor: FlutterWechatPalette.appBar,
        foregroundColor: Colors.white,
        title: const Text('基础组件'),
      ),
      body: GridView.count(
        primary: false,
        childAspectRatio: 0.7,
        crossAxisCount: 2,
        children: flutterWechatBasicsEntries,
      ),
    );
  }
}
