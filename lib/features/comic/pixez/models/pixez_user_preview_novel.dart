import '../pixez_json.dart';
import 'pixez_image_urls.dart';

/// The novel teaser embedded in a `/v1/search/user` result.
class PixezUserPreviewNovel {
  const PixezUserPreviewNovel({
    required this.id,
    required this.title,
    required this.caption,
    required this.imageUrls,
  });

  final int id;
  final String title;
  final String? caption;
  final PixezImageUrls imageUrls;

  factory PixezUserPreviewNovel.fromJson(Map<String, dynamic> json) {
    return PixezUserPreviewNovel(
      id: pixezInt(json['id']),
      title: pixezString(json['title']),
      caption: pixezStringOrNull(json['caption']),
      imageUrls: PixezImageUrls.fromJson(pixezMap(json['image_urls'])),
    );
  }
}
