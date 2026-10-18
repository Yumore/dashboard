import 'package:dashboard/features/chat/flutterwechat_demo/flutterwechat_widget_entries.dart';
import 'package:dashboard/features/chat/flutterwechat_demo/flutterwechat_palette.dart';
import 'package:flutter/material.dart';

/// Port of the source Material Components list (source
/// `lib/widgets/MaterialWeigets.dart`).
class FlutterWechatMaterialPage extends StatelessWidget {
  const FlutterWechatMaterialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterWechatPalette.scaffold,
      appBar: AppBar(
        elevation: 0.0,
        centerTitle: true,
        backgroundColor: FlutterWechatPalette.appBar,
        foregroundColor: Colors.white,
        title: const Text('Material Components'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Wrap(children: flutterWechatMaterialEntries),
      ),
    );
  }
}
