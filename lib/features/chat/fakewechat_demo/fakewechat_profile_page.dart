import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_profile_page_state.dart';
import 'package:flutter/material.dart';

/// The source has no "我" tab. This page satisfies the host module entry (which
/// asks for a me tab) using only the source `USER` record, and states that fact
/// visibly instead of inventing WeChat features.
class FakeWechatProfilePage extends StatefulWidget {
  const FakeWechatProfilePage({super.key});

  @override
  State<FakeWechatProfilePage> createState() => FakeWechatProfilePageState();
}
