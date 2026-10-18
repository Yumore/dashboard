import 'package:flutter/material.dart';
import 'package:dashboard/features/comic/hakacomic/haka_entry_page.dart';

/// Metadata the host module page needs to list this source.
///
/// The host `comic_module_page.dart` is owned by another change; wire this in
/// there instead of editing that file here.
class HakaEntry {
  const HakaEntry._();

  static const String title = 'Haka 漫画';

  static const String subtitle = '哔咔漫画 picacomic 公开接口 · 搜索 / 分类 / 阅读';

  static const IconData icon = Icons.auto_stories_outlined;

  /// Widget class the module page should push.
  static Widget page() => const HakaEntryPage();
}
