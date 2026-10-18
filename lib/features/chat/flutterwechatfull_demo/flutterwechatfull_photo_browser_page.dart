import 'package:flutter/material.dart';
import 'flutterwechatfull_photo_browser_page_state.dart';

/// The source's `PhotoBrowserPage`, used by the contact profile pictures and
/// the moments header. Read-only: pinch to zoom, swipe between photos.
class FlutterWechatFullPhotoBrowserPage extends StatefulWidget {
  const FlutterWechatFullPhotoBrowserPage({
    required this.photos,
    this.initialIndex = 0,
    super.key,
  });

  final List<String> photos;
  final int initialIndex;

  @override
  State<FlutterWechatFullPhotoBrowserPage> createState() =>
      FlutterWechatFullPhotoBrowserPageState();
}
