import 'package:cached_network_image/cached_network_image.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_image.dart';
import 'package:flutter/material.dart';

/// Poster/avatar image with the source's placeholder behaviour, ported.
///
/// The source used `Image.asset('assets/images/ic_default_img_subject_movie.9.png')`
/// as the `CachedNetworkImage.placeholder` (`subject_mark_image_widget.dart:56`);
/// this host does not carry that bitmap, so the fallback is a Material icon on
/// a themed surface. A null/blank/non-network URL renders the same fallback.
class FlutterDouBanPoster extends StatelessWidget {
  const FlutterDouBanPoster({
    super.key,
    this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 6,
  });

  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final resolved = FlutterDouBanImage.resolve(url);
    final placeholder = _placeholder(context);
    if (resolved == null) return placeholder;
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: resolved,
        width: width,
        height: height,
        fit: fit,
        placeholder: (_, _) => placeholder,
        errorWidget: (_, _, _) => placeholder,
      ),
    );
  }

  Widget _placeholder(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.movie_outlined,
        size: 22,
        color: scheme.onSurfaceVariant,
      ),
    );
  }
}
