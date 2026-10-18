import 'package:flutter/material.dart';

import 'flutterwechatfull_binding_mailbox_page.dart';
import 'flutterwechatfull_demo_data.dart';
import 'flutterwechatfull_group.dart';
import 'flutterwechatfull_group_view.dart';
import 'flutterwechatfull_list_tile.dart';
import 'flutterwechatfull_more_security_setting_page.dart';
import 'flutterwechatfull_style.dart';

/// QQ号 / 邮箱地址; only the mailbox row navigates.
class FlutterWechatFullMoreSecuritySettingPageState
    extends State<FlutterWechatFullMoreSecuritySettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterWechatFullStyle.background,
      appBar: AppBar(
        backgroundColor: FlutterWechatFullStyle.background,
        elevation: 0.5,
        centerTitle: true,
        title: const Text(
          '更多安全设置',
          style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 8.0),
        children: <Widget>[
          FlutterWechatFullGroupView(
            group: FlutterWechatFullGroup(
              items: <FlutterWechatFullListTile>[
                FlutterWechatFullListTile(
                  title: 'QQ号',
                  subtitle: FlutterWechatFullDemoData.profileQq,
                  subtitleInline: true,
                  onTap: () {},
                ),
                FlutterWechatFullListTile(
                  title: '邮箱地址',
                  subtitle: FlutterWechatFullDemoData.profileMailbox,
                  subtitleInline: true,
                  onTap: () => Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          const FlutterWechatFullBindingMailboxPage(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
