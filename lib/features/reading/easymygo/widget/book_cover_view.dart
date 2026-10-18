import 'package:dashboard/features/reading/easymygo/entity/book_cover.dart';
import 'package:flutter/material.dart';

/// Book cover with a graceful placeholder.
///
/// The ported sources return remote cover URLs; the inner demo sources exist so
/// the UI also has to survive an empty or broken URL without a dependency.
class BookCoverView extends StatelessWidget {
  const BookCoverView({
    super.key,
    required this.cover,
    this.width = 56,
    this.height = 76,
    this.radius = 6,
  });

  final BookCover cover;
  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Icon(
        cover.type.name == 'novel'
            ? Icons.menu_book_outlined
            : Icons.photo_library_outlined,
        size: width * 0.5,
      ),
    );
    if (cover.cover.isEmpty) return placeholder;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.network(
        cover.cover,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => placeholder,
      ),
    );
  }
}
