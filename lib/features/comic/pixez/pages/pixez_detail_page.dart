import 'package:flutter/material.dart';

import '../controllers/pixez_detail_controller.dart';
import 'pixez_detail_page_state.dart';

/// Detail tab: illust detail, related works, bookmark/follow actions.
class PixezDetailPage extends StatefulWidget {
  const PixezDetailPage({
    required this.illustId,
    this.controller,
    super.key,
  });

  final int illustId;
  final PixezDetailController? controller;

  @override
  PixezDetailPageState createState() => PixezDetailPageState();
}
