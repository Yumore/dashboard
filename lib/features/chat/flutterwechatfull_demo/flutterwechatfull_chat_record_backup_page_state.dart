import 'package:flutter/material.dart';

import 'flutterwechatfull_chat_record_backup_page.dart';
import 'flutterwechatfull_group.dart';
import 'flutterwechatfull_group_view.dart';
import 'flutterwechatfull_list_tile.dart';
import 'flutterwechatfull_style.dart';

/// 迁移聊天记录到另一台设备 / 备份聊天记录到电脑 — both dead in the source.
class FlutterWechatFullChatRecordBackupPageState
    extends State<FlutterWechatFullChatRecordBackupPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterWechatFullStyle.background,
      appBar: AppBar(
        backgroundColor: FlutterWechatFullStyle.background,
        elevation: 0.5,
        centerTitle: true,
        title: const Text(
          '聊天记录备份与迁移',
          style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 8.0),
        children: <Widget>[
          FlutterWechatFullGroupView(
            group: FlutterWechatFullGroup(
              items: <FlutterWechatFullListTile>[
                FlutterWechatFullListTile(title: '迁移聊天记录到另一台设备', onTap: () {}),
                FlutterWechatFullListTile(title: '备份聊天记录到电脑', onTap: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
