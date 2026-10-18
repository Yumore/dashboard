import '../pixez_json.dart';
import 'pixez_image_urls.dart';

/// One page of a multi-page illust, including the original-size URL.
class PixezIllustMetaPage {
  const PixezIllustMetaPage({required this.imageUrls});

  final PixezImageUrls imageUrls;

  factory PixezIllustMetaPage.fromJson(Map<String, dynamic> json) {
    return PixezIllustMetaPage(
      imageUrls: PixezImageUrls.fromJson(pixezMap(json['image_urls'])),
    );
  }
}
