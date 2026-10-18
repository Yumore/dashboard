import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'flutterwechatfull_action_sheet.dart';
import 'flutterwechatfull_home_page.dart';
import 'flutterwechatfull_loading_dialog.dart';
import 'flutterwechatfull_phone_login_page.dart';
import 'flutterwechatfull_style.dart';
import 'flutterwechatfull_text_field.dart';

/// Password / captcha login for the phone entered on the previous screen.
class FlutterWechatFullPhoneLoginPageState
    extends State<FlutterWechatFullPhoneLoginPage> {
  bool _passwordWay = true;
  String _captchaTitle = '获取验证码';
  bool _captchaDisabled = false;
  int _secondsLeft = 60;
  Timer? _timer;

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _captchaController = TextEditingController();

  String get _phone => widget.phone;

  String get _phoneFormat => '+${widget.zoneCode} ${_formatMobile(_phone)}';

  bool get _loginDisabled {
    return _passwordWay
        ? _passwordController.text.isEmpty
        : _captchaController.text.isEmpty;
  }

  bool get _validPhone => RegExp(r'^1[3-9]\d{9}$').hasMatch(_phone);

  @override
  void dispose() {
    _timer?.cancel();
    _passwordController.dispose();
    _captchaController.dispose();
    super.dispose();
  }

  String _formatMobile(String mobile) {
    if (mobile.length != 11) {
      return mobile;
    }
    return '${mobile.substring(0, 3)} ${mobile.substring(3, 7)} '
        '${mobile.substring(7)}';
  }

  void _toggleWay() {
    setState(() {
      _passwordWay = !_passwordWay;
    });
  }

  void _submit() {
    if (_loginDisabled) {
      return;
    }
    if (_passwordWay) {
      final String password = _passwordController.text;
      if (!_validPhone ||
          password.length < 8 ||
          password.length > 16 ||
          RegExp(r'[\u4e00-\u9fa5]').hasMatch(password)) {
        _showError('账号或密码错误，请重新填写');
        return;
      }
    } else {
      final String captcha = _captchaController.text;
      if (!_validPhone ||
          captcha.length != 6 ||
          !RegExp(r'^\d+$').hasMatch(captcha)) {
        _showError('验证码超时，请重新获取验证码');
        return;
      }
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

  void _requestCaptcha() {
    if (_captchaDisabled) {
      return;
    }
    if (!_validPhone) {
      _showError('手机号码错误', content: '你输入的是一个无效的手机号码');
      return;
    }
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认手机号码', style: TextStyle(fontSize: 17.0)),
        content: Text(
          '我们将发送验证码短信到这个号码：$_phoneFormat',
          style: const TextStyle(fontSize: 15.0),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              '取消',
              style: TextStyle(color: FlutterWechatFullStyle.textPrimary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _fetchCaptcha();
            },
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

  void _fetchCaptcha() {
    setState(() {
      _captchaDisabled = true;
      _captchaTitle = '发送中...';
    });
    Future<void>.delayed(const Duration(seconds: 1), () {
      if (!mounted) {
        return;
      }
      setState(() {
        _secondsLeft = 60;
        _captchaTitle = '60s后重新发送';
      });
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _secondsLeft--;
          if (_secondsLeft == 0) {
            timer.cancel();
            _timer = null;
            _captchaDisabled = false;
            _captchaTitle = '获取验证码';
            return;
          }
          _captchaTitle = '$_secondsLeft后重新发送';
        });
      });
    });
  }

  void _showError(String title, {String? content}) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: content == null
            ? null
            : Text(title, style: const TextStyle(fontSize: 17.0)),
        content: Text(content ?? title, style: const TextStyle(fontSize: 17.0)),
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
          child: const Text('找回密码'),
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        actions: <Widget>[
          IconButton(
            onPressed: _showMoreSheet,
            icon: const Icon(
              Icons.more_horiz,
              color: FlutterWechatFullStyle.textPrimary,
            ),
          ),
        ],
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 90.0),
            child: Column(
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.fromLTRB(20.0, 0, 20.0, 14.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '手机号登录',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.w500,
                        color: FlutterWechatFullStyle.textPrimary,
                      ),
                    ),
                  ),
                ),
                Row(
                  children: <Widget>[
                    const SizedBox(
                      width: 105.0,
                      child: Padding(
                        padding: EdgeInsets.only(left: 20.0),
                        child: Text(
                          '手机号',
                          style: TextStyle(
                            fontSize: 17.0,
                            color: FlutterWechatFullStyle.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        _phoneFormat,
                        style: const TextStyle(
                          fontSize: 17.0,
                          color: FlutterWechatFullStyle.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20.0),
                  ],
                ),
                const SizedBox(height: 14.0),
                const Divider(
                  height: 0.5,
                  indent: 20.0,
                  endIndent: 20.0,
                  color: FlutterWechatFullStyle.divider,
                ),
                _passwordWay ? _buildPasswordRow() : _buildCaptchaRow(),
                const Divider(
                  height: 0.5,
                  indent: 20.0,
                  endIndent: 20.0,
                  color: FlutterWechatFullStyle.divider,
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 20.0,
                    top: 34.0,
                    right: 20.0,
                  ),
                  child: GestureDetector(
                    onTap: _toggleWay,
                    behavior: HitTestBehavior.opaque,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _passwordWay ? '用短信验证码登录' : '用密码登录',
                        style: const TextStyle(
                          fontSize: 16.0,
                          color: Color(0xFF5B6A91),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 20.0,
                    top: 63.0,
                    right: 20.0,
                  ),
                  child: Opacity(
                    opacity: _loginDisabled ? 0.5 : 1.0,
                    child: SizedBox(
                      width: double.maxFinite,
                      child: Material(
                        color: FlutterWechatFullStyle.primary,
                        borderRadius: BorderRadius.circular(4.0),
                        child: InkWell(
                          onTap: _submit,
                          borderRadius: BorderRadius.circular(4.0),
                          highlightColor: FlutterWechatFullStyle.primaryDark,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 11.0,
                              horizontal: 24.0,
                            ),
                            child: Center(
                              child: Text(
                                '登录',
                                style: TextStyle(
                                  fontSize: 17.0,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40.0),
          _buildFooter(),
          const SizedBox(height: 20.0),
        ],
      ),
    );
  }

  Widget _buildPasswordRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
            child: FlutterWechatFullTextField(
              controller: _passwordController,
              hintText: '请填写密码',
              obscureText: true,
              onChanged: (_) => setState(() {}),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaptchaRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: <Widget>[
          const SizedBox(
            width: 85.0,
            child: Text(
              '验证码',
              style: TextStyle(
                fontSize: 17.0,
                color: FlutterWechatFullStyle.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: FlutterWechatFullTextField(
              controller: _captchaController,
              hintText: '请输入验证码',
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
            ),
          ),
          GestureDetector(
            onTap: _requestCaptcha,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 5.0,
                vertical: 2.0,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: _captchaDisabled
                      ? const Color(0xFF999999)
                      : const Color(0xFF353535),
                  width: 0.5,
                ),
                borderRadius: BorderRadius.circular(3.0),
              ),
              child: Text(
                _captchaTitle,
                style: TextStyle(
                  fontSize: 13.0,
                  color: _captchaDisabled
                      ? const Color(0xFF999999)
                      : FlutterWechatFullStyle.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Text(
          '找回密码',
          style: TextStyle(fontSize: 15.0, color: Color(0xFF5B6A91)),
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
    );
  }
}
