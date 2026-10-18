import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_avatar.dart';
import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_demo_config.dart';
import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_profile_page.dart';
import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_seed_data.dart';
import 'package:flutter/material.dart';

class FakeWechatProfilePageState extends State<FakeWechatProfilePage> {
  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: FakeWechatDemoConfig.pageBackground,
      child: ListView(
        children: <Widget>[
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            child: Row(
              children: <Widget>[
                const FakeWechatAvatar(name: '廖布斯', size: 64, borderRadius: 8),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        FakeWechatSeedData.user.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        FakeWechatDemoConfig.profileSignature,
                        style: TextStyle(
                          fontSize: 13,
                          color: FakeWechatDemoConfig.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: const Text(
              FakeWechatDemoConfig.meTabNote,
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                color: FakeWechatDemoConfig.secondaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
