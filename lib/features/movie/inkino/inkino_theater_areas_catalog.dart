import 'package:dashboard/features/movie/inkino/inkino_theater_area.dart';
import 'package:dashboard/features/movie/inkino/inkino_theater_parser.dart';

/// The `TheatreAreas` response the source shipped as a bundled asset.
///
/// inKino never fetched theatre areas at runtime; it parsed this exact snapshot
/// (`core/lib/src/preloaded_data.dart`). Keeping it as the offline fallback
/// means the showtime flow still has an area to request against when the live
/// fetch is unavailable, without copying an asset into the host.
class InKinoTheaterAreasCatalog {
  const InKinoTheaterAreasCatalog._();

  static const String assetXml = '''<?xml version="1.0"?>
<TheatreAreas xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <TheatreArea><ID>1029</ID><Name>Valitse alue/teatteri</Name></TheatreArea>
    <TheatreArea><ID>1014</ID><Name>Pääkaupunkiseutu</Name></TheatreArea>
    <TheatreArea><ID>1012</ID><Name>Espoo</Name></TheatreArea>
    <TheatreArea><ID>1039</ID><Name>Espoo: OMENA</Name></TheatreArea>
    <TheatreArea><ID>1038</ID><Name>Espoo: SELLO</Name></TheatreArea>
    <TheatreArea><ID>1002</ID><Name>Helsinki</Name></TheatreArea>
    <TheatreArea><ID>1045</ID><Name>Helsinki: ITIS</Name></TheatreArea>
    <TheatreArea><ID>1031</ID><Name>Helsinki: KINOPALATSI</Name></TheatreArea>
    <TheatreArea><ID>1032</ID><Name>Helsinki: MAXIM</Name></TheatreArea>
    <TheatreArea><ID>1033</ID><Name>Helsinki: TENNISPALATSI</Name></TheatreArea>
    <TheatreArea><ID>1013</ID><Name>Vantaa: FLAMINGO</Name></TheatreArea>
    <TheatreArea><ID>1015</ID><Name>Jyväskylä: FANTASIA</Name></TheatreArea>
    <TheatreArea><ID>1016</ID><Name>Kuopio: SCALA</Name></TheatreArea>
    <TheatreArea><ID>1017</ID><Name>Lahti: KUVAPALATSI</Name></TheatreArea>
    <TheatreArea><ID>1041</ID><Name>Lappeenranta: STRAND</Name></TheatreArea>
    <TheatreArea><ID>1018</ID><Name>Oulu: PLAZA</Name></TheatreArea>
    <TheatreArea><ID>1019</ID><Name>Pori: PROMENADI</Name></TheatreArea>
    <TheatreArea><ID>1021</ID><Name>Tampere</Name></TheatreArea>
    <TheatreArea><ID>1034</ID><Name>Tampere: CINE ATLAS</Name></TheatreArea>
    <TheatreArea><ID>1035</ID><Name>Tampere: PLEVNA</Name></TheatreArea>
    <TheatreArea><ID>1022</ID><Name>Turku: KINOPALATSI</Name></TheatreArea>
</TheatreAreas>''';

  static List<InKinoTheaterArea>? _cached;

  /// Parses [assetXml] on first use. Never throws: a broken snapshot yields an
  /// empty list so the page can fall back to "all theaters".
  static List<InKinoTheaterArea> all() {
    final cached = _cached;
    if (cached != null) return cached;
    final parsed = InKinoTheaterParser.parse(assetXml);
    _cached = parsed;
    return parsed;
  }
}
