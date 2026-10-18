import 'package:flutter/material.dart';

import 'flutterwechatfull_add_friend_page.dart';
import 'flutterwechatfull_demo_data.dart';
import 'flutterwechatfull_images.dart';
import 'flutterwechatfull_local_image.dart';
import 'flutterwechatfull_style.dart';

/// All six rows in the source are dead: their `onTap` is never wired up.
class FlutterWechatFullAddFriendPageState
    extends State<FlutterWechatFullAddFriendPage> {
  static const List<(String, String, String)> _entries =
      <(String, String, String)>[
        ('雷达加朋友', '添加身边的朋友', FlutterWechatFullImages.radar),
        ('面对面建群', '与身边的朋友进入同一个群聊', FlutterWechatFullImages.faceGroup),
        ('扫一扫', '扫描二维码名片', FlutterWechatFullImages.scanQr),
        ('手机联系人', '添加通讯录中的朋友', FlutterWechatFullImages.phoneContacts),
        ('公众号', '获取更多资讯和服务', FlutterWechatFullImages.officialAccount),
        ('企业微信联系人', '通过手机号搜索企业微信用户', FlutterWechatFullImages.weWork),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterWechatFullStyle.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: const Text(
          '添加朋友',
          style: TextStyle(
            fontSize: 17.0,
            fontWeight: FontWeight.w600,
            color: Color(0xFF181818),
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
            color: Colors.white,
            height: 44.0,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: <Widget>[
                FlutterWechatFullLocalImage(
                  path: FlutterWechatFullImages.addFriendSearch,
                  width: 36.0,
                  height: 30.0,
                ),
                const SizedBox(width: 8.0),
                const Text(
                  '搜索',
                  style: TextStyle(
                    fontSize: 17.0,
                    color: FlutterWechatFullStyle.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: FlutterWechatFullStyle.background,
            padding: const EdgeInsets.only(top: 6.0, bottom: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  '我的微信号：${FlutterWechatFullDemoData.profileWechatIdValue}',
                  style: const TextStyle(
                    fontSize: 14.0,
                    color: FlutterWechatFullStyle.textSecondary,
                  ),
                ),
                const SizedBox(width: 6.0),
                FlutterWechatFullLocalImage(
                  path: FlutterWechatFullImages.addFriendQr,
                  width: 20.0,
                  height: 20.0,
                ),
              ],
            ),
          ),
          Container(
            color: Colors.white,
            child: Column(
              children: <Widget>[
                for (
                  int index = 0;
                  index < _entries.length;
                  index++
                ) ...<Widget>[
                  _buildEntry(_entries[index]),
                  if (index != _entries.length - 1)
                    const Divider(
                      height: 0.5,
                      indent: 68.0,
                      color: FlutterWechatFullStyle.rowDivider,
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntry((String, String, String) entry) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Row(
            children: <Widget>[
              FlutterWechatFullLocalImage(
                path: entry.$3,
                width: 36.0,
                height: 36.0,
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      entry.$1,
                      style: const TextStyle(
                        fontSize: 16.0,
                        color: FlutterWechatFullStyle.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3.0),
                    Text(
                      entry.$2,
                      style: const TextStyle(
                        fontSize: 12.0,
                        color: FlutterWechatFullStyle.textHint,
                      ),
                    ),
                  ],
                ),
              ),
              FlutterWechatFullLocalImage(
                path: FlutterWechatFullImages.arrow,
                width: 8.0,
                height: 13.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
