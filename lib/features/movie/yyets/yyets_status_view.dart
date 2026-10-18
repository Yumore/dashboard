import 'package:flutter/material.dart';

/// 列表的加载 / 空 / 失败三态视图。
///
/// 源工程用 `LoadingStatus` 枚举 + `LoadingPageState` 混入驱动 UI（见
/// `lib/ui/load/LoadingStatus.dart`），这里保留同样的三态语义，但换成无状态
/// widget，方便每个页面复用与测试断言。
class YyetsStatusView extends StatelessWidget {
  const YyetsStatusView({
    super.key,
    this.loading = false,
    this.error,
    this.emptyText,
    this.onRetry,
  });

  /// 首次加载中（列表为空时的转圈）。
  final bool loading;

  /// 失败文案；非 null 时优先展示失败态。
  final String? error;

  /// 空数据文案；非 null 时展示空态。
  final String? emptyText;

  /// 失败态的重试按钮回调。
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    final error = this.error;
    if (error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.error_outline, size: 36),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(error, textAlign: TextAlign.center),
            ),
            if (onRetry != null)
              TextButton(onPressed: onRetry, child: const Text('重试')),
          ],
        ),
      );
    }
    final emptyText = this.emptyText;
    if (emptyText != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.inbox_outlined, size: 36),
            const SizedBox(height: 8),
            Text(emptyText),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
