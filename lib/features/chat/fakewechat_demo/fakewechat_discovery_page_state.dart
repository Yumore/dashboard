import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_demo_config.dart';
import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_discovery_page.dart';
import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_moments_page.dart';
import 'package:flutter/material.dart';

class FakeWechatDiscoveryPageState extends State<FakeWechatDiscoveryPage> {
  void _openMoments() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const FakeWechatMomentsPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: FakeWechatDemoConfig.pageBackground,
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: _openMoments,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(14),
              child: const Row(
                children: <Widget>[
                  Icon(Icons.camera),
                  SizedBox(width: 8),
                  Text(
                    FakeWechatDemoConfig.momentsTitle,
                    style: TextStyle(fontSize: 16),
                  ),
                  Spacer(),
                  Icon(Icons.chevron_right, color: Color(0xFFBDBDBD)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
