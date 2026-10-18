import 'package:dashboard/features/reading/eso/eso_page_state.dart';
import 'package:flutter/material.dart';

/// eso 书源阅读入口页：书架 / 搜索 / 书源三个页签。
///
/// 对应 eso 的组合首页（`lib/page/novel_page.dart` 一类页面 + 抽屉里的
/// `menu_search_source` / `menu_discover_source`），这里把「书架、跨源搜索、
/// 书源管理」收进一个入口，阅读页交给 [EsoReaderPage]。
class EsoPage extends StatefulWidget {
  const EsoPage({super.key});

  @override
  State<EsoPage> createState() => EsoPageState();
}
