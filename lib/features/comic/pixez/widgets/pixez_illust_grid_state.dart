import 'package:flutter/material.dart';

import 'pixez_illust_card.dart';
import 'pixez_illust_grid.dart';

class PixezIllustGridState extends State<PixezIllustGrid> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_maybeLoadMore);
  }

  void _maybeLoadMore() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.maxScrollExtent <= 0) return;
    if (position.pixels >= position.maxScrollExtent - 320) {
      widget.onLoadMore?.call();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.illusts.isEmpty && !widget.loading) {
      return const Center(child: Text('没有作品'));
    }
    return CustomScrollView(
      controller: _scrollController,
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics,
      slivers: <Widget>[
        SliverPadding(
          padding: widget.padding,
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.62,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final illust = widget.illusts[index];
              return PixezIllustCard(
                illust: illust,
                onTap: widget.onTap == null
                    ? null
                    : () => widget.onTap!(illust),
              );
            }, childCount: widget.illusts.length),
          ),
        ),
        if (widget.loading)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(bottom: 24),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }
}
