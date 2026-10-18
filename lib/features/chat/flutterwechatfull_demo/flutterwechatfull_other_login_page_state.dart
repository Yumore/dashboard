import 'package:flutter/material.dart';
import 'flutterwechatfull_other_login_page.dart';

import 'package:flutter/cupertino.dart';

import 'flutterwechatfull_action_sheet.dart';
import 'flutterwechatfull_home_page.dart';
import 'flutterwechatfull_images.dart';
import 'flutterwechatfull_loading_dialog.dart';
import 'flutterwechatfull_local_image.dart';
import 'flutterwechatfull_phone_login_page.dart';
import 'flutterwechatfull_style.dart';
import 'flutterwechatfull_text_field.dart';
import 'flutterwechatfull_zone_code_picker_page.dart';
import 'flutterwechatfull_zone_code.dart';
import 'flutterwechatfull_demo_data.dart';

/// 手机号登录 / 微信号、QQ号、邮箱登录 toggle, copied from `OtherLoginWidget`.
class FlutterWechatFullOtherLoginPageState
    extends State<FlutterWechatFullOtherLoginPage> {
  bool _phoneWay = true;
  bool _closePressed = false;
  String _zoneCodeName = '中国大陆';

  final TextEditingController _zoneController = TextEditingController(
    text: '86',
  );
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool get _loginDisabled {
    return _phoneWay
        ? _phoneController.text.isEmpty
        : _accountController.text.isEmpty || _passwordController.text.isEmpty;
  }

  String get _changeWayLabel => _phoneWay ? '用微信号/QQ号/邮箱登录' : '用手机号登录';

  String get _loginLabel => _phoneWay ? '下一步' : '登录';

  @override
  void dispose() {
    _zoneController.dispose();
    _phoneController.dispose();
    _accountController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _switchWay() {
    setState(() {
      _phoneWay = !_phoneWay;
    });
  }

  Future<void> _pickZoneCode() async {
    final String? result = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (_) =>
            FlutterWechatFullZoneCodePickerPage(zoneCode: _zoneController.text),
      ),
    );
    if (result == null || !mounted) {
      return;
    }
    setState(() {
      _zoneController.text = result;
      _zoneCodeName = _zoneNameFor(result);
    });
  }

  void _updateZoneName(String value) {
    setState(() {
      _zoneCodeName = _zoneNameFor(value);
    });
  }

  String _zoneNameFor(String tel) {
    for (final FlutterWechatFullZoneCode zone
        in FlutterWechatFullDemoData.zoneCodes) {
      if (zone.tel == tel) {
        return zone.name;
      }
    }
    return '国家/地区代码无效';
  }

  void _submit() {
    if (_loginDisabled) {
      return;
    }
    if (_phoneWay) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => FlutterWechatFullPhoneLoginPage(
            phone: _phoneController.text,
            zoneCode: _zoneController.text,
          ),
        ),
      );
      return;
    }
    final bool validQq = RegExp(
      r'^[1-9][0-9]{4,9}$',
    ).hasMatch(_accountController.text);
    final String password = _passwordController.text;
    final bool validPassword =
        password.length >= 8 &&
        password.length <= 16 &&
        !RegExp(r'[\u4e00-\u9fa5]').hasMatch(password);
    if (!validQq || !validPassword) {
      _showError('账号或密码错误，请重新填写');
      return;
    }
    FlutterWechatFullLoadingDialog.simulate(context, onFinished: _openHome);
  }

  void _openHome() {
    if (!mounted) {
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => const FlutterWechatFullHomePage(),
      ),
      (route) => false,
    );
  }

  void _showError(String title) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(title, style: const TextStyle(fontSize: 17.0)),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              '确定',
              style: TextStyle(
                color: FlutterWechatFullStyle.warning,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMoreSheet() {
    FlutterWechatFullActionSheet.show(
      context,
      actions: <Widget>[
        CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('紧急冻结'),
        ),
        CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('前往微信安全中心'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          Container(
            height: kToolbarHeight + MediaQuery.of(context).padding.top,
            padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 12.0),
            alignment: Alignment.bottomLeft,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              onTapDown: (_) => setState(() => _closePressed = true),
              onTapUp: (_) => setState(() => _closePressed = false),
              onTapCancel: () => setState(() => _closePressed = false),
              child: FlutterWechatFullLocalImage(
                path: _closePressed
                    ? FlutterWechatFullImages.closeIconPressed
                    : FlutterWechatFullImages.closeIcon,
                width: 18.0,
                height: 18.0,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 90.0),
                  child: Column(
                    children: <Widget>[
                      _buildTitleInput(),
                      _buildChangeButton(),
                      _buildLoginButton(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildTitleInput() {
    return Container(
      width: double.maxFinite,
      color: Colors.white,
      child: _phoneWay ? _buildPhoneForm() : _buildAccountForm(),
    );
  }

  Widget _buildTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 14.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.w500,
            color: FlutterWechatFullStyle.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 0.5,
      indent: 20.0,
      endIndent: 20.0,
      color: FlutterWechatFullStyle.divider,
    );
  }

  Widget _buildPhoneForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildTitle('手机号登录'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Row(
            children: <Widget>[
              const SizedBox(
                width: 105.0,
                child: Text(
                  '国家/地区',
                  style: TextStyle(
                    fontSize: 17.0,
                    color: FlutterWechatFullStyle.textPrimary,
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: _pickZoneCode,
                  behavior: HitTestBehavior.opaque,
                  child: Text(
                    _zoneCodeName,
                    style: const TextStyle(
                      fontSize: 17.0,
                      color: FlutterWechatFullStyle.textPrimary,
                    ),
                  ),
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
        _buildDivider(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 80.0,
                child: Row(
                  children: <Widget>[
                    const Text(
                      '+',
                      style: TextStyle(
                        fontSize: 17.0,
                        fontWeight: FontWeight.w500,
                        color: FlutterWechatFullStyle.textPrimary,
                      ),
                    ),
                    Expanded(
                      child: FlutterWechatFullTextField(
                        controller: _zoneController,
                        maxLength: 4,
                        keyboardType: TextInputType.number,
                        onChanged: _updateZoneName,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 10.0,
                margin: const EdgeInsets.symmetric(vertical: 10.0),
                decoration: const BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      width: 0.5,
                      color: FlutterWechatFullStyle.divider,
                    ),
                  ),
                ),
                child: const SizedBox(width: 10.0, height: 24.0),
              ),
              Expanded(
                child: FlutterWechatFullTextField(
                  controller: _phoneController,
                  hintText: '请填写手机号码',
                  keyboardType: TextInputType.phone,
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
        ),
        _buildDivider(),
      ],
    );
  }

  Widget _buildAccountForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildTitle('微信号/QQ号/邮箱登录'),
        _buildAccountRow(
          title: '账号',
          hint: '微信号/QQ号/邮箱',
          controller: _accountController,
        ),
        _buildDivider(),
        _buildAccountRow(
          title: '密码',
          hint: '请填写密码',
          controller: _passwordController,
          obscure: true,
        ),
        _buildDivider(),
      ],
    );
  }

  Widget _buildAccountRow({
    required String title,
    required String hint,
    required TextEditingController controller,
    bool obscure = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 105.0,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 17.0,
                color: FlutterWechatFullStyle.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: FlutterWechatFullTextField(
              controller: controller,
              hintText: hint,
              obscureText: obscure,
              onChanged: (_) => setState(() {}),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChangeButton() {
    return Container(
      padding: const EdgeInsets.only(left: 20.0, top: 34.0, right: 20.0),
      width: double.maxFinite,
      child: GestureDetector(
        onTap: _switchWay,
        behavior: HitTestBehavior.opaque,
        child: Text(
          _changeWayLabel,
          style: const TextStyle(fontSize: 16.0, color: Color(0xFF5B6A91)),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, top: 63.0, right: 20.0),
      child: Opacity(
        opacity: _loginDisabled ? 0.5 : 1.0,
        child: SizedBox(
          width: double.maxFinite,
          child: Material(
            color: FlutterWechatFullStyle.primary,
            borderRadius: BorderRadius.circular(4.0),
            child: InkWell(
              onTap: _submit,
              highlightColor: _loginDisabled
                  ? Colors.transparent
                  : FlutterWechatFullStyle.primaryDark,
              borderRadius: BorderRadius.circular(4.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 11.0,
                  horizontal: 24.0,
                ),
                child: Center(
                  child: Text(
                    _loginLabel,
                    style: const TextStyle(fontSize: 17.0, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          GestureDetector(
            onTap: () {},
            child: const Text(
              '找回密码',
              style: TextStyle(fontSize: 15.0, color: Color(0xFF5B6A91)),
            ),
          ),
          const SizedBox(width: 10.0),
          Container(width: 1.0, height: 12.0, color: const Color(0xFF5B6A91)),
          const SizedBox(width: 10.0),
          GestureDetector(
            onTap: _showMoreSheet,
            child: const Text(
              '更多选项',
              style: TextStyle(fontSize: 15.0, color: Color(0xFF5B6A91)),
            ),
          ),
        ],
      ),
    );
  }
}
