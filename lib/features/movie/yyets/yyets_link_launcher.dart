import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// 打开下载 / 播放链接的接口。
///
/// 源工程把链接分两类处理：
///
/// * 磁力、ed2k、迅雷等交给原生下载器（`RRResManager` + `item_app` 的
///   边下边播地址，仅安卓可用）；
/// * 其余链接在 `ResInfoPage` 里用 `WebView` 或系统浏览器打开。
///
/// 宿主没有原生下载器（见移植说明），所以统一走 `url_launcher` 唤起外部
/// 应用。这里做成可注入的类：页面只依赖这个接口，widget 测试可以塞一个
/// 记录调用的假实现，不必真的拉起外部应用。
class YyetsLinkLauncher {
  const YyetsLinkLauncher({this.launch});

  /// 测试注入点：给定时用它替代 `launchUrl`。
  final Future<bool> Function(Uri uri)? launch;

  /// 打开一个链接；地址为空或不是合法 URI 时返回 false，从不抛异常。
  ///
  /// `magnet:` / `ed2k:` 这类非 http 协议同样交给系统处理（桌面端没装对应
  /// 应用时会返回 false，页面负责提示）。
  Future<bool> open(String address, {String? passwd}) async {
    final text = address.trim();
    if (text.isEmpty) return false;
    final uri = Uri.tryParse(text);
    if (uri == null || uri.scheme.isEmpty) return false;
    try {
      final handler = launch;
      if (handler != null) return await handler(uri);
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on Exception {
      return false;
    }
  }
}

/// 打开链接并给出用户提示的便捷扩展（源工程用 toast，这里用 SnackBar）。
extension YyetsLinkLauncherFeedback on YyetsLinkLauncher {
  Future<void> openWithFeedback(
    BuildContext context,
    String address, {
    String? passwd,
  }) async {
    final ok = await open(address, passwd: passwd);
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.showSnackBar(
      SnackBar(content: Text(ok ? '已打开链接' : '打开链接失败：$address')),
    );
  }
}
