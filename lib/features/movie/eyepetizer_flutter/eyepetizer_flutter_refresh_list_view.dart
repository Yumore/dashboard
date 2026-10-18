import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_refresh_list_view_state.dart';
import 'package:flutter/material.dart';

/// `lib/widgets/refresh_listview.dart`'s two typedefs.
typedef EyepetizerFlutterOnLoadMore = void Function();

typedef EyepetizerFlutterOnRefreshCallback =
    Future<void> Function({bool isReload});

/// `lib/widgets/refresh_listview.dart` → `RefreshListView`.
///
/// Pull-to-refresh plus the source's "reached the bottom" rule: the listener
/// fires when `position.pixels == position.maxScrollExtent`, not when it comes
/// within a threshold, and it does not debounce — the caller guards re-entry.
class EyepetizerFlutterRefreshListView extends StatefulWidget {
  const EyepetizerFlutterRefreshListView({
    super.key,
    required this.scrollController,
    this.onRefresh,
    this.onLoadMore,
    this.enableRefresh = true,
    this.enableLoadMore = true,
    this.itemCount,
    this.itemBuilder,
    this.child,
  });

  final ScrollController scrollController;
  final EyepetizerFlutterOnRefreshCallback? onRefresh;
  final EyepetizerFlutterOnLoadMore? onLoadMore;
  final bool enableRefresh;
  final bool enableLoadMore;
  final int? itemCount;
  final NullableIndexedWidgetBuilder? itemBuilder;
  final Widget? child;

  @override
  State<EyepetizerFlutterRefreshListView> createState() =>
      EyepetizerFlutterRefreshListViewState();
}
