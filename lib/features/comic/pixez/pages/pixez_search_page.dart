import 'package:flutter/material.dart';

import '../controllers/pixez_search_controller.dart';
import 'pixez_search_page_state.dart';

/// Search tab: illust results or author results.
class PixezSearchPage extends StatefulWidget {
  const PixezSearchPage({this.controller, super.key});

  final PixezSearchController? controller;

  @override
  PixezSearchPageState createState() => PixezSearchPageState();
}
