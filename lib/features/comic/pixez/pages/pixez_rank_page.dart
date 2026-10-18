import 'package:flutter/material.dart';

import '../controllers/pixez_rank_controller.dart';
import 'pixez_rank_page_state.dart';

/// Rank tab: 12 pixiv ranking modes and an optional date.
class PixezRankPage extends StatefulWidget {
  const PixezRankPage({this.controller, super.key});

  final PixezRankController? controller;

  @override
  PixezRankPageState createState() => PixezRankPageState();
}
