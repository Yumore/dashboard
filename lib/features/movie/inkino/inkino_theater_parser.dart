import 'package:dashboard/features/movie/inkino/inkino_theater_area.dart';
import 'package:dashboard/features/movie/inkino/inkino_xml.dart';

/// Parses the `<TheatreAreas>` block of Finnkino's XML.
class InKinoTheaterParser {
  const InKinoTheaterParser._();

  /// Finnkino returns a fake first row named "Valitse alue/teatteri"
  /// ("choose an area/theatre") whose id is [InKinoTheaterArea.placeholderId].
  static const String chooseTheaterId = InKinoTheaterArea.placeholderId;

  static final RegExp _upperRun = RegExp(r'([A-Z])([A-Z]+)');

  static List<InKinoTheaterArea> parse(String xmlSource) {
    final document = InKinoXml.parse(xmlSource, rootTag: 'TheatreAreas');
    return InKinoXml.findAll(
      document,
      'TheatreArea',
    ).map(parseElement).toList();
  }

  static InKinoTheaterArea parseElement(InKinoXmlNode node) {
    final id = InKinoXml.childText(node, 'ID') ?? '';
    final rawName = InKinoXml.childText(node, 'Name') ?? '';
    return InKinoTheaterArea(id: id, name: normalizeName(id, rawName));
  }

  /// `"Helsinki: TENNISPALATSI"` -> `"Helsinki: Tennispalatsi"`.
  static String normalize(String text) =>
      text.replaceAllMapped(_upperRun, (match) {
        return '${match.group(1)}${match.group(2)!.toLowerCase()}';
      });

  /// The source renamed the fake "choose an area" row; the live endpoint is
  /// localized, so the rename is keyed on the id rather than the Finnish text.
  static String normalizeName(String id, String rawName) =>
      id == chooseTheaterId ? 'All theaters' : normalize(rawName);
}
