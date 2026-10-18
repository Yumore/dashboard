import 'package:flutter/material.dart';

import 'pages/pixez_home_page.dart';

/// Static module entry for the pixiv (pixez) client.
///
/// The Lead inserts one `ListTile` into `ComicModulePage.build`; see the
/// module report for the exact snippet. Keeping the title/subtitle/icon here
/// avoids editing the shared module page from this feature.
class PixezEntry {
  const PixezEntry._();

  static const String title = 'Pixiv（Pixez）';
  static const String subtitle = '推荐、排行榜、搜索、作品详情与作者主页（需登录令牌）';
  static const IconData icon = Icons.photo_library_outlined;

  static Widget page() => const PixezHomePage();
}
