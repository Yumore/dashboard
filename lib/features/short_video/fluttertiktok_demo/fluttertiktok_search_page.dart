import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_search_page_state.dart';
import 'package:flutter/material.dart';

/// Port of `SearchPage` from `flutter_tiktok/lib/pages/searchPage.dart`.
class FlutterTiktokSearchPage extends StatefulWidget {
  const FlutterTiktokSearchPage({this.onPop, super.key});

  final VoidCallback? onPop;

  @override
  State<FlutterTiktokSearchPage> createState() =>
      FlutterTiktokSearchPageState();
}
