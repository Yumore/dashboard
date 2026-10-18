import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_photo_view_page_state.dart';
import 'package:flutter/material.dart';

/// `lib/pages/photo_view_page.dart` → `PhotoViewPage`.
///
/// A full-screen single image, opened from a person page's avatar. The source
/// read the URL out of `ModalRoute.settings.arguments`; the port takes it as a
/// typed constructor argument.
class EyepetizerFlutterPhotoViewPage extends StatefulWidget {
  const EyepetizerFlutterPhotoViewPage({super.key, this.url});

  final String? url;

  @override
  State<EyepetizerFlutterPhotoViewPage> createState() =>
      EyepetizerFlutterPhotoViewPageState();
}
