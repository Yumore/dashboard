import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_content_data.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_detail_repository.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_picture_detail_page_state.dart';
import 'package:flutter/material.dart';

/// `lib/pages/detail/picture_detail_page.dart` → `PictureDetailPage`.
///
/// The photo gallery: a full-screen swipeable set of [PhotoView]s over a black
/// background, an `n/total` indicator, and the picture's info sheet.
///
/// Two structural deviations from the source, both forced by the host's
/// dependencies: the argument is a typed `ContentData` instead of
/// `ModalRoute.settings.arguments`, and the gallery is a [PageView] instead of
/// `flutter_swiper` (not a host package). The swiper was created with
/// `loop: false` and no viewport fraction, which is exactly a default
/// [PageView].
class EyepetizerFlutterPictureDetailPage extends StatefulWidget {
  const EyepetizerFlutterPictureDetailPage({
    super.key,
    required this.contentData,
    this.repository,
  });

  final EyepetizerFlutterContentData contentData;
  final EyepetizerFlutterDetailRepository? repository;

  @override
  State<EyepetizerFlutterPictureDetailPage> createState() =>
      EyepetizerFlutterPictureDetailPageState();
}
