import 'package:flutter/material.dart';

import 'flutterwechatfull_discover_manager_page.dart';
import 'flutterwechatfull_style.dart';
import 'flutterwechatfull_switch_group.dart';

/// One switch per discover entry, all enabled like a fresh install.
class FlutterWechatFullDiscoverManagerPageState
    extends State<FlutterWechatFullDiscoverManagerPage> {
  final Map<String, bool> _entries = <String, bool>{
    '朋友圈': true,
    '扫一扫': true,
    '摇一摇': true,
    '看一看': true,
    '搜一搜': true,
    '附近的人': true,
    '漂流瓶': true,
    '购物': true,
    '游戏': true,
    '小程序': true,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterWechatFullStyle.background,
      appBar: AppBar(
        backgroundColor: FlutterWechatFullStyle.background,
        elevation: 0.5,
        centerTitle: true,
        title: const Text(
          '发现页管理',
          style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 8.0),
        children: <Widget>[
          FlutterWechatFullSwitchGroup(
            header: '打开/关闭发现页的入口',
            footer: '关闭后，仅隐藏“发现”中该功能的入库，不会清空任何历史数据',
            values: _entries,
            onChanged: (String title, bool value) {
              setState(() => _entries[title] = value);
            },
          ),
        ],
      ),
    );
  }
}
