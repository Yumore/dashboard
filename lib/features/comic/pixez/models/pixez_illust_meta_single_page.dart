import '../pixez_json.dart';

/// `meta_single_page.original_image_url` (absent on multi-page works).
class PixezIllustMetaSinglePage {
  const PixezIllustMetaSinglePage({this.originalImageUrl});

  final String? originalImageUrl;

  factory PixezIllustMetaSinglePage.fromJson(Map<String, dynamic> json) {
    return PixezIllustMetaSinglePage(
      originalImageUrl: pixezStringOrNull(json['original_image_url']),
    );
  }
}
