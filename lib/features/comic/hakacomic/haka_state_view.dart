import 'package:flutter/material.dart';
import 'package:dashboard/features/comic/hakacomic/haka_request_state.dart';

/// Renders the three terminal states of a [HakaRequestState]:
/// first-load spinner, failure with retry, or the success [builder].
///
/// The module UI contract requires a visible loading-failure state and forbids
/// network calls from `build`, so pages delegate both here.
class HakaStateView<T> extends StatelessWidget {
  const HakaStateView({
    super.key,
    required this.state,
    required this.builder,
    required this.onRetry,
    this.emptyMessage,
  });

  final HakaRequestState<T> state;

  final Widget Function(BuildContext context, T data) builder;

  final VoidCallback onRetry;

  /// Shown when the success payload is an empty list.
  final String? emptyMessage;

  @override
  Widget build(BuildContext context) {
    final data = state.data;
    if (state.isLoading && data == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.hasError) {
      final error = state.error;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 40),
              const SizedBox(height: 12),
              Text(
                '加载失败',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                '$error',
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              FilledButton(onPressed: onRetry, child: const Text('重试')),
            ],
          ),
        ),
      );
    }
    if (data == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (emptyMessage != null && data is List && data.isEmpty) {
      return Center(child: Text(emptyMessage!));
    }
    return builder(context, data);
  }
}
