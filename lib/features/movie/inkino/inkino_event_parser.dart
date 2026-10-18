import 'package:dashboard/features/movie/inkino/inkino_content_descriptor_parser.dart';
import 'package:dashboard/features/movie/inkino/inkino_event.dart';
import 'package:dashboard/features/movie/inkino/inkino_gallery_parser.dart';
import 'package:dashboard/features/movie/inkino/inkino_image_rewriter.dart';
import 'package:dashboard/features/movie/inkino/inkino_images_parser.dart';
import 'package:dashboard/features/movie/inkino/inkino_name_cleaner.dart';
import 'package:dashboard/features/movie/inkino/inkino_xml.dart';

/// Maps the `<Event>` elements of Finnkino's `<Events>` response.
class InKinoEventParser {
  const InKinoEventParser._();

  static List<InKinoEvent> parse(String xmlSource) {
    final document = InKinoXml.parse(xmlSource, rootTag: 'Events');
    return InKinoXml.findAll(document, 'Event').map(parseElement).toList();
  }

  static InKinoEvent parseElement(InKinoXmlNode node) {
    final title = InKinoXml.childText(node, 'Title') ?? '';
    final originalTitle = InKinoXml.childText(node, 'OriginalTitle') ?? '';

    return InKinoEvent(
      id: InKinoXml.childText(node, 'ID') ?? '',
      title: InKinoNameCleaner.cleanup(title),
      originalTitle: InKinoNameCleaner.cleanup(originalTitle),
      releaseDate: _parseDate(InKinoXml.childText(node, 'dtLocalRelease')),
      ageRating: InKinoXml.childText(node, 'Rating'),
      ageRatingUrl: InKinoImageRewriter.rewrite(
        InKinoXml.childText(node, 'RatingImageUrl'),
      ),
      genres: InKinoXml.childText(node, 'Genres') ?? '',
      // Finnkino nests these under optional <Directors>/<Cast> wrappers that
      // the source tolerated being absent, so every descendant is collected.
      directors: _parseNames(
        InKinoXml.findAll(node, 'Director'),
        (first, last) => '$first $last',
      ),
      actors: _parseNames(
        InKinoXml.findAll(node, 'Actor'),
        (first, last) => '$first $last',
      ),
      lengthInMinutes: InKinoXml.childText(node, 'LengthInMinutes'),
      shortSynopsis: InKinoXml.childText(node, 'ShortSynopsis'),
      synopsis: InKinoXml.childText(node, 'Synopsis'),
      images: InKinoImagesParser.parse(node),
      contentDescriptors: InKinoContentDescriptorParser.parseRoots(
        InKinoXml.children(node, 'ContentDescriptors'),
      ),
      youtubeTrailers: InKinoGalleryParser.parseTrailerIds(
        InKinoXml.findAll(node, 'EventVideo'),
      ),
      galleryImages: InKinoGalleryParser.parseRoots(
        InKinoXml.children(node, 'Gallery'),
      ),
    );
  }

  /// `<dtLocalRelease>` is absent for events without a release date; the source
  /// swallowed the parse failure, so a null date is the expected outcome.
  static DateTime? _parseDate(String? raw) => DateTime.tryParse(raw ?? '');

  static List<String> _parseNames(
    List<InKinoXmlNode> nodes,
    String Function(String first, String last) join,
  ) {
    return nodes
        .map(
          (node) => join(
            InKinoXml.childText(node, 'FirstName') ?? '',
            InKinoXml.childText(node, 'LastName') ?? '',
          ).trim(),
        )
        .where((name) => name.isNotEmpty)
        .toList();
  }
}
