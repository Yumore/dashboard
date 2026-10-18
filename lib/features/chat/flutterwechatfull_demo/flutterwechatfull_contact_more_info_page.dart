import 'package:flutter/material.dart';

import 'flutterwechatfull_contact.dart';
import 'flutterwechatfull_contact_more_info_page_state.dart';

/// The source's `ContactMoreInfoPage` (社交资料).
class FlutterWechatFullContactMoreInfoPage extends StatefulWidget {
  const FlutterWechatFullContactMoreInfoPage({
    required this.contact,
    super.key,
  });

  final FlutterWechatFullContact contact;

  @override
  State<FlutterWechatFullContactMoreInfoPage> createState() =>
      FlutterWechatFullContactMoreInfoPageState();
}
