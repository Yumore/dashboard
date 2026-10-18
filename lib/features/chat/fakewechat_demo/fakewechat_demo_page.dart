import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_demo_page_state.dart';
import 'package:flutter/material.dart';

/// Local static-demo shell for the ported `fake_wechat` UI.
///
/// The source `lib/home_page.dart` is a three-tab `PageView`
/// (聊天 / 联系人 / 发现). This widget adds the host-requested "我" tab; see
/// [FakeWechatDemoConfig.meTabNote].
class FakeWechatDemoPage extends StatefulWidget {
  const FakeWechatDemoPage({super.key});

  @override
  State<FakeWechatDemoPage> createState() => FakeWechatDemoPageState();
}
