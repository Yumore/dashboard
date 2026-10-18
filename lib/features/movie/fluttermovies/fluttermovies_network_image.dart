import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// CMS 图片：统一占位 / 失败样式，地址由 FlutterMoviesApi.imageUrl 解析。
class FlutterMoviesNetworkImage extends StatelessWidget {
  const FlutterMoviesNetworkImage({
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.radius = 8,
    this.icon = Icons.movie_outlined,
    super.key,
  });

  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double radius;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: url == null
          ? _Placeholder(width: width, height: height, icon: icon)
          : CachedNetworkImage(
              imageUrl: url,
              width: width,
              height: height,
              fit: fit,
              placeholder: (_, _) =>
                  _Placeholder(width: width, height: height, icon: icon),
              errorWidget: (_, _, _) => _Placeholder(
                width: width,
                height: height,
                icon: Icons.broken_image_outlined,
              ),
            ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({this.width, this.height, required this.icon});

  final double? width;
  final double? height;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    color: Theme.of(context).colorScheme.surfaceContainerHighest,
    alignment: Alignment.center,
    child: Icon(icon, color: Theme.of(context).colorScheme.outline),
  );
}
