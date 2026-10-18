import 'package:dashboard/features/movie/fluttercinematic/cinematic_media_item.dart';
import 'package:dashboard/features/movie/fluttercinematic/cinematic_paging_controller.dart';
import 'package:dashboard/features/movie/fluttercinematic/widgets/cinematic_poster_card.dart';
import 'package:dashboard/features/movie/fluttercinematic/widgets/cinematic_section_header.dart';
import 'package:flutter/material.dart';

/// Port of the source's `SimilarMediaList` on the detail pages: a horizontal
/// poster strip. The source always loaded page 1 and pushed the next page once
/// the offset passed 2500px; [loadMoreThreshold] keeps that larger value.
class CinematicSimilarMediaList extends StatefulWidget {
  const CinematicSimilarMediaList({
    required this.controller,
    required this.title,
    required this.onItemTap,
    this.loadMoreThreshold = 2500,
    super.key,
  });

  final CinematicPagingController controller;
  final String title;
  final ValueChanged<CinematicMediaItem> onItemTap;
  final double loadMoreThreshold;

  @override
  State<CinematicSimilarMediaList> createState() =>
      _CinematicSimilarMediaListState();
}

class _CinematicSimilarMediaListState extends State<CinematicSimilarMediaList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
    _scrollController.addListener(_onScroll);
    widget.controller.loadInitial();
  }

  @override
  void didUpdateWidget(CinematicSimilarMediaList oldWidget) {
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
    if (position.maxScrollExtent - position.pixels < widget.loadMoreThreshold) {
      widget.controller.fetchNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    if (controller.items.isEmpty && controller.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (controller.items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        CinematicSectionHeader(widget.title),
        SizedBox(
          height: 250,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: controller.items.length,
            itemBuilder: (context, index) {
              final item = controller.items[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: CinematicPosterCard.media(
                  item: item,
                  onTap: () => widget.onItemTap(item),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
