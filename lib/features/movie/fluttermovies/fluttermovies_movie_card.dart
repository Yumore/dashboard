import 'package:dashboard/features/movie/fluttermovies/fluttermovies_list_item.dart';
import 'package:dashboard/features/movie/fluttermovies/fluttermovies_network_image.dart';
import 'package:flutter/material.dart';

/// 列表 / 网格里的影片卡片。
class FlutterMoviesMovieCard extends StatelessWidget {
  const FlutterMoviesMovieCard({
    required this.title,
    this.imageUrl,
    this.remarks = '',
    this.score = '',
    this.onTap,
    super.key,
  });

  factory FlutterMoviesMovieCard.of(
    FlutterMoviesListItem item, {
    String? imageUrl,
    VoidCallback? onTap,
  }) => FlutterMoviesMovieCard(
    title: item.title,
    imageUrl: imageUrl,
    remarks: item.vodRemarks,
    score: item.scoreLabel,
    onTap: onTap,
  );

  final String title;
  final String? imageUrl;
  final String remarks;
  final String score;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                FlutterMoviesNetworkImage(imageUrl: imageUrl),
                if (remarks.isNotEmpty)
                  Positioned(right: 4, top: 4, child: _Badge(text: remarks)),
                if (score.isNotEmpty)
                  Positioned(
                    left: 4,
                    bottom: 4,
                    child: _Badge(text: score, highlight: true),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text, this.highlight = false});

  final String text;
  final bool highlight;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
    decoration: BoxDecoration(
      color: highlight ? Colors.black54 : Colors.black45,
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      text,
      style: TextStyle(
        color: highlight ? Colors.amber : Colors.white,
        fontSize: 11,
      ),
    ),
  );
}
