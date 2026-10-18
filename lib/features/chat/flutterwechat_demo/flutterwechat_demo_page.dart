import 'package:flutter/material.dart';

import 'flutterwechat_demo_page_state.dart';

/// Entry point of the ported flutter-wechat static UI demo.
///
/// The source application shell (`lib/app.dart`) was itself the home page; in
/// the host it is reached from the chat module and keeps the same four tabs:
/// 首页 / 通讯录 / 发现 / 我的.
class FlutterWechatDemoPage extends StatefulWidget {
  const FlutterWechatDemoPage({super.key});

  @override
  State<FlutterWechatDemoPage> createState() => FlutterWechatDemoPageState();
}
