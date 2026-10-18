import 'package:flutter/material.dart';

import 'flutterwechatfull_chat_background_page.dart';
import 'flutterwechatfull_group.dart';
import 'flutterwechatfull_group_view.dart';
import 'flutterwechatfull_list_tile.dart';
import 'flutterwechatfull_style.dart';

/// 选择背景图 / 从手机相册选择 / 拍一张 are all dead in the source; the center
/// row is inert as well.
class FlutterWechatFullChatBackgroundPageState
    extends State<FlutterWechatFullChatBackgroundPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterWechatFullStyle.background,
      appBar: AppBar(
        backgroundColor: FlutterWechatFullStyle.background,
        elevation: 0.5,
        centerTitle: true,
        title: const Text(
          '聊天背景',
          style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 8.0),
        children: <Widget>[
          FlutterWechatFullGroupView(
            group: FlutterWechatFullGroup(
              items: <FlutterWechatFullListTile>[
                FlutterWechatFullListTile(title: '选择背景图', onTap: () {}),
              ],
            ),
          ),
          const SizedBox(height: 8.0),
          FlutterWechatFullGroupView(
            group: FlutterWechatFullGroup(
              items: <FlutterWechatFullListTile>[
                FlutterWechatFullListTile(title: '从手机相册选择', onTap: () {}),
                FlutterWechatFullListTile(title: '拍一张', onTap: () {}),
              ],
            ),
          ),
          const SizedBox(height: 8.0),
          FlutterWechatFullGroupView(
            group: FlutterWechatFullGroup(
              items: <FlutterWechatFullListTile>[
                FlutterWechatFullListTile(
                  title: '将背景应用到所有聊天场景',
                  center: true,
                  showArrow: false,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
