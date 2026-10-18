import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_refresh_list_view.dart';
import 'package:flutter/material.dart';

/// State for [EyepetizerFlutterRefreshListView].
class EyepetizerFlutterRefreshListViewState
    extends State<EyepetizerFlutterRefreshListView> {
  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(scrollControllerListener);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(scrollControllerListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await widget.onRefresh?.call(isReload: true);
      },
      child:
          widget.child ??
          ListView.builder(
            controller: widget.scrollController,
            itemBuilder: widget.itemBuilder ?? (context, index) => null,
            itemCount: widget.itemCount,
          ),
    );
  }

  /// `RefreshListViewState.scrollControllerListener`.
  void scrollControllerListener() {
    final position = widget.scrollController.position;
    if (position.pixels == position.maxScrollExtent) {
      if (widget.enableLoadMore && widget.onLoadMore != null) {
        widget.onLoadMore!();
      }
    }
  }
}
