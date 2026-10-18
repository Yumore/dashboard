import 'package:dashboard/features/movie/inkino/inkino_image_rewriter.dart';
import 'package:dashboard/features/movie/inkino/inkino_images_parser.dart';
import 'package:dashboard/features/movie/inkino/inkino_name_cleaner.dart';
import 'package:dashboard/features/movie/inkino/inkino_show.dart';
import 'package:dashboard/features/movie/inkino/inkino_xml.dart';

/// Maps the `<Show>` elements of a Finnkino `<Schedule>` response.
class InKinoShowParser {
  const InKinoShowParser._();

  static List<InKinoShow> parse(String xmlSource) {
    final document = InKinoXml.parse(xmlSource, rootTag: 'Schedule');
    return InKinoXml.findAll(document, 'Show').map(parseElement).toList();
  }

  static InKinoShow parseElement(InKinoXmlNode node) {
    final title = InKinoXml.childText(node, 'Title') ?? '';
    final originalTitle = InKinoXml.childText(node, 'OriginalTitle') ?? '';

    return InKinoShow(
      id: InKinoXml.childText(node, 'ID') ?? '',
      eventId: InKinoXml.childText(node, 'EventID') ?? '',
      title: InKinoNameCleaner.cleanup(title),
      originalTitle: InKinoNameCleaner.cleanup(originalTitle),
      url: InKinoXml.childText(node, 'ShowURL') ?? '',
      start: _parseDateTime(InKinoXml.childText(node, 'dttmShowStart')),
      end: _parseDateTime(InKinoXml.childText(node, 'dttmShowEnd')),
      ageRating: InKinoXml.childText(node, 'Rating'),
      ageRatingUrl: InKinoImageRewriter.rewrite(
        InKinoXml.childText(node, 'RatingImageUrl'),
      ),
      productionYear: InKinoXml.childText(node, 'ProductionYear'),
      lengthInMinutes: InKinoXml.childText(node, 'LengthInMinutes'),
      genres: InKinoXml.childText(node, 'Genres'),
      presentationMethod: InKinoXml.childText(node, 'PresentationMethod'),
      theater: InKinoXml.childText(node, 'Theatre'),
      theaterAuditorium: InKinoXml.childText(node, 'TheatreAuditorium'),
      theaterAndAuditorium: InKinoXml.childText(node, 'TheatreAndAuditorium'),
      images: InKinoImagesParser.parse(node),
    );
  }

  /// `dttmShowStart` / `dttmShowEnd` are local cinema time without an offset,
  /// so `DateTime.parse` produces exactly the wall-clock time the schedule
  /// advertises. A missing value becomes [DateTime.fromMillisecondsSinceEpoch]
  /// zero rather than throwing, so one malformed show cannot kill the whole
  /// schedule.
  static DateTime _parseDateTime(String? raw) =>
      DateTime.tryParse(raw ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
}
