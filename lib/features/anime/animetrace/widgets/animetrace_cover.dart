import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dashboard/app/platform/app_local_image.dart';
import 'package:dashboard/app/platform/app_platform.dart';
import 'package:flutter/material.dart';

/// Cover thumbnail for a collected anime.
///
/// Handles both cases the source app supports: an `http(s)` cover URL fetched
/// (and cached) from the network, and a cover already saved inside the user's
/// cover folder, whose absolute [localRoot] is resolved by the caller so this
/// widget stays synchronous and does no I/O in `build`.
class AnimeTraceCover extends StatelessWidget {
  const AnimeTraceCover({
    super.key,
    required this.url,
    this.localRoot = '',
    this.width = 56,
    this.height = 76,
  });

  final String url;
  final String localRoot;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: _buildImage(context),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    if (url.isEmpty) return _placeholder(context, Icons.image_not_supported);
    if (url.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: url,
        width: width,
        height: height,
        fit: BoxFit.cover,
        placeholder: (_, _) => _placeholder(context, Icons.image_outlined),
        errorWidget: (_, _, _) =>
            _placeholder(context, Icons.broken_image_outlined),
      );
    }
    if (localRoot.isEmpty) {
      return _placeholder(context, Icons.folder_off_outlined);
    }
    if (!AppPlatform.supportsFileSystem) {
      return _placeholder(context, Icons.folder_off_outlined);
    }
    final file = File('$localRoot${Platform.pathSeparator}$url');
    if (!file.existsSync()) {
      return _placeholder(context, Icons.broken_image_outlined);
    }
    return Image(
      image: AppLocalImage.provider(file.path),
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) =>
          _placeholder(context, Icons.broken_image_outlined),
    );
  }

  Widget _placeholder(BuildContext context, IconData icon) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(icon, size: width * 0.5),
    );
  }
}
