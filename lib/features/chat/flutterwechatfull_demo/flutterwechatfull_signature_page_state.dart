import 'package:flutter/material.dart';

import 'flutterwechatfull_bar_button.dart';
import 'flutterwechatfull_signature_page.dart';
import 'flutterwechatfull_style.dart';

/// Pops the edited signature; 取消 pops null.
class FlutterWechatFullSignaturePageState
    extends State<FlutterWechatFullSignaturePage> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.text,
  );

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
          '设置个性签名',
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
            onPressed: () => Navigator.of(context).pop(_controller.text),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          const SizedBox(height: 12.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: TextField(
              controller: _controller,
              maxLines: 2,
              maxLength: 30,
              autofocus: true,
              textInputAction: TextInputAction.done,
              cursorColor: FlutterWechatFullStyle.primary,
              style: const TextStyle(
                fontSize: 17.0,
                color: FlutterWechatFullStyle.textPrimary,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: '请输入个性签名',
                hintStyle: TextStyle(fontSize: 17.0, color: Color(0xFFC7C7C7)),
                counterStyle: TextStyle(
                  fontSize: 12.0,
                  color: FlutterWechatFullStyle.textHint,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
