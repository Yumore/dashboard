import 'package:flutter/material.dart';

import 'flutterwechatfull_add_way_page.dart';
import 'flutterwechatfull_style.dart';
import 'flutterwechatfull_switch_group.dart';

/// 可以通过以下方式找到我 / 添加我 switch groups.
class FlutterWechatFullAddWayPageState
    extends State<FlutterWechatFullAddWayPage> {
  final Map<String, bool> _findMe = <String, bool>{
    '手机号': true,
    '微信号': true,
    'QQ号': true,
  };

  final Map<String, bool> _addMe = <String, bool>{
    '群聊': true,
    '我的二维码': true,
    '名片': true,
  };

  void _toggle(Map<String, bool> group, String title, bool value) {
    setState(() => group[title] = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterWechatFullStyle.background,
      appBar: AppBar(
        backgroundColor: FlutterWechatFullStyle.background,
        elevation: 0.5,
        centerTitle: true,
        title: const Text(
          '添加我的方式',
          style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 8.0),
        children: <Widget>[
          FlutterWechatFullSwitchGroup(
            header: '可以通过以下方式找到我：',
            footer: '关闭后，其他用户将不不能通过上述信息找到你。',
            values: _findMe,
            onChanged: (String title, bool value) =>
                _toggle(_findMe, title, value),
          ),
          const SizedBox(height: 8.0),
          FlutterWechatFullSwitchGroup(
            header: '可以通过以下方式添加我：',
            values: _addMe,
            onChanged: (String title, bool value) =>
                _toggle(_addMe, title, value),
          ),
        ],
      ),
    );
  }
}
