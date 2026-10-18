import 'package:dashboard/features/shared/ui/content_status.dart';
import 'package:flutter/material.dart';

/// Renders a `Future` through one loading / error / empty / data state machine.
///
/// Module pages previously duplicated their own `FutureBuilder` handling with
/// slightly different wording and no retry; they now share this widget.
class AsyncContentView<T> extends StatelessWidget {
  const AsyncContentView({
    required this.future,
    required this.builder,
    this.onRetry,
    this.retryLabel = '重试',
    this.errorMessage = '加载失败',
    this.emptyMessage = '暂无内容',
    this.idleMessage = '尚未开始加载',
    this.isEmpty,
    this.loading,
    super.key,
  });

  /// `null` renders the idle placeholder instead of spinning forever.
  final Future<T>? future;

  final Widget Function(BuildContext context, T data) builder;
  final VoidCallback? onRetry;
  final String retryLabel;
  final String errorMessage;
  final String emptyMessage;
  final String idleMessage;
  final bool Function(T data)? isEmpty;
  final Widget? loading;

  @override
  Widget build(BuildContext context) {
    final future = this.future;
    if (future == null) {
      return ContentStatusView(
        message: idleMessage,
        icon: Icons.hourglass_empty,
      );
    }
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return ContentStatusView(
            message: '$errorMessage：${snapshot.error}',
            icon: Icons.error_outline,
            actionLabel: onRetry == null ? null : retryLabel,
            onAction: onRetry,
          );
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return loading ?? const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data;
        if (data == null || (isEmpty?.call(data) ?? false)) {
          return ContentStatusView(message: emptyMessage);
        }
        return builder(context, data);
      },
    );
  }
}
