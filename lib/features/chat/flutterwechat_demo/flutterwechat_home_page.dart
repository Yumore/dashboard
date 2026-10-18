import 'package:dashboard/features/chat/flutterwechat_demo/flutterwechat_message.dart';
import 'package:dashboard/features/chat/flutterwechat_demo/flutterwechat_message_item.dart';
import 'package:dashboard/features/chat/flutterwechat_demo/flutterwechat_palette.dart';
import 'package:flutter/material.dart';

/// Port of the source `Home` tab (source `lib/home/home.dart`): the
/// conversation list, built from [flutterWechatMessages] exactly as the source
/// builds it from `messageData`.
class FlutterWechatHomePage extends StatelessWidget {
  const FlutterWechatHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterWechatPalette.scaffold,
      body: ListView.builder(
        itemCount: flutterWechatMessages.length,
        itemBuilder: (context, index) {
          return FlutterWechatMessageItem(
            message: flutterWechatMessages[index],
          );
        },
      ),
    );
  }
}
