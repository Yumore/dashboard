import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_message_detail_page_state.dart';
import 'package:flutter/material.dart';

/// Port of `MsgDetailListPage` from
/// `flutter_tiktok/lib/pages/msgDetailListPage.dart`.
class FlutterTiktokMessageDetailPage extends StatefulWidget {
  const FlutterTiktokMessageDetailPage({
    required this.title,
    required this.messageTitle,
    required this.messageDesc,
    this.reverse = false,
    super.key,
  });

  final String title;
  final String messageTitle;
  final String messageDesc;
  final bool reverse;

  static const int rowCount = 20;

  @override
  State<FlutterTiktokMessageDetailPage> createState() =>
      FlutterTiktokMessageDetailPageState();
}
