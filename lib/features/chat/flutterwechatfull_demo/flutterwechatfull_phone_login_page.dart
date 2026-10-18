import 'package:flutter/material.dart';

import 'flutterwechatfull_phone_login_page_state.dart';

/// Second step of the phone login, from the source
/// `lib/views/login/phone_login/phone_login_page.dart`.
class FlutterWechatFullPhoneLoginPage extends StatefulWidget {
  const FlutterWechatFullPhoneLoginPage({
    required this.phone,
    required this.zoneCode,
    super.key,
  });

  final String phone;
  final String zoneCode;

  @override
  State<FlutterWechatFullPhoneLoginPage> createState() =>
      FlutterWechatFullPhoneLoginPageState();
}
