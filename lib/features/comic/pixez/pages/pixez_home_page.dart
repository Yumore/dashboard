import 'package:flutter/material.dart';

import '../controllers/pixez_home_controller.dart';
import 'pixez_home_page_state.dart';

/// Home tab of the pixiv client (recommended illusts).
class PixezHomePage extends StatefulWidget {
  const PixezHomePage({this.controller, super.key});

  final PixezHomeController? controller;

  @override
  PixezHomePageState createState() => PixezHomePageState();
}
