import 'package:flutter/material.dart';

import 'flutterwechatfull_zone_code_picker_page_state.dart';

/// The source's country/region picker; pops the chosen dialing code.
class FlutterWechatFullZoneCodePickerPage extends StatefulWidget {
  const FlutterWechatFullZoneCodePickerPage({
    required this.zoneCode,
    super.key,
  });

  final String zoneCode;

  @override
  FlutterWechatFullZoneCodePickerPageState createState() =>
      FlutterWechatFullZoneCodePickerPageState();
}
