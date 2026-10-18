import 'package:dashboard/features/movie/eyepetizer/eyepetizer_category.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_image.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_thumbnail.dart';
import 'package:flutter/material.dart';

/// One tile of the category grid.
///
/// Port of `module_discover/lib/widget/category_item_widget.dart` + the grid in
/// `category_page.dart`, which printed `category.alias` (not `name`) over the
/// category's blurred background.
class EyepetizerCategoryWidgetItem extends StatelessWidget {
  const EyepetizerCategoryWidgetItem({
    required this.category,
    this.onTap,
    super.key,
  });

  final EyepetizerCategory category;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final label = category.alias.isNotEmpty ? category.alias : category.name;
    final url = EyepetizerImage.resolve(category.bgPicture) == null
        ? category.headerImage
        : category.bgPicture;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            EyepetizerThumbnail(
              url: url,
              fit: BoxFit.cover,
              placeholderIcon: Icons.grid_view_outlined,
            ),
            const DecoratedBox(
              decoration: BoxDecoration(color: Colors.black38),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
