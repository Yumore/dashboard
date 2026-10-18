import 'dart:io';

import 'package:url_launcher/url_launcher.dart';

/// 打开已下载 EPUB 的方式。
///
/// 源工程用 vendored Readium（`iridium_reader_widget` 的
/// `EpubScreen.fromPath`）就地阅读；该目录明确不属于本次移植范围，宿主也没有
/// 其它 EPUB 渲染器（`alexandria` 是 libgen/zlib 搜索页，`easymygo` /
/// `book/reader` 是纯文本排版器），所以这里按任务允许的方式**交给系统外部
/// 应用打开**。
///
/// 做成可注入的类（同 `YyetsLinkLauncher` 的写法）：widget 测试塞一个记录型
/// 假实现，不必真的拉起外部应用。
class FeedbooksBookOpener {
  const FeedbooksBookOpener({this.fileExists, this.launch});

  /// 测试注入点：给定时替代 `File(path).exists()`。
  final Future<bool> Function(String path)? fileExists;

  /// 测试注入点：给定时替代 `launchUrl`。
  final Future<bool> Function(Uri uri)? launch;

  /// 源工程 `openBook` 里文件缺失时的提示文案。
  static const String missingFileMessage =
      'Could not find the book file. Please download it again.';

  /// 文件在但没能唤起外部应用时的提示文案（源工程没有这条路径）。
  static const String openFailedMessage = 'Could not open the book file.';

  Future<bool> exists(String path) async {
    if (path.trim().isEmpty) return false;
    final Future<bool> Function(String path)? impl = fileExists;
    if (impl != null) return impl(path);
    try {
      return await File(path).exists();
    } on Exception {
      return false;
    }
  }

  Future<bool> openFile(String path) async {
    if (path.trim().isEmpty) return false;
    final Uri uri = Uri.file(path);
    final Future<bool> Function(Uri uri)? handler = launch;
    try {
      if (handler != null) return await handler(uri);
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on Exception {
      return false;
    }
  }
}
