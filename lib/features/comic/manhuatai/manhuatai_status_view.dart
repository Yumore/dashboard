import 'package:flutter/material.dart';

/// Shared loading / error / empty placeholder for the manhuatai screens.
///
/// The source showed the same states through `flutter_spinkit` spinners and
/// toasts; this port renders them inline so no extra dependency is needed.
class ManhuataiStatusView extends StatelessWidget {
  const ManhuataiStatusView({
    super.key,
    this.message,
    this.onRetry,
    this.loading = false,
  });

  final String? message;
  final VoidCallback? onRetry;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(message ?? '暂无数据'),
          if (onRetry != null) ...<Widget>[
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onRetry, child: const Text('重试')),
          ],
        ],
      ),
    );
  }
}
