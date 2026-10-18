import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// `lib/widgets/cover_image_widget.dart` — the app's only image widget.
///
/// Every surface in this module shows network art through it, so its two
/// defaults are part of the look: a grey rounded box while loading and a
/// centred error icon on failure. `imageUrl` is nullable here because the
/// source's `String imageUrl` was frequently null in practice (a card whose
/// `cover.feed` was absent); a null URL renders the placeholder immediately.
class EyepetizerFlutterCoverImageWidget extends StatelessWidget {
  const EyepetizerFlutterCoverImageWidget({
    super.key,
    this.imageUrl,
    this.width,
    this.height,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  final String? imageUrl;
  final double? width;
  final double? height;
  final double? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    if (url == null || url.isEmpty) {
      return _placeholderBox();
    }
    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      placeholder: (context, url) => _placeholderBox(),
      errorWidget: (context, url, error) =>
          errorWidget ?? const Center(child: Icon(Icons.error)),
      imageBuilder: (context, imageProvider) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius ?? 0),
          image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
        ),
      ),
    );
  }

  Widget _placeholderBox() =>
      placeholder ??
      Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(borderRadius ?? 0),
        ),
      );
}
