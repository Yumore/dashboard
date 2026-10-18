import 'package:dashboard/features/movie/inkino/inkino_event_images.dart';
import 'package:dashboard/features/movie/inkino/inkino_xml.dart';

/// Maps the image block shared by `<Event>` and `<Show>` elements.
class InKinoImagesParser {
  const InKinoImagesParser._();

  static InKinoEventImages parse(InKinoXmlNode parent) {
    // `xml`'s `findElements('Images')` looked at *descendants*, so a nested
    // `<Images>` wrapper is the documented shape; several captured payloads
    // inline the image tags directly on the parent instead. Both are handled.
    final block = InKinoXml.child(parent, 'Images') ?? parent;
    return InKinoEventImages(
      portraitMicro: InKinoXml.childText(block, 'EventMicroImagePortrait'),
      portraitSmall: InKinoXml.childText(block, 'EventSmallImagePortrait'),
      portraitMedium: InKinoXml.childText(block, 'EventMediumImagePortrait'),
      portraitLarge: InKinoXml.childText(block, 'EventLargeImagePortrait'),
      landscapeSmall: InKinoXml.childText(block, 'EventSmallImageLandscape'),
      landscapeLarge: InKinoXml.childText(block, 'EventLargeImageLandscape'),
    );
  }
}
