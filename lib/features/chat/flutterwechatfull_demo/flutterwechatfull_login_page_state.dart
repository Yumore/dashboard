import 'package:flutter/material.dart';
import 'flutterwechatfull_login_page.dart';

import 'flutterwechatfull_demo_data.dart';
import 'flutterwechatfull_images.dart';
import 'flutterwechatfull_language_picker_page.dart';
import 'flutterwechatfull_other_login_page.dart';
import 'flutterwechatfull_register_page.dart';
import 'flutterwechatfull_style.dart';

/// Background image, language picker entry and the 登陆 / 注册 buttons.
class FlutterWechatFullLoginPageState
    extends State<FlutterWechatFullLoginPage> {
  String _language = FlutterWechatFullDemoData.languages.first;

  Future<void> _pickLanguage() async {
    final String? result = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (_) => FlutterWechatFullLanguagePickerPage(value: _language),
      ),
    );
    if (result != null && result != _language && mounted) {
      setState(() {
        _language = result;
      });
    }
  }

  void _openOtherLogin() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const FlutterWechatFullOtherLoginPage(),
      ),
    );
  }

  void _openRegister() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const FlutterWechatFullRegisterPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.maxFinite,
        height: double.maxFinite,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(FlutterWechatFullImages.launchImage),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: <Widget>[
            Positioned(
              left: 20.0,
              right: 20.0,
              bottom: 20.0,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: _buildButton(
                      label: '登陆',
                      textColor: FlutterWechatFullStyle.primaryDark,
                      background: Colors.white,
                      highlight: const Color(0xFFD9D9D9),
                      onPressed: _openOtherLogin,
                    ),
                  ),
                  const SizedBox(width: 20.0, height: 20.0),
                  Expanded(
                    child: _buildButton(
                      label: '注册',
                      textColor: Colors.white,
                      background: FlutterWechatFullStyle.primary,
                      highlight: FlutterWechatFullStyle.primaryDark,
                      onPressed: _openRegister,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 5.0,
              right: 20.0,
              child: InkWell(
                onTap: _pickLanguage,
                child: Text(
                  _language,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 12.0,
                    color: Color(0xB3FFFFFF),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required Color textColor,
    required Color background,
    required Color highlight,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(4.0),
      child: InkWell(
        onTap: onPressed,
        highlightColor: highlight,
        borderRadius: BorderRadius.circular(4.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 24.0),
          child: Center(
            child: Text(
              label,
              style: TextStyle(fontSize: 17.0, color: textColor),
            ),
          ),
        ),
      ),
    );
  }
}
