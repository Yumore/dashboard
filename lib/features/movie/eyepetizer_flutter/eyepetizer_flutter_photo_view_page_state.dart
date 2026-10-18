import 'package:cached_network_image/cached_network_image.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_photo_view_page.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

/// State for [EyepetizerFlutterPhotoViewPage].
class EyepetizerFlutterPhotoViewPageState
    extends State<EyepetizerFlutterPhotoViewPage> {
  @override
  Widget build(BuildContext context) {
    final url = widget.url;
    if (url == null || url.isEmpty) return Container();
    return PhotoView(imageProvider: CachedNetworkImageProvider(url));
  }
}
