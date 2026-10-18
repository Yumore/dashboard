import 'package:flutter/material.dart';

import 'flutterwechatfull_bar_button.dart';
import 'flutterwechatfull_binding_mailbox_page.dart';
import 'flutterwechatfull_style.dart';

/// A single mailbox field; 完成 enables once something is typed.
class FlutterWechatFullBindingMailboxPageState
    extends State<FlutterWechatFullBindingMailboxPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        title: const Text(
          '邮箱地址',
          style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w600),
        ),
        leading: FlutterWechatFullBarButton(
          label: '取消',
          onPressed: () => Navigator.of(context).pop(),
        ),
        leadingWidth: 88.0,
        actions: <Widget>[
          FlutterWechatFullBarButton(
            label: '完成',
            enabled: _controller.text.isNotEmpty,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 16.0),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _controller,
              onChanged: (_) => setState(() {}),
              keyboardType: TextInputType.emailAddress,
              cursorColor: FlutterWechatFullStyle.primary,
              style: const TextStyle(fontSize: 17.0),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: '请输入邮箱地址',
                hintStyle: TextStyle(fontSize: 17.0, color: Color(0xFFC7C7C7)),
                helperText: '你可以用验证过的邮箱来找回微信密码',
                helperStyle: TextStyle(
                  fontSize: 12.0,
                  color: Color(0xFF808080),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
