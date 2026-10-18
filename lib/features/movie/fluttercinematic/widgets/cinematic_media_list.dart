import 'package:dashboard/features/movie/fluttercinematic/cinematic_media_item.dart';
import 'package:dashboard/features/movie/fluttercinematic/cinematic_paging_controller.dart';
import 'package:dashboard/features/movie/fluttercinematic/widgets/cinematic_media_list_item.dart';
import 'package:flutter/material.dart';

/// Port of the source `lib/widgets/media_list.dart` (`MediaList` +
/// `MediaListState`): one category tab with infinite scroll.
///
/// The source pushed the next page when the `ScrollController` offset passed
/// 300px; that threshold now lives on [CinematicPagingController] and is
/// checked here against the last scroll offset.
class CinematicMediaList extends StatefulWidget {
  const CinematicMediaList({
    required this.controller,
    required this.onItemTap,
    this.favoriteBuilder,
    super.key,
  });

  final CinematicPagingController controller;
  final ValueChanged<CinematicMediaItem> onItemTap;

  /// Supplies the optional favourite control for each row.
  final Widget Function(CinematicMediaItem item)? favoriteBuilder;

  @override
  State<CinematicMediaList> createState() => _CinematicMediaListState();
}

class _CinematicMediaListState extends State<CinematicMediaList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
    _scrollController.addListener(_onScroll);
    widget.controller.loadInitial();
  }

  @override
  void didUpdateWidget(CinematicMediaList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onChanged);
      widget.controller.addListener(_onChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    _scrollController.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    final remaining = position.maxScrollExtent - position.pixels;
    if (remaining < widget.controller.loadMoreThreshold) {
      widget.controller.fetchNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    if (controller.items.isEmpty && controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (controller.items.isEmpty && controller.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text('Something went wrong'),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: controller.fetchNextPage,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(top: 12, bottom: 24),
      itemCount: controller.items.length + (controller.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= controller.items.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final item = controller.items[index];
        return CinematicMediaListItem(
          item: item,
          onTap: widget.onItemTap,
          favoriteButton: widget.favoriteBuilder?.call(item),
        );
      },
    );
  }
}
