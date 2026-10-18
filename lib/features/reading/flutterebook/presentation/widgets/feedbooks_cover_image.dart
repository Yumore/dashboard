import 'package:cached_network_image/cached_network_image.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/widgets/feedbooks_loading_widget.dart';
import 'package:flutter/material.dart';

/// 书封。源工程直接用 `CachedNetworkImage`，占位是 `LoadingWidget(isImage: true)`，
/// 失败回退 `assets/images/place.png`。
///
/// 宿主 `assets/` 下没有 `images/` 目录，那张占位图不存在，所以失败态换成
/// 同尺寸的图标占位（见交付说明）。
class FeedbooksCoverImage extends StatelessWidget {
  const FeedbooksCoverImage({
    super.key,
    required this.url,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
  });

  final String url;
  final double? height;
  final double? width;
  final BoxFit fit;

  /// 测试注入点：给定时用它替代 [CachedNetworkImage]，widget 测试因此
  /// 完全不碰网络与磁盘缓存。
  @visibleForTesting
  static Widget Function(BuildContext context, String url)? debugBuilder;

  @override
  Widget build(BuildContext context) {
    final Widget Function(BuildContext, String)? overridden = debugBuilder;
    if (overridden != null) {
      return overridden(context, url);
    }
    return CachedNetworkImage(
      imageUrl: url,
      placeholder: (context, url) => const FeedbooksLoadingWidget(isImage: true),
      errorWidget: (context, url, error) => SizedBox(
        height: height,
        width: width,
        child: Icon(
          Icons.menu_book,
          size: height == null ? 24.0 : height! * 0.4,
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
      fit: fit,
      height: height,
      width: width,
    );
  }
}
