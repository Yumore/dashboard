import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_account_repository.dart';
import 'package:dashboard/app/platform/app_toast.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_countdown_button.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_exception.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_register_page.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_string_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// State for [EyepetizerFlutterRegisterPage].
class EyepetizerFlutterRegisterPageState
    extends State<EyepetizerFlutterRegisterPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _verificationCodeController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late final EyepetizerFlutterAccountRepository _repository;
  late final bool _ownsRepository;
  bool _submitting = false;

  /// `RegisterPageState.register`'s guard order and strings.
  ///
  /// The source called `register(phone, verificationCode, password)` against a
  /// repository signature of `(phone, password, verificationCode)`, swapping the
  /// last two arguments twice; the request that left the device was therefore
  /// `code=<verificationCode>, password=<password>`. The port calls the
  /// repository with its declared order, so the wire format is unchanged and
  /// the accidental double swap is not reproduced.
  static String? validate({
    String? phone,
    String? password,
    String? verificationCode,
  }) {
    if (EyepetizerFlutterStringUtil.isEmpty(phone)) return '手机号不能为空';
    if (EyepetizerFlutterStringUtil.isEmpty(password)) return '密码不能为空';
    if (EyepetizerFlutterStringUtil.isEmpty(verificationCode)) {
      return '验证码不能为空';
    }
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
    _verificationCodeController.dispose();
    _passwordController.dispose();
    if (_ownsRepository) _repository.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('注册')),
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
            Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _verificationCodeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: '请输入验证码'),
                  ),
                ),
                const SizedBox(width: 10),
                EyepetizerFlutterCountdownButton(
                  text: '获取验证码',
                  period: 60,
                  interval: 1,
                  onCountDownStart: getVerificationCode,
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(hintText: '请输入密码'),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _submitting ? null : register,
              child: const Text('注册'),
            ),
          ],
        ),
      ),
    );
  }

  /// `RegisterPageState.getVerificationCode` — a non-zero `error` is reported
  /// and nothing else happens.
  Future<void> getVerificationCode() async {
    final phone = _phoneController.text;
    if (EyepetizerFlutterStringUtil.isEmpty(phone)) {
      await AppToast.show(msg: '手机号不能为空');
      return;
    }
    try {
      final value = await _repository.getVerificationCode(phone);
      if ((value.error ?? 0) != 0) {
        await AppToast.show(msg: value.msg ?? '');
      }
    } on EyepetizerFlutterException catch (error) {
      await AppToast.show(msg: error.message);
    }
  }

  /// `RegisterPageState.register`.
  Future<void> register() async {
    final phone = _phoneController.text;
    final password = _passwordController.text;
    final code = _verificationCodeController.text;
    final message = validate(
      phone: phone,
      password: password,
      verificationCode: code,
    );
    if (message != null) {
      await AppToast.show(msg: message);
      return;
    }
    setState(() => _submitting = true);
    try {
      final value = await _repository.register(phone, code, password);
      if ((value.error ?? 0) != 0) {
        await AppToast.show(msg: value.msg ?? '');
        return;
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on EyepetizerFlutterException catch (error) {
      await AppToast.show(msg: error.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}
