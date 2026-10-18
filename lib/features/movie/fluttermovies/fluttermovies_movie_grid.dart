import 'package:dashboard/features/movie/fluttermovies/fluttermovies_list_item.dart';
import 'package:dashboard/features/movie/fluttermovies/fluttermovies_movie_card.dart';
import 'package:flutter/material.dart';

/// 竖版海报网格（可带底部 footer，用于「加载更多 / 没有更多」）。
class FlutterMoviesMovieGrid extends StatelessWidget {
  const FlutterMoviesMovieGrid({
    required this.items,
    required this.imageUrl,
    required this.onTap,
    this.header,
    this.footer,
    this.padding = const EdgeInsets.fromLTRB(12, 8, 12, 24),
    super.key,
  });

  final List<FlutterMoviesListItem> items;
  final String? Function(FlutterMoviesListItem item) imageUrl;
  final void Function(FlutterMoviesListItem item) onTap;
  final Widget? header;
  final Widget? footer;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => CustomScrollView(
    slivers: [
      if (header != null) SliverToBoxAdapter(child: header),
      SliverPadding(
        padding: padding,
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.62,
          ),
          delegate: SliverChildBuilderDelegate((context, index) {
            final item = items[index];
            return FlutterMoviesMovieCard.of(
              item,
              imageUrl: imageUrl(item),
              onTap: () => onTap(item),
            );
          }, childCount: items.length),
        ),
      ),
      if (footer != null) SliverToBoxAdapter(child: footer),
    ],
  );
}
