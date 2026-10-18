import 'package:flutter/material.dart';

import 'flutterwechatfull_contact.dart';
import 'flutterwechatfull_contact_setting_info_page_state.dart';

/// The source's `ContactSettingInfoPage` (资料设置).
class FlutterWechatFullContactSettingInfoPage extends StatefulWidget {
  const FlutterWechatFullContactSettingInfoPage({
    required this.contact,
    super.key,
  });

  final FlutterWechatFullContact contact;

  @override
  FlutterWechatFullContactSettingInfoPageState createState() =>
      FlutterWechatFullContactSettingInfoPageState();
}
