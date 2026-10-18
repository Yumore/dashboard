import 'package:dashboard/features/reading/eso/eso_rss_page_state.dart';
import 'package:dashboard/features/reading/eso/eso_search_item.dart';
import 'package:flutter/material.dart';

/// eso 的 RSS 源阅读页。
///
/// 源实现把正文 HTML 拼成 `Uri.dataFromString` 丢给 WebView；宿主没有
/// WebView 依赖的排版保证，这里把 HTML 转成纯文本段落用原生控件渲染
/// （图片不显示，样式不保留，其余阅读体验一致）。
class EsoRssPage extends StatefulWidget {
  const EsoRssPage({required this.item, super.key});

  final EsoSearchItem item;

  @override
  State<EsoRssPage> createState() => EsoRssPageState();
}
