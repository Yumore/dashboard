import 'package:flutter/material.dart';

import 'flutterwechatfull_contact.dart';
import 'flutterwechatfull_contact_info_page_state.dart';

/// The source's `ContactInfoPage` for one contact.
class FlutterWechatFullContactInfoPage extends StatefulWidget {
  const FlutterWechatFullContactInfoPage({required this.contact, super.key});

  final FlutterWechatFullContact contact;

  @override
  FlutterWechatFullContactInfoPageState createState() =>
      FlutterWechatFullContactInfoPageState();
}
