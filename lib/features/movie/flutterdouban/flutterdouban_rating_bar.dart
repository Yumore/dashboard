import 'package:flutter/material.dart';

/// Five-star rendering of douban's 10-point `rating.average`.
///
/// The source's `RatingBar` widget did the same `/2` conversion; this version
/// is stateless and exposes [iconFor] so the mapping is unit-testable.
class FlutterDouBanRatingBar extends StatelessWidget {
  const FlutterDouBanRatingBar({
    super.key,
    required this.average,
    this.max = 10,
    this.size = 14,
    this.showText = true,
  });

  final double average;
  final int max;
  final double size;
  final bool showText;

  double get stars => max <= 0 ? 0 : average / max * 5;

  static IconData iconFor(int star, double stars) {
    if (stars >= star) return Icons.star;
    if (stars >= star - 0.5) return Icons.star_half;
    return Icons.star_border;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var star = 1; star <= 5; star++)
          Icon(
            iconFor(star, stars),
            size: size,
            color: Theme.of(context).colorScheme.primary,
          ),
        if (showText && average > 0)
          Padding(
            padding: const EdgeInsets.only(left: 6),
            child: Text(
              average.toStringAsFixed(1),
              style: TextStyle(
                fontSize: size - 1,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
      ],
    );
  }
}
