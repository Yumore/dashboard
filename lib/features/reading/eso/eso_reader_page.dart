import 'package:dashboard/features/reading/eso/eso_reader_page_state.dart';
import 'package:dashboard/features/reading/eso/eso_search_item.dart';
import 'package:flutter/material.dart';

/// eso 阅读/播放页：按内容类型分发到文字阅读、RSS 阅读或宿主播放器。
class EsoReaderPage extends StatefulWidget {
  const EsoReaderPage({required this.item, super.key});

  final EsoSearchItem item;

  @override
  State<EsoReaderPage> createState() => EsoReaderPageState();
}
