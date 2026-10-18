import 'package:flutter/material.dart';

import 'flutterwechatfull_message_notify_page.dart';
import 'flutterwechatfull_style.dart';
import 'flutterwechatfull_switch_group.dart';

/// 微信未打开时 / 微信打开时 switch groups.
class FlutterWechatFullMessageNotifyPageState
    extends State<FlutterWechatFullMessageNotifyPage> {
  final Map<String, bool> _offline = <String, bool>{
    '新消息通知': true,
    '语音和视频通话提醒': true,
  };

  final Map<String, bool> _detail = <String, bool>{'通知显示消息详情': true};

  final Map<String, bool> _online = <String, bool>{'声音': true, '振动': true};

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
          '新消息通知',
          style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 8.0),
        children: <Widget>[
          FlutterWechatFullSwitchGroup(
            header: '微信未打开时',
            values: _offline,
            onChanged: (String title, bool value) =>
                _toggle(_offline, title, value),
          ),
          const SizedBox(height: 8.0),
          FlutterWechatFullSwitchGroup(
            values: _detail,
            onChanged: (String title, bool value) =>
                _toggle(_detail, title, value),
          ),
          const SizedBox(height: 8.0),
          FlutterWechatFullSwitchGroup(
            header: '微信打开时',
            values: _online,
            onChanged: (String title, bool value) =>
                _toggle(_online, title, value),
          ),
        ],
      ),
    );
  }
}
