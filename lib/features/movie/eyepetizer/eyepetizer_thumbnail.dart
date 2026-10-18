import 'package:cached_network_image/cached_network_image.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_image.dart';
import 'package:flutter/material.dart';

/// Signature of the swappable image builder, so widget tests can render without
/// touching the network or the disk cache.
typedef EyepetizerThumbnailBuilder =
    Widget Function(BuildContext context, String url);

/// A 开眼 thumbnail with the source's placeholder behaviour.
///
/// Replaces `ImgUtil.cacheImage` (`component/lib_utils/lib/img_util.dart`):
/// * a blank/non-network URL draws the placeholder directly instead of handing
///   `null` to `CachedNetworkImage` and crashing (the source's behaviour);
/// * `CachedNetworkImage` handles the loading/error placeholder.
class EyepetizerThumbnail extends StatelessWidget {
  const EyepetizerThumbnail({
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = BorderRadius.zero,
    this.circle = false,
    this.placeholderIcon = Icons.image_outlined,
    super.key,
  });

  /// Test seam: when set, every thumbnail renders through this builder. Widget
  /// tests set it in `setUp` and clear it in `tearDown`.
  static EyepetizerThumbnailBuilder? builderOverride;

  final Object? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius borderRadius;
  final bool circle;
  final IconData placeholderIcon;

  @override
  Widget build(BuildContext context) {
    final resolved = EyepetizerImage.resolve(url);
    final Widget child;
    if (resolved == null) {
      child = _placeholder(context);
    } else {
      final override = builderOverride;
      child = override != null
          ? override(context, resolved)
          : CachedNetworkImage(
              imageUrl: resolved,
              width: width,
              height: height,
              fit: fit,
              placeholder: (context, url) => _placeholder(context),
              errorWidget: (context, url, error) => _placeholder(context),
            );
    }
    if (circle) return ClipOval(child: child);
    if (borderRadius == BorderRadius.zero) return child;
    return ClipRRect(borderRadius: borderRadius, child: child);
  }

  Widget _placeholder(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: width,
      height: height,
      color: scheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(placeholderIcon, size: 20, color: scheme.outline),
    );
  }
}
