import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_account_repository.dart';
import 'package:dashboard/app/platform/app_toast.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_exception.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_login_page.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_prefs_key.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_prefs_util.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_register_page.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_string_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// State for [EyepetizerFlutterLoginPage].
class EyepetizerFlutterLoginPageState
    extends State<EyepetizerFlutterLoginPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late final EyepetizerFlutterAccountRepository _repository;
  late final bool _ownsRepository;
  bool _submitting = false;

  /// `LoginPageState.login`'s guard order and strings, split out so the rules
  /// are assertable without a widget tree.
  static String? validate({String? phone, String? password}) {
    if (EyepetizerFlutterStringUtil.isEmpty(phone)) return '手机号不能为空';
    if (EyepetizerFlutterStringUtil.isEmpty(password)) return '密码不能为空';
    return null;
  }

  @override
  void initState() {
    super.initState();
    _ownsRepository = widget.repository == null;
    _repository = widget.repository ?? EyepetizerFlutterAccountRepository();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    if (_ownsRepository) _repository.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('登录')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.number,
              maxLength: 11,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: const InputDecoration(hintText: '请输入手机号'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(hintText: '请输入密码'),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _submitting ? null : login,
              child: const Text('登录'),
            ),
            TextButton(
              onPressed: _openRegister,
              child: const Text('没有账号，先去注册'),
            ),
          ],
        ),
      ),
    );
  }

  /// `LoginPageState.login`.
  Future<void> login() async {
    final phone = _phoneController.text;
    final password = _passwordController.text;
    final message = validate(phone: phone, password: password);
    if (message != null) {
      await AppToast.show(msg: message);
      return;
    }
    setState(() => _submitting = true);
    try {
      final login = await _repository.login(phone, password);
      // The source stored the whole `Login` (not the member) under this key.
      await EyepetizerFlutterPrefsUtil.putObject(
        EyepetizerFlutterPrefsKey.userData,
        login,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on EyepetizerFlutterException catch (error) {
      await AppToast.show(msg: error.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _openRegister() {
    Navigator.of(context).push(
      MaterialPageRoute<bool>(
        builder: (_) => const EyepetizerFlutterRegisterPage(),
      ),
    );
  }
}
