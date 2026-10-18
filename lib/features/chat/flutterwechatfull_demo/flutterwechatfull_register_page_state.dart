import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'flutterwechatfull_action_sheet.dart';
import 'flutterwechatfull_demo_data.dart';
import 'flutterwechatfull_bar_button.dart';
import 'flutterwechatfull_home_page.dart';
import 'flutterwechatfull_images.dart';
import 'flutterwechatfull_loading_dialog.dart';
import 'flutterwechatfull_local_image.dart';
import 'flutterwechatfull_register_page.dart';
import 'flutterwechatfull_style.dart';
import 'flutterwechatfull_zone_code.dart';
import 'flutterwechatfull_zone_code_picker_page.dart';

/// 用手机号注册 with the source's validation order: agreement shake, invalid
/// phone dialog, password rules dialog, then the 1s loading dialog → 微信.
class FlutterWechatFullRegisterPageState
    extends State<FlutterWechatFullRegisterPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late final AnimationController _shakeController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  );

  String _zoneCodeName = '中国大陆';
  String _zoneCode = '86';
  bool _agreed = false;
  bool _obscure = true;

  bool get _registerDisabled =>
      _nicknameController.text.isEmpty ||
      _passwordController.text.isEmpty ||
      _phoneController.text.isEmpty;

  @override
  void dispose() {
    _nicknameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _pickZoneCode() async {
    final String? tel = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (_) =>
            FlutterWechatFullZoneCodePickerPage(zoneCode: _zoneCode),
      ),
    );
    if (tel == null || !mounted) {
      return;
    }
    String name = '国家/地区代码无效';
    for (final FlutterWechatFullZoneCode code
        in FlutterWechatFullDemoData.zoneCodes) {
      if (code.tel == tel) {
        name = code.name;
        break;
      }
    }
    setState(() {
      _zoneCode = tel;
      _zoneCodeName = name;
    });
  }

  void _showError(String message) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _register() {
    if (_registerDisabled) {
      return;
    }
    if (!_agreed) {
      _shakeController.forward(from: 0.0);
      return;
    }
    if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(_phoneController.text)) {
      _showError('手机号码错误');
      return;
    }
    final String password = _passwordController.text;
    final bool pureDigits = RegExp(r'^\d+$').hasMatch(password);
    final bool hasChinese = RegExp(r'[\u4e00-\u9fa5]').hasMatch(password);
    if (password.length < 8 ||
        password.length > 16 ||
        hasChinese ||
        pureDigits) {
      _showError('密码必须是8-16位英文字母、数字、字符组合（不能是纯数字）');
      return;
    }
    FlutterWechatFullLoadingDialog.simulate(
      context,
      onFinished: () {
        if (!mounted) {
          return;
        }
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(
            builder: (_) => const FlutterWechatFullHomePage(),
          ),
          (Route<dynamic> route) => false,
        );
      },
    );
  }

  void _showAvatarSheet() {
    FlutterWechatFullActionSheet.show(
      context,
      actions: <Widget>[
        CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('拍照'),
        ),
        CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('从手机相册选择'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        title: const Text(
          '注册',
          style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w600),
        ),
        leading: FlutterWechatFullBarButton(
          label: '取消',
          onPressed: () => Navigator.of(context).pop(),
        ),
        leadingWidth: 88.0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20.0, 28.0, 20.0, 40.0),
        children: <Widget>[
          const Text(
            '用手机号注册',
            style: TextStyle(
              fontSize: 21.0,
              fontWeight: FontWeight.w500,
              color: FlutterWechatFullStyle.textPrimary,
            ),
          ),
          const SizedBox(height: 46.0),
          Center(
            child: GestureDetector(
              onTap: _showAvatarSheet,
              child: FlutterWechatFullLocalImage(
                path: FlutterWechatFullImages.changeAvatar,
                width: 64.0,
                height: 64.0,
              ),
            ),
          ),
          const SizedBox(height: 30.0),
          _buildFieldRow(
            '昵称',
            TextField(
              controller: _nicknameController,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(fontSize: 17.0),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: '例如：陈晨',
                hintStyle: TextStyle(fontSize: 17.0, color: Color(0xFFC7C7C7)),
              ),
            ),
          ),
          const Divider(height: 0.5, color: Color(0x1A000000)),
          _buildZoneRow(),
          const Divider(height: 0.5, color: Color(0x1A000000)),
          _buildPhoneRow(),
          const Divider(height: 0.5, color: Color(0x1A000000)),
          _buildPasswordRow(),
          const SizedBox(height: 24.0),
          _buildAgreement(),
          const SizedBox(height: 10.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: SizedBox(
              height: 44.0,
              child: Opacity(
                opacity: _registerDisabled ? 0.5 : 1.0,
                child: Material(
                  color: FlutterWechatFullStyle.primary,
                  borderRadius: BorderRadius.circular(4.0),
                  child: InkWell(
                    onTap: _registerDisabled ? null : _register,
                    child: const Center(
                      child: Text(
                        '注册',
                        style: TextStyle(fontSize: 17.0, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldRow(String label, Widget field) {
    return SizedBox(
      height: 56.0,
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 85.0,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 17.0,
                color: FlutterWechatFullStyle.textPrimary,
              ),
            ),
          ),
          Expanded(child: field),
        ],
      ),
    );
  }

  Widget _buildZoneRow() {
    return InkWell(
      onTap: _pickZoneCode,
      child: SizedBox(
        height: 56.0,
        child: Row(
          children: <Widget>[
            const SizedBox(
              width: 85.0,
              child: Text(
                '国家/地区',
                style: TextStyle(
                  fontSize: 17.0,
                  color: FlutterWechatFullStyle.textPrimary,
                ),
              ),
            ),
            Expanded(
              child: Text(
                _zoneCodeName,
                style: const TextStyle(fontSize: 17.0),
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
    );
  }

  Widget _buildPhoneRow() {
    return SizedBox(
      height: 56.0,
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 60.0,
            child: Text(
              '+$_zoneCode',
              style: const TextStyle(
                fontSize: 17.0,
                color: FlutterWechatFullStyle.textPrimary,
              ),
            ),
          ),
          const SizedBox(
            width: 16.0,
            child: Text(
              '|',
              style: TextStyle(fontSize: 17.0, color: Color(0xFFC7C7C7)),
            ),
          ),
          Expanded(
            child: TextField(
              controller: _phoneController,
              onChanged: (_) => setState(() {}),
              keyboardType: TextInputType.phone,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
              style: const TextStyle(fontSize: 17.0),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: '请填写手机号码',
                hintStyle: TextStyle(fontSize: 17.0, color: Color(0xFFC7C7C7)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordRow() {
    return SizedBox(
      height: 56.0,
      child: Row(
        children: <Widget>[
          const SizedBox(
            width: 85.0,
            child: Text(
              '密码',
              style: TextStyle(
                fontSize: 17.0,
                color: FlutterWechatFullStyle.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: _passwordController,
              onChanged: (_) => setState(() {}),
              obscureText: _obscure,
              maxLength: 16,
              style: const TextStyle(fontSize: 17.0),
              decoration: const InputDecoration(
                isDense: true,
                counterText: '',
                border: InputBorder.none,
                hintText: '请设置密码',
                hintStyle: TextStyle(fontSize: 17.0, color: Color(0xFFC7C7C7)),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _obscure = !_obscure),
            child: FlutterWechatFullLocalImage(
              path: _obscure
                  ? FlutterWechatFullImages.passwordEye
                  : FlutterWechatFullImages.passwordEyePressed,
              width: 22.0,
              height: 14.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgreement() {
    return AnimatedBuilder(
      animation: _shakeController,
      builder: (BuildContext context, Widget? child) {
        final double offset =
            math.sin(_shakeController.value * math.pi * 6) * 6.0;
        return Transform.translate(offset: Offset(offset, 0.0), child: child);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          GestureDetector(
            onTap: () => setState(() => _agreed = !_agreed),
            child: FlutterWechatFullLocalImage(
              path: _agreed
                  ? FlutterWechatFullImages.agreementSelected
                  : FlutterWechatFullImages.agreementUnselected,
              width: 16.0,
              height: 16.0,
            ),
          ),
          const SizedBox(width: 3.0),
          const Text(
            '我已阅读并同意',
            style: TextStyle(fontSize: 13.0, color: Color(0xFF525458)),
          ),
          GestureDetector(
            onTap: () {},
            child: const Text(
              '《微信软件许可及服务协议》',
              style: TextStyle(fontSize: 13.0, color: Color(0xFF576B95)),
            ),
          ),
        ],
      ),
    );
  }
}
