import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ZhihuRemoteImage extends StatelessWidget {
  const ZhihuRemoteImage({
    required this.url,
    required this.width,
    required this.height,
    super.key,
  });

  final String url;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) => CachedNetworkImage(
    imageUrl: url,
    width: width,
    height: height,
    fit: BoxFit.cover,
    placeholder: (_, _) => SizedBox(
      width: width,
      height: height,
      child: const ColoredBox(color: Colors.grey),
    ),
    errorWidget: (_, _, _) => SizedBox(
      width: width,
      height: height,
      child: const Icon(Icons.broken_image_outlined),
    ),
  );
}
