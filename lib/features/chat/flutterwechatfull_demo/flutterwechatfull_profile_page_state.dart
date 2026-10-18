import 'package:flutter/material.dart';

import 'flutterwechatfull_demo_data.dart';
import 'flutterwechatfull_images.dart';
import 'flutterwechatfull_local_image.dart';
import 'flutterwechatfull_profile_page.dart';
import 'flutterwechatfull_remote_image.dart';
import 'flutterwechatfull_setting_page.dart';
import 'flutterwechatfull_style.dart';
import 'flutterwechatfull_user_info_page.dart';

/// Mirrors `ProfilePage`: header (tap → 个人信息) then 支付 / 收藏… / 设置.
class FlutterWechatFullProfilePageState
    extends State<FlutterWechatFullProfilePage> {
  void _openUserInfo() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const FlutterWechatFullUserInfoPage(),
      ),
    );
  }

  void _openSetting() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const FlutterWechatFullSettingPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterWechatFullStyle.background,
      body: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          _buildHeader(),
          const SizedBox(height: 8.0),
          _buildGroup(<_ProfileEntry>[
            const _ProfileEntry('支付', FlutterWechatFullImages.pay, null),
          ]),
          const SizedBox(height: 8.0),
          _buildGroup(<_ProfileEntry>[
            const _ProfileEntry('收藏', FlutterWechatFullImages.favorites, null),
            const _ProfileEntry('相册', FlutterWechatFullImages.album, null),
            const _ProfileEntry('卡包', FlutterWechatFullImages.cards, null),
            const _ProfileEntry('表情', FlutterWechatFullImages.sticker, null),
          ]),
          const SizedBox(height: 8.0),
          _buildGroup(<_ProfileEntry>[
            _ProfileEntry('设置', FlutterWechatFullImages.setting, _openSetting),
          ]),
          const SizedBox(height: 24.0),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: _openUserInfo,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16.0, 72.0, 16.0, 40.0),
          child: Row(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(6.0),
                child: FlutterWechatFullRemoteImage(
                  url: FlutterWechatFullDemoData.profileAvatarUrl,
                  width: 66.0,
                  height: 66.0,
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      FlutterWechatFullDemoData.profileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.w500,
                        color: FlutterWechatFullStyle.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 5.0),
                    Row(
                      children: <Widget>[
                        Text(
                          FlutterWechatFullDemoData.profileWechatId,
                          style: const TextStyle(
                            fontSize: 16.0,
                            color: FlutterWechatFullStyle.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 13.0),
                        FlutterWechatFullLocalImage(
                          path: FlutterWechatFullImages.qrCode,
                          width: 18.0,
                          height: 18.0,
                        ),
                        const SizedBox(width: 13.0),
                        FlutterWechatFullLocalImage(
                          path: FlutterWechatFullImages.arrow,
                          width: 8.0,
                          height: 13.0,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroup(List<_ProfileEntry> entries) {
    return Container(
      color: Colors.white,
      child: Column(
        children: <Widget>[
          for (int index = 0; index < entries.length; index++) ...<Widget>[
            Material(
              color: Colors.white,
              child: InkWell(
                onTap: entries[index].onTap,
                child: SizedBox(
                  height: 56.0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: <Widget>[
                        FlutterWechatFullLocalImage(
                          path: entries[index].icon,
                          width: 24.0,
                          height: 24.0,
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: Text(
                            entries[index].title,
                            style: const TextStyle(
                              fontSize: 17.0,
                              color: FlutterWechatFullStyle.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (index != entries.length - 1)
              const Divider(
                height: 0.5,
                indent: 62.0,
                color: FlutterWechatFullStyle.rowDivider,
              ),
          ],
        ],
      ),
    );
  }
}

class _ProfileEntry {
  const _ProfileEntry(this.title, this.icon, this.onTap);

  final String title;
  final String icon;
  final VoidCallback? onTap;
}
