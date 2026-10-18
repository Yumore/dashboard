import 'package:dashboard/features/movie/inkino/inkino_gallery_image.dart';
import 'package:dashboard/features/movie/inkino/inkino_image_rewriter.dart';
import 'package:dashboard/features/movie/inkino/inkino_xml.dart';

/// Maps the optional `<Gallery>` block of an event.
class InKinoGalleryParser {
  const InKinoGalleryParser._();

  static List<InKinoGalleryImage> parseRoots(List<InKinoXmlNode> roots) {
    if (roots.isEmpty) return const [];
    return InKinoXml.children(roots.first, 'GalleryImage')
        .map(
          (node) => InKinoGalleryImage(
            location:
                InKinoImageRewriter.rewrite(
                  InKinoXml.childText(node, 'Location'),
                ) ??
                '',
            thumbnailLocation: InKinoImageRewriter.rewrite(
              InKinoXml.childText(node, 'ThumbnailLocation'),
            ),
          ),
        )
        .toList();
  }

  /// Trailer markup: `<EventVideo><Location>abc123</Location></EventVideo>`
  /// becomes the full YouTube watch URL.
  static List<String> parseTrailerIds(List<InKinoXmlNode> videoNodes) =>
      videoNodes
          .map((node) => InKinoXml.childText(node, 'Location') ?? '')
          .where((location) => location.isNotEmpty)
          .map((location) => 'https://youtube.com/watch?v=$location')
          .toList();
}
